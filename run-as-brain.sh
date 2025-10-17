#!/bin/bash
# run-as-brain.sh - Start a Brain session on maxyolo

set -e

ROLE="brain"
ROLE_DIR="$HOME/pinkyandbrain/roles/$ROLE"
PROMPT_FILE="$HOME/pinkyandbrain/prompts/${ROLE}-prompt.md"

# Colors
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧠 Starting BRAIN session on maxyolo${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Role: $ROLE"
echo "Working directory: $ROLE_DIR"
echo "Prompt: $PROMPT_FILE"
echo ""
echo "Your mission:"
cat "$PROMPT_FILE" | head -10
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Starting cloud poller for brain role..."
echo ""

cd "$HOME/pinkyandbrain"

# Start the cloud poller in the background
./cloud-poller.sh brain > "$HOME/pinkyandbrain/cloud-poller-brain-local.log" 2>&1 &
POLLER_PID=$!

echo "✓ Cloud poller started (PID: $POLLER_PID)"
echo "✓ Watching for messages to: brain"
echo "✓ Logs: ~/pinkyandbrain/cloud-poller-brain-local.log"
echo ""
echo "To view logs: tail -f ~/pinkyandbrain/cloud-poller-brain-local.log"
echo "To stop: pkill -f 'cloud-poller.sh brain'"
echo ""
echo -e "${BLUE}🧠 BRAIN is online and waiting for messages!${NC}"
