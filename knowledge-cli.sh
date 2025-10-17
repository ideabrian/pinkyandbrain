#!/bin/bash

# knowledge-cli.sh - CLI tool for team knowledge sharing
#
# Usage:
#   ./knowledge-cli.sh share "Topic" "Title" "What you learned"
#   ./knowledge-cli.sh search "keyword"
#   ./knowledge-cli.sh recent
#   ./knowledge-cli.sh helpful knowledge-123

set -e

# Configuration
CLOUD_BUS="${CLOUD_BUS_URL:-https://pinky-brain-hub.b-9f2.workers.dev}"
API_KEY="${CLOUD_API_KEY:-3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5}"
MACHINE=$(hostname | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Commands
CMD=${1:-help}

case "$CMD" in
  share)
    # Share knowledge
    TOPIC=${2:-"General"}
    TITLE=${3:-""}
    LEARNING=${4:-""}
    CODE_EXAMPLE=${5:-""}
    CATEGORY=${6:-"best-practice"}
    TAGS=${7:-""}

    if [ -z "$TITLE" ] || [ -z "$LEARNING" ]; then
      echo -e "${YELLOW}Usage: $0 share TOPIC TITLE LEARNING [CODE_EXAMPLE] [CATEGORY] [TAGS]${NC}"
      echo ""
      echo "Example:"
      echo "  $0 share \"React\" \"useState pattern\" \"Use for simple state\" \"const [x,setX]=useState(0)\" \"best-practice\" \"react,hooks\""
      exit 1
    fi

    echo -e "${CYAN}Sharing knowledge with team...${NC}"

    # Use jq to properly escape JSON
    JSON_PAYLOAD=$(jq -n \
      --arg machine "$MACHINE" \
      --arg topic "$TOPIC" \
      --arg category "$CATEGORY" \
      --arg title "$TITLE" \
      --arg learning "$LEARNING" \
      --arg code "$CODE_EXAMPLE" \
      --arg tags "$TAGS" \
      '{from_machine: $machine, topic: $topic, category: $category, title: $title, learning: $learning, code_example: $code, tags: $tags}')

    RESPONSE=$(curl -s -X POST "$CLOUD_BUS/knowledge" \
      -H "Content-Type: application/json" \
      -H "X-API-Key: $API_KEY" \
      -d "$JSON_PAYLOAD")

    SUCCESS=$(echo "$RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")

    if [ "$SUCCESS" = "true" ]; then
      KNOWLEDGE_ID=$(echo "$RESPONSE" | jq -r '.knowledgeId')
      echo -e "${GREEN}✓ Knowledge shared!${NC}"
      echo -e "  ID: $KNOWLEDGE_ID"
      echo -e "  From: $MACHINE"
      echo -e "  Topic: $TOPIC"
      echo -e "${BLUE}Your team can now search for this learning!${NC}"
    else
      echo -e "${YELLOW}Error sharing knowledge:${NC}"
      echo "$RESPONSE" | jq '.'
    fi
    ;;

  search)
    # Search knowledge base
    QUERY=${2:-""}

    if [ -z "$QUERY" ]; then
      echo -e "${YELLOW}Usage: $0 search KEYWORD${NC}"
      exit 1
    fi

    echo -e "${CYAN}Searching knowledge base for: $QUERY${NC}"
    echo ""

    RESPONSE=$(curl -s "$CLOUD_BUS/knowledge/search?q=$QUERY" \
      -H "X-API-Key: $API_KEY")

    RESULTS=$(echo "$RESPONSE" | jq -r '.results' 2>/dev/null || echo "0")

    if [ "$RESULTS" = "0" ]; then
      echo -e "${YELLOW}No knowledge found for: $QUERY${NC}"
    else
      echo -e "${GREEN}Found $RESULTS result(s):${NC}"
      echo ""
      echo "$RESPONSE" | jq -r '.knowledge[] | "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n📚 \(.title)\n   Topic: \(.topic) | Category: \(.category)\n   From: \(.from_machine) | Helpful: \(.helpful_count)\n\n   \(.learning)\n\n" + if .code_example != null and .code_example != "" then "   Code:\n   \(.code_example)\n" else "" end'
    fi
    ;;

  recent)
    # Get recent learnings
    LIMIT=${2:-10}

    echo -e "${CYAN}Recent team learnings:${NC}"
    echo ""

    RESPONSE=$(curl -s "$CLOUD_BUS/knowledge/recent?limit=$LIMIT" \
      -H "X-API-Key: $API_KEY")

    TOTAL=$(echo "$RESPONSE" | jq -r '.total' 2>/dev/null || echo "0")

    if [ "$TOTAL" = "0" ]; then
      echo -e "${YELLOW}No knowledge shared yet!${NC}"
      echo "Be the first: $0 share \"Topic\" \"Title\" \"What you learned\""
    else
      echo -e "${GREEN}Latest $TOTAL learnings:${NC}"
      echo ""
      echo "$RESPONSE" | jq -r '.knowledge[] | "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n📚 \(.title)\n   Topic: \(.topic) | From: \(.from_machine) | Helpful: \(.helpful_count)\n\n   \(.learning)\n\n" + if .code_example != null and .code_example != "" then "   Code:\n   \(.code_example)\n" else "" end'
    fi
    ;;

  helpful)
    # Mark as helpful
    KNOWLEDGE_ID=${2:-""}

    if [ -z "$KNOWLEDGE_ID" ]; then
      echo -e "${YELLOW}Usage: $0 helpful KNOWLEDGE_ID${NC}"
      exit 1
    fi

    RESPONSE=$(curl -s -X POST "$CLOUD_BUS/knowledge/$KNOWLEDGE_ID/helpful" \
      -H "X-API-Key: $API_KEY")

    SUCCESS=$(echo "$RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")

    if [ "$SUCCESS" = "true" ]; then
      echo -e "${GREEN}✓ Marked as helpful!${NC}"
    else
      echo -e "${YELLOW}Error:${NC}"
      echo "$RESPONSE" | jq '.'
    fi
    ;;

  get)
    # Get specific knowledge
    KNOWLEDGE_ID=${2:-""}

    if [ -z "$KNOWLEDGE_ID" ]; then
      echo -e "${YELLOW}Usage: $0 get KNOWLEDGE_ID${NC}"
      exit 1
    fi

    RESPONSE=$(curl -s "$CLOUD_BUS/knowledge/$KNOWLEDGE_ID" \
      -H "X-API-Key: $API_KEY")

    ERROR=$(echo "$RESPONSE" | jq -r '.error' 2>/dev/null || echo "null")

    if [ "$ERROR" != "null" ]; then
      echo -e "${YELLOW}Knowledge not found: $KNOWLEDGE_ID${NC}"
    else
      echo -e "${GREEN}Knowledge Details:${NC}"
      echo ""
      echo "$RESPONSE" | jq -r '"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n📚 \(.title)\n\nTopic: \(.topic)\nCategory: \(.category)\nFrom: \(.from_machine)\nHelpful: \(.helpful_count)\nTags: \(.tags)\n\nLearning:\n\(.learning)\n\n" + if .code_example != null and .code_example != "" then "Code Example:\n\(.code_example)\n" else "" end'
    fi
    ;;

  help|*)
    # Show help
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   Team Knowledge Sharing CLI${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Usage:${NC}"
    echo "  $0 share TOPIC TITLE LEARNING [CODE] [CATEGORY] [TAGS]"
    echo "  $0 search KEYWORD"
    echo "  $0 recent [LIMIT]"
    echo "  $0 get KNOWLEDGE_ID"
    echo "  $0 helpful KNOWLEDGE_ID"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo ""
    echo -e "${CYAN}Share knowledge:${NC}"
    echo "  $0 share \"React\" \"useState pattern\" \"Use for simple state\""
    echo "  $0 share \"TypeScript\" \"Type guards\" \"Use 'typeof' for primitives\" \"if(typeof x === 'string')\" \"pattern\" \"ts,types\""
    echo ""
    echo -e "${CYAN}Search:${NC}"
    echo "  $0 search useState"
    echo "  $0 search \"type guards\""
    echo ""
    echo -e "${CYAN}Recent:${NC}"
    echo "  $0 recent       # Last 10"
    echo "  $0 recent 5     # Last 5"
    echo ""
    echo -e "${CYAN}Mark helpful:${NC}"
    echo "  $0 helpful knowledge-1760578901473"
    echo ""
    echo -e "${YELLOW}Cloud: $CLOUD_BUS${NC}"
    ;;
esac
