#!/bin/bash
#
# vote-simple.sh - Simple file-based voting until API is ready
#
# Usage:
#   ./vote-simple.sh propose "Question?" "option1,option2"
#   ./vote-simple.sh list
#   ./vote-simple.sh vote VOTE_ID option
#   ./vote-simple.sh results VOTE_ID

set -e

VOTES_DIR="$HOME/pinkyandbrain/votes"
mkdir -p "$VOTES_DIR"
MACHINE=$(hostname | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CMD=${1:-help}

case "$CMD" in
  propose)
    QUESTION=${2:-""}
    OPTIONS=${3:-"yes,no"}

    if [ -z "$QUESTION" ]; then
      echo -e "${YELLOW}Usage: $0 propose \"Question?\" \"option1,option2\"${NC}"
      exit 1
    fi

    VOTE_ID="vote-$(date +%s)"
    VOTE_FILE="$VOTES_DIR/$VOTE_ID.txt"

    cat > "$VOTE_FILE" <<EOF
QUESTION: $QUESTION
OPTIONS: $OPTIONS
PROPOSED_BY: $MACHINE
PROPOSED_AT: $(date)
STATUS: open

--- VOTES ---
EOF

    echo -e "${GREEN}✓ Vote created!${NC}"
    echo -e "  ID: $VOTE_ID"
    echo -e "  Question: $QUESTION"
    echo -e "  Options: $OPTIONS"
    echo ""
    echo -e "${BLUE}Team members can vote with:${NC}"
    echo -e "  ./vote-simple.sh vote $VOTE_ID <option>"
    ;;

  list)
    echo -e "${CYAN}Active votes:${NC}"
    echo ""

    COUNT=0
    for VOTE_FILE in "$VOTES_DIR"/vote-*.txt; do
      if [ -f "$VOTE_FILE" ]; then
        COUNT=$((COUNT + 1))
        VOTE_ID=$(basename "$VOTE_FILE" .txt)
        QUESTION=$(grep "^QUESTION:" "$VOTE_FILE" | cut -d: -f2-)
        STATUS=$(grep "^STATUS:" "$VOTE_FILE" | cut -d: -f2- | xargs)

        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "🗳️  ${QUESTION}"
        echo -e "   ID: $VOTE_ID"
        echo -e "   Status: $STATUS"
        echo ""
      fi
    done

    if [ $COUNT -eq 0 ]; then
      echo -e "${YELLOW}No votes found!${NC}"
    fi
    ;;

  vote)
    VOTE_ID=${2:-""}
    CHOICE=${3:-""}

    if [ -z "$VOTE_ID" ] || [ -z "$CHOICE" ]; then
      echo -e "${YELLOW}Usage: $0 vote VOTE_ID choice${NC}"
      exit 1
    fi

    VOTE_FILE="$VOTES_DIR/$VOTE_ID.txt"

    if [ ! -f "$VOTE_FILE" ]; then
      echo -e "${YELLOW}Vote not found: $VOTE_ID${NC}"
      exit 1
    fi

    # Check if already voted
    if grep -q "^$MACHINE:" "$VOTE_FILE" 2>/dev/null; then
      echo -e "${YELLOW}You already voted! Updating your vote...${NC}"
      # Remove old vote
      sed -i.bak "/^$MACHINE:/d" "$VOTE_FILE"
    fi

    # Add vote
    echo "$MACHINE: $CHOICE ($(date '+%Y-%m-%d %H:%M'))" >> "$VOTE_FILE"

    echo -e "${GREEN}✓ Vote recorded!${NC}"
    echo -e "  Machine: $MACHINE"
    echo -e "  Choice: $CHOICE"
    ;;

  results)
    VOTE_ID=${2:-""}

    if [ -z "$VOTE_ID" ]; then
      echo -e "${YELLOW}Usage: $0 results VOTE_ID${NC}"
      exit 1
    fi

    VOTE_FILE="$VOTES_DIR/$VOTE_ID.txt"

    if [ ! -f "$VOTE_FILE" ]; then
      echo -e "${YELLOW}Vote not found: $VOTE_ID${NC}"
      exit 1
    fi

    QUESTION=$(grep "^QUESTION:" "$VOTE_FILE" | cut -d: -f2-)
    OPTIONS=$(grep "^OPTIONS:" "$VOTE_FILE" | cut -d: -f2-)

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}           VOTE RESULTS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Question:${NC}${QUESTION}"
    echo ""
    echo -e "${GREEN}Votes:${NC}"

    # Show all votes
    sed -n '/^--- VOTES ---$/,$p' "$VOTE_FILE" | tail -n +2 | while read -r line; do
      if [ -n "$line" ]; then
        echo "  $line"
      fi
    done

    echo ""
    echo -e "${GREEN}Tally:${NC}"

    # Count votes by option
    IFS=',' read -ra OPTS <<< "$OPTIONS"
    for opt in "${OPTS[@]}"; do
      opt=$(echo "$opt" | xargs)  # trim whitespace
      count=$(sed -n '/^--- VOTES ---$/,$p' "$VOTE_FILE" | grep -c ": $opt " || echo "0")
      echo "  $opt: $count"
    done

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    ;;

  help|*)
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   Simple File-Based Voting${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC}"
    echo "  $0 propose \"Question?\" \"option1,option2\""
    echo "  $0 list"
    echo "  $0 vote VOTE_ID choice"
    echo "  $0 results VOTE_ID"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo "  $0 propose \"Create GitHub repo?\" \"yes,no,maybe-later\""
    echo "  $0 list"
    echo "  $0 vote vote-1760623000 yes"
    echo "  $0 results vote-1760623000"
    echo ""
    echo -e "${YELLOW}Votes stored in: $VOTES_DIR${NC}"
    ;;
esac
