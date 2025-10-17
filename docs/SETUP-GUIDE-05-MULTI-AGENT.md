# Setup Guide 05: Multi-Agent Claude Code Communication

**Goal**: Run multiple Claude Code sessions that can talk to each other across machines

## What You'll Build

A system where:
- Multiple Claude Code sessions run simultaneously (on different machines)
- Each agent has its own "inbox" for receiving messages
- Agents can send messages to each other via HTTP
- An orchestrator script launches everything with one command

**Real-world analogy**: Like Slack, but for your AI assistants. One Claude on your laptop can ask another Claude on your Mac mini to run a task.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│  maxyolo (laptop)                                           │
│  ┌─────────────────┐        ┌──────────────────┐          │
│  │ Claude Code     │───────▶│ Message Bus      │          │
│  │ maxyolo-claude  │        │ localhost:3100   │          │
│  └─────────────────┘        └──────────────────┘          │
└───────────────────────────────────┬─────────────────────────┘
                                    │
                                    │ HTTP Messages
                                    │
┌───────────────────────────────────┴─────────────────────────┐
│  pinky (Mac mini)                                           │
│  ┌─────────────────┐        ┌──────────────────┐          │
│  │ Claude Code     │───────▶│ Message Bus      │          │
│  │ pinky-claude    │        │ 192.168.5.80:3100│          │
│  └─────────────────┘        └──────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

**How it works:**
1. Each machine runs a **message bus** server (HTTP API on port 3100)
2. Each machine runs a **Claude Code session**
3. Claude can send HTTP requests to post/read messages
4. Messages are stored in JSON files on each machine

## Prerequisites

Before starting, you need:
- ✅ SSH access between machines (SETUP-GUIDE-01-SSH.md)
- ✅ Node.js installed on all machines (SETUP-GUIDE-04-CLAUDE-CODE.md)
- ✅ `run-on-all.sh` script working (SETUP-GUIDE-03-ORCHESTRATION.md)

## Step 1: Understanding the Message Bus

The message bus is a simple HTTP server with these endpoints:

### API Reference

**POST /send** - Send a message
```bash
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "maxyolo-claude",
    "to": "pinky-claude",
    "subject": "Task Request",
    "body": "Run tests on the API",
    "priority": "high"
  }'
```

**GET /inbox** - Check all messages
```bash
curl http://localhost:3100/inbox | jq
```

**GET /inbox/unread** - Check only unread messages
```bash
curl http://localhost:3100/inbox/unread | jq
```

**POST /inbox/:id/read** - Mark message as read
```bash
curl -X POST http://localhost:3100/inbox/MESSAGE_ID/read
```

**GET /health** - Check if server is running
```bash
curl http://localhost:3100/health
```

**Response format:**
```json
{
  "machine": "maxyolo",
  "total": 5,
  "unread": 2,
  "messages": [
    {
      "id": "1729012345-abc123",
      "from": "maxyolo-claude",
      "to": "pinky-claude",
      "subject": "Task Request",
      "body": "Run tests on the API",
      "priority": "high",
      "timestamp": "2024-10-15T10:30:00.000Z",
      "read": false,
      "replyCount": 0
    }
  ]
}
```

## Step 2: The Message Bus Code

The message bus is implemented in `claude-messenger.js`:

**Key features:**
- Express.js HTTP server on port 3100
- Messages stored in `inbox-{hostname}.json` files
- Each machine maintains its own inbox
- Messages persist across restarts

**File location:** `/Users/maxyolo/Documents/projects/pinkyandbrain/claude-messenger.js`

**How it works:**
1. Loads existing messages from disk on startup
2. Accepts POST requests to `/send` endpoint
3. Stores messages in memory + writes to disk
4. Returns messages via `/inbox` endpoint

**Why port 3100?**
- Ports 1-1023: System/well-known services (HTTP=80, SSH=22)
- Ports 1024-49151: Registered/user services
- Port 3100: Arbitrary choice, not commonly used

## Step 3: Deploy Message Bus to All Machines

**Install dependencies everywhere:**
```bash
# On maxyolo
cd ~/Documents/projects/pinkyandbrain
npm install express

# On pinky (via SSH)
ssh pinky "cd ~ && npm install express"
```

**Copy message bus to pinky:**
```bash
scp claude-messenger.js pinky:~/claude-messenger.js
```

**Verify it's there:**
```bash
ssh pinky "ls -lh ~/claude-messenger.js"
```

## Step 4: Test Message Bus Manually

