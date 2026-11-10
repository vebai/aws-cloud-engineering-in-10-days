# Validation boundaries

`./validation/validate-repo.sh` checks Bash syntax, JSON, important file presence and CloudFormation YAML *parse* syntax where Ruby is installed. `python3 -m unittest discover -s tests -v` tests key assets. These checks make **no AWS calls**. For template-specific validation, install `cfn-lint` and run it on both YAML files; AWS `validate-template` checks server-side semantics but does not deploy resources.

`./validation/validate-aws.sh` verifies identity and Region; `./validation/inventory-resources.sh` reads regional inventory. Both require a configured AWS CLI and appropriate read permissions.

These tests do **not** establish that an ALB, Auto Scaling group, EC2 instance or CloudWatch pipeline has been deployed or run successfully in your AWS account. Complete the appropriate live verification steps during your own lab and clean up afterwards.

## macOS Python environment

A shell prompt showing `(.venv)` does not prove that a working Python interpreter exists. If a previous environment was deleted, run `deactivate` (if available), `hash -r`, and then `/usr/bin/python3 -m unittest discover -s tests -v`, or use the path from `command -v python3` after deactivation. A virtual environment is not required for the standard-library tests.

README verification now confirms Day 1–10 guides and local Markdown links. Documentation examples requiring AWS privileges are not live-tested by the offline checker.

## Live validation evidence — 10 November 2026

In one AWS test account in `eu-west-2`, the Day 9 network CloudFormation template deployed with `CREATE_COMPLETE`, then its stack was deleted and confirmed absent. On a disposable Amazon Linux 2023 instance, EC2 status and Session Manager registration passed; Nginx served the Shop HTML and `/healthz` HTTP 200. Stopping Nginx produced a refused connection, and restarting restored HTTP 200. The CloudWatch Agent installed and its configuration validated, but log submission initially failed with IAM `AccessDeniedException` for `logs:PutLogEvents` and `logs:DescribeLogGroups`. After a temporary IAM policy correction, CloudWatch access events appeared for the test instance and both dedicated log groups reported three-day retention.

This is **historical evidence for a particular test account**, not a claim that a fresh reader account or every day of the complete architecture was validated. The full Day 7 ALB/ASG architecture and the standalone Day 9 security-group stack were not re-deployed in this pass. EC2/CloudWatch cleanup should be verified separately from application success. The bootstrap currently produces a minimal Shop HTML page; `assets/shop/index.html` provides a richer example and must not be mistaken for the exact bootstrap output.


## Live AWS validation evidence (10 November 2026)

Observed in the author's test account, Region `eu-west-2`: the optional VPC network stack created successfully and was deleted; one disposable EC2 instance registered with Session Manager; the Shop service and `/healthz` returned HTTP 200; stopping Nginx produced connection refusal and restarting restored HTTP 200; the CloudWatch Agent passed both configuration phases; CloudWatch Logs published HTTP 200 access events after IAM permissions were corrected; both log groups had three-day retention. The test instance, security group, temporary IAM policy and log groups were subsequently deleted, and the final read-only checks found no available EBS volumes or allocated Elastic IP addresses in that Region.

**Scope and caveat:** This evidence predates the final Shop catalogue and Day 9 S3 template alignment. It does **not** demonstrate a fresh live deployment of the final revised user-data script or the S3 template progression. Day 7 ALB/Auto Scaling was previously tested with the book's Console workflow, not rerun against these repository assets. Static checks cannot substitute for live service behaviour. No account identifiers or private run outputs are retained here.
