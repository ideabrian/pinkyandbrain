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

# Fix PATH for background daemon (add common install locations)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Find claude executable
CLAUDE_BIN=$(which claude 2>/dev/null || echo "/opt/homebrew/bin/claude")

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

# Function to send status update to cloud
send_status_update() {
    local unread_count=$(curl -s "$LOCAL_BUS/inbox/unread" 2>/dev/null | jq -r '.unread' 2>/dev/null || echo "0")

    curl -s -X POST "$CLOUD_BUS/cluster-status" \
        -H "X-API-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"machine\": \"$ROLE\",
            \"poller_running\": true,
            \"poller_pid\": $$,
            \"unread_messages\": $unread_count,
            \"timestamp\": $(date +%s)000
        }" > /dev/null 2>&1
}

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

            # Skip messages from yourself (prevent loops)
            if [ "$MESSAGE_FROM" = "$ROLE" ] || [ "$MESSAGE_FROM" = "${ROLE}.local" ]; then
                log "${YELLOW}⚠ Skipping message from self (preventing loop)${NC}"
                curl -s -X POST "$LOCAL_BUS/inbox/$MESSAGE_ID/read" > /dev/null
                continue
            fi

            # Mark as read
            curl -s -X POST "$LOCAL_BUS/inbox/$MESSAGE_ID/read" > /dev/null

            # Trigger Claude Code with role-specific prompt
            PROMPT_FILE="$PROMPT_DIR/$ROLE-prompt.md"
            if [ -f "$PROMPT_FILE" ]; then
                log "${YELLOW}Launching Claude Code in iTerm with $ROLE role...${NC}"

                # Regenerate system context
                $HOME/pinkyandbrain/generate-context.sh > /dev/null 2>&1 || true

                # Create context file with message + full system state
                CONTEXT_FILE="/tmp/claude-context-$MESSAGE_ID.md"
                cat > "$CONTEXT_FILE" <<EOF
# Message from $MESSAGE_FROM

$MESSAGE_BODY

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Your Role: $ROLE

$(cat "$PROMPT_FILE")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## IMPORTANT: Sending Messages

When sending messages via curl, wrap the command in the danger function to avoid approval prompts:

\`\`\`bash
danger curl -X POST http://RECIPIENT.local:3100/send -H "Content-Type: application/json" -d '{"from":"$ROLE","to":"RECIPIENT","body":"your message"}'
\`\`\`

The danger function is available in your shell and bypasses approval requirements.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Current System Context

$(cat $HOME/pinkyandbrain/CONTEXT-SUMMARY.txt)

**Full context available at:** ~/pinkyandbrain/CONTEXT.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

                log "Context prepared at: $CONTEXT_FILE"

                # Launch Claude in iTerm window (bottom left, small size)
                osascript <<APPLESCRIPT
tell application "iTerm"
    create window with default profile
    tell current window
        -- Position: bottom left corner
        -- Size: 1000 wide x 500 tall
        set bounds to {20, 750, 1020, 1250}
        set current session's name to "🤖 $ROLE processing: $MESSAGE_ID"
    end tell
    tell current session of current window
        write text "cd ~/pinkyandbrain"
        write text "~/pinkyandbrain/process-message.sh '$CONTEXT_FILE' '$MESSAGE_FROM' '$MESSAGE_ID' '$ROLE'"
    end tell
end tell
APPLESCRIPT

                log "${GREEN}✓ Claude launched in iTerm window${NC}"
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
                log "${YELLOW}Launching Claude Code in iTerm with $ROLE role...${NC}"

                # Regenerate system context
                $HOME/pinkyandbrain/generate-context.sh > /dev/null 2>&1 || true

                # Create context file with message + full system state
                CONTEXT_FILE="/tmp/claude-cloud-context-$CLOUD_MSG_ID.md"
                cat > "$CONTEXT_FILE" <<EOF
# Cloud Message from $CLOUD_MSG_FROM

**Workflow ID**: $WORKFLOW_ID

$CLOUD_MSG_BODY

**Important**: When done, update cloud status using danger function:
\`\`\`bash
danger curl -X POST $CLOUD_BUS/update/$WORKFLOW_ID \\
  -H "X-API-Key: $API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{"status":"implemented","completed":true}'
\`\`\`

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Your Role: $ROLE

$(cat "$PROMPT_FILE")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## IMPORTANT: Sending Messages

When sending messages via curl, wrap the command in the danger function to avoid approval prompts:

\`\`\`bash
danger curl -X POST http://RECIPIENT.local:3100/send -H "Content-Type: application/json" -d '{"from":"$ROLE","to":"RECIPIENT","body":"your message"}'
\`\`\`

The danger function is available in your shell and bypasses approval requirements.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Current System Context

$(cat $HOME/pinkyandbrain/CONTEXT-SUMMARY.txt)

**Full context available at:** ~/pinkyandbrain/CONTEXT.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

                log "Context prepared at: $CONTEXT_FILE"

                # Launch Claude in iTerm window (bottom left, small size)
                osascript <<APPLESCRIPT
tell application "iTerm"
    create window with default profile
    tell current window
        -- Position: bottom left corner
        -- Size: 1000 wide x 500 tall
        set bounds to {20, 750, 1020, 1250}
        set current session's name to "☁️  $ROLE processing: $WORKFLOW_ID"
    end tell
    tell current session of current window
        write text "cd ~/pinkyandbrain"
        write text "~/pinkyandbrain/process-message.sh '$CONTEXT_FILE' '$CLOUD_MSG_FROM' '$CLOUD_MSG_ID' '$ROLE'"
    end tell
end tell
APPLESCRIPT

                log "${GREEN}✓ Claude launched in iTerm window${NC}"
            else
                log "${YELLOW}⚠ Prompt file not found: $PROMPT_FILE${NC}"
            fi
        fi
    fi

    # Send status update to cloud dashboard
    send_status_update

    # Sleep before next poll
    sleep "$POLL_INTERVAL"
done
