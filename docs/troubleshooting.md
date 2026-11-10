# Troubleshooting by boundary

| Symptom | Inspect | Decide |
| --- | --- | --- |
| CLI `AccessDenied` | Caller identity, Region, IAM policies and permissions boundary | Fix only missing permission; do not grant blanket admin |
| EC2 user data did not finish | `sudo tail -n 50 /var/log/cloud-init-output.log`, `sudo tail -n 50 /var/log/shop-bootstrap.log` | Check package manager, role, network and exit status |
| Nginx absent or inactive | `sudo systemctl status nginx`, `sudo nginx -t` | Correct configuration then restart |
| Local health fails | `curl -v http://127.0.0.1/healthz`, `sudo ss -lntp` | Check process, port and vhost |
| ALB fails, localhost works | target health, listener, ALB and instance security groups, subnet routes | Determine the failing request boundary |
| ASG replaces instance | scaling activities, lifecycle state, EC2 and target health | Confirm the *replacement* is serving, not just created |
| No CloudWatch data | agent status and logs, instance role, log group Region | Verify data pipeline and write/retention permissions |
| Direct private EC2 address times out | intended network topology | This can be expected; inspect through SSM / ALB |
| Stack deletion blocked | stack events, attached dependencies | Remove dependencies in a deliberate order |

Avoid treating one green signal as proof that the entire application path is healthy. Collect independent evidence.
