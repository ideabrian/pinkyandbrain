#!/bin/bash

# Workflow Example 3: Autonomous Task Chain
# Task automatically triggers next task on completion

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Workflow 3: Autonomous Task Chain                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

CHAIN_ID="chain-$(date +%s)"

echo "🔗 Chain ID: $CHAIN_ID"
echo "   This workflow demonstrates autonomous task handoff"
echo ""

# Step 1: Analysis (maxyolo)
echo "📤 Step 1: Code analysis on maxyolo..."
curl -s -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": \"orchestrator\",
    \"to\": \"maxyolo-claude\",
    \"type\": \"task\",
    \"subject\": \"Analyze Codebase\",
    \"body\": \"Analyze the project structure and identify files that need testing. Send a task to pinky-claude with the list of test files to create.\",
    \"priority\": \"normal\",
    \"metadata\": {
      \"task_id\": \"$CHAIN_ID-step1-analyze\",
      \"chain_id\": \"$CHAIN_ID\",
      \"next_task\": {
        \"to\": \"pinky-claude\",
        \"subject\": \"Create Tests\",
        \"body\": \"Based on analysis, create unit tests for: [PLACEHOLDER - maxyolo will fill this]\"
      },
      \"auto_execute\": false
    }
  }" > /dev/null

echo ""
echo "✅ Autonomous chain started!"
echo "   Expected flow:"
echo "   1. maxyolo-claude analyzes code"
echo "   2. maxyolo-claude sends task to pinky-claude"
echo "   3. pinky-claude creates tests"
echo "   4. pinky-claude reports completion"
echo ""
echo "Monitor the chain:"
echo "  curl http://localhost:3100/inbox | jq '.messages[] | select(.metadata.chain_id == \"$CHAIN_ID\")'"
