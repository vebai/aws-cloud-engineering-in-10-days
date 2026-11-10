# Prerequisite tools — installation and verification

**Where to run:** Your local macOS/Linux terminal. AWS CloudShell already includes several tools; check versions before installing. Installation commands do not create AWS resources. Follow your organisation's approved installation policy. Avoid `curl ... | bash` installer pipelines you have not reviewed.

## 1. macOS (Homebrew)

First check what is installed:
```bash
command -v curl git python3 aws || true
curl --version
git --version
python3 --version
aws --version
```

On a Mac with Homebrew installed:
```bash
brew update
brew install curl git python awscli unzip
```

macOS includes `/usr/bin/curl`, which is usually sufficient; Homebrew may install another `curl` later on your `PATH`. If `brew` is missing, see the installation steps at https://brew.sh/ and read them before execution, or install Git, Python and AWS CLI from their official sites. The repository uses standard Bash features; the system Bash 3.2 is sufficient.

Verify binaries actually used:
```bash
command -v curl git python3 aws
curl --version
git --version
python3 --version
aws --version
```

If a previous virtual environment is broken (`(.venv)` and a missing Python executable), run `deactivate 2>/dev/null || true`, then `hash -r`. Do not create a virtual environment for these built-in `unittest` tests.

## 2. Ubuntu / Debian

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl unzip git python3
curl --version
git --version
python3 --version
```

Install **AWS CLI v2** using AWS's official package (choose the correct CPU architecture):
```bash
uname -m
```

For `x86_64`:
```bash
curl -fL 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o /tmp/awscliv2.zip
```
For `aarch64` / `arm64`:
```bash
curl -fL 'https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip' -o /tmp/awscliv2.zip
```

Then, for **either** architecture:
```bash
cd /tmp
unzip -q -o awscliv2.zip -d awscli-install
sudo ./awscli-install/aws/install --update
aws --version
```

If you have an AWS CLI installed through another package manager, do not mix upgrades: remove conflicting installations or use the supported update mechanism for that installation. Official installation details: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html . For high-assurance environments, verify the AWS installer signature using AWS's documented PGP procedure before installing.

## 3. Fedora / RHEL-family Linux

```bash
sudo dnf install -y ca-certificates curl unzip git python3
```

Install AWS CLI v2 using the same AWS Linux ZIP procedure above, choosing the architecture returned by `uname -m`.

## 4. Optional: CloudFormation linting

The repository validates YAML syntax with Ruby where present, but that does **not** prove CloudFormation semantics. Optional `cfn-lint` can be installed in a separate Python environment with `pipx` (https://github.com/aws-cloudformation/cfn-lint):
```bash
cfn-lint --version
cfn-lint days/day-09-infrastructure-as-code/*.yaml
```

If `cfn-lint` is absent, follow the project's supported installation instructions; do not assume it is installed globally. You can also use AWS CLI `cloudformation validate-template` after authentication (a non-deploying API call).

## 5. Confirm your terminal is ready

Return to your repository root:
```bash
pwd
./validation/validate-repo.sh
python3 -m unittest discover -s tests -v
```

Next: [AWS identity and Region setup](setup.md). `curl` tests **HTTP endpoints**; it is not used for AWS authentication.
