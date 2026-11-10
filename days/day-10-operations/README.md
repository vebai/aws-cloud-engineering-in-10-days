# Day 10 — Operational recovery and full cleanup

**Objective:** Practise evidence-driven diagnosis and verify that every resource created for the learning journey has been removed when no longer needed.

**Where to run:** Mac/Linux or CloudShell for AWS inventory and deletion; EC2 Session Manager for instance logs **before** terminating EC2. **Guides:** [complete cleanup](../../docs/cleanup.md), [troubleshooting](../../docs/troubleshooting.md).

1. Confirm account/Region and inspect inventory:
   ```bash
   export AWS_REGION=eu-west-2
   aws sts get-caller-identity
   ./validation/inventory-resources.sh
   ```
2. Compare actual resources with your **private ledger**. The inventory is read-only and **not** exhaustive: add S3, IAM, EBS, Elastic IPs, target groups, NAT gateways, snapshots, ECR and other Regions where applicable.
3. For any broken application, follow the boundary: client → ALB → target group → instance network → Nginx process → application response. Gather AWS resource state and Linux logs; change only the smallest justified element and verify again.
4. Follow [docs/cleanup.md](../../docs/cleanup.md), **including the dependency order and final verification checks**. AWS cost reporting may lag actual deletion.

**Success criteria:** Service checks have attributable evidence, cleanup commands target only resources recorded for this lab, deletion has been independently confirmed and any remaining resource is explained. Next: return to [repository contents](../../README.md).
