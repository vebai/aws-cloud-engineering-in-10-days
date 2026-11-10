# Account setup, authentication and execution context

## 1. Decide where each command runs

| Terminal | Run here | Credentials |
| --- | --- | --- |
| Local macOS / Linux | `git`, validation, AWS CLI, CloudFormation, local `curl` to public ALB | Your configured AWS profile or temporary identity |
| AWS CloudShell | AWS CLI control-plane commands and repository files if cloned there | CloudShell session's AWS identity |
| EC2 Session Manager shell | `curl localhost`, `sudo systemctl`, `sudo tail`, `sudo ss`, CloudWatch Agent installation | Instance role; often signed in as `ssm-user` |

**Do not paste local terminal commands into EC2 blindly.** A Session Manager shell normally does not have your laptop files, and an instance role has different permissions from your administrative AWS identity.

## 2. Authenticate locally or in CloudShell

Recommended for organisational accounts: AWS IAM Identity Center (SSO):
```bash
aws configure sso --profile cloud-lab
aws sso login --profile cloud-lab
export AWS_PROFILE=cloud-lab
```

Use an approved IAM role or other short-lived credential mechanism if Identity Center is unavailable. Some recent AWS CLI versions support `aws login` with additional permissions; do not presume it is enabled for your account. **Do not create root or long-lived IAM access keys for this course.**

## 3. Confirm account, Region and CLI

```bash
export AWS_REGION=eu-west-2
aws --version
aws sts get-caller-identity
aws configure list
./validation/validate-aws.sh
```

Read the returned **Account** and **Arn** before creating resources. Run these commands from repository root. If you use a named profile, set `AWS_PROFILE` before any action. `aws configure list` may contain source metadata; never share secrets.

## 4. Cost boundary and resource ledger

Choose disposable names; record resource type, actual ID, AWS account, Region, creator, dependency and cleanup result in a **private** ledger. Example columns: `resource | id | region | created | depends_on | removed | verified`. Review the Billing console before starting; enable budgets/alerts if permitted. Budgets are not spending caps.

## 5. Recommended session sequence

```bash
./validation/validate-repo.sh
python3 -m unittest discover -s tests -v
./validation/validate-aws.sh
./validation/inventory-resources.sh
```

The inventory is **read-only** and not exhaustive. Before leaving the lab, open [cleanup](cleanup.md). AWS account and Region may differ between commands when using profiles, so repeat `aws sts get-caller-identity` whenever you switch sessions.
