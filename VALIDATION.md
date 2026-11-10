# Validation boundaries

`./validation/validate-repo.sh` checks Bash syntax, JSON, important file presence and CloudFormation YAML *parse* syntax where Ruby is installed. `python3 -m unittest discover -s tests -v` tests key assets. These checks make **no AWS calls**. For template-specific validation, install `cfn-lint` and run it on both YAML files; AWS `validate-template` checks server-side semantics but does not deploy resources.

`./validation/validate-aws.sh` verifies identity and Region; `./validation/inventory-resources.sh` reads regional inventory. Both require a configured AWS CLI and appropriate read permissions.

These tests do **not** establish that an ALB, Auto Scaling group, EC2 instance or CloudWatch pipeline has been deployed or run successfully in your AWS account. Complete the appropriate live verification steps during your own lab and clean up afterwards.

## macOS Python environment

A shell prompt showing `(.venv)` does not prove that a working Python interpreter exists. If a previous environment was deleted, run `deactivate` (if available), `hash -r`, and then `/usr/bin/python3 -m unittest discover -s tests -v`, or use the path from `command -v python3` after deactivation. A virtual environment is not required for the standard-library tests.

README verification now confirms Day 1–10 guides and local Markdown links. Documentation examples requiring AWS privileges are not live-tested by the offline checker.
