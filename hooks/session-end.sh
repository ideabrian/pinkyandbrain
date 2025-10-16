#!/bin/bash
#
# session-end.sh - SessionEnd hook for Claude Code
# Captures session context before ending
#
# This runs automatically when a Claude Code session ends

set -e

MACHINE=$(hostname | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_DIR="$HOME/pinkyandbrain/sessions"
SESSION_FILE="$SESSION_DIR/session-$(date +%s).txt"

mkdir -p "$SESSION_DIR"

# Capture what happened this session
cat > "$SESSION_FILE" <<EOF
SESSION SUMMARY
===============
Machine: $MACHINE
Ended: $TIMESTAMP

Recent commands (last 10):
EOF

# Get last 10 bash commands from our hook log
if [ -f "$HOME/pinkyandbrain/bash-history.log" ]; then
    tail -20 "$HOME/pinkyandbrain/bash-history.log" | grep "Command:" | tail -10 >> "$SESSION_FILE"
fi

cat >> "$SESSION_FILE" <<EOF

Active votes:
EOF

# List active votes if they exist
if [ -d "$HOME/pinkyandbrain/votes" ]; then
    ls "$HOME/pinkyandbrain/votes"/*.txt 2>/dev/null | wc -l | xargs echo "  Total:" >> "$SESSION_FILE"
fi

cat >> "$SESSION_FILE" <<EOF

Unread messages:
EOF

# Check for unread messages
if curl -s http://localhost:3100/inbox 2>/dev/null | grep -q "unread"; then
    curl -s http://localhost:3100/inbox 2>/dev/null | grep -o '"unread":[0-9]*' >> "$SESSION_FILE" || echo "  Unable to check" >> "$SESSION_FILE"
else
    echo "  Message bus not running" >> "$SESSION_FILE"
fi

# Post to knowledge base (if available)
if [ -f "$HOME/pinkyandbrain/knowledge-cli.sh" ]; then
    SUMMARY=$(cat "$SESSION_FILE" | head -20)
    "$HOME/pinkyandbrain/knowledge-cli.sh" share \
        "Session End" \
        "$MACHINE session ended at $TIMESTAMP" \
        "Session saved to sessions/ directory. Check inbox and votes for pending work." \
        "" \
        "session" \
        "session,context,$MACHINE" 2>/dev/null || true
fi

# Send message to self
if curl -s http://localhost:3100/health 2>/dev/null | grep -q "ok"; then
    curl -s -X POST http://localhost:3100/send \
        -H "Content-Type: application/json" \
        -d "{\"to\":\"$MACHINE\",\"subject\":\"Session Ended\",\"body\":\"Session ended at $TIMESTAMP. Summary saved to $SESSION_FILE. Check for: unread messages, active votes, pending work.\"}" \
        2>/dev/null || true
fi

echo "✓ Session context saved to $SESSION_FILE"
exit 0
