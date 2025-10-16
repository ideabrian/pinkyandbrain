#!/bin/bash

# Workflow Example 1: Simple Test Task
# maxyolo sends test task to pinky, pinky executes and reports back

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Workflow 1: Simple Test Task                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Send task from maxyolo to pinky
echo "📤 Sending test task to pinky-claude..."

curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "orchestrator",
    "to": "pinky-claude",
    "type": "task",
    "subject": "Run Project Tests",
    "body": "Run npm test in the current project and report the results back to me via the message bus",
    "priority": "high",
    "metadata": {
      "task_id": "test-task-001",
      "auto_execute": false,
      "reply_to": "maxyolo-claude",
      "timeout": 300
    }
  }' | jq

echo ""
echo "✅ Task sent! Pinky-claude should see this in their inbox."
echo ""
echo "To check on pinky:"
echo "  curl http://localhost:3100/inbox/unread | jq"
