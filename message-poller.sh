#!/bin/bash

# message-poller.sh - Autonomous task queue daemon
# Continuously polls message bus for auto-executable tasks
# When found, launches Claude Code session with task prompt

set -e

# Configuration
MACHINE_NAME=$(hostname -s)
AGENT_NAME="${MACHINE_NAME}-claude"
MESSAGE_BUS="http://localhost:3100"
POLL_INTERVAL=5  # seconds
LOG_FILE="$HOME/poller-${MACHINE_NAME}.log"
PID_FILE="/tmp/poller-${MACHINE_NAME}.pid"

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        log "ERROR" "${RED}Poller already running with PID $OLD_PID${NC}"
        exit 1
    else
        log "WARN" "${YELLOW}Removing stale PID file${NC}"
        rm "$PID_FILE"
    fi
fi

# Save our PID
echo $$ > "$PID_FILE"

log "INFO" "${GREEN}Message poller started for $AGENT_NAME${NC}"
log "INFO" "Watching: $MESSAGE_BUS"
log "INFO" "Poll interval: ${POLL_INTERVAL}s"
log "INFO" "PID: $$"
log "INFO" "Log: $LOG_FILE"

# Cleanup on exit
cleanup() {
    log "INFO" "${YELLOW}Shutting down poller...${NC}"
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Process a task message
process_task() {
    local message_json="$1"

    local task_id=$(echo "$message_json" | jq -r '.metadata.task_id // "unknown"')
    local auto_exec=$(echo "$message_json" | jq -r '.metadata.auto_execute // false')
    local body=$(echo "$message_json" | jq -r '.body')
    local from=$(echo "$message_json" | jq -r '.from')
    local msg_id=$(echo "$message_json" | jq -r '.id')

    log "INFO" "${BLUE}Task received: $task_id from $from${NC}"
    log "INFO" "Auto-execute: $auto_exec"
    log "INFO" "Prompt: ${body:0:50}..."

    if [ "$auto_exec" = "true" ]; then
        log "INFO" "${GREEN}Launching Claude Code session...${NC}"

        # Mark message as read
        curl -s -X POST "$MESSAGE_BUS/inbox/$msg_id/read" > /dev/null

        # Launch Claude Code in background
        # Note: This would need a way to pass the prompt to claude
        # For now, we log it and manual execution is required
        log "WARN" "${YELLOW}Auto-execution not yet fully implemented${NC}"
        log "INFO" "To execute manually: echo '$body' | claude"

        # Send status update
        curl -s -X POST "$MESSAGE_BUS/send" \
          -H "Content-Type: application/json" \
          -d "{
            \"from\": \"$AGENT_NAME\",
            \"to\": \"$from\",
            \"type\": \"status\",
            \"subject\": \"Task Received\",
            \"body\": \"Task $task_id received and queued\",
            \"metadata\": {
              \"task_id\": \"$task_id\",
              \"status\": \"queued\"
            }
          }" > /dev/null
    else
        log "INFO" "Task not marked for auto-execution, skipping"
    fi
}

# Main polling loop
log "INFO" "${GREEN}Starting polling loop...${NC}"

while true; do
    # Check for unread task messages
    UNREAD_TASKS=$(curl -s "$MESSAGE_BUS/inbox/unread" | \
        jq -r '.messages[] | select(.to == "'"$AGENT_NAME"'" or .to == "any") | select(.type == "task") | @json')

    if [ ! -z "$UNREAD_TASKS" ]; then
        log "INFO" "${BLUE}Found $(echo "$UNREAD_TASKS" | wc -l | tr -d ' ') unread task(s)${NC}"

        # Process each task
        while IFS= read -r task; do
            if [ ! -z "$task" ]; then
                process_task "$task"
            fi
        done <<< "$UNREAD_TASKS"
    fi

    # Sleep before next poll
    sleep $POLL_INTERVAL
done
