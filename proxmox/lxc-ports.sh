#!/usr/bin/env bash
# pct-ports.sh
# Iterate running LXC containers, show IP(s) and listening sockets,
# excluding DHCP (67/68), SSH (22), SMTP (25), and localhost bindings (127.0.0.1, ::1).

EXCLUDE_PORTS_RE=':(22|25|67|68)(\b|/)'
EXCLUDE_LOCALHOST_RE='(127\.0\.0\.1|\[::1\])'

# Get list of running container IDs
ids=$(pct list | awk 'NR>1 && $2=="running" {print $1}')

if [ -z "$ids" ]; then
  echo "No running containers found (or pct list output format unexpected)."
  exit 0
fi

for id in $ids; do
  echo "===== CT$id ====="
  name=$(pct exec $id -- hostname -f 2>/dev/null || pct config $id 2>/dev/null | awk -F': ' '/hostname/ {print $2}')
  echo "Name: ${name:-N/A}"

  # Get IPv4 addresses
  ips=$(pct exec $id -- sh -c "ip -o -4 addr show scope global 2>/dev/null | awk '{print \$4}'" 2>/dev/null || true)
  if [ -z "$ips" ]; then
    ips=$(pct exec $id -- hostname -I 2>/dev/null || true)
  fi
  echo "IPs: ${ips:-(none)}"

  # Gather listening sockets
  ports_output=$(pct exec $id -- sh -c 'if command -v ss >/dev/null 2>&1; then ss -tunlp 2>/dev/null || true; elif command -v netstat >/dev/null 2>&1; then netstat -tulpen 2>/dev/null || true; else echo "NO-SS-NETSTAT"; fi' 2>/dev/null)

  if [ -z "$ports_output" ]; then
    echo "  (no listening sockets found or ss/netstat missing)"
  elif echo "$ports_output" | grep -q 'NO-SS-NETSTAT'; then
    echo "  ss/netstat not installed inside container."
  else
    # Filter out DHCP, SSH, SMTP, and localhost
    filtered=$(printf "%s\n" "$ports_output" \
      | grep -v -E "$EXCLUDE_PORTS_RE" \
      | grep -v -E "$EXCLUDE_LOCALHOST_RE" || true)

    if [ -z "$filtered" ]; then
      echo "  All listening sockets filtered (only DHCP/SSH/SMTP/localhost found) or none left after excluding."
    else
      printf "%s\n" "$filtered" | sed 's/^/  /'
    fi
  fi

  echo
done
