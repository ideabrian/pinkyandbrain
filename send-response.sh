#!/bin/bash
# send-response.sh - Wait for Claude output and send response
# Usage: ./send-response.sh <CLAUDE_PID> <OUTPUT_FILE> <MESSAGE_FROM> <ROLE>

CLAUDE_PID=$1
OUTPUT_FILE=$2
MESSAGE_FROM=$3
ROLE=$4
LOCAL_BUS="http://localhost:3100"
MAX_WAIT=60  # Maximum 60 seconds

# Wait for Claude process to finish (with timeout)
WAITED=0
while kill -0 $CLAUDE_PID 2>/dev/null; do
    sleep 1
    WAITED=$((WAITED + 1))
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo "Timeout waiting for Claude PID $CLAUDE_PID"
        exit 1
    fi
done

# Check if output file exists and has content
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Output file not found: $OUTPUT_FILE"
    exit 1
fi

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "Output file is empty: $OUTPUT_FILE"
    exit 1
fi

# Read the response
RESPONSE=$(cat "$OUTPUT_FILE")

# Send response back via message bus
curl -s -X POST "$LOCAL_BUS/send" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg from "$ROLE" \
        --arg to "$MESSAGE_FROM" \
        --arg subject "Re: Auto-processed message" \
        --arg body "$RESPONSE" \
        '{from: $from, to: $to, subject: $subject, body: $body, priority: "normal"}'
    )" > /dev/null

echo "Response sent from $ROLE to $MESSAGE_FROM"
