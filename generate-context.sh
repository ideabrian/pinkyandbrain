#!/bin/bash

# generate-context.sh - Generate comprehensive system context
# Creates a living snapshot of current system state for background agents

set -e

OUTPUT_FILE="$HOME/pinkyandbrain/CONTEXT.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "🔄 Generating system context..."

# Get current machine info
MACHINE=$(hostname | cut -d'.' -f1)
IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
UPTIME=$(uptime | awk '{print $3 " " $4}' | sed 's/,//')

# Get cluster machine status
CLUSTER_STATUS=$(cat <<EOF
{
  "pinky": {
    "hostname": "pinky.local",
    "ip": "$(ping -c 1 pinky.local 2>/dev/null | grep 'PING' | awk '{print $3}' | tr -d '()' || echo 'offline')",
    "reachable": $(ping -c 1 pinky.local &>/dev/null && echo 'true' || echo 'false')
  },
  "brain": {
    "hostname": "brain.local",
    "ip": "$(ping -c 1 brain.local 2>/dev/null | grep 'PING' | awk '{print $3}' | tr -d '()' || echo 'offline')",
    "reachable": $(ping -c 1 brain.local &>/dev/null && echo 'true' || echo 'false')
  },
  "max": {
    "hostname": "max.local",
    "ip": "$(ping -c 1 max.local 2>/dev/null | grep 'PING' | awk '{print $3}' | tr -d '()' || echo 'offline')",
    "reachable": $(ping -c 1 max.local &>/dev/null && echo 'true' || echo 'false')
  }
}
EOF
)

# Get recent knowledge (last 5 entries)
RECENT_KNOWLEDGE=$(curl -s "https://pinky-brain-hub.b-9f2.workers.dev/knowledge/recent?limit=5" \
  -H "X-API-Key: 3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5" \
  2>/dev/null | jq -c '.recent // []' || echo '[]')

# Get active Cloudflare projects
CLOUDFLARE_PROJECTS=$(cat <<EOF
[
  {
    "name": "knowledge-search",
    "type": "pages",
    "url": "https://knowledge-search.pages.dev",
    "status": "live",
    "updated": "2025-10-17"
  },
  {
    "name": "pinky-brain-hub",
    "type": "worker",
    "url": "https://pinky-brain-hub.b-9f2.workers.dev",
    "status": "live",
    "features": ["message-bus", "knowledge-api", "voting", "workflows"]
  },
  {
    "name": "funjobs-ai",
    "type": "worker",
    "url": "https://funjobs-ai.b-9f2.workers.dev",
    "status": "live",
    "features": ["job-board", "ai-parsing", "image-upload"]
  }
]
EOF
)

# Get running processes
CLOUD_POLLER_PID=$(pgrep -f cloud-poller || echo "")
CLOUD_POLLER_STATUS="stopped"
if [ -n "$CLOUD_POLLER_PID" ]; then
  CLOUD_POLLER_STATUS="running"
fi

# Read current handoff if exists
HANDOFF_SUMMARY=""
if [ -f ~/pinkyandbrain/HANDOFF.md ]; then
  HANDOFF_SUMMARY=$(head -50 ~/pinkyandbrain/HANDOFF.md | tail -40)
fi

