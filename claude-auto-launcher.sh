#!/bin/bash

# claude-auto-launcher.sh - Launch Claude Code session from task message
# Bridges message bus tasks to actual Claude Code execution

set -e

# Configuration
MACHINE_NAME=$(hostname -s)
AGENT_NAME="${MACHINE_NAME}-claude"
MESSAGE_BUS="http://localhost:3100"
LOG_FILE="$HOME/launcher-${MACHINE_NAME}.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    echo -e "${timestamp} $@" | tee -a "$LOG_FILE"
}

# Usage
if [ $# -lt 1 ]; then
    echo "Usage: $0 <task_prompt> [task_id]"
    echo "Example: $0 'Run npm test' task-123"
    exit 1
fi

TASK_PROMPT="$1"
TASK_ID="${2:-auto-$(date +%s)}"

log "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
log "${BLUE}║  Auto-Launching Claude Code Session                       ║${NC}"
log "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
log "${GREEN}Agent: $AGENT_NAME${NC}"
log "${GREEN}Task ID: $TASK_ID${NC}"
log "${GREEN}Prompt: ${TASK_PROMPT:0:60}...${NC}"

# Send status update - task starting
curl -s -X POST "$MESSAGE_BUS/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": \"$AGENT_NAME\",
    \"to\": \"orchestrator\",
    \"type\": \"status\",
    \"subject\": \"Task Started\",
    \"body\": \"Starting task: $TASK_ID\",
    \"metadata\": {
      \"task_id\": \"$TASK_ID\",
      \"status\": \"running\",
      \"started_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")\"
    }
  }" > /dev/null 2>&1

log "${YELLOW}Launching Claude Code...${NC}"

# Option 1: Open in new iTerm window
if command -v osascript > /dev/null 2>&1; then
    log "Opening new iTerm window..."
    osascript <<EOF
tell application "iTerm"
    create window with default profile
    tell current session of current window
        write text "clear"
        write text "echo '╔════════════════════════════════════════════════════════════╗'"
        write text "echo '║  Automated Task: $TASK_ID'"
        write text "echo '╚════════════════════════════════════════════════════════════╝'"
        write text "echo ''"
        write text "echo 'Task Prompt: $TASK_PROMPT'"
        write text "echo ''"
        write text "claude"
    end tell
end tell
EOF
    log "${GREEN}New Claude session opened in iTerm${NC}"

# Option 2: Run in current terminal (for SSH/remote execution)
else
    log "Running in current terminal..."
    echo "═══════════════════════════════════════════════════════════"
    echo "Automated Task: $TASK_ID"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Task Prompt: $TASK_PROMPT"
    echo ""
    echo "Start Claude and paste this prompt:"
    echo "$TASK_PROMPT"
    echo ""
fi

log "${GREEN}Task $TASK_ID launched successfully${NC}"