**Start on maxyolo:**
```bash
cd ~/Documents/projects/pinkyandbrain
node claude-messenger.js &
```

**Start on pinky:**
```bash
ssh pinky "node ~/claude-messenger.js > ~/messenger.log 2>&1 &"
```

**Test health check:**
```bash
# Local
curl http://localhost:3100/health

# Remote
curl http://192.168.5.80:3100/health
```

**Expected output:**
```json
{
  "status": "ok",
  "machine": "maxyolo",
  "messages": 0,
  "timestamp": "2024-10-15T10:30:00.000Z"
}
```

## Step 5: Test Cross-Machine Messaging

**Send message from maxyolo to pinky:**
```bash
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "maxyolo",
    "to": "pinky",
    "body": "Hello from maxyolo!"
  }'
```

**Check inbox on pinky:**
```bash
curl http://192.168.5.80:3100/inbox | jq
```

**Expected response:**
```json
{
  "machine": "pinky",
  "total": 1,
  "unread": 1,
  "messages": [
    {
      "id": "...",
      "from": "maxyolo",
      "to": "pinky",
      "body": "Hello from maxyolo!",
      "timestamp": "...",
      "read": false
    }
  ]
}
```

## Step 6: The Orchestrator Script

The orchestrator (`orchestrator.sh`) automates everything:

**What it does:**
1. Checks if message bus is running on each machine
2. Starts message bus if needed
3. Opens iTerm windows with Claude Code sessions
4. Provides example commands in each terminal

**Usage:**
```bash
cd ~/Documents/projects/pinkyandbrain
./orchestrator.sh
```

**What you'll see:**
1. Two new iTerm windows open
2. One window: `maxyolo-claude` (local Claude session)
3. One window: `pinky-claude` (SSH to pinky, then Claude)
4. Each window shows commands for messaging the other agent

**How osascript works:**
The script uses AppleScript to control iTerm:
```applescript
tell application "iTerm"
    create window with default profile
    tell current session of current window
        write text "ssh pinky"
        write text "claude"
    end tell
end tell
```

This programmatically opens terminals and runs commands - automation at the OS level!

## Step 7: Multi-Agent Communication Examples

### Example 1: Parallel Development

**Scenario:** Build frontend on maxyolo, backend on pinky simultaneously

**In maxyolo-claude terminal:**
```
I'm working on a dashboard UI. Can you build a React component for displaying user metrics?
```

**In pinky-claude terminal:**
```
I need an Express API endpoint that serves user metrics. Can you create `/api/metrics` with mock data?
```

Both work in parallel, no context switching!

### Example 2: Orchestrator → Executor Pattern

**In maxyolo-claude terminal:**
```
Send a message to pinky-claude asking them to run tests:

curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "maxyolo-claude",
    "to": "pinky-claude",
    "body": "Run npm test and report results"
  }'
```

**In pinky-claude terminal:**
```
Check my inbox for tasks:

curl http://localhost:3100/inbox/unread | jq

[See message from maxyolo-claude]

Run the tests:
npm test

[Tests complete]

Send results back:
curl -X POST http://192.168.5.76:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "pinky-claude",
    "to": "maxyolo-claude",
    "body": "Tests complete: 47 passed, 0 failed"
  }'
```

### Example 3: Distributed Build System

**In maxyolo-claude:**
```bash
# Send build tasks to both machines
curl -X POST http://192.168.5.80:3100/send \
  -d '{"from":"orchestrator","to":"pinky-claude","body":"Build the backend"}'
```

**In pinky-claude:**
```bash
# Check for tasks
curl http://localhost:3100/inbox/unread | jq

# Execute build
npm run build:backend

# Report completion
curl -X POST http://192.168.5.76:3100/send \
  -d '{"from":"pinky-claude","to":"orchestrator","body":"Backend build complete"}'
```

## How Claude Code Uses the Message Bus

Claude Code can use bash commands, so it can:

**Send messages:**
```bash
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"maxyolo-claude","to":"pinky-claude","body":"Start the server"}'
```

**Check inbox:**
```bash
curl http://localhost:3100/inbox/unread | jq '.messages[] | .body'
```

**Process messages programmatically:**
```bash
# Get unread messages, extract bodies
MESSAGES=$(curl -s http://localhost:3100/inbox/unread | jq -r '.messages[] | .body')

# Execute tasks based on message content
if echo "$MESSAGES" | grep -q "run tests"; then
  npm test
fi
```

## Troubleshooting

