#!/bin/bash

# pinky - Unified CLI for distributed agent orchestration
# Makes everything so easy you'll smile until your face hurts

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
MACHINE_NAME=$(hostname -s)
LOCAL_BUS="http://localhost:3100"
MAXYOLO_BUS="http://192.168.5.76:3100"
PINKY_BUS="http://192.168.5.80:3100"

# Agent names
if [ "$MACHINE_NAME" = "maxyolo" ]; then
    CURRENT_AGENT="maxyolo-claude"
    REMOTE_AGENTS=("pinky-claude")
    REMOTE_BUSES=("$PINKY_BUS")
elif [ "$MACHINE_NAME" = "pinky" ] || [ "$MACHINE_NAME" = "Pinkys-Mac-mini" ]; then
    CURRENT_AGENT="pinky-claude"
    REMOTE_AGENTS=("maxyolo-claude")
    REMOTE_BUSES=("$MAXYOLO_BUS")
else
    CURRENT_AGENT="${MACHINE_NAME}-claude"
    REMOTE_AGENTS=()
    REMOTE_BUSES=()
fi

# Helper: Print usage
usage() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║  Pinky - Distributed Agent CLI                            ║
║  "Make your face hurt from smiling"                       ║
╚════════════════════════════════════════════════════════════╝

USAGE:
  pinky <command> [options]

COMMANDS:
  send <msg> [--to agent] [--priority high]   Send task to agent
  inbox [--unread] [--type task]              View your inbox
  status                                      Show all agents status
  health                                      Full system health check
  logs [--follow] [--agent name]              View logs
  agents                                      List all agents
  clear                                       Clear all messages

EXAMPLES:
  pinky send "Run npm test" --to pinky-claude
  pinky inbox --unread
  pinky status
  pinky health
  pinky logs --follow --agent pinky-claude

SHORTCUTS:
  pinky s <msg>     = send (to auto-selected agent)
  pinky i           = inbox
  pinky st          = status
  pinky h           = health
  pinky l           = logs

OPTIONS:
  --help, -h        Show this help
  --version, -v     Show version
  --verbose         Verbose output

EOF
}

# Helper: Generate task ID
generate_task_id() {
    echo "task-$(date +%s)-$(openssl rand -hex 3)"
}

# Helper: Select best agent for task
auto_select_agent() {
    # Simple: just return first remote agent
    # Future: check agent load, availability, etc.
    if [ ${#REMOTE_AGENTS[@]} -gt 0 ]; then
        echo "${REMOTE_AGENTS[0]}"
    else
        echo "orchestrator"
    fi
}

# Helper: Get agent bus URL
get_agent_bus() {
    local agent=$1

    if [[ "$agent" == *"maxyolo"* ]]; then
        echo "$MAXYOLO_BUS"
    elif [[ "$agent" == *"pinky"* ]]; then
        echo "$PINKY_BUS"
    else
        echo "$LOCAL_BUS"
    fi
}

# Command: Send task
cmd_send() {
    local message="$1"
    shift

    local to_agent=""
    local priority="normal"
    local auto_exec="false"

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --to)
                to_agent="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --auto)
                auto_exec="true"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Auto-select agent if not specified
    if [ -z "$to_agent" ]; then
        to_agent=$(auto_select_agent)
        echo -e "${YELLOW}Auto-selected agent: $to_agent${NC}"
    fi

    local task_id=$(generate_task_id)
    local target_bus=$(get_agent_bus "$to_agent")

    echo -e "${BLUE}📤 Sending task to $to_agent...${NC}"
    echo -e "   Task ID: ${CYAN}$task_id${NC}"
    echo -e "   Priority: $priority"
    echo -e "   Message: ${message:0:60}..."

    local response=$(curl -s -X POST "$target_bus/send" \
        -H "Content-Type: application/json" \
        -d "{
            \"from\": \"$CURRENT_AGENT\",
            \"to\": \"$to_agent\",
            \"type\": \"task\",
            \"subject\": \"CLI Task\",
            \"body\": \"$message\",
            \"priority\": \"$priority\",
            \"metadata\": {
                \"task_id\": \"$task_id\",
                \"auto_execute\": $auto_exec,
                \"reply_to\": \"$CURRENT_AGENT\"
            }
        }")

    if echo "$response" | jq -e '.success' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Task sent successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to send task${NC}"
        echo "$response" | jq
    fi
}

# Command: View inbox
cmd_inbox() {
    local unread_only=false
    local type_filter=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --unread)
                unread_only=true
                shift
                ;;
            --type)
                type_filter="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${BLUE}📬 Inbox for $CURRENT_AGENT${NC}"
    echo ""

    local endpoint="$LOCAL_BUS/inbox"
    if $unread_only; then
        endpoint="$LOCAL_BUS/inbox/unread"
    fi

    local messages=$(curl -s "$endpoint")
    local total=$(echo "$messages" | jq -r '.total // 0')
    local unread=$(echo "$messages" | jq -r '.unread // 0')

    echo -e "Total: ${CYAN}$total${NC}  Unread: ${YELLOW}$unread${NC}"
    echo ""

    # Filter and display messages
    local query='.messages[]'
    if [ ! -z "$type_filter" ]; then
        query="$query | select(.type == \"$type_filter\")"
    fi

    echo "$messages" | jq -r "$query |
        \"${BOLD}\(.from)${NC} → \(.to)  [\(.type)] \(.priority)
  📝 \(.subject // \"No subject\")
  💬 \(.body | .[0:80])
  🕐 \(.timestamp)
  ID: \(.id)
  ---\"" 2>/dev/null || echo "No messages"
}

