# Day 2 — IAM and the AWS CLI

**Objective:** Confirm *which principal* executes each API call and work with short-lived credentials without granting unnecessary permissions.

**Where to run:** Mac/Linux terminal or CloudShell, **from the repository root**. **Files:** [`create-lab-user.sh`](create-lab-user.sh) (optional, guarded), [setup](../../docs/setup.md).

1. Follow [account setup](../../docs/setup.md); prefer IAM Identity Center or another approved role-based sign-in.
2. Inspect the identity and CLI settings:
   ```bash
   export AWS_REGION=eu-west-2
   aws --version
   aws sts get-caller-identity
   aws configure list
   ./validation/validate-aws.sh
   ```
3. **Optional only if your book lab requires an IAM user:** inspect [`create-lab-user.sh`](create-lab-user.sh), then run `bash days/day-02-iam-and-cli/create-lab-user.sh` to see the dry-run message. `--create` makes a real **global IAM user**, with no policies or keys attached; do not run it unless expressly needed and authorised.
4. **Verify:** compare the returned ARN and account with your intended account. Avoid printing, sharing or committing credentials.

**Cleanup:** If you intentionally created the optional user and confirmed no policies, groups, keys, passwords or other dependencies were added, delete it by exact name with `aws iam delete-user --user-name cloud-engineering-lab-reader`. Use your actual `LAB_USER_NAME` if overridden. IAM is account-global; never delete unrelated users. See [full cleanup](../../docs/cleanup.md). Next: [Day 3](../day-03-ec2/README.md).