### Message bus not responding

**Check if it's running:**
```bash
# Local
curl http://localhost:3100/health

# Remote
curl http://192.168.5.80:3100/health
```

**If not running, check process:**
```bash
# Local
ps aux | grep claude-messenger

# Remote
ssh pinky "ps aux | grep claude-messenger"
```

**Restart if needed:**
```bash
# Kill old process
pkill -f claude-messenger

# Start fresh
node claude-messenger.js > ~/messenger.log 2>&1 &
```

### Can't reach remote message bus

**Test connectivity:**
```bash
ping 192.168.5.80
nc -zv 192.168.5.80 3100
```

**Check firewall (macOS):**
- System Settings → Network → Firewall
- Ensure Node.js is allowed to accept incoming connections

### Messages not persisting

**Check inbox file:**
```bash
# Local
cat ~/Documents/projects/pinkyandbrain/inbox-*.json | jq

# Remote
ssh pinky "cat ~/inbox-*.json | jq"
```

**If file is missing, permissions issue:**
```bash
ls -la ~/Documents/projects/pinkyandbrain/inbox-*.json
```

### iTerm windows not opening

**Test osascript manually:**
```bash
osascript <<EOF
tell application "iTerm"
    create window with default profile
end tell
EOF
```

**If fails:**
- Grant iTerm automation permissions
- System Settings → Privacy & Security → Automation
- Allow Terminal/iTerm to control iTerm

## Advanced: Automated Coordination

Create a supervisor script that coordinates multiple agents:

**supervisor.sh:**
```bash
#!/bin/bash

# Send tasks to all agents
for agent in maxyolo-claude pinky-claude; do
  MACHINE=$(echo $agent | cut -d'-' -f1)
  if [ "$MACHINE" = "maxyolo" ]; then
    BUS="http://localhost:3100"
  else
    BUS="http://192.168.5.80:3100"
  fi

  curl -X POST $BUS/send \
    -H "Content-Type: application/json" \
    -d "{
      \"from\": \"supervisor\",
      \"to\": \"$agent\",
      \"body\": \"Run health check\"
    }"
done

# Wait for responses
sleep 5

# Collect results
curl http://localhost:3100/inbox | jq '.messages[] | select(.from | contains("claude"))'
```

## The Power of Multi-Agent Systems

**What you've built:**
1. **Distributed computing** - Multiple machines, one goal
2. **Asynchronous communication** - Agents work independently
3. **Fault tolerance** - One agent down? Others keep working
4. **Scalability** - Add more agents by adding machines
5. **Real networking** - Not simulated, actual HTTP across real hardware

**Real-world parallels:**
- Microservices architecture (separate services communicating)
- Message queues (RabbitMQ, AWS SQS)
- Actor model (Akka, Erlang)
- Distributed systems (Kubernetes pods talking to each other)

**What makes this special:**
- You own the hardware (no cloud costs)
- You control the network (learn without AWS complexity)
- You can see the latency (real physical distance)
- You can experiment freely (break things, learn, rebuild)

## Next Steps

### When brain comes online:

1. **Add to network:**
```bash
# Get brain's IP
ssh brain "ipconfig getifaddr en0"

# Add to orchestrator.sh
# Add to run-on-all.sh
```

2. **Three-agent patterns:**
- **Pipeline**: maxyolo → pinky → brain (sequential processing)
- **Map-Reduce**: maxyolo coordinates, pinky+brain execute
- **Redundancy**: All three run same task, first to finish wins

### Future enhancements:

- [ ] Web dashboard showing agent status
- [ ] Message priority queue (high-priority tasks first)
- [ ] Authentication (secure message bus)
- [ ] Message encryption (TLS/HTTPS)
- [ ] Persistent task queue (survive restarts)
- [ ] Agent discovery (auto-detect machines on network)
- [ ] Load balancing (route tasks to least-busy agent)

## Philosophy

> "Three less-powerful machines working together > One powerful machine working alone"

**What you learned:**
- HTTP APIs from scratch
- Cross-machine networking
- Process automation (osascript)
- Distributed systems thinking
- Message-based architecture

**Skills that transfer:**
- Building microservices
- Designing APIs
- Understanding async communication
- Debugging network issues
- Systems thinking

---

**Status**: Complete when you can run `./orchestrator.sh` and have multiple Claude sessions talking to each other

**Achievement unlocked**: Multi-agent AI orchestration 🤖💬🤖

Built with HTTP, bash, and a lot of SSH.
