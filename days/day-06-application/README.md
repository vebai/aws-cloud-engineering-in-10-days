# Day 6 — Prove the Shop application works

**Objective:** Verify the Shop service on EC2 and learn to separate application failures from network reachability failures.

**Where to run:** Commands below run **inside the EC2 Session Manager shell**, not your Mac. **Files:** [Shop HTML](../../assets/shop/index.html), [Nginx example](../../assets/shop/nginx-shop.conf), [EC2 bootstrap](../day-03-ec2/user-data.sh).

1. Connect to the EC2 instance through the Console (EC2 → Instances → select lab instance → Connect → Session Manager). The instance must be online in Systems Manager and have appropriate role/connectivity.
2. Verify:
   ```bash
   whoami
   curl -fsS http://127.0.0.1/
   curl -fsS http://127.0.0.1/healthz
   sudo systemctl status nginx --no-pager
   sudo ss -lntp | grep ':80'
   sudo tail -n 50 /var/log/cloud-init-output.log
   sudo tail -n 50 /var/log/nginx/error.log
   ```
3. **Controlled fault exercise (disposable lab instance only):**
   ```bash
   sudo systemctl stop nginx
   curl -v --max-time 5 http://127.0.0.1/healthz || true
   sudo systemctl start nginx
   curl -fsS http://127.0.0.1/healthz
   ```
   Perform the restart even if the diagnostic step fails. The ALB may briefly mark targets unhealthy if this instance is in service.
4. **Verify:** Nginx is active, `/healthz` returns `ok` and the Shop page is rendered. A healthy instance endpoint does **not** prove an ALB request works; that is Day 7.

**Expected catalogue:** The response from `/` includes `Keyboard - £49`, `Mouse - £25` and `Monitor - £189`. A generic `Shop` heading alone is insufficient to verify the book's actual application content. The `/healthz` endpoint is a plain file containing `ok`.

**Cleanup:** No new resources are created by these checks. Keep the instance for the next lab or terminate only when no ASG depends on it. See [cleanup](../../docs/cleanup.md). Next: [Day 7](../day-07-load-balancing/README.md).
