#!/bin/bash

# read-url.sh - Send URL to Pinky for fetching and reading aloud
# Usage: ./read-url.sh <url>

URL="$1"

if [ -z "$URL" ]; then
    echo "Usage: $0 <url>"
    echo ""
    echo "Example:"
    echo "  $0 https://learn.omacom.io/3/omacom/76/omakase-computing"
    exit 1
fi

echo "🔊 Read URL Workflow"
echo "===================="
echo ""
echo "📎 URL: $URL"
echo ""

# Send task to Pinky
echo "📤 Sending to Pinky for processing..."
cd ~/Documents/projects/pinkyandbrain
./pinky-cli.sh send "Fetch and summarize this URL for audio: $URL" --to pinky-claude --priority high

echo ""
echo "⏳ Pinky will:"
echo "   1. Fetch the URL content"
echo "   2. Summarize it (2-3 sentences)"
echo "   3. Send it back"
echo "   4. Audio system will read it aloud"
echo ""
echo "🎧 Listen for Pinky's summary in ~10-15 seconds!"
