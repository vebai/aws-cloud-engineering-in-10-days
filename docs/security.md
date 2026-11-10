# Security checks

Use least privilege and temporary credentials. Prefer Session Manager over broad SSH exposure; scope ALB HTTP/HTTPS and instance inbound rules explicitly. Protect S3 with Block Public Access and encryption. Keep live credentials, key material, public IP addresses, instance identifiers and account-specific evidence out of Git. Scripts that create resources require explicit opt-in; carefully inspect their output and pricing first.

The app and examples are educational; they do not include TLS termination, a production-grade authentication flow, secret management or full multi-zone resiliency. Apply your organisation's deployment standards before reuse.
