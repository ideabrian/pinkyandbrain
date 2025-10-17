#!/bin/bash
# vote-simple.sh - Democratic voting system for Pinky and Brain cluster
# Usage:
#   ./vote-simple.sh propose "Question text" [duration_hours]
#   ./vote-simple.sh list
#   ./vote-simple.sh vote <vote_id> <yes|no|abstain>
#   ./vote-simple.sh results <vote_id>
#   ./vote-simple.sh close <vote_id>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOTES_DIR="$SCRIPT_DIR/votes"
LOCAL_BUS="http://localhost:3100"
CLOUD_BUS="https://pinky-brain-hub.b-9f2.workers.dev"
MACHINE_NAME=$(hostname -s)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Ensure votes directory exists
mkdir -p "$VOTES_DIR"

# Generate unique vote ID
generate_vote_id() {
    echo "vote-$(date +%s)-$(openssl rand -hex 4)"
}

# Propose a new vote
propose_vote() {
    local question="$1"
    local duration_hours="${2:-24}" # Default 24 hours
    local vote_id=$(generate_vote_id)
    local expires_at=$(date -u -v+${duration_hours}H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "+${duration_hours} hours" +"%Y-%m-%dT%H:%M:%SZ")
    local created_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Create vote file
    cat > "$VOTES_DIR/$vote_id.json" <<EOF
{
  "id": "$vote_id",
  "question": "$question",
  "proposedBy": "$MACHINE_NAME",
  "createdAt": "$created_at",
  "expiresAt": "$expires_at",
  "status": "active",
  "votes": {},
  "threshold": "majority"
}
EOF

    echo -e "${GREEN}✓${NC} Vote created: ${BOLD}$vote_id${NC}"
    echo -e "${CYAN}Question:${NC} $question"
    echo -e "${YELLOW}Expires:${NC} $expires_at (${duration_hours}h from now)"
    echo

    # Send notification to all machines via message bus
    local message_data=$(cat <<EOF
{
  "from": "$MACHINE_NAME",
  "to": "all",
  "type": "vote-proposed",
  "data": {
    "voteId": "$vote_id",
    "question": "$question",
    "proposedBy": "$MACHINE_NAME",
    "expiresAt": "$expires_at"
  },
  "timestamp": "$created_at"
}
EOF
)

    # Send to local and cloud buses
    curl -s -X POST "$LOCAL_BUS/send" \
        -H "Content-Type: application/json" \
        -d "$message_data" > /dev/null || true

    curl -s -X POST "$CLOUD_BUS/send" \
        -H "Content-Type: application/json" \
        -d "$message_data" > /dev/null || true

    echo -e "${BLUE}Notify all machines to vote with:${NC}"
    echo -e "  ${BOLD}./vote-simple.sh vote $vote_id <yes|no|abstain>${NC}"
    echo
}

