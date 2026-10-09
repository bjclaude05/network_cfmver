#!/usr/bin/env bash
# ufw_rules.sh - default-deny host firewall for an application server.
# Usage: sudo ./ufw_rules.sh [admin_cidr=10.10.99.0/24]
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo)"; exit 2; }
ADMIN_NET="${1:-10.10.99.0/24}"

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw logging medium

# SSH only from the management network, rate limited
ufw limit from "$ADMIN_NET" to any port 22 proto tcp comment 'SSH admin'
# Public web (via Nginx)
ufw allow 80/tcp  comment 'HTTP redirect'
ufw allow 443/tcp comment 'HTTPS'
# Monitoring agent from monitoring host only
ufw allow from 10.10.99.20 to any port 9100 proto tcp comment 'node_exporter'

ufw --force enable
ufw status verbose
