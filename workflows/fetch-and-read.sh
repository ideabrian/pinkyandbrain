#!/bin/bash

# fetch-and-read.sh - Fetch URL, summarize with AI, and read aloud
# Usage: ./workflows/fetch-and-read.sh <url>

URL="$1"

if [ -z "$URL" ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

echo "🔊 Fetch & Read Workflow"
echo "========================"
echo "URL: $URL"
echo ""

# Step 1: Max sends task to Pinky
echo "📤 Step 1: Max sending task to Pinky..."
TASK_ID=$(cd ~/Documents/projects/pinkyandbrain && ./pinky-cli.sh send "Fetch and summarize this URL for audio playback: $URL" --to pinky-claude --priority high 2>&1 | grep "Task ID" | awk '{print $3}')
echo "   Task sent: $TASK_ID"
echo ""

# Step 2: Instruction for Pinky
echo "📋 Step 2: Pinky should:"
echo "   - Fetch URL content"
echo "   - Summarize in 2-3 sentences"
echo "   - Send summary back to maxyolo-claude"
echo ""
echo "   Example Pinky workflow:"
echo "   1. Read task from inbox: pinky inbox"
echo "   2. Fetch URL: use WebFetch tool or curl"
echo "   3. Summarize with AI"
echo "   4. Send back: pinky send \"<summary>\" --to maxyolo-claude"
echo ""

# Step 3: Monitor for Pinky's response
echo "⏳ Step 3: Waiting for Pinky's response..."
echo "   (Monitoring pinky's message bus for 30 seconds...)"
echo ""

# Wait for response
for i in {1..6}; do
    sleep 5
    MESSAGES=$(curl -s http://192.168.5.80:3100/inbox | jq '.messages[] | select(.from == "pinky-claude" and .to == "maxyolo-claude" and .read == false) | .body' 2>/dev/null | head -1)

    if [ ! -z "$MESSAGES" ]; then
        echo "✅ Received response from Pinky!"
        break
    fi

    echo "   Still waiting... ($((i*5))s)"
done

# Step 4: Audio playback
echo ""
echo "🔊 Step 4: Playing audio summary..."
sleep 3  # Wait for audio bridge to poll

RESULT=$(curl -s -X POST http://localhost:3200/api/inbox/play-all)
COUNT=$(echo "$RESULT" | jq -r '.count // 0')
DURATION=$(echo "$RESULT" | jq -r '.estimated_duration_seconds // 0')

if [ "$COUNT" -gt 0 ]; then
    echo "   Playing $COUNT messages (~${DURATION}s)"
    echo ""
    echo "🎧 Listen for the summary!"
else
    echo "   No new messages to play"
fi

echo ""
echo "✅ Workflow complete!"
