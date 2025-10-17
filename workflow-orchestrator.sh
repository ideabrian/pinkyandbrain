#!/bin/bash

# workflow-orchestrator.sh - Master coordinator for autonomous 3-machine workflows
# Initiates distributed Claude Code workflows across brain, pinky, and maxyolo
#
# Usage:
#   ./workflow-orchestrator.sh "Build me a todo list component"
#   ./workflow-orchestrator.sh "Create a user profile card"

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
BRAIN_IP="192.168.5.81"
PINKY_IP="192.168.5.80"
MAXYOLO_IP="192.168.5.76"

USER_REQUEST="${1:-}"

if [ -z "$USER_REQUEST" ]; then
    echo -e "${RED}Error: No request provided${NC}"
    echo ""
    echo "Usage: $0 \"Your feature request\""
    echo ""
    echo "Examples:"
    echo "  $0 \"Build me a todo list component\""
    echo "  $0 \"Create a user authentication form\""
    echo "  $0 \"Make a responsive navigation bar\""
    exit 1
fi

# Banner
clear
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  🤖 Autonomous Workflow Orchestrator${NC}"
echo -e "${MAGENTA}  Three Machines. One Goal. Zero Manual Steps.${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Request:${NC} $USER_REQUEST"
echo ""

# Health check all message buses
echo -e "${BLUE}━━━ Health Check ━━━${NC}"
check_bus() {
    local name=$1
    local ip=$2

    if curl -s "http://$ip:3100/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name message bus: Online"
        return 0
    else
        echo -e "${RED}✗${NC} $name message bus: Offline"
        return 1
    fi
}

HEALTH_OK=true
check_bus "brain" "$BRAIN_IP" || HEALTH_OK=false
check_bus "pinky" "$PINKY_IP" || HEALTH_OK=false
check_bus "maxyolo" "$MAXYOLO_IP" || HEALTH_OK=false

if [ "$HEALTH_OK" = false ]; then
    echo ""
    echo -e "${RED}Error: Not all message buses are online${NC}"
    echo "Start message buses on all machines first:"
    echo "  ssh brain 'cd ~/pinkyandbrain && node claude-messenger.js &'"
    echo "  ssh pinky 'cd ~/pinkyandbrain && node claude-messenger.js &'"
    exit 1
fi

echo ""

# Step 1: Send initial request to brain
echo -e "${BLUE}━━━ Step 1: Sending Request to Brain (Planner) ━━━${NC}"
echo ""

WORKFLOW_ID="workflow-$(date +%s)"
echo -e "${CYAN}Workflow ID:${NC} $WORKFLOW_ID"
echo ""

# Send message to brain
curl -s -X POST "http://$BRAIN_IP:3100/send" \
    -H "Content-Type: application/json" \
    -d "{
        \"from\": \"orchestrator\",
        \"to\": \"brain\",
        \"subject\": \"New Feature Request\",
        \"body\": \"$(echo "$USER_REQUEST" | sed 's/"/\\"/g')\",
        \"priority\": \"normal\"
    }" | jq '.'

echo ""
echo -e "${GREEN}✓${NC} Request sent to brain"
echo ""

# Step 2: Start message pollers on all machines
echo -e "${BLUE}━━━ Step 2: Starting Autonomous Agents ━━━${NC}"
echo ""

# Deploy message poller to all machines if not already there
echo "Deploying message pollers..."

for machine in brain pinky; do
    echo -e "${CYAN}→${NC} Deploying to $machine..."
    scp -q message-poller.sh $machine:~/pinkyandbrain/
    scp -r -q prompts/ $machine:~/pinkyandbrain/
done

echo -e "${GREEN}✓${NC} Pollers deployed"
echo ""

# Start pollers in background
echo "Starting autonomous agents..."

# Start brain poller
ssh brain "bash -l -c 'cd ~/pinkyandbrain && ./message-poller.sh brain > poller-brain.log 2>&1 &'" &
echo -e "${GREEN}✓${NC} brain agent started"

