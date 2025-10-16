#!/bin/bash

# Workflow Example 2: Build Pipeline
# Coordinate build across multiple agents

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Workflow 2: Distributed Build Pipeline                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

PIPELINE_ID="build-$(date +%s)"

echo "🏗️  Pipeline ID: $PIPELINE_ID"
echo ""

# Task 1: Frontend build on maxyolo
echo "📤 Task 1: Frontend build on maxyolo..."
curl -s -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": \"orchestrator\",
    \"to\": \"maxyolo-claude\",
    \"type\": \"task\",
    \"subject\": \"Build Frontend\",
    \"body\": \"Build the React frontend with npm run build:frontend. Send results to pinky-claude when done.\",
    \"priority\": \"high\",
    \"metadata\": {
      \"task_id\": \"$PIPELINE_ID-frontend\",
      \"pipeline_id\": \"$PIPELINE_ID\",
      \"auto_execute\": false,
      \"timeout\": 600
    }
  }" > /dev/null

# Task 2: Backend build on pinky
echo "📤 Task 2: Backend build on pinky..."
curl -s -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d "{
    \"from\": \"orchestrator\",
    \"to\": \"pinky-claude\",
    \"type\": \"task\",
    \"subject\": \"Build Backend\",
    \"body\": \"Build the API backend with npm run build:backend. Wait for frontend to complete, then run integration tests.\",
    \"priority\": \"high\",
    \"metadata\": {
      \"task_id\": \"$PIPELINE_ID-backend\",
      \"pipeline_id\": \"$PIPELINE_ID\",
      \"depends_on\": [\"$PIPELINE_ID-frontend\"],
      \"auto_execute\": false,
      \"timeout\": 600
    }
  }" > /dev/null

echo ""
echo "✅ Build pipeline initiated!"
echo "   Pipeline ID: $PIPELINE_ID"
echo ""
echo "Monitor progress:"
echo "  maxyolo: curl http://localhost:3100/inbox | jq '.messages[] | select(.metadata.pipeline_id == \"$PIPELINE_ID\")'"
echo "  pinky:   curl http://localhost:3100/inbox | jq '.messages[] | select(.metadata.pipeline_id == \"$PIPELINE_ID\")'"
