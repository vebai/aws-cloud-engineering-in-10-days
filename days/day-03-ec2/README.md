# Day 3 — Launch and inspect EC2

**Objective:** Bootstrap a disposable EC2 instance with Nginx and verify that user data produces a reachable local Shop page and health endpoint.

**Where to run:** Mac/Linux or CloudShell for `aws` commands; EC2 **Session Manager** shell for Linux service checks. **Files:** [`user-data.sh`](user-data.sh), [`create-instance.sh`](create-instance.sh).

1. Confirm your Region and principal (`aws sts get-caller-identity`). Inspect [`user-data.sh`](user-data.sh); it targets Amazon Linux / `dnf` or `yum`-compatible AMIs, not Ubuntu. You need an AMI available in your Region, a subnet, a restrictive security group, and an existing IAM instance profile permitting Session Manager (normally AmazonSSMManagedInstanceCore) with outbound connectivity to SSM services. The repository **does not create** these dependencies.
2. From repository root, supply **your own** IDs and profile name:
   ```bash
   export AWS_REGION=eu-west-2
   export AMI_ID=ami-REPLACE_ME
   export SUBNET_ID=subnet-REPLACE_ME
   export SECURITY_GROUP_ID=sg-REPLACE_ME
   export INSTANCE_PROFILE_NAME=REPLACE_ME
   bash days/day-03-ec2/create-instance.sh
   ```
   Review the dry-run information, then **only when ready for a billable deployment**:
   ```bash
   bash days/day-03-ec2/create-instance.sh --create
   ```
   Type `CREATE` only after inspecting account, AMI, subnet, security group and pricing. Record the returned instance ID privately. An SSM-managed instance must have role permissions and SSM network connectivity; you can connect through EC2 Console → Instances → Connect → Session Manager when ready.
3. **On the instance, inside Session Manager**:
   ```bash
   sudo tail -n 50 /var/log/cloud-init-output.log
   sudo tail -n 50 /var/log/shop-bootstrap.log
   sudo systemctl status nginx --no-pager
   sudo nginx -t
   sudo ss -lntp | grep ':80'
   curl -fsS http://127.0.0.1/
   curl -fsS http://127.0.0.1/healthz
   ```
4. **Verify:** health reports `ok`, service is active and HTTP listens on port 80. Diagnose any bootstrap failure using root-owned logs with `sudo`. A private instance may intentionally have no direct internet-facing address.

**Cleanup:** If no longer needed by later days, terminate the **specific lab instance**, not a production instance: `aws ec2 terminate-instances --instance-ids i-REPLACE_ME --region "$AWS_REGION"`, then check termination and inspect retained EBS volumes/IPs. Do not terminate an instance managed by an Auto Scaling group without first addressing the group. See [cleanup](../../docs/cleanup.md). Next: [Day 4](../day-04-storage/README.md).
