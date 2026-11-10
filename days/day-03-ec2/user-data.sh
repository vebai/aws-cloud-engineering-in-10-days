#!/usr/bin/env bash
set -euo pipefail
exec > >(tee -a /var/log/shop-bootstrap.log) 2>&1

# EC2 first-boot user data, intended for Amazon Linux 2023.
if command -v dnf >/dev/null 2>&1; then
  dnf install -y nginx
elif command -v yum >/dev/null 2>&1; then
  yum install -y nginx
else
  echo 'This example requires a dnf/yum-compatible AMI' >&2
  exit 1
fi

# Match the catalogue and /healthz used throughout Days 6 and 7.
mkdir -p /usr/share/nginx/html
cat > /usr/share/nginx/html/index.html <<'HTML'
<h1>Shop</h1><p>Keyboard - £49</p><p>Mouse - £25</p><p>Monitor - £189</p>
HTML
printf 'ok\n' > /usr/share/nginx/html/healthz

# Use the AMI-provided Nginx configuration rather than rewriting nginx.conf.
nginx -t
systemctl enable --now nginx
curl -fsS http://127.0.0.1/ >/dev/null
curl -fsS http://127.0.0.1/healthz
