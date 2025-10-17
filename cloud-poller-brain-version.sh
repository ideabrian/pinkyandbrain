#!/bin/bash

# cloud-poller.sh - Hybrid message poller (local + cloud)
# Polls BOTH local message bus AND Cloudflare Workers cloud bus
#
# Usage:
#   ./cloud-poller.sh [role]
#
# Examples:
#   ./cloud-poller.sh brain
#   ./cloud-poller.sh pinky
#   ./cloud-poller.sh maxyolo

set -e

# Configuration
ROLE=${1:-$(hostname | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')}
LOCAL_BUS="http://localhost:3100"
CLOUD_BUS="${CLOUD_BUS_URL:-https://pinky-brain-hub.b-9f2.workers.dev}"
API_KEY="${CLOUD_API_KEY}"  # Set via environment variable
POLL_INTERVAL=10  # seconds

# Validate API key is set
if [ -z "$API_KEY" ]; then
    echo "Error: CLOUD_API_KEY environment variable must be set"
    echo "Usage: export CLOUD_API_KEY=your_key_here"
    exit 1
fi
PROMPT_DIR="$HOME/pinkyandbrain/prompts"
LOG_FILE="$HOME/pinkyandbrain/cloud-poller-$ROLE.log"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log() {
    echo "[$(date +'%Y-%m-%dT%H:%M:%S.000Z')] $1" | tee -a "$LOG_FILE"
}

log "${GREEN}Cloud message poller started for $ROLE${NC}"
log "Watching local: $LOCAL_BUS"
log "Watching cloud: $CLOUD_BUS"
log "Poll interval: ${POLL_INTERVAL}s"
log "PID: $$"
log "Log: $LOG_FILE"
log "${GREEN}Starting hybrid polling loop...${NC}"

# Main polling loop
while true; do
    # ━━━ Poll LOCAL bus ━━━
    LOCAL_UNREAD=$(curl -s "$LOCAL_BUS/inbox/unread" 2>/dev/null | jq -r '.unread' 2>/dev/null || echo "0")

    if [ "$LOCAL_UNREAD" != "0" ] && [ "$LOCAL_UNREAD" != "" ]; then
        log "${CYAN}📬 Local: $LOCAL_UNREAD unread message(s)${NC}"

        # Get first unread message
        MESSAGE=$(curl -s "$LOCAL_BUS/inbox/unread" | jq -r '.messages[0]')
        MESSAGE_ID=$(echo "$MESSAGE" | jq -r '.id')
        MESSAGE_FROM=$(echo "$MESSAGE" | jq -r '.from')
        MESSAGE_BODY=$(echo "$MESSAGE" | jq -r '.body')

        if [ "$MESSAGE_ID" != "null" ]; then
            log "${BLUE}Processing local message: $MESSAGE_ID${NC}"
            log "From: $MESSAGE_FROM"
            log "Body: ${MESSAGE_BODY:0:100}..."

            # Mark as read
            curl -s -X POST "$LOCAL_BUS/inbox/$MESSAGE_ID/read" > /dev/null

            # Trigger Claude Code with role-specific prompt
            PROMPT_FILE="$PROMPT_DIR/$ROLE-prompt.md"
            if [ -f "$PROMPT_FILE" ]; then
                log "${YELLOW}Launching Claude Code with $ROLE role...${NC}"

                # Create context file with message
                CONTEXT_FILE="/tmp/claude-context-$MESSAGE_ID.md"
                cat > "$CONTEXT_FILE" <<EOF
# Message from $MESSAGE_FROM

$MESSAGE_BODY

---

**Your role**: $ROLE
**Prompt**: $(cat "$PROMPT_FILE")
EOF

                # Launch Claude Code (in background)
                log "Context prepared at: $CONTEXT_FILE"

                # Execute claude -p in background to process the message
                OUTPUT_FILE="/tmp/claude-output-$MESSAGE_ID.txt"
                (claude -p "Process this message and respond appropriately" < "$CONTEXT_FILE" > "$OUTPUT_FILE" 2>&1) &
                CLAUDE_PID=$!
                log "Claude launched in background (PID: $CLAUDE_PID, output: $OUTPUT_FILE)"

                # Launch response handler in background
                (sleep 2 && $HOME/pinkyandbrain/send-response.sh "$CLAUDE_PID" "$OUTPUT_FILE" "$MESSAGE_FROM" "$ROLE" >> "$LOG_FILE" 2>&1) &
                log "Response handler launched for message from $MESSAGE_FROM"

                log "${GREEN}✓ Local message processed${NC}"
            else
                log "${YELLOW}⚠ Prompt file not found: $PROMPT_FILE${NC}"
            fi
        fi
    fi

    # ━━━ Poll CLOUD bus ━━━
    CLOUD_RESPONSE=$(curl -s "$CLOUD_BUS/poll/$ROLE" -H "X-API-Key: $API_KEY" 2>/dev/null || echo '{"unread":0}')
    CLOUD_UNREAD=$(echo "$CLOUD_RESPONSE" | jq -r '.unread' 2>/dev/null || echo "0")

    if [ "$CLOUD_UNREAD" != "0" ] && [ "$CLOUD_UNREAD" != "" ]; then
        log "${CYAN}☁️  Cloud: $CLOUD_UNREAD unread message(s)${NC}"

        # Get first message
        CLOUD_MESSAGE=$(echo "$CLOUD_RESPONSE" | jq -r '.messages[0]')
        CLOUD_MSG_ID=$(echo "$CLOUD_MESSAGE" | jq -r '.id')
        CLOUD_MSG_FROM=$(echo "$CLOUD_MESSAGE" | jq -r '.from_machine')
        CLOUD_MSG_BODY=$(echo "$CLOUD_MESSAGE" | jq -r '.body')
        WORKFLOW_ID=$(echo "$CLOUD_MESSAGE" | jq -r '.workflow_id')

        if [ "$CLOUD_MSG_ID" != "null" ]; then
            log "${BLUE}Processing cloud message: $CLOUD_MSG_ID${NC}"
            log "From: $CLOUD_MSG_FROM"
            log "Workflow: $WORKFLOW_ID"
            log "Body: ${CLOUD_MSG_BODY:0:100}..."

            # Mark as complete in cloud
            curl -s -X POST "$CLOUD_BUS/complete/$CLOUD_MSG_ID" -H "X-API-Key: $API_KEY" > /dev/null

            # Trigger Claude Code with role-specific prompt
            PROMPT_FILE="$PROMPT_DIR/$ROLE-prompt.md"
            if [ -f "$PROMPT_FILE" ]; then
                log "${YELLOW}Launching Claude Code with $ROLE role...${NC}"

                # Create context file with message
                CONTEXT_FILE="/tmp/claude-cloud-context-$CLOUD_MSG_ID.md"
                cat > "$CONTEXT_FILE" <<EOF
# Cloud Message from $CLOUD_MSG_FROM

**Workflow ID**: $WORKFLOW_ID

$CLOUD_MSG_BODY

---

**Your role**: $ROLE
**Prompt**: $(cat "$PROMPT_FILE")

**Important**: When done, update cloud status:
\`\`\`bash
curl -X POST $CLOUD_BUS/update/$WORKFLOW_ID \\
  -H "X-API-Key: $API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{"status":"implemented","completed":true}'
\`\`\`
EOF

                log "Context prepared at: $CONTEXT_FILE"

                # Execute claude -p in background to process the message
                OUTPUT_FILE="/tmp/claude-cloud-output-$CLOUD_MSG_ID.txt"
                (claude -p "Process this message and respond appropriately" < "$CONTEXT_FILE" > "$OUTPUT_FILE" 2>&1) &
                CLAUDE_PID=$!
                log "Claude launched in background (PID: $CLAUDE_PID, output: $OUTPUT_FILE)"

                log "${GREEN}✓ Cloud message processed${NC}"
            else
                log "${YELLOW}⚠ Prompt file not found: $PROMPT_FILE${NC}"
            fi
        fi
    fi

    # Sleep before next poll
    sleep "$POLL_INTERVAL"
done
