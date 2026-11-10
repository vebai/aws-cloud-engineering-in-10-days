# Day 9 — Infrastructure as code with CloudFormation

**Objective:** Validate and deploy a small, reviewable VPC template, then inspect stack resources and delete them cleanly. Distinguish template syntax from deployability.

**Where to run:** Mac/Linux or CloudShell, from repository root. **Files:** [`shop-network.yaml`](shop-network.yaml), [`shop-security-group.yaml`](shop-security-group.yaml).

1. Understand scope before deployment: `shop-network.yaml` creates one VPC, two **public** subnets, route table, internet gateway and public route. It does **not** create EC2, SSM endpoints, private subnets, an ALB, NAT gateway or an ASG. `shop-security-group.yaml` creates an instance HTTP security group **only when supplied** an existing VPC ID and ALB security-group ID.
2. **Validate without deploying:**
   ```bash
   export AWS_REGION=eu-west-2
   aws sts get-caller-identity
   ./validation/validate-repo.sh
   aws cloudformation validate-template --template-body file://days/day-09-infrastructure-as-code/shop-network.yaml --region "$AWS_REGION"
   aws cloudformation validate-template --template-body file://days/day-09-infrastructure-as-code/shop-security-group.yaml --region "$AWS_REGION"
   ```
   `cfn-lint` is optional and checks more than generic YAML parsing; see [prerequisites](../../docs/prerequisites.md).
3. After reviewing CIDRs, AZ capacity, ownership and costs, deploy the **network stack**:
   ```bash
   aws cloudformation deploy --template-file days/day-09-infrastructure-as-code/shop-network.yaml --stack-name shop-lab-network --region "$AWS_REGION"
   aws cloudformation describe-stacks --stack-name shop-lab-network --region "$AWS_REGION"
   aws cloudformation describe-stack-resources --stack-name shop-lab-network --region "$AWS_REGION"
   ```
   Record the stack and IDs privately. Deploy the security-group stack only if a suitable ALB SG already exists, with `--parameter-overrides VpcId=vpc-REPLACE_ME AlbSecurityGroupId=sg-REPLACE_ME --stack-name shop-lab-instance-sg`; confirm they are in the same VPC.
4. **Verify:** Stack shows `CREATE_COMPLETE`; output CIDRs and resources match the template. A valid template is not proof that the Shop app is deployed.

**Cleanup:** Remove dependent EC2/ELB/ASG resources and the optional `shop-lab-instance-sg` stack first. Then:
```bash
aws cloudformation delete-stack --stack-name shop-lab-network --region "$AWS_REGION"
aws cloudformation wait stack-delete-complete --stack-name shop-lab-network --region "$AWS_REGION"
```
If deletion fails, inspect stack events instead of blindly retrying or deleting unrelated network resources. See [cleanup](../../docs/cleanup.md). Next: [Day 10](../day-10-operations/README.md).
