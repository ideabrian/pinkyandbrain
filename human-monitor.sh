#!/bin/bash

# human-monitor.sh - Monitor messages intended for human participant
# Includes visual dashboard and audio notifications

set -e

# Configuration
ROLE="human"
LOCAL_BUS="http://localhost:3100"
CLOUD_BUS="${CLOUD_BUS_URL:-https://pinky-brain-hub.b-9f2.workers.dev}"
API_KEY="${CLOUD_API_KEY:-3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5}"
POLL_INTERVAL=5  # seconds
PROMPT_DIR="$HOME/pinkyandbrain/prompts"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}   🧠 Human Participant Monitor${NC}"
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Watching for messages addressed to: human${NC}"
echo -e "${CYAN}Cloud bus: $CLOUD_BUS${NC}"
echo -e "${CYAN}Poll interval: ${POLL_INTERVAL}s${NC}"
echo ""
echo -e "${GREEN}✓ Visual feedback enabled${NC}"
echo -e "${GREEN}✓ Audio notifications enabled (if audio-bridge is running)${NC}"
echo ""
echo -e "${YELLOW}💡 Tip: Start audio-bridge.js for voice notifications${NC}"
echo -e "${YELLOW}   cd ~/pinkyandbrain && node audio-bridge.js${NC}"
echo ""
echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to display message with visual formatting
display_message() {
    local from="$1"
    local body="$2"
    local workflow_id="$3"
    local timestamp=$(date +'%H:%M:%S')

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📨 New Message [$timestamp]${NC}"
    echo -e "${BLUE}From:${NC} $from"
    if [ "$workflow_id" != "null" ] && [ -n "$workflow_id" ]; then
        echo -e "${BLUE}Workflow:${NC} $workflow_id"
    fi
    echo ""
    echo -e "${YELLOW}Message:${NC}"
    echo "$body" | fold -w 70 -s | sed 's/^/  /'
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Main polling loop
while true; do
    # Poll cloud bus for messages to "human"
    CLOUD_RESPONSE=$(curl -s "$CLOUD_BUS/poll/$ROLE" -H "X-API-Key: $API_KEY" 2>/dev/null || echo '{"unread":0}')
    CLOUD_UNREAD=$(echo "$CLOUD_RESPONSE" | jq -r '.unread' 2>/dev/null || echo "0")

    if [ "$CLOUD_UNREAD" != "0" ] && [ "$CLOUD_UNREAD" != "" ]; then
        # Get first message
        CLOUD_MESSAGE=$(echo "$CLOUD_RESPONSE" | jq -r '.messages[0]')
        CLOUD_MSG_ID=$(echo "$CLOUD_MESSAGE" | jq -r '.id')
        CLOUD_MSG_FROM=$(echo "$CLOUD_MESSAGE" | jq -r '.from_machine')
        CLOUD_MSG_BODY=$(echo "$CLOUD_MESSAGE" | jq -r '.body')
        WORKFLOW_ID=$(echo "$CLOUD_MESSAGE" | jq -r '.workflow_id')

        if [ "$CLOUD_MSG_ID" != "null" ]; then
            # Display with visual formatting
            display_message "$CLOUD_MSG_FROM" "$CLOUD_MSG_BODY" "$WORKFLOW_ID"

            # Mark as complete
            curl -s -X POST "$CLOUD_BUS/complete/$CLOUD_MSG_ID" -H "X-API-Key: $API_KEY" > /dev/null

            # Desktop notification (macOS)
            osascript -e "display notification \"$CLOUD_MSG_BODY\" with title \"Message from $CLOUD_MSG_FROM\" sound name \"Ping\"" 2>/dev/null || true
        fi
    fi

    # Sleep before next poll
    sleep "$POLL_INTERVAL"
done
