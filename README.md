# AWS Cloud Engineering in 10 Days — companion repository

Practical reader assets for **AWS Cloud Engineering in 10 Days**, by Victor Ebai.

**The book is the teaching authority.** It explains why and when to use AWS services, the AWS Console walkthroughs, architecture decisions and interpretation of evidence. This companion repository supplies copyable files, careful operating instructions and validation helpers. Follow the book's day-by-day sequence; repository examples are intentionally limited in scope, and do **not** deploy the complete 10-day architecture automatically.

## Start here — first use

1. Read [prerequisites and installation](docs/prerequisites.md) to install `curl`, Git, Python 3, AWS CLI v2 and optional template linting tools.
2. Download using **Code → Download ZIP** on GitHub or clone:
   ```bash
   git clone https://github.com/vebai/aws-cloud-engineering-in-10-days.git
   cd aws-cloud-engineering-in-10-days
   ```
   If you downloaded the ZIP, extract it and `cd` into the extracted folder instead.
3. Read [execution context, sign-in and setup](docs/setup.md). Confirm the AWS account before making changes.
4. On your Mac, Linux machine or CloudShell, set the chosen Region (examples use London):
   ```bash
   export AWS_REGION=eu-west-2
   aws --version
   aws sts get-caller-identity
   aws configure list
   ```
5. From the **repository root**, run the non-deploying checks:
   ```bash
   ./validation/validate-repo.sh
   python3 -m unittest discover -s tests -v
   ./validation/validate-aws.sh
   ```
   The first two work without AWS credentials; the last makes read-only calls to your selected AWS account.
6. Open the README for your current day. Before creating anything, open [the cleanup plan](docs/cleanup.md) and start your own private resource ledger.
7. At the end of a lab, follow the [cleanup guide](docs/cleanup.md) and **verify** deletion; stopping an instance is not the same as removing charges.

## Day-by-day contents — clickable guides

| Day | Objective | Reader guide |
| --- | --- | --- |
| 1 | Establish account, Region, costs and safe working habits | [Day 1 — Orientation](days/day-01-orientation/README.md) |
| 2 | Identify the AWS principal and use the CLI safely | [Day 2 — IAM and CLI](days/day-02-iam-and-cli/README.md) |
| 3 | Launch and inspect an EC2 instance bootstrapped with Nginx | [Day 3 — EC2](days/day-03-ec2/README.md) |
| 4 | Inspect S3 storage security and data boundaries | [Day 4 — S3](days/day-04-storage/README.md) |
| 5 | Recognise and build controlled VPC networking | [Day 5 — VPC](days/day-05-vpc/README.md) |
| 6 | Prove the Shop application responds on its instance | [Day 6 — Application](days/day-06-application/README.md) |
| 7 | Verify ALB routing and Auto Scaling replacement | [Day 7 — Load balancing](days/day-07-load-balancing/README.md) |
| 8 | Collect application logs and inspect CloudWatch evidence | [Day 8 — Monitoring](days/day-08-monitoring/README.md) |
| 9 | Evolve S3 CloudFormation templates through create, update and change set; optional network examples | [Day 9 — Infrastructure as code](days/day-09-infrastructure-as-code/README.md) |
| 10 | Troubleshoot, verify recovery and remove lab resources | [Day 10 — Operations](days/day-10-operations/README.md) |

## Other reader files

| Resource | Description |
| --- | --- |
| [Prerequisites](docs/prerequisites.md) | macOS, Ubuntu and other Linux installation instructions; `curl`, AWS CLI, Git, Python |
| [Account setup](docs/setup.md) | Where to run commands; authentication; identity/Region checks |
| [Security](docs/security.md) | Least privilege, SSM and restricted network boundaries |
| [Troubleshooting](docs/troubleshooting.md) | Diagnostic workflow and common errors |
| [Full cleanup](docs/cleanup.md) | Dependency-aware, explicit cleanup and post-cleanup checks |
| [Shop application](assets/shop/) | Minimal HTML and Nginx example |
| [Validation scripts](validation/) | Offline checks, read-only AWS preflight and inventory |
| [Validation scope](VALIDATION.md) | What automated checks establish and what they do not |

## Safety, cost and cleanup

AWS resources can incur charges, including running EC2 instances, load balancers, NAT gateways, public IPv4 addresses, EBS volumes, CloudWatch, storage and data transfer. **Never run an AWS create or delete command without reviewing your selected account, Region, resource IDs and dependencies first.** The scripts requiring AWS creation have explicit opt-in, but CloudFormation `deploy` and commands shown in guides are real changes.

- Default examples use `eu-west-2`; the Region is a **choice**, not an automatic restriction on other Regions.
- Use temporary credentials and prefer Session Manager to opening SSH to the internet.
- Never commit account secrets, access keys, private keys, real customer data or your personal AWS resource ledger.
- This repo has **no automated destructive cleanup**. See [docs/cleanup.md](docs/cleanup.md).

**Engineering habit:** ORIENT → INSPECT → ACT → VERIFY → DIAGNOSE → RECOVER → CLEAN UP.

Licensed under the [MIT Licence](LICENSE).

**Day 9 template progression:** [S3 baseline](days/day-09-infrastructure-as-code/templates/01-baseline.yml) · [parameterised S3](days/day-09-infrastructure-as-code/templates/02-parameterised.yml) · [versioning change-set proposal](days/day-09-infrastructure-as-code/templates/03-suspend-versioning.yml).
