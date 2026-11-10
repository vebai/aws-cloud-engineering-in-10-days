# Day 8 — CloudWatch logging and evidence

**Objective:** Ship Nginx access/error logs from a working EC2 instance to CloudWatch, verify their arrival and apply three-day retention.

**Where to run:** Configuration is in the repository on your **Mac**, but installing the agent and setting its configuration happens **inside EC2 Session Manager**. **File:** [`cloudwatch-agent.json`](cloudwatch-agent.json).

1. **IAM and cost preflight (Mac/CloudShell):** Inspect the instance profile role before configuring the agent. `AmazonSSMManagedInstanceCore` permits Session Manager access, **not** CloudWatch Logs delivery. A dedicated lab role may use AWS-managed `CloudWatchAgentServerPolicy`, or a narrowly scoped policy granting the actions needed for this configuration. Never amend a shared role without checking its other workloads. In particular, publishing requires `logs:PutLogEvents` and stream creation may require `logs:CreateLogStream`; the agent may call `logs:DescribeLogGroups` and apply retention (`logs:PutRetentionPolicy`). Creating groups requires `logs:CreateLogGroup` unless an administrator creates them first. If managing a temporary policy, keep its name and removal instructions in your private lab ledger. **Do not publish account-specific policy ARNs in this repo.**

   For a controlled least-privilege lab, an administrator can pre-create the two dedicated log groups and set retention from Mac/CloudShell (first confirm these names are not shared):
   ```bash
   export AWS_REGION=eu-west-2
   aws sts get-caller-identity
   aws logs create-log-group --log-group-name /shop-dev/nginx/access --region "$AWS_REGION"
   aws logs create-log-group --log-group-name /shop-dev/nginx/error --region "$AWS_REGION"
   for group in /shop-dev/nginx/access /shop-dev/nginx/error; do
     aws logs put-retention-policy --log-group-name "$group" --retention-in-days 3 --region "$AWS_REGION"
   done
   ```
   If a group already exists, do not blindly recreate or delete it: inspect ownership and retention. Grant the instance role `logs:DescribeLogGroups` (resource `*`) and log-stream creation/publishing permissions scoped to the two dedicated groups. See [AWS IAM documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html).

2. Review the JSON: it collects `/var/log/nginx/access.log` and `/var/log/nginx/error.log` into `/shop-dev/nginx/access` and `/shop-dev/nginx/error`. Ensure your EC2 role allows CloudWatch Agent to create log streams and put log events. Creating groups or setting retention may require additional permissions. Confirm Region and account first.
3. On **EC2**, install the agent if not already present. For Amazon Linux 2023:
   ```bash
   sudo dnf install -y amazon-cloudwatch-agent
   sudo test -x /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl
   ```
   On other supported AMIs follow the official AWS install guide; do not assume `dnf` is available.
4. **Transfer the configuration to EC2:** in an EC2 Session Manager shell, use a text editor such as `sudo vi /tmp/shop-cloudwatch-agent.json` and paste the **complete raw JSON** from [`cloudwatch-agent.json`](cloudwatch-agent.json); save it. (A local `cp` of this repo file will **not** work in Session Manager unless the repository was independently transferred to EC2.) For automated transfer, use your organisation's approved S3/SSM process with the corresponding instance-role permissions.
5. Still **on EC2**:
   ```bash
   sudo python3 -m json.tool /tmp/shop-cloudwatch-agent.json >/dev/null
   sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
   sudo cp /tmp/shop-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/shop-cloudwatch-agent.json
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/shop-cloudwatch-agent.json
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
   curl -fsS http://127.0.0.1/
   sudo tail -n 50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
   ```
6. **On Mac/CloudShell** (read-only), check both log groups in your selected Region:
   ```bash
   aws logs describe-log-groups --log-group-name-prefix /shop-dev/nginx/ --region "$AWS_REGION" --query 'logGroups[].{Name:logGroupName,Retention:retentionInDays}' --output table
   ```
   If retention is not `3`, and **only if you have permission and the groups belong to this lab**, set it explicitly:
   ```bash
   aws logs put-retention-policy --log-group-name /shop-dev/nginx/access --retention-in-days 3 --region "$AWS_REGION"
   aws logs put-retention-policy --log-group-name /shop-dev/nginx/error --retention-in-days 3 --region "$AWS_REGION"
   ```
7. **Verify:** both groups have streams, recent events arrive after a request, and retention is three days. Missing events require checking IAM, Region, files, service state and the agent log.

**Cleanup:** Stop/remove the agent on disposable instances when finished, and delete only the two dedicated lab log groups after you have retained needed evidence. See [cleanup](../../docs/cleanup.md). Next: [Day 9](../day-09-infrastructure-as-code/README.md).

## When the agent is running but CloudWatch has no events

**Key decision rule:** a successful agent `status` command proves process state, not successful ingestion. Verify each boundary: Nginx writes local access logs → agent reads them → IAM authorises log publication → CloudWatch stores events.

On **EC2 Session Manager**:
```bash
curl -fsS http://127.0.0.1/ >/dev/null
sudo tail -n 10 /var/log/nginx/access.log
sudo tail -n 50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

If the agent log contains `AccessDeniedException` for `logs:PutLogEvents` or `logs:DescribeLogGroups`, verify the **instance role**, not your local AWS CLI user's permissions. Reconcile only the missing permissions using a dedicated lab role or an approved temporary least-privilege policy. After IAM propagation, restart the agent, generate new requests and inspect CloudWatch again. If there is no `AccessDeniedException`, confirm the Region, log-group names, file paths and network access to CloudWatch Logs.

On **Mac/CloudShell**:
```bash
aws logs describe-log-groups --log-group-name-prefix /shop-dev/nginx/ --region "$AWS_REGION" --query 'logGroups[].{Name:logGroupName,Retention:retentionInDays}' --output table
aws logs tail /shop-dev/nginx/access --since 15m --region "$AWS_REGION"
```

An empty error log is possible when Nginx has not logged an error. Verify its group/stream independently rather than inventing an error. Before cleanup, preserve needed evidence; then remove any temporary inline IAM policy, terminate the **specific** lab EC2 instance, remove its **dedicated** security group and delete only lab-owned log groups using [the cleanup guide](../../docs/cleanup.md).
