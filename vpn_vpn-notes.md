# VPN deployment notes (OpenVPN)

1. Build a small CA with easy-rsa; issue one certificate per user, revoke on departure (`crl-verify`).
2. Use `server.conf` as a base: TLS 1.2+, AES-256-GCM, `tls-crypt`, routes pushed only to required subnets.
3. Firewall: allow UDP 1194 on the edge; forward `tun0` to the server VLAN only.
4. Access control: split by group with `client-config-dir`; add MFA through the PAM plugin where required.
5. Monitoring: watch `/var/log/openvpn-status.log` and failed authentication attempts.
6. Test: connect, confirm only the pushed routes are reachable, confirm a revoked certificate is rejected.
