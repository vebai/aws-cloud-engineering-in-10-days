# Complete AWS lab cleanup — explicit, dependency-aware procedure

**Goal:** Remove **only** AWS resources you created for this 10-day lab, and verify no billable lab dependencies remain. No script in this repository automatically deletes resources. These instructions are intentionally manual because accounts and names differ and unintended deletion is irreversible.

## A. Establish the deletion boundary FIRST (local Mac/Linux or CloudShell)

1. Confirm the exact account and selected Region:
   ```bash
   export AWS_REGION=eu-west-2
   aws sts get-caller-identity
   aws configure list
   ./validation/inventory-resources.sh
   ```
2. Open your **private ledger** (do not commit to Git). For each lab-created resource, record `type / name / ID / Region / creation method / depends-on / deletion evidence`. Use EC2/ASG/ELB, VPC, CloudFormation, S3, CloudWatch and IAM consoles to cross-check. If you created resources in other Regions, repeat inventory for each Region. **IAM is global**, while S3 bucket names are global but buckets have a home Region.
3. Identify resources that are **not** lab-created (default VPC, production apps, shared roles, company resources). Never delete them. Preserve logs/evidence you need before deleting them. Stop the lab before cleaning it up.

## B. Remove application infrastructure, starting with owners

**These are templates, not a copy/paste batch. Replace placeholders after checking IDs and ownership.** Some commands require privileges or fail if a dependency still exists.

### 1. CloudFormation-managed resources

If CloudFormation created an ALB/ASG/EC2 or VPC, prefer deleting the owning stack rather than manually deleting stack-managed children. Inspect first:
```bash
aws cloudformation list-stacks --region "$AWS_REGION" --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE DELETE_FAILED --output table
aws cloudformation describe-stack-resources --stack-name REPLACE_WITH_LAB_STACK --region "$AWS_REGION"
```

Delete **dependent** application/security-group stacks **before** the underlying VPC/network stack:
```bash
aws cloudformation delete-stack --stack-name REPLACE_WITH_LAB_APP_STACK --region "$AWS_REGION"
aws cloudformation wait stack-delete-complete --stack-name REPLACE_WITH_LAB_APP_STACK --region "$AWS_REGION"
```

Do not use the sample stack name unless it actually belongs to you. A failed wait needs `describe-stack-events` diagnosis; never assume deletion succeeded.

### 2. Auto Scaling groups (manual lab infrastructure only)

Inspect group and attached instances first:
```bash
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names REPLACE_WITH_LAB_ASG --region "$AWS_REGION"
```

After verifying this is a disposable lab group, remove it **before** separately terminating instances (otherwise it may recreate them):
```bash
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name REPLACE_WITH_LAB_ASG --force-delete --region "$AWS_REGION"
```

`--force-delete` can terminate group instances and disrupt services: use only for a group that is exclusively yours. Check that the group is absent and instances are terminating; wait for removal and inspect remaining EC2 instances. If a CloudFormation stack owns the group, delete the stack instead.

### 3. ALB and target groups (manual lab infrastructure only)

Inspect exact ARN and group dependencies:
```bash
aws elbv2 describe-load-balancers --region "$AWS_REGION" --output table
aws elbv2 describe-target-groups --region "$AWS_REGION" --output table
```

Once you know the **lab-only** load balancer ARN:
```bash
aws elbv2 delete-load-balancer --load-balancer-arn REPLACE_WITH_LAB_ALB_ARN --region "$AWS_REGION"
aws elbv2 wait load-balancers-deleted --load-balancer-arns REPLACE_WITH_LAB_ALB_ARN --region "$AWS_REGION"
aws elbv2 delete-target-group --target-group-arn REPLACE_WITH_LAB_TARGET_GROUP_ARN --region "$AWS_REGION"
```

A target group can only be deleted after listeners/rules no longer use it and its load balancer is removed. Check for deletion protection first. Do **not** remove an unrelated ALB. A Network Load Balancer uses the same API family.

### 4. EC2 instances, EBS and launch templates

Check instance ownership and ASG membership before termination:
```bash
aws ec2 describe-instances --region "$AWS_REGION" --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name,Tags:Tags}' --output table
```

For a standalone **lab-only** instance:
```bash
aws ec2 terminate-instances --instance-ids i-REPLACE_WITH_LAB_INSTANCE --region "$AWS_REGION"
aws ec2 wait instance-terminated --instance-ids i-REPLACE_WITH_LAB_INSTANCE --region "$AWS_REGION"
```

Inspect any surviving EBS volumes, snapshots and AMIs you created; some volumes are **not** deleted on termination:
```bash
aws ec2 describe-volumes --region "$AWS_REGION" --query 'Volumes[].{ID:VolumeId,State:State,Size:Size,Attachments:Attachments}' --output table
aws ec2 describe-snapshots --owner-ids self --region "$AWS_REGION" --query 'Snapshots[].{ID:SnapshotId,Volume:VolumeId}' --output table
aws ec2 describe-launch-templates --region "$AWS_REGION" --output table
```

Only after confirming a resource is lab-owned and unused, use `aws ec2 delete-volume --volume-id vol-...`, `aws ec2 delete-snapshot --snapshot-id snap-...`, or `aws ec2 delete-launch-template --launch-template-id lt-...` with the actual ID. Do not delete in-use or shared resources.

