#!/bin/bash

# orchestrator.sh - Multi-agent Claude Code coordinator
# Opens terminal windows on different machines and enables inter-agent communication

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Multi-Agent Orchestrator            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# Check if message bus is running
check_message_bus() {
    local host=$1
    local port=3100

    if curl -s "http://$host:$port/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Message bus on $host is running"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Message bus on $host is NOT running"
        return 1
    fi
}

# Start message bus if not running
start_message_bus() {
    local machine=$1

    echo -e "${YELLOW}Starting message bus on $machine...${NC}"

    if [ "$machine" = "localhost" ]; then
        node claude-messenger.js > ~/messenger.log 2>&1 &
        echo $! > /tmp/messenger-localhost.pid
    else
        ssh "$machine" "bash -l -c 'cd ~ && node claude-messenger.js > ~/messenger.log 2>&1 &'"
    fi

    sleep 2
}

# Open terminal window with Claude session
open_claude_terminal() {
    local machine=$1
    local agent_name=$2
    local initial_prompt=$3

    echo -e "${BLUE}Opening Claude terminal for $agent_name on $machine...${NC}"

    if [ "$machine" = "localhost" ]; then
        # Open new iTerm window for local Claude session
        osascript <<EOF
tell application "iTerm"
    create window with default profile
    tell current session of current window
        write text "cd ~/Documents/projects/pinkyandbrain"
        write text "clear"
        write text "echo '╔════════════════════════════════════════════════════════════╗'"
        write text "echo '║  🤖 Agent: $agent_name'"
        write text "echo '║  💻 Machine: $machine'"
        write text "echo '║  📡 Message Bus: http://localhost:3100'"
        write text "echo '╚════════════════════════════════════════════════════════════╝'"
        write text "echo ''"
        write text "echo '📬 To start Claude Code, run: claude'"
        write text "echo ''"
        write text "echo 'Quick Commands:'"
        write text "echo '  📥 Check messages:    curl http://localhost:3100/inbox | jq'"
        write text "echo '  📤 Send to pinky:     curl -X POST http://192.168.5.80:3100/send -H \"Content-Type: application/json\" -d '\"'\"'{\"from\":\"$agent_name\",\"to\":\"pinky-claude\",\"body\":\"YOUR_MESSAGE\"}'\"'\"''"
        write text "echo ''"
    end tell
end tell
EOF
    else
        # Open new iTerm window with SSH to remote machine
        osascript <<EOF
tell application "iTerm"
    create window with default profile
    tell current session of current window
        write text "ssh $machine"
        delay 2
        write text "clear"
        write text "echo '╔════════════════════════════════════════════════════════════╗'"
        write text "echo '║  🤖 Agent: $agent_name'"
        write text "echo '║  💻 Machine: $machine'"
        write text "echo '║  📡 Message Bus: http://localhost:3100'"
        write text "echo '╚════════════════════════════════════════════════════════════╝'"
        write text "echo ''"
        write text "echo '📬 To start Claude Code, run: claude'"
        write text "echo '   (First time? You may need to authorize in browser)'"
        write text "echo ''"
        write text "echo 'Quick Commands:'"
        write text "echo '  📥 Check messages:    curl http://localhost:3100/inbox | jq'"
        write text "echo '  📤 Send to maxyolo:   curl -X POST http://192.168.5.76:3100/send -H \"Content-Type: application/json\" -d '\"'\"'{\"from\":\"$agent_name\",\"to\":\"maxyolo-claude\",\"body\":\"YOUR_MESSAGE\"}'\"'\"''"
        write text "echo ''"
    end tell
end tell
EOF
    fi

    echo -e "${GREEN}✓${NC} Terminal opened for $agent_name"
}

# Main orchestration
main() {
    echo "Checking message bus status..."
    echo ""

    # Check/start message bus on maxyolo
    if ! check_message_bus "localhost"; then
        start_message_bus "localhost"
        check_message_bus "localhost" || echo "Failed to start on localhost"
    fi

    # Check/start message bus on pinky
    if ! check_message_bus "192.168.5.80"; then
        start_message_bus "pinky"
        check_message_bus "192.168.5.80" || echo "Failed to start on pinky"
    fi

    echo ""
    echo -e "${GREEN}Message bus ready! Now opening Claude sessions...${NC}"
    echo ""
    sleep 2

    # Open Claude session on maxyolo
    open_claude_terminal "localhost" "maxyolo-claude" "I am the orchestrator on maxyolo"

    sleep 2

    # Open Claude session on pinky
    open_claude_terminal "pinky" "pinky-claude" "I am the executor on pinky"

    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Multi-agent session initialized     ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Two terminal windows are now open!${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. In each terminal window, run: ${GREEN}claude${NC}"
    echo "  2. First time on pinky? Follow the auth link in your browser"
    echo "  3. Start sending messages between agents!"
    echo ""
    echo "Message buses running at:"
    echo "  • maxyolo: http://localhost:3100"
    echo "  • pinky:   http://192.168.5.80:3100"
    echo ""
}

main "$@"