# List all votes
list_votes() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}   Active Votes${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo

    local found_active=false
    local found_closed=false
    local active_votes=()
    local closed_votes=()

    for vote_file in "$VOTES_DIR"/*.json; do
        if [ ! -f "$vote_file" ]; then
            continue
        fi

        local status=$(jq -r '.status' "$vote_file")
        if [ "$status" = "active" ]; then
            found_active=true
            active_votes+=("$vote_file")
        else
            closed_votes+=("$vote_file")
        fi
    done

    if [ "$found_active" = false ]; then
        echo -e "${YELLOW}No active votes${NC}"
        echo
    else
        for vote_file in "${active_votes[@]}"; do
            display_vote "$vote_file"
        done
    fi

    # Show closed votes if any
    if [ ${#closed_votes[@]} -gt 0 ]; then
        echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}${BLUE}   Recently Closed${NC}"
        echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        for vote_file in "${closed_votes[@]}"; do
            display_vote "$vote_file"
        done
    fi
}

# Display a single vote
display_vote() {
    local vote_file="$1"
    local vote_id=$(jq -r '.id' "$vote_file")
    local question=$(jq -r '.question' "$vote_file")
    local proposed_by=$(jq -r '.proposedBy' "$vote_file")
    local status=$(jq -r '.status' "$vote_file")
    local expires_at=$(jq -r '.expiresAt' "$vote_file")

    # Count votes
    local yes_count=$(jq -r '[.votes | to_entries[] | select(.value == "yes")] | length' "$vote_file")
    local no_count=$(jq -r '[.votes | to_entries[] | select(.value == "no")] | length' "$vote_file")
    local abstain_count=$(jq -r '[.votes | to_entries[] | select(.value == "abstain")] | length' "$vote_file")
    local total_votes=$((yes_count + no_count + abstain_count))

    # Status color
    local status_color=$GREEN
    if [ "$status" = "closed" ]; then
        status_color=$PURPLE
    fi

    echo -e "${BOLD}Vote ID:${NC} $vote_id"
    echo -e "${BOLD}Question:${NC} $question"
    echo -e "${BOLD}Proposed by:${NC} $proposed_by"
    echo -e "${BOLD}Status:${NC} ${status_color}$status${NC}"
    echo -e "${BOLD}Expires:${NC} $expires_at"
    echo -e "${BOLD}Votes:${NC} ${GREEN}Yes: $yes_count${NC} | ${RED}No: $no_count${NC} | ${YELLOW}Abstain: $abstain_count${NC} (Total: $total_votes)"

    # Show who voted what
    if [ $total_votes -gt 0 ]; then
        echo -e "${BOLD}Ballots:${NC}"
        jq -r '.votes | to_entries[] | "  \(.key): \(.value)"' "$vote_file" | while read -r line; do
            echo -e "  $line"
        done
    fi

    echo
}

# Cast a vote
cast_vote() {
    local vote_id="$1"
    local choice="$2"
    local vote_file="$VOTES_DIR/$vote_id.json"

    if [ ! -f "$vote_file" ]; then
        echo -e "${RED}✗${NC} Vote not found: $vote_id"
        exit 1
    fi

    # Check if vote is still active
    local status=$(jq -r '.status' "$vote_file")
    if [ "$status" != "active" ]; then
        echo -e "${RED}✗${NC} Vote is closed"
        exit 1
    fi

    # Validate choice
    if [[ ! "$choice" =~ ^(yes|no|abstain)$ ]]; then
        echo -e "${RED}✗${NC} Invalid choice. Must be: yes, no, or abstain"
        exit 1
    fi

    # Update vote
    local tmp_file=$(mktemp)
    jq --arg machine "$MACHINE_NAME" --arg choice "$choice" \
        '.votes[$machine] = $choice' "$vote_file" > "$tmp_file"
    mv "$tmp_file" "$vote_file"

    echo -e "${GREEN}✓${NC} Vote recorded: ${BOLD}$MACHINE_NAME${NC} → ${BOLD}$choice${NC}"

    # Send notification
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local message_data=$(cat <<EOF
{
  "from": "$MACHINE_NAME",
  "to": "all",
  "type": "vote-cast",
  "data": {
    "voteId": "$vote_id",
    "machine": "$MACHINE_NAME",
    "choice": "$choice"
  },
  "timestamp": "$timestamp"
}
EOF
)

    curl -s -X POST "$LOCAL_BUS/send" \
        -H "Content-Type: application/json" \
        -d "$message_data" > /dev/null || true

    curl -s -X POST "$CLOUD_BUS/send" \
        -H "Content-Type: application/json" \
        -d "$message_data" > /dev/null || true

    echo
    results "$vote_id"
}

# Show vote results
results() {
    local vote_id="$1"
    local vote_file="$VOTES_DIR/$vote_id.json"

    if [ ! -f "$vote_file" ]; then
        echo -e "${RED}✗${NC} Vote not found: $vote_id"
        exit 1
    fi

    display_vote "$vote_file"

    # Calculate result
    local yes_count=$(jq -r '[.votes | to_entries[] | select(.value == "yes")] | length' "$vote_file")
    local no_count=$(jq -r '[.votes | to_entries[] | select(.value == "no")] | length' "$vote_file")
    local total_votes=$((yes_count + no_count))

    if [ $total_votes -gt 0 ]; then
        if [ $yes_count -gt $no_count ]; then
            echo -e "${GREEN}${BOLD}Result: PASSING${NC} ($yes_count yes vs $no_count no)"
        elif [ $no_count -gt $yes_count ]; then
            echo -e "${RED}${BOLD}Result: FAILING${NC} ($no_count no vs $yes_count yes)"
        else
            echo -e "${YELLOW}${BOLD}Result: TIED${NC} ($yes_count yes vs $no_count no)"
        fi
    else
        echo -e "${YELLOW}${BOLD}Result: NO VOTES YET${NC}"
    fi
    echo
}

# Close a vote
close_vote() {
    local vote_id="$1"
    local vote_file="$VOTES_DIR/$vote_id.json"

    if [ ! -f "$vote_file" ]; then
        echo -e "${RED}✗${NC} Vote not found: $vote_id"
        exit 1
    fi

    # Update status
    local tmp_file=$(mktemp)
    jq '.status = "closed"' "$vote_file" > "$tmp_file"
    mv "$tmp_file" "$vote_file"

    echo -e "${GREEN}✓${NC} Vote closed: $vote_id"
    echo

    results "$vote_id"

    # Send notification
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local message_data=$(cat <<EOF
{
  "from": "$MACHINE_NAME",
  "to": "all",
  "type": "vote-closed",
  "data": {
    "voteId": "$vote_id",
    "closedBy": "$MACHINE_NAME"
  },
  "timestamp": "$timestamp"
}
EOF
)

    curl -s -X POST "$LOCAL_BUS/send" \
        -H "Content-Type: application/json" \
        -d "$message_data" > /dev/null || true

    curl -s -X POST "$CLOUD_BUS/send" \
        -H "Content-Type: application/json" \
        -d "$message_data" > /dev/null || true
}

# Main command router
case "${1:-}" in
    propose)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 propose \"Question text\" [duration_hours]"
            exit 1
        fi
        propose_vote "$2" "${3:-24}"
        ;;
    list)
        list_votes
        ;;
    vote)
        if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
            echo "Usage: $0 vote <vote_id> <yes|no|abstain>"
            exit 1
        fi
        cast_vote "$2" "$3"
        ;;
    results)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 results <vote_id>"
            exit 1
        fi
        results "$2"
        ;;
    close)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 close <vote_id>"
            exit 1
        fi
        close_vote "$2"
        ;;
    *)
        echo "Pinky and Brain Voting System"
        echo
        echo "Usage:"
        echo "  $0 propose \"Question text\" [duration_hours]  - Create a new vote"
        echo "  $0 list                                       - List all votes"
        echo "  $0 vote <vote_id> <yes|no|abstain>           - Cast your vote"
        echo "  $0 results <vote_id>                         - Show vote results"
        echo "  $0 close <vote_id>                           - Close a vote"
        echo
        echo "Examples:"
        echo "  $0 propose \"Should we deploy the new feature?\" 48"
        echo "  $0 list"
        echo "  $0 vote vote-1234567890-abcd1234 yes"
        echo "  $0 results vote-1234567890-abcd1234"
        exit 1
        ;;
esac
