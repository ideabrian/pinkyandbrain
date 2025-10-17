#!/bin/bash
# Heartbeat Service - Broadcasts machine status to central server
# Run via cron every 30 seconds: */1 * * * * /path/to/heartbeat-service.sh

MACHINE=$(hostname -s)
STATUS_FILE="$HOME/pinkyandbrain/status-${MACHINE}.json"
CENTRAL_SERVER="http://pinky.local:3100"  # pinky as central hub

# Get current session info
CLAUDE_ACTIVE=$(ps aux | grep -i "claude" | grep -v grep | wc -l | tr -d ' ')
LAST_COMMAND=$(fc -ln -1 2>/dev/null || echo "none")

# Create status payload
cat > "$STATUS_FILE" <<EOF
{
  "machine": "$MACHINE",
  "hostname": "$(hostname)",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "online",
  "claude_active": $CLAUDE_ACTIVE,
  "last_command": "$(echo "$LAST_COMMAND" | head -c 100)",
  "uptime": "$(uptime | awk '{print $3}')",
  "load": "$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}')"
}
EOF

# Send heartbeat to central server
curl -s -X POST "$CENTRAL_SERVER/api/heartbeat" \
  -H "Content-Type: application/json" \
  -d @"$STATUS_FILE" \
  --max-time 5 > /dev/null 2>&1

# Also broadcast to other machines (peer-to-peer backup)
for server in "http://max.local:3100" "http://localhost:3100"; do
  curl -s -X POST "$server/api/heartbeat" \
    -H "Content-Type: application/json" \
    -d @"$STATUS_FILE" \
    --max-time 3 > /dev/null 2>&1 &
done
