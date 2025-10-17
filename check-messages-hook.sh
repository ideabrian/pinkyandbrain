#!/bin/bash
# Claude Code hook to check messages when stopping/pausing
# This runs automatically when Claude finishes responding

ROLE=$(hostname | cut -d'.' -f1)
INBOX_URL="http://localhost:3100/inbox/unread"

# Get unread messages
UNREAD=$(curl -s "$INBOX_URL" 2>/dev/null || echo '{"unread":0}')
COUNT=$(echo "$UNREAD" | jq -r '.unread // 0' 2>/dev/null || echo "0")

if [ "$COUNT" -gt 0 ]; then
    echo ""
    echo "📬 You have $COUNT unread message(s)"
    echo "   Run: curl http://localhost:3100/inbox/unread | jq"
    echo "   Or just say: 'check messages'"
    echo ""
fi
