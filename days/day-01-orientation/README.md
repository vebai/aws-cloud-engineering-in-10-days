# Day 1 — Orient yourself in AWS

**Objective:** Identify the AWS account and Region you will use, understand the cost boundary and establish a safe read-only baseline before deploying any resources.

**Where to run:** macOS/Linux terminal or AWS CloudShell, from the repository root. **Files:** [prerequisites](../../docs/prerequisites.md), [setup](../../docs/setup.md), [cleanup](../../docs/cleanup.md).

1. Install and verify `curl`, Git, Python and AWS CLI v2 using [prerequisites](../../docs/prerequisites.md).
2. Sign in using [setup instructions](../../docs/setup.md) and select `eu-west-2` or your intentionally chosen Region.
3. Run:
   ```bash
   export AWS_REGION=eu-west-2
   aws sts get-caller-identity
   aws configure list
   ./validation/validate-repo.sh
   ./validation/validate-aws.sh
   ./validation/inventory-resources.sh
   ```
4. **Verify:** record the correct account ID privately and check the Region; recognise any existing resources as potentially unrelated to this lab.
5. Create a private resource ledger and familiarise yourself with the AWS Billing console and [cleanup order](../../docs/cleanup.md).

**Cleanup:** No lab resources are created by the commands above. Do not delete pre-existing inventory items. Next: [Day 2](../day-02-iam-and-cli/README.md).
