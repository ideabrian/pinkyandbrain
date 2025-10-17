#!/bin/bash

# process-message.sh
# Wrapper script that processes a message with Claude

# Source aliases to get danger function
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

CONTEXT_FILE="$1"
MESSAGE_FROM="$2"
MESSAGE_ID="$3"
ROLE="$4"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📬 Message from: $MESSAGE_FROM"
echo "🆔 Message ID: $MESSAGE_ID"
echo "👤 Your role: $ROLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run Claude with the context and capture output
echo "🤖 Processing with Claude..."
RESPONSE=$(cat "$CONTEXT_FILE" | danger claude -p "Process this message and respond appropriately." 2>&1)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 Sending response to $MESSAGE_FROM..."

# Send response automatically to local message bus (no approval needed - bash script runs curl)
SEND_RESULT=$(curl -s -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d "{\"from\":\"$ROLE\",\"to\":\"$MESSAGE_FROM\",\"body\":$(echo "$RESPONSE" | jq -Rs .)}" 2>&1)

if echo "$SEND_RESULT" | grep -q "success"; then
    echo "✅ Response sent successfully!"
else
    echo "❌ Failed to send response:"
    echo "$SEND_RESULT"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Response Preview:"
echo "$RESPONSE" | head -20
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Message processing complete!"
echo "👁️  Window staying open for inspection"
echo "🔒 Close manually when done (⌘+W or type 'exit')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
