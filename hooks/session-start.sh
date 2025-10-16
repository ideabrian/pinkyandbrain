#!/bin/bash
#
# session-start.sh - SessionStart hook for Claude Code
# Loads context from previous session
#
# This runs automatically when a Claude Code session starts

set -e

MACHINE=$(hostname | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_DIR="$HOME/pinkyandbrain/sessions"

# Find most recent session
LAST_SESSION=$(ls -t "$SESSION_DIR"/session-*.txt 2>/dev/null | head -1)

if [ -n "$LAST_SESSION" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 CONTEXT FROM LAST SESSION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$LAST_SESSION"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

# Check for unread messages
if curl -s http://localhost:3100/inbox/unread 2>/dev/null | grep -q "unread"; then
    UNREAD=$(curl -s http://localhost:3100/inbox/unread 2>/dev/null | grep -o '"unread":[0-9]*' | grep -o '[0-9]*')
    if [ "$UNREAD" -gt 0 ]; then
        echo ""
        echo "📬 You have $UNREAD unread message(s)"
        echo "   Check with: curl http://localhost:3100/inbox/unread | jq ."
    fi
fi

# Check for active votes
if [ -d "$HOME/pinkyandbrain/votes" ]; then
    VOTE_COUNT=$(ls "$HOME/pinkyandbrain/votes"/*.txt 2>/dev/null | wc -l | xargs)
    if [ "$VOTE_COUNT" -gt 0 ]; then
        echo ""
        echo "🗳️  $VOTE_COUNT active vote(s)"
        echo "   Check with: ./vote-simple.sh list"
    fi
fi

echo ""
echo "✓ Session context loaded for $MACHINE at $TIMESTAMP"
echo ""

exit 0
