#!/bin/bash
# gm.sh - Send Good Morning messages to all machines

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
FROM_MACHINE=$(hostname -s)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

show_usage() {
    echo "Usage: ./gm.sh [send|receive|both]"
    echo ""
    echo "Commands:"
    echo "  send    - Send GM to all machines (brain, pinky, maxyolo)"
    echo "  receive - Read GM messages from all machines"
    echo "  both    - Send GM then show received messages (default)"
    echo ""
    echo "Examples:"
    echo "  ./gm.sh              # Send and receive"
    echo "  ./gm.sh send         # Just send"
    echo "  ./gm.sh receive      # Just check messages"
}

send_gm() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}☀️  Good Morning from $FROM_MACHINE!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Send to local buses on each machine
    MACHINES=("brain" "pinky" "maxyolo")
    
    for machine in "${MACHINES[@]}"; do
        if [ "$machine" = "$FROM_MACHINE" ]; then
            continue  # Don't send to yourself
        fi
        
        echo -e "${YELLOW}→${NC} Sending GM to $machine..."
        
        if [ "$machine" = "maxyolo" ]; then
            # Send to local bus
            curl -s -X POST http://localhost:3100/send \
                -H "Content-Type: application/json" \
                -d "{
                    \"from\": \"$FROM_MACHINE\",
                    \"to\": \"$machine\",
                    \"body\": \"Good morning! ☀️ Starting a new day. Ready to build something awesome together!\"
                }" > /dev/null
        else
            # Send to remote machine's local bus
            ssh $machine "curl -s -X POST http://localhost:3100/send \
                -H 'Content-Type: application/json' \
                -d '{
                    \"from\": \"$FROM_MACHINE\",
                    \"to\": \"$machine\",
                    \"body\": \"Good morning! ☀️ Starting a new day. Ready to build something awesome together!\"
                }'" > /dev/null
        fi
        
        echo -e "${GREEN}✓${NC} GM sent to $machine"
    done
    
    # Also post to cloud timeline
    echo ""
    echo -e "${YELLOW}→${NC} Posting to public timeline..."
    curl -s -X POST https://pinky-brain-hub.b-9f2.workers.dev/timeline \
        -H "Content-Type: application/json" \
        -H "X-API-Key: 3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5" \
        -d "{
            \"machine\": \"$FROM_MACHINE\",
            \"event_type\": \"greeting\",
            \"title\": \"Good Morning! ☀️\",
            \"description\": \"$FROM_MACHINE says GM to the team\",
            \"icon\": \"☀️\"
        }" > /dev/null
    
    echo -e "${GREEN}✓${NC} Posted to timeline"
    echo ""
}

receive_gm() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📬 Good Morning Messages${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Check local inbox
    MESSAGES=$(curl -s http://localhost:3100/inbox | jq -r '.messages[] | select(.body | contains("Good morning") or contains("GM")) | "\(.from) → \(.to): \(.body)"')
    
    if [ -z "$MESSAGES" ]; then
        echo -e "${YELLOW}No GM messages yet today${NC}"
    else
        echo "$MESSAGES" | while read -r msg; do
            echo -e "${GREEN}☀️${NC}  $msg"
        done
    fi
    
    echo ""
    
    # Show recent timeline greetings
    echo -e "${BLUE}Recent timeline greetings:${NC}"
    curl -s "https://pinky-brain-hub.b-9f2.workers.dev/timeline?limit=10" | \
        jq -r '.events[] | select(.event_type == "greeting") | "[\(.timestamp | strftime("%H:%M"))] \(.machine): \(.title)"' | head -5
    
    echo ""
}

# Main
case "${1:-both}" in
    send)
        send_gm
        ;;
    receive)
        receive_gm
        ;;
    both)
        send_gm
        receive_gm
        ;;
    -h|--help)
        show_usage
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
