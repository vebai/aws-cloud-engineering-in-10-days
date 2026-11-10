# Day 8 — CloudWatch logging and evidence

**Objective:** Ship Nginx access/error logs from a working EC2 instance to CloudWatch, verify their arrival and apply three-day retention.

**Where to run:** Configuration is in the repository on your **Mac**, but installing the agent and setting its configuration happens **inside EC2 Session Manager**. **File:** [`cloudwatch-agent.json`](cloudwatch-agent.json).

1. Review the JSON: it collects `/var/log/nginx/access.log` and `/var/log/nginx/error.log` into `/shop-dev/nginx/access` and `/shop-dev/nginx/error`. Ensure your EC2 role allows CloudWatch Agent to create log streams and put log events. Creating groups or setting retention may require additional permissions. Confirm Region and account first.
2. On **EC2**, install the agent if not already present. For Amazon Linux 2023:
   ```bash
   sudo dnf install -y amazon-cloudwatch-agent
   sudo test -x /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl
   ```
   On other supported AMIs follow the official AWS install guide; do not assume `dnf` is available.
3. **Transfer the configuration to EC2:** in an EC2 Session Manager shell, use a text editor such as `sudo vi /tmp/shop-cloudwatch-agent.json` and paste the **complete raw JSON** from [`cloudwatch-agent.json`](cloudwatch-agent.json); save it. (A local `cp` of this repo file will **not** work in Session Manager unless the repository was independently transferred to EC2.) For automated transfer, use your organisation's approved S3/SSM process with the corresponding instance-role permissions.
4. Still **on EC2**:
   ```bash
   sudo python3 -m json.tool /tmp/shop-cloudwatch-agent.json >/dev/null
   sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
   sudo cp /tmp/shop-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/shop-cloudwatch-agent.json
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/shop-cloudwatch-agent.json
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status -m ec2
   curl -fsS http://127.0.0.1/
   sudo tail -n 50 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
   ```
5. **On Mac/CloudShell** (read-only), check both log groups in your selected Region:
   ```bash
   aws logs describe-log-groups --log-group-name-prefix /shop-dev/nginx/ --region "$AWS_REGION" --query 'logGroups[].{Name:logGroupName,Retention:retentionInDays}' --output table
   ```
   If retention is not `3`, and **only if you have permission and the groups belong to this lab**, set it explicitly:
   ```bash
   aws logs put-retention-policy --log-group-name /shop-dev/nginx/access --retention-in-days 3 --region "$AWS_REGION"
   aws logs put-retention-policy --log-group-name /shop-dev/nginx/error --retention-in-days 3 --region "$AWS_REGION"
   ```
6. **Verify:** both groups have streams, recent events arrive after a request, and retention is three days. Missing events require checking IAM, Region, files, service state and the agent log.

**Cleanup:** Stop/remove the agent on disposable instances when finished, and delete only the two dedicated lab log groups after you have retained needed evidence. See [cleanup](../../docs/cleanup.md). Next: [Day 9](../day-09-infrastructure-as-code/README.md).