# Build the complete context JSON
cat > "$OUTPUT_FILE" <<EOF
{
  "generated_at": "$TIMESTAMP",
  "version": "1.0",
  "current_machine": {
    "name": "$MACHINE",
    "hostname": "$(hostname)",
    "ip": "$IP",
    "uptime": "$UPTIME",
    "cwd": "$(pwd)"
  },
  "cluster": $CLUSTER_STATUS,
  "infrastructure": {
    "message_bus": {
      "local": "http://localhost:3100",
      "cloud": "https://pinky-brain-hub.b-9f2.workers.dev",
      "api_key": "3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5"
    },
    "cloudflare_projects": $CLOUDFLARE_PROJECTS
  },
  "processes": {
    "cloud_poller": {
      "status": "$CLOUD_POLLER_STATUS",
      "pid": "$CLOUD_POLLER_PID",
      "log": "~/pinkyandbrain/cloud-poller-$MACHINE.log"
    }
  },
  "recent_knowledge": $RECENT_KNOWLEDGE,
  "key_locations": {
    "project_root": "~/pinkyandbrain",
    "knowledge_search": "~/pinkyandbrain/knowledge-search",
    "funjobs_ai": "~/pinkyandbrain/funjobs-ai",
    "docs": "~/pinkyandbrain/docs",
    "prompts": "~/pinkyandbrain/prompts"
  },
  "key_commands": {
    "search_knowledge": "curl https://pinky-brain-hub.b-9f2.workers.dev/knowledge/search?q=QUERY",
    "send_message": "curl -X POST http://MACHINE.local:3100/send -d '{\"from\":\"FROM\",\"to\":\"TO\",\"body\":\"MESSAGE\"}'",
    "check_inbox": "curl http://localhost:3100/inbox",
    "deploy_pages": "cd apps/web && npm run build && wrangler pages deploy dist --project-name=PROJECT"
  },
  "recent_activity": {
    "deployments": [
      {
        "project": "knowledge-search",
        "time": "2025-10-17T08:30:00Z",
        "url": "https://knowledge-search.pages.dev",
        "features": ["search", "browse", "knowledge-base-ui"]
      }
    ],
    "knowledge_added": [
      {
        "id": "knowledge-1760715870990",
        "title": "Move Fast: Deploy Full-Stack Apps in 30 Minutes",
        "topic": "Cloudflare Deployment"
      },
      {
        "id": "knowledge-1760714638289",
        "title": "Defensive Scripting: Safe File Modification Patterns",
        "topic": "Bash Scripting"
      }
    ]
  },
  "quick_facts": {
    "total_cloudflare_projects": "92+",
    "pages_projects": 90,
    "workers": 2,
    "active_agents": ["brain", "pinky", "max"],
    "network_migration": "IPs → hostnames (brain.local, pinky.local, max.local)"
  }
}
EOF

# Also create a minimal version for quick access
cat > "$HOME/pinkyandbrain/CONTEXT-SUMMARY.txt" <<EOF
# SYSTEM CONTEXT - Generated $TIMESTAMP

Current Machine: $MACHINE ($IP)
Cluster Status:
  - pinky.local: $(ping -c 1 pinky.local &>/dev/null && echo '✅ online' || echo '❌ offline')
  - brain.local: $(ping -c 1 brain.local &>/dev/null && echo '✅ online' || echo '❌ offline')
  - max.local: $(ping -c 1 max.local &>/dev/null && echo '✅ online' || echo '❌ offline')

Cloud Poller: $CLOUD_POLLER_STATUS $([ -n "$CLOUD_POLLER_PID" ] && echo "(PID: $CLOUD_POLLER_PID)" || echo "")

Active Projects:
  - knowledge-search.pages.dev (Knowledge base UI)
  - pinky-brain-hub.b-9f2.workers.dev (Message bus + Knowledge API)
  - funjobs-ai.b-9f2.workers.dev (Job board API)

Recent Knowledge: $(echo "$RECENT_KNOWLEDGE" | jq -r 'length') entries

Key URLs:
  - Search knowledge: https://knowledge-search.pages.dev
  - Message bus: https://pinky-brain-hub.b-9f2.workers.dev
  - Local inbox: http://localhost:3100/inbox

Commands:
  - Update context: ~/pinkyandbrain/generate-context.sh
  - View full context: cat ~/pinkyandbrain/CONTEXT.json | jq .
EOF

echo "✅ Context generated:"
echo "   Full: $OUTPUT_FILE"
echo "   Summary: $HOME/pinkyandbrain/CONTEXT-SUMMARY.txt"
echo ""
echo "📊 Current state:"
cat "$HOME/pinkyandbrain/CONTEXT-SUMMARY.txt"
