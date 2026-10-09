#!/usr/bin/env bash
# network-check.sh - connectivity, latency, packet loss, DNS and port checks. Exit 0 OK, 2 on any failure.
# Usage: ./network-check.sh [-H "10.10.99.1 10.10.10.1"] [-D example.com] [-T "10.10.10.10:443"]
set -uo pipefail
HOSTS="8.8.8.8"; DNSNAME="example.com"; TCP=""
while getopts "H:D:T:" o; do case "$o" in H) HOSTS="$OPTARG";; D) DNSNAME="$OPTARG";; T) TCP="$OPTARG";; esac; done
fail=0
echo "== Network check $(date '+%F %T') =="
for h in $HOSTS; do
  out=$(ping -c 4 -W 2 "$h" 2>&1)
  loss=$(echo "$out" | grep -oE '[0-9]+% packet loss' | grep -oE '^[0-9]+')
  avg=$(echo "$out" | awk -F'/' '/rtt|round-trip/{print $5}')
  if [ "${loss:-100}" -lt 50 ]; then echo "OK   ping $h loss=${loss}% avg=${avg:-n/a}ms"
  else echo "FAIL ping $h loss=${loss:-100}%"; fail=2; fi
done
if getent hosts "$DNSNAME" >/dev/null; then echo "OK   dns $DNSNAME"; else echo "FAIL dns $DNSNAME"; fail=2; fi
for t in $TCP; do
  if timeout 3 bash -c "</dev/tcp/${t%:*}/${t#*:}" 2>/dev/null; then echo "OK   tcp $t"; else echo "FAIL tcp $t"; fail=2; fi
done
exit $fail