## C. Remove observability and storage

### 5. CloudWatch log groups and alarms

Confirm the names first:
```bash
aws logs describe-log-groups --log-group-name-prefix /shop-dev/nginx/ --region "$AWS_REGION" --output table
aws cloudwatch describe-alarms --region "$AWS_REGION" --output table
```

If these **two** groups are exclusively from the lab and evidence is no longer needed:
```bash
aws logs delete-log-group --log-group-name /shop-dev/nginx/access --region "$AWS_REGION"
aws logs delete-log-group --log-group-name /shop-dev/nginx/error --region "$AWS_REGION"
```

For any lab alarm, delete only its exact verified name with `aws cloudwatch delete-alarms --alarm-names REPLACE_WITH_LAB_ALARM --region "$AWS_REGION"`. Inspect metric filters, dashboards and retained metrics if your lab created them; deleting a log group cannot undo already incurred charges.

### 6. S3 buckets and all object versions

List the bucket and determine if it contains important objects or versions:
```bash
aws s3 ls
aws s3api get-bucket-versioning --bucket REPLACE_WITH_LAB_BUCKET
aws s3api list-object-versions --bucket REPLACE_WITH_LAB_BUCKET
```

For a **dedicated unversioned, disposable** bucket only (irreversible):
```bash
aws s3 rb s3://REPLACE_WITH_LAB_BUCKET --force
```

For versioned buckets, `aws s3 rb --force` alone is insufficient: versions and delete markers need explicit removal, often with additional pagination. Object Lock, retention or MFA Delete may prevent removal. Follow the S3 Console **Empty bucket** workflow after checking bucket identity and delete-marker/version behaviour, and then **Delete bucket**. Never force-remove unrelated or shared data. Check lifecycle configurations, replication destinations and access logs if configured.

## D. Remove networking and IAM after dependants are gone

### 7. NAT gateways, endpoints and Elastic IPs (if created)

NAT gateways can generate charges while provisioned; inspect first:
```bash
aws ec2 describe-nat-gateways --region "$AWS_REGION" --output table
aws ec2 describe-vpc-endpoints --region "$AWS_REGION" --output table
aws ec2 describe-addresses --region "$AWS_REGION" --output table
```

For **identified lab-only** resources:
```bash
aws ec2 delete-nat-gateway --nat-gateway-id nat-REPLACE_ME --region "$AWS_REGION"
aws ec2 delete-vpc-endpoints --vpc-endpoint-ids vpce-REPLACE_ME --region "$AWS_REGION"
```

Wait for NAT gateway deletion before releasing its unassociated Elastic IP with `aws ec2 release-address --allocation-id eipalloc-REPLACE_ME --region "$AWS_REGION"`. Confirm the address is not used elsewhere. Check public IPv4 allocations not associated with an EC2 instance.

### 8. Security groups, subnets, routes, gateways and VPC

If Day 9 CloudFormation created the network, **delete the CloudFormation network stack instead**:
```bash
aws cloudformation delete-stack --stack-name shop-lab-network --region "$AWS_REGION"
aws cloudformation wait stack-delete-complete --stack-name shop-lab-network --region "$AWS_REGION"
```

If you created a standalone Day 5 VPC using `create-network.sh` and it has **no** dependent nondefault subnets, ENIs, gateways, endpoints, security groups or routes:
```bash
aws ec2 delete-vpc --vpc-id vpc-REPLACE_ME --region "$AWS_REGION"
```

For manually built networks with dependencies, detach/delete dependent interfaces/endpoints/gateways, custom routes/route tables, security groups and subnets **before** deleting the VPC. An internet gateway must be detached from the VPC before deletion. If AWS reports `DependencyViolation`, inspect dependencies rather than blindly retrying. Never delete a shared/default VPC.

### 9. IAM roles and the optional lab user (global scope)

Check the exact optional IAM user and its dependencies:
```bash
aws iam get-user --user-name cloud-engineering-lab-reader
```

If you created this user and it has **no** access keys, console login profile, MFA devices, inline/attached policies or groups, delete it:
```bash
aws iam delete-user --user-name cloud-engineering-lab-reader
```

Otherwise remove owned dependencies carefully first. Instance profiles and roles likewise must be detached from resources before deletion; do not remove shared administrative or SSM roles. IAM changes affect the whole account, not just `eu-west-2`.

## E. Prove cleanup; inspect billing

1. Re-run the [read-only inventory](../validation/inventory-resources.sh) in **every Region used**, and compare it against your **private ledger**. Check S3, IAM, EC2, target groups, EBS, NAT, EIPs, CloudFormation, CloudWatch and any additional lab services.
2. Confirm each stack/ASG/ALB/instance and lab log group is absent. Check AWS Console resource pages for the same account/Region; do not treat an inventory script as comprehensive proof.
3. Use the Billing and Cost Management console (Cost Explorer or Bills) to check charges after cleanup. **Billing data is delayed** and some spend (usage before deletion, snapshots, storage, addresses, data transfer) can continue to appear later.
4. Record any remaining lab resource, why it remains, and a plan to remove it. Stop only when every lab-created resource has an accountable status.

For failed deletions, use [troubleshooting](troubleshooting.md) and examine stack events. There is deliberately **no broad `delete-all` script**.
