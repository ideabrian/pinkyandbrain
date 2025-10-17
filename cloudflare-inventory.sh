#!/bin/bash

# cloudflare-inventory.sh - Complete inventory of all Cloudflare Workers and Pages
# Generates a JSON report of all deployments

set -e

ACCOUNT_ID="9f2fcf619e8e9758a4b7e95c878dd49c"
OUTPUT_FILE="cloudflare-inventory.json"

echo "🔍 Scanning Cloudflare account: $ACCOUNT_ID"
echo ""

# Get API token from wrangler config
CONFIG_FILE="$HOME/.wrangler/config/default.toml"
if [ -f "$CONFIG_FILE" ]; then
    echo "✓ Found wrangler config"
else
    echo "⚠ No wrangler config found, authentication may fail"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 CLOUDFLARE PAGES PROJECTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get all Pages projects
wrangler pages project list --format json > /tmp/cf-pages.json 2>/dev/null || echo "[]" > /tmp/cf-pages.json

PAGES_COUNT=$(cat /tmp/cf-pages.json | jq '. | length' 2>/dev/null || echo "0")
echo "Total Pages Projects: $PAGES_COUNT"
echo ""

# Display top 10 most recently updated
echo "Most Recent Pages Projects:"
cat /tmp/cf-pages.json | jq -r '.[] | "\(.name) - \(.domains[0]) - Updated: \(.last_modified)"' 2>/dev/null | head -10

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  CLOUDFLARE WORKERS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find all local worker projects
echo "Local Worker Projects:"
WORKERS=()

# Check known workers
if [ -f ~/pinkyandbrain/cloudflare-message-bus/wrangler.toml ]; then
    WORKERS+=("pinky-brain-hub")
    echo "  ✓ pinky-brain-hub (Message Bus)"
fi

if [ -f ~/pinkyandbrain/funjobs-ai/wrangler.toml ]; then
    WORKERS+=("funjobs-ai")
    echo "  ✓ funjobs-ai (Job Board API)"
fi

echo ""
echo "Total Local Workers: ${#WORKERS[@]}"

# Create comprehensive JSON report
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Generating Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat > "$OUTPUT_FILE" <<EOF
{
  "account_id": "$ACCOUNT_ID",
  "generated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "pages": {
    "count": $PAGES_COUNT,
    "projects": $(cat /tmp/cf-pages.json)
  },
  "workers": {
    "count": ${#WORKERS[@]},
    "projects": [
      {
        "name": "pinky-brain-hub",
        "description": "Cloud message bus for Pinky & Brain cluster",
        "url": "https://pinky-brain-hub.b-9f2.workers.dev",
        "local_path": "~/pinkyandbrain/cloudflare-message-bus",
        "features": ["D1 Database", "Message Queue", "Knowledge Base", "Voting System"]
      },
      {
        "name": "funjobs-ai",
        "description": "AI-powered job board API",
        "url": "https://funjobs-ai.b-9f2.workers.dev",
        "local_path": "~/pinkyandbrain/funjobs-ai",
        "features": ["D1 Database", "R2 Storage", "Cloudflare AI", "Image Upload", "Job Scraping"]
      }
    ]
  },
  "summary": {
    "total_deployments": $(($PAGES_COUNT + ${#WORKERS[@]})),
    "pages_projects": $PAGES_COUNT,
    "workers_projects": ${#WORKERS[@]}
  }
}
EOF

echo "✓ Report generated: $OUTPUT_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total Deployments: $(($PAGES_COUNT + ${#WORKERS[@]}))"
echo "  📄 Pages: $PAGES_COUNT projects"
echo "  ⚙️  Workers: ${#WORKERS[@]} projects"
echo ""
echo "View full report: cat $OUTPUT_FILE | jq ."
echo ""

# Cleanup
rm -f /tmp/cf-pages.json
