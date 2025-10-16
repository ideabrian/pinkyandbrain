#!/bin/bash
# run-as-pinky.sh - Start a Pinky session on maxyolo

set -e

ROLE="pinky"
ROLE_DIR="$HOME/pinkyandbrain/roles/$ROLE"
PROMPT_FILE="$HOME/pinkyandbrain/prompts/${ROLE}-prompt.md"

# Colors
PINK='\033[0;35m'
NC='\033[0m'

echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PINK}💖 Starting PINKY session on maxyolo${NC}"
echo -e "${PINK}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
echo "Starting cloud poller for pinky role..."
echo ""

cd "$HOME/pinkyandbrain"

# Start the cloud poller in the background
./cloud-poller.sh pinky > "$HOME/pinkyandbrain/cloud-poller-pinky-local.log" 2>&1 &
POLLER_PID=$!

echo "✓ Cloud poller started (PID: $POLLER_PID)"
echo "✓ Watching for messages to: pinky"
echo "✓ Logs: ~/pinkyandbrain/cloud-poller-pinky-local.log"
echo ""
echo "To view logs: tail -f ~/pinkyandbrain/cloud-poller-pinky-local.log"
echo "To stop: pkill -f 'cloud-poller.sh pinky'"
echo ""
echo -e "${PINK}💖 PINKY is online and waiting for messages!${NC}"
