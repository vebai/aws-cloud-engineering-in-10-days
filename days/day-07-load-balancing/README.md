# Day 7 — Load balancing and Auto Scaling

**Objective:** Follow a real request through an ALB to a healthy target, and verify that an Auto Scaling group replaces a disposable failed instance.

**Where to run:** Mac/Linux or CloudShell. The ALB/ASG must already exist from the **book's Console lab**; this repository does **not** create them. Do not run the replacement experiment in production.

1. From the EC2/ELB Console, record the lab's actual ALB DNS name, target-group ARN and Auto Scaling group name **privately**. Then, from your local terminal:
   ```bash
   export AWS_REGION=eu-west-2
   export ALB_DNS_NAME=REPLACE_WITH_ALB_DNS
   export TARGET_GROUP_ARN=REPLACE_WITH_TARGET_GROUP_ARN
   export ASG_NAME=REPLACE_WITH_ASG_NAME
   aws sts get-caller-identity
   curl -v --max-time 15 "http://$ALB_DNS_NAME/"
   aws elbv2 describe-target-health --target-group-arn "$TARGET_GROUP_ARN" --region "$AWS_REGION"
   aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$ASG_NAME" --region "$AWS_REGION"
   aws autoscaling describe-scaling-activities --auto-scaling-group-name "$ASG_NAME" --region "$AWS_REGION"
   ```
2. **Verify:** ALB serves the Shop HTML; the listener forwards to your target group; targets become `healthy`; ASG reports expected desired/in-service instances. Check the target group's actual health path, ideally `/healthz`.
3. **Optional controlled recovery:** use the book's termination experiment only with a disposable ASG-managed instance ID. The group may replace it automatically. Compare instance IDs, scaling activity and target health **after** replacement, not just the EC2 `running` state. This exercise is not performed by any script in this repository.
4. A request to an EC2 instance's private address from your laptop timing out may be correct. Troubleshoot ALB security group, instance security group source, subnet routes, target port and health-check path independently.

**Cleanup:** To avoid ASG automatically recreating instances, delete or scale down the **lab ASG** deliberately before terminating instances. Remove ALB/listeners/rules and target groups in dependency order; delete launch templates after groups stop using them. See [cleanup](../../docs/cleanup.md). Next: [Day 8](../day-08-monitoring/README.md).