# Start pinky poller
ssh pinky "bash -l -c 'cd ~/pinkyandbrain && ./message-poller.sh pinky > poller-pinky.log 2>&1 &'" &
echo -e "${GREEN}✓${NC} pinky agent started"

# Start maxyolo poller (local)
./message-poller.sh maxyolo > poller-maxyolo.log 2>&1 &
MAXYOLO_PID=$!
echo -e "${GREEN}✓${NC} maxyolo agent started (PID: $MAXYOLO_PID)"

echo ""

# Step 3: Monitor workflow progress
echo -e "${BLUE}━━━ Step 3: Monitoring Workflow ━━━${NC}"
echo ""
echo "Autonomous workflow in progress..."
echo "Each machine will process messages and coordinate automatically."
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop monitoring (agents will continue running)${NC}"
echo ""

# Monitor message bus activity
LAST_TOTAL=0
TIMEOUT=300  # 5 minutes timeout
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
    # Check total messages across all buses
    BRAIN_MSGS=$(curl -s "http://$BRAIN_IP:3100/health" | jq -r '.messages' 2>/dev/null || echo "0")
    PINKY_MSGS=$(curl -s "http://$PINKY_IP:3100/health" | jq -r '.messages' 2>/dev/null || echo "0")
    MAXYOLO_MSGS=$(curl -s "http://$MAXYOLO_IP:3100/health" | jq -r '.messages' 2>/dev/null || echo "0")

    TOTAL_MSGS=$((BRAIN_MSGS + PINKY_MSGS + MAXYOLO_MSGS))

    if [ "$TOTAL_MSGS" != "$LAST_TOTAL" ]; then
        echo -e "${CYAN}[$(date +'%H:%M:%S')]${NC} Messages: brain=$BRAIN_MSGS, pinky=$PINKY_MSGS, maxyolo=$MAXYOLO_MSGS"
        LAST_TOTAL=$TOTAL_MSGS
    fi

    # Check for completion (look for message to user or "complete" status)
    MAXYOLO_UNREAD=$(curl -s "http://$MAXYOLO_IP:3100/inbox/unread" | jq -r '.unread' 2>/dev/null || echo "0")

    # If maxyolo has processed its message, workflow might be complete
    if [ "$MAXYOLO_MSGS" -gt 0 ] && [ "$MAXYOLO_UNREAD" = "0" ]; then
        echo ""
        echo -e "${GREEN}✅ Workflow appears complete!${NC}"
        echo ""
        break
    fi

    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo ""
    echo -e "${YELLOW}⚠ Workflow monitoring timed out after 5 minutes${NC}"
    echo "Agents are still running in the background."
fi

# Step 4: Show results
echo -e "${BLUE}━━━ Step 4: Results ━━━${NC}"
echo ""

# Check workflow output directory
echo "Checking workflow output..."
if [ -d "$HOME/pinkyandbrain/workflow-output" ]; then
    echo -e "${GREEN}✓${NC} Output directory exists"
    echo ""
    echo "Files created:"
    find "$HOME/pinkyandbrain/workflow-output" -type f -newer /tmp/workflow-start-$$ 2>/dev/null || echo "  (checking...)"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Workflow Status${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show message history
echo "Recent messages:"
echo ""
curl -s "http://$MAXYOLO_IP:3100/inbox" | jq -r '.messages[0:3] | .[] | "  [\(.timestamp | split("T")[1] | split(".")[0])] \(.from) → \(.to): \(.subject)"' 2>/dev/null || echo "  (no messages yet)"

echo ""
echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  Autonomous agents are running in background${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo ""

echo "To stop agents:"
echo "  ./run-on-all.sh 'pkill -f message-poller'"
echo ""

echo "To view logs:"
echo "  tail -f ~/pinkyandbrain/poller-maxyolo.log"
echo "  ssh brain 'tail -f ~/pinkyandbrain/poller-brain.log'"
echo "  ssh pinky 'tail -f ~/pinkyandbrain/poller-pinky.log'"
echo ""

echo "To check message bus status:"
echo "  ./run-on-all.sh 'curl -s http://localhost:3100/inbox | jq .'"
echo ""
