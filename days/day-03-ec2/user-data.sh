#!/usr/bin/env bash
set -euo pipefail
exec > >(tee -a /var/log/shop-bootstrap.log) 2>&1
if command -v dnf >/dev/null 2>&1; then dnf install -y nginx
elif command -v yum >/dev/null 2>&1; then yum install -y nginx
else echo 'Requires an Amazon Linux or dnf/yum-compatible AMI' >&2; exit 1; fi
mkdir -p /usr/share/nginx/html
# Fresh lab instances can include a stock default vhost; avoid duplicate default_server.
if [[ -f /etc/nginx/conf.d/default.conf ]]; then mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled; fi
cat > /usr/share/nginx/html/index.html <<'HTML'
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Shop</title></head><body><h1>Shop</h1><p>AWS Cloud Engineering lab application.</p></body></html>
HTML
cat > /etc/nginx/conf.d/shop-health.conf <<'NGINX'
server {
  listen 80 default_server;
  server_name _;
  root /usr/share/nginx/html;
  location = /healthz { access_log off; add_header Content-Type text/plain; return 200 'ok\n'; }
  location / { try_files $uri $uri/ =404; }
}
NGINX
# Disable conflicting stock default server blocks, where present.
if [[ -f /etc/nginx/nginx.conf ]]; then
  # On Amazon Linux, the stock server block may already listen on port 80.
  # Use a portable default vhost instead by replacing the main config explicitly.
  cat > /etc/nginx/nginx.conf <<'MAIN'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;
events { worker_connections 1024; }
http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  access_log /var/log/nginx/access.log;
  sendfile on;
  include /etc/nginx/conf.d/*.conf;
}
MAIN
fi
nginx -t
systemctl enable --now nginx
curl -fsS http://127.0.0.1/healthz
