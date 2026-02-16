#!/usr/bin/env bash
# pct-start-stopped.sh
# Loop through all stopped LXC containers and start them.

# Get list of stopped container IDs
ids=$(pct list | awk 'NR>1 && $2=="stopped" {print $1}')

if [ -z "$ids" ]; then
  echo "✅ No stopped containers found."
  exit 0
fi

echo "🔄 Starting stopped containers..."
for id in $ids; do
  echo "➡️  Starting CT$id..."
  pct start "$id"
  sleep 1  # short pause between starts (optional)
done

echo "✅ All stopped containers have been started."
