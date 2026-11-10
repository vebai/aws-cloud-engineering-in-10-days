# Day 9 — CloudFormation: declare, update, review and clean up

**Objective:** Use one versioned S3 bucket to learn the CloudFormation lifecycle: describe → deploy → verify → change → review → detect drift → remove. Follow Chapter 9 of the book; use the three matching files below.

**Where to run:** Use the AWS Management Console for the guided stack workflow. Use your Mac terminal or CloudShell for AWS CLI verification. Check the Region and AWS account before any creation or deletion.

## Book-aligned S3 workshop

1. Read [01-baseline.yml](templates/01-baseline.yml). In **CloudFormation → Stacks → Create stack**, upload it and name the stack `shop-dev-storage`. This creates a versioned S3 bucket with an AWS-generated physical name.
2. Confirm `CREATE_COMPLETE` and inspect the bucket's versioning status. Keep a private record of the physical bucket name. Do not upload important data.
3. Read [02-parameterised.yml](templates/02-parameterised.yml). Choose **Update stack** on the *same* stack, upload this template, and accept the `EnvironmentName=dev` default. Verify the Environment tag and `BucketName` output.
4. Read [03-suspend-versioning.yml](templates/03-suspend-versioning.yml). Choose **Create change set for current stack**, upload it, name the change set `suspend-versioning`, and inspect the proposed modification before choosing whether to execute. A change set is a proposal, not a guarantee of successful deployment.
5. Follow the book's **Drift** exercise. Check the stack's drift result and any resource differences; capture evidence privately.
6. **Cleanup:** Delete objects, object versions and delete markers from the dedicated stack bucket before deleting its stack; delete the stack and verify it no longer exists. Do not delete your Day 4 bucket or another user's S3 objects. Follow [the full cleanup guide](../../docs/cleanup.md).

**Local checks (Mac or CloudShell, from repository root):**
```bash
export AWS_REGION=eu-west-2
aws sts get-caller-identity
./validation/validate-repo.sh
# If installed:
cfn-lint days/day-09-infrastructure-as-code/templates/*.yml
```
CloudFormation service-side validation (read-only) can also check each of these templates:
```bash
for template in days/day-09-infrastructure-as-code/templates/*.yml; do
  aws cloudformation validate-template --template-body "file://$template" --region "$AWS_REGION"
done
```
Passing syntax or service validation does not prove deployment.

## Optional VPC and security-group examples

These are *additional*, independent reference assets, not the Chapter 9 S3 workshop: [shop-network.yaml](shop-network.yaml) and [shop-security-group.yaml](shop-security-group.yaml). They were used for a separate controlled network validation; they do not deploy the full ALB/Auto Scaling architecture.

The network template creates a VPC, two public subnets, an internet gateway and routes. It does not create private subnets, EC2, NAT, ALB or ASG. The security-group template requires existing compatible VPC and ALB security-group IDs and has not been live-deployed as part of this validation.

To use the optional network example, review ownership, Region and costs, then:
```bash
aws cloudformation deploy --template-file days/day-09-infrastructure-as-code/shop-network.yaml --stack-name shop-lab-network --region "$AWS_REGION"
aws cloudformation describe-stacks --stack-name shop-lab-network --region "$AWS_REGION"
```
When finished and after checking there are no dependent resources:
```bash
aws cloudformation delete-stack --stack-name shop-lab-network --region "$AWS_REGION"
aws cloudformation wait stack-delete-complete --stack-name shop-lab-network --region "$AWS_REGION"
```

**Next:** [Day 10 — Operations](../day-10-operations/README.md).