# Command: System status
cmd_status() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  System Status                                             ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check all message buses
    local buses=("$LOCAL_BUS" "$MAXYOLO_BUS" "$PINKY_BUS")
    local bus_names=("Local" "maxyolo" "pinky")

    for i in "${!buses[@]}"; do
        local bus="${buses[$i]}"
        local name="${bus_names[$i]}"

        echo -ne "  ${BOLD}$name${NC} ($bus): "

        local health=$(curl -s "$bus/health" 2>/dev/null)
        if [ $? -eq 0 ]; then
            local msg_count=$(echo "$health" | jq -r '.messages // 0')
            echo -e "${GREEN}✅ Running${NC} ($msg_count messages)"
        else
            echo -e "${RED}❌ Down${NC}"
        fi
    done

    echo ""

    # Check pollers
    echo -e "${BOLD}Pollers:${NC}"
    if pgrep -f "message-poller.sh" > /dev/null; then
        echo -e "  ${GREEN}✅ Running${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Not running${NC}"
    fi

    echo ""

    # Agent status
    echo -e "${BOLD}Current Agent:${NC} $CURRENT_AGENT"
    echo -e "${BOLD}Remote Agents:${NC} ${REMOTE_AGENTS[@]}"
}

# Command: Health check
cmd_health() {
    echo -e "${BLUE}🏥 Running full health check...${NC}"
    echo ""

    local errors=0

    # 1. Message buses
    echo -e "${BOLD}1. Message Buses${NC}"
    for bus in "$MAXYOLO_BUS" "$PINKY_BUS"; do
        if curl -s "$bus/health" > /dev/null 2>&1; then
            echo -e "   ${GREEN}✅${NC} $bus"
        else
            echo -e "   ${RED}❌${NC} $bus"
            ((errors++))
        fi
    done
    echo ""

    # 2. SSH connectivity
    echo -e "${BOLD}2. SSH Connectivity${NC}"
    if [ "$MACHINE_NAME" = "maxyolo" ]; then
        if ssh -o ConnectTimeout=2 pinky "echo 'ok'" > /dev/null 2>&1; then
            echo -e "   ${GREEN}✅${NC} SSH to pinky"
        else
            echo -e "   ${RED}❌${NC} SSH to pinky"
            ((errors++))
        fi
    fi
    echo ""

    # 3. File permissions
    echo -e "${BOLD}3. File Permissions${NC}"
    local files=(
        "$SCRIPT_DIR/orchestrator.sh"
        "$SCRIPT_DIR/message-poller.sh"
        "$HOME/.claude/hooks/session-end.sh"
    )

    for file in "${files[@]}"; do
        if [ -x "$file" ]; then
            echo -e "   ${GREEN}✅${NC} $(basename "$file")"
        else
            echo -e "   ${YELLOW}⚠️${NC}  $(basename "$file") not executable"
        fi
    done
    echo ""

    # Summary
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✅ All systems operational!                               ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ❌ $errors issues found                                       ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    fi
}

# Command: View logs
cmd_logs() {
    local follow=false
    local agent=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --follow|-f)
                follow=true
                shift
                ;;
            --agent)
                agent="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    local log_file="$HOME/poller-$(hostname -s).log"

    if [ ! -f "$log_file" ]; then
        echo -e "${YELLOW}No log file found: $log_file${NC}"
        return 1
    fi

    echo -e "${BLUE}📋 Logs: $log_file${NC}"
    echo ""

    if $follow; then
        tail -f "$log_file"
    else
        tail -50 "$log_file"
    fi
}

# Command: List agents
cmd_agents() {
    echo -e "${BLUE}🤖 Available Agents${NC}"
    echo ""
    echo -e "  ${GREEN}●${NC} $CURRENT_AGENT (current)"
    for agent in "${REMOTE_AGENTS[@]}"; do
        echo -e "  ${YELLOW}●${NC} $agent"
    done
}

# Command: Clear messages
cmd_clear() {
    echo -e "${YELLOW}⚠️  This will delete ALL messages. Are you sure? (y/N)${NC}"
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        curl -s -X DELETE "$LOCAL_BUS/messages/all" > /dev/null
        echo -e "${GREEN}✅ All messages cleared${NC}"
    else
        echo "Cancelled"
    fi
}

# Main command dispatcher
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi

    local command=$1
    shift

    case $command in
        send|s)
            cmd_send "$@"
            ;;
        inbox|i)
            cmd_inbox "$@"
            ;;
        status|st)
            cmd_status "$@"
            ;;
        health|h)
            cmd_health "$@"
            ;;
        logs|l)
            cmd_logs "$@"
            ;;
        agents|a)
            cmd_agents "$@"
            ;;
        clear)
            cmd_clear "$@"
            ;;
        --version|-v)
            echo "pinky CLI version $VERSION"
            ;;
        --help|-h|help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            echo ""
            usage
            exit 1
            ;;
    esac
}

main "$@"
