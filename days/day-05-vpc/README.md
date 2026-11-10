# Day 5 — VPC and network boundaries

**Objective:** Identify how VPCs, subnets, routes and security groups control traffic; observe the boundaries that separate a public ALB from private application instances.

**Where to run:** Mac/Linux terminal or CloudShell, from repository root. **File:** [`create-network.sh`](create-network.sh), which creates **one VPC only**, not a full network.

1. Confirm identity, Region and existing VPCs:
   ```bash
   export AWS_REGION=eu-west-2
   aws sts get-caller-identity
   aws ec2 describe-vpcs --region "$AWS_REGION" --output table
   aws ec2 describe-subnets --region "$AWS_REGION" --output table
   ```
2. Review the [create-network script](create-network.sh) and preview it without deployment:
   ```bash
   bash days/day-05-vpc/create-network.sh
   ```
   It proposes `10.20.0.0/16` by default. `bash days/day-05-vpc/create-network.sh --create` will create a **billable-context tagged VPC resource** only after interactive `CREATE`; record the returned VPC ID. **Do not also deploy Day 9's independent VPC stack for the same intended network unless that duplication is deliberate.**
3. For public subnet routes and a full sample VPC topology, inspect [Day 9's network template](../day-09-infrastructure-as-code/shop-network.yaml). It creates two public subnets and an internet gateway but **no NAT gateway or private subnets**. Complete the book's private-subnet/ALB architecture separately; the repository does not silently provision it.
4. **Verify:** inspect VPC ID, subnet associations, route tables, security group sources and whether instances can reach required SSM endpoints. Prefer instance inbound HTTP from the ALB security group, not `0.0.0.0/0`.

**Cleanup:** Remove instances, load balancers, gateways, endpoints and VPC attachments before deleting dependent security groups/subnets/VPC. For an otherwise empty VPC created by this script: `aws ec2 delete-vpc --vpc-id vpc-REPLACE_ME --region "$AWS_REGION"` after confirming the ID. See [cleanup](../../docs/cleanup.md). Next: [Day 6](../day-06-application/README.md).
