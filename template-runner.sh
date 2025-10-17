#!/bin/bash

# template-runner.sh - Execute tasks from template library
# Makes complex workflows as simple as: template run test-runner

TEMPLATES_DIR="$(dirname "$0")/templates"
SCRIPT_DIR="$(dirname "$0")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

usage() {
    cat << EOF
╔════════════════════════════════════════════════════════════╗
║  Template Runner                                           ║
║  Pre-built workflows that just work                        ║
╚════════════════════════════════════════════════════════════╝

USAGE:
  template <command> [template-name] [options]

COMMANDS:
  list                    List all available templates
  show <name>             Show template details
  run <name> [vars]       Execute template with variables
  create <name>           Create new template

EXAMPLES:
  template list
  template show test-runner
  template run test-runner
  template run build-frontend build_command="npm run build:prod"
  template run deploy-pipeline environment=staging

AVAILABLE TEMPLATES:
EOF

    # List templates
    for template in "$TEMPLATES_DIR"/*.json; do
        if [ -f "$template" ]; then
            local name=$(basename "$template" .json)
            local desc=$(jq -r '.description' "$template")
            echo "  • $name - $desc"
        fi
    done
}

# List all templates
cmd_list() {
    echo -e "${BLUE}📋 Available Templates${NC}"
    echo ""

    for template in "$TEMPLATES_DIR"/*.json; do
        if [ -f "$template" ]; then
            local name=$(basename "$template" .json)
            local desc=$(jq -r '.description' "$template")
            local priority=$(jq -r '.template.priority' "$template")

            echo -e "  ${GREEN}▸${NC} ${BOLD}$name${NC}"
            echo -e "    $desc"
            echo -e "    Priority: $priority"
            echo ""
        fi
    done
}

# Show template details
cmd_show() {
    local template_name="$1"
    local template_file="$TEMPLATES_DIR/$template_name.json"

    if [ ! -f "$template_file" ]; then
        echo -e "${RED}Template not found: $template_name${NC}"
        exit 1
    fi

    echo -e "${BLUE}📄 Template: $template_name${NC}"
    echo ""

    jq -r '
        "Description: \(.description)\n" +
        "Priority: \(.template.priority)\n" +
        "Timeout: \(.template.metadata.timeout)s\n" +
        "\nTask Body:\n\(.template.body)\n" +
        "\nVariables:"
    ' "$template_file"

    jq -r '.variables | to_entries[] | "  • \(.key): \(.value.description) (default: \(.value.default // "none"))"' "$template_file"
}

# Run template
cmd_run() {
    local template_name="$1"
    shift

    local template_file="$TEMPLATES_DIR/$template_name.json"

    if [ ! -f "$template_file" ]; then
        echo -e "${RED}Template not found: $template_name${NC}"
        exit 1
    fi

    echo -e "${BLUE}🚀 Running template: $template_name${NC}"
    echo ""

    # Load template
    local template=$(cat "$template_file")

    # Parse variable overrides
    local vars="{}"
    for arg in "$@"; do
        if [[ "$arg" == *"="* ]]; then
            local key="${arg%%=*}"
            local value="${arg#*=}"
            vars=$(echo "$vars" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
        fi
    done

    # Generate task with defaults + overrides
    local defaults=$(echo "$template" | jq -r '.variables | to_entries | map({(.key): (.value.default // "")}) | add')
    local merged=$(echo "$defaults" | jq --argjson overrides "$vars" '. + $overrides')

    # Add timestamp
    local timestamp=$(date +%s)
    merged=$(echo "$merged" | jq --arg ts "$timestamp" '. + {timestamp: $ts}')

    # Build task body by replacing {{variables}}
    local task=$(echo "$template" | jq -r '.template')

    # Replace all {{var}} with actual values
    while IFS=$'\n' read -r line; do
        local key=$(echo "$line" | jq -r '.key')
        local value=$(echo "$line" | jq -r '.value')
        task=$(echo "$task" | jq --arg k "$key" --arg v "$value" 'walk(if type == "string" then gsub("{{" + $k + "}}"; $v) else . end)')
    done < <(echo "$merged" | jq -c 'to_entries[]')

    # Show what we're sending
    echo -e "${YELLOW}Task Details:${NC}"
    echo "$task" | jq '.'
    echo ""

    # Extract target agent and bus
    local to_agent=$(echo "$task" | jq -r '.to')
    local message_bus=""

    if [[ "$to_agent" == *"maxyolo"* ]]; then
        message_bus="http://192.168.5.76:3100"
    elif [[ "$to_agent" == *"pinky"* ]]; then
        message_bus="http://192.168.5.80:3100"
    else
        message_bus="http://localhost:3100"
    fi

    # Send task
    echo -e "${BLUE}📤 Sending to $to_agent...${NC}"

    local response=$(curl -s -X POST "$message_bus/send" \
        -H "Content-Type: application/json" \
        -d "$task")

    if echo "$response" | jq -e '.success' > /dev/null 2>&1; then
        local msg_id=$(echo "$response" | jq -r '.messageId')
        echo -e "${GREEN}✅ Task sent successfully!${NC}"
        echo -e "   Message ID: $msg_id"
        echo -e "   Check status: pinky inbox"
    else
        echo -e "${RED}❌ Failed to send task${NC}"
        echo "$response" | jq
    fi
}

# Main
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi

    local command=$1
    shift

    case $command in
        list|l)
            cmd_list "$@"
            ;;
        show|s)
            cmd_show "$@"
            ;;
        run|r)
            cmd_run "$@"
            ;;
        --help|-h|help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            usage
            exit 1
            ;;
    esac
}

main "$@"
