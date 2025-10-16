# Setup Guide 06: Autonomous Multi-Agent Orchestration

**Goal**: Automate task coordination between Claude Code agents using message queues

## What You're Building

A **fully autonomous task orchestration system** where:
- Tasks are sent to a message queue
- Agents poll the queue for new work
- Claude Code sessions start automatically
- Results are reported back
- Workflows chain together without human intervention

**This is the architecture behind:**
- CI/CD pipelines (GitHub Actions, CircleCI)
- Task queues (Celery, Bull, AWS SQS)
- Workflow engines (Airflow, Temporal)
- Serverless functions (AWS Lambda triggers)

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│ AUTONOMOUS WORKFLOW                                      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. Orchestrator sends task to message bus              │
│      ↓                                                   │
│  2. Poller detects new task                             │
│      ↓                                                   │
│  3. Auto-launcher starts Claude Code                    │
│      ↓                                                   │
│  4. Claude executes task                                │
│      ↓                                                   │
│  5. Session-end hook sends completion                   │
│      ↓                                                   │
│  6. Next task triggered (if chained)                    │
│      ↓                                                   │
│  7. Repeat                                              │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Components

### 1. Task Message Schema

**Location**: `task-schema.json`

Messages follow a standard format for consistency:

```json
{
  "from": "maxyolo-claude",
  "to": "pinky-claude",
  "type": "task",
  "subject": "Run Tests",
  "body": "Run npm test and report results",
  "priority": "high",
  "metadata": {
    "task_id": "test-20251015-001",
    "auto_execute": true,
    "reply_to": "maxyolo-claude",
    "timeout": 300,
    "depends_on": []
  }
}
```

**Message Types:**
- `task` - Work to be done
- `completion` - Task finished
- `error` - Task failed
- `status` - Progress update
- `command` - Control messages

**Priority Levels:**
- `low` - Background tasks
- `normal` - Default
- `high` - Important work
- `critical` - Drop everything

### 2. Session-End Hook

**Location**: `~/.claude/hooks/session-end.sh`

Automatically runs when Claude Code session ends. Sends completion message to message bus.

**What it does:**
1. Detects session completion
2. Generates task ID
3. Sends completion message
4. Optionally triggers next task

**Enable auto-chaining:**
Uncomment the remote notification section to enable automatic task handoff between agents.

### 3. Message Poller Daemon

**Location**: `message-poller.sh`

Continuously watches message bus for new tasks.

**Start the poller:**
```bash
# On maxyolo
./message-poller.sh &

# On pinky (via SSH)
ssh pinky "cd ~ && ./message-poller.sh &"
```

**Check poller status:**
```bash
# View logs
tail -f ~/poller-$(hostname -s).log

# Check if running
ps aux | grep message-poller
```

**Stop the poller:**
```bash
# Find PID
cat /tmp/poller-$(hostname -s).pid

# Kill it
kill $(cat /tmp/poller-$(hostname -s).pid)
```

**Features:**
- Polls every 5 seconds (configurable)
- Filters for auto-execute tasks
- Marks messages as read
- Sends status updates
- Logs all activity

### 4. Auto-Launcher

**Location**: `claude-auto-launcher.sh`

Launches Claude Code sessions from task messages.

**Usage:**
```bash
# Manual launch
./claude-auto-launcher.sh "Run npm test" task-123

# From poller (automatic)
# The poller calls this when auto_execute = true
```

**What it does:**
1. Receives task prompt
2. Opens new iTerm window (macOS)
3. Sets up environment
4. Shows task details
5. Launches Claude Code
6. Sends status updates

### 5. Example Workflows

**Location**: `workflows/`

Three pre-built workflows demonstrating different patterns:

#### Workflow 1: Simple Task

**File**: `workflows/01-simple-test.sh`

Send a task from orchestrator to pinky-claude:

```bash
./workflows/01-simple-test.sh
```

**Pattern**: One-shot task execution

#### Workflow 2: Build Pipeline

**File**: `workflows/02-build-pipeline.sh`

Coordinate parallel builds across machines:

```bash
./workflows/02-build-pipeline.sh
```

**Pattern**: Parallel task execution with dependencies

#### Workflow 3: Autonomous Chain

**File**: `workflows/03-autonomous-chain.sh`

Tasks automatically trigger follow-up tasks:

```bash
./workflows/03-autonomous-chain.sh
```

**Pattern**: Sequential task chaining (task A → task B → task C)

## Setup Instructions

### Step 1: Copy Session-End Hook to Pinky

```bash
# From maxyolo
scp ~/.claude/hooks/session-end.sh pinky:~/.claude/hooks/

# Make executable
ssh pinky "chmod +x ~/.claude/hooks/session-end.sh"
```

### Step 2: Deploy Poller to Both Machines

```bash
# Copy to pinky
scp message-poller.sh pinky:~/

# Make executable
ssh pinky "chmod +x ~/message-poller.sh"
```

### Step 3: Deploy Auto-Launcher

```bash
# Copy to pinky
scp claude-auto-launcher.sh pinky:~/

# Make executable
ssh pinky "chmod +x ~/claude-auto-launcher.sh"
```

### Step 4: Start Pollers (Optional)

```bash
# On maxyolo
./message-poller.sh > /dev/null 2>&1 &

# On pinky
ssh pinky "~/message-poller.sh > /dev/null 2>&1 &"
```

**Note**: Pollers are optional. You can run workflows manually without them.

## Usage Patterns

### Pattern 1: Manual Task Assignment

**Scenario**: You want to delegate a task to pinky-claude

```bash
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "you",
    "to": "pinky-claude",
    "type": "task",
    "subject": "Build API",
    "body": "Create Express API endpoints for user management",
    "priority": "high",
    "metadata": {
      "task_id": "api-build-001",
      "auto_execute": false
    }
  }'
```

**Then on pinky:**
1. Check inbox: `curl http://localhost:3100/inbox | jq`
2. Start Claude
3. Execute the task
4. Session-end hook reports completion

### Pattern 2: Automated Execution

**Scenario**: Task should start immediately without manual intervention

Set `auto_execute: true`:

```bash
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "orchestrator",
    "to": "pinky-claude",
    "type": "task",
    "body": "Run npm test",
    "metadata": {
      "auto_execute": true
    }
  }'
```

**If poller is running**: Task automatically launches in new window

### Pattern 3: Pipeline with Dependencies

**Scenario**: Task B waits for task A

```json
{
  "task_id": "task-b",
  "depends_on": ["task-a"],
  "body": "Deploy after tests pass"
}
```

**Logic**:
1. Poller sees task-b
2. Checks if task-a is complete
3. Waits if not complete
4. Executes when dependency satisfied

### Pattern 4: Task Chaining

**Scenario**: Completing one task triggers the next

**In maxyolo-claude:**
```
When I finish analyzing the code, send a task to pinky-claude
with a list of test files to create. Use this command:

curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "maxyolo-claude",
    "to": "pinky-claude",
    "type": "task",
    "body": "Create tests for: [FILES YOU IDENTIFIED]",
    "metadata": {"auto_execute": false}
  }'
```

**Result**: Analysis → Testing (autonomous handoff)

## Advanced Configuration

### Custom Poll Interval

Edit `message-poller.sh`:

```bash
POLL_INTERVAL=5  # Change to 10 for slower polling
```

### Priority-Based Execution

Pollers can prioritize critical tasks:

```bash
# In message-poller.sh, modify the jq filter:
jq -r '.messages[] | select(.priority == "critical" or .priority == "high")'
```

### Remote vs Local Execution

**Local execution**: Auto-launcher opens new terminal
**Remote execution**: Shows prompt to copy-paste

Detect with:
```bash
if [ -n "$SSH_CONNECTION" ]; then
    # Running over SSH, can't open iTerm
    echo "Run this in Claude: $TASK_PROMPT"
fi
```

### Notification on Task Arrival

Add to poller:

```bash
# macOS notification
osascript -e "display notification \"New task: $task_id\" with title \"Claude Agent\""
```

## Monitoring & Debugging

### View All Tasks

```bash
# All messages
curl http://localhost:3100/inbox | jq '.messages'

# Only tasks
curl http://localhost:3100/inbox | jq '.messages[] | select(.type == "task")'

# Unread tasks
curl http://localhost:3100/inbox/unread | jq '.messages[] | select(.type == "task")'
```

### Check Poller Logs

```bash
# Live tail
tail -f ~/poller-$(hostname -s).log

# Last 50 lines
tail -50 ~/poller-$(hostname -s).log

# Search for task ID
grep "task-123" ~/poller-$(hostname -s).log
```

### Verify Session-End Hook

```bash
# Start Claude session
claude

# Exit (Ctrl+D or /exit)

# Check if completion message was sent
curl http://localhost:3100/inbox | jq '.messages[] | select(.type == "completion")'
```

### Debug Message Delivery

```bash
# Send test message
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "test",
    "to": "test-agent",
    "type": "task",
    "body": "Test message",
    "metadata": {"auto_execute": false}
  }'

# Verify it arrived
curl http://localhost:3100/inbox | jq '.messages[-1]'
```

## Troubleshooting

### Poller not detecting tasks

**Check:**
1. Is poller running? `ps aux | grep message-poller`
2. Are tasks marked for correct agent? `to: "pinky-claude"`
3. Check logs: `tail ~/poller-*.log`

**Fix:**
```bash
# Restart poller
kill $(cat /tmp/poller-*.pid)
./message-poller.sh &
```

### Auto-launcher not working

**Common issues:**
- Running over SSH (can't open iTerm remotely)
- osascript not available (not macOS)
- Permissions issue

**Workaround:**
Set `auto_execute: false` and execute manually

### Session-end hook not running

**Check:**
```bash
# Is hook executable?
ls -la ~/.claude/hooks/session-end.sh

# Test it manually
~/.claude/hooks/session-end.sh

# Check for errors
bash -x ~/.claude/hooks/session-end.sh
```

### Messages not persisting

**Problem**: Message bus restarted, lost messages

**Solution**: Messages are saved to disk automatically
```bash
# Check inbox file
cat ~/inbox-$(hostname).json | jq
```

## Real-World Use Cases

### 1. Continuous Testing

```bash
# Every code change triggers tests on pinky
# In maxyolo's git post-commit hook:
curl -X POST http://192.168.5.80:3100/send \
  -d '{"to":"pinky-claude","type":"task","body":"Run tests"}'
```

### 2. Scheduled Backups

```bash
# Cron job sends backup task daily
0 2 * * * curl -X POST http://localhost:3100/send \
  -d '{"to":"pinky-claude","body":"Backup database"}'
```

### 3. Load Distribution

```bash
# Spread work across machines
for file in *.js; do
  curl -X POST http://192.168.5.80:3100/send \
    -d "{\"body\":\"Lint $file\"}"
done
```

### 4. Build Matrix

```bash
# Test on multiple environments
for env in dev staging prod; do
  curl -X POST http://192.168.5.80:3100/send \
    -d "{\"body\":\"Deploy to $env\"}"
done
```

## What You've Built

- ✅ **Task Queue System** - Like AWS SQS
- ✅ **Autonomous Agents** - Like GitHub Actions runners
- ✅ **Workflow Engine** - Like Airflow/Temporal
- ✅ **Distributed Computing** - Like Kubernetes jobs
- ✅ **Event-Driven Architecture** - Like Lambda triggers

**All on hardware you own, with code you understand.**

## Next Steps

### When brain comes online:

**Three-agent patterns:**
- **Pipeline**: maxyolo → pinky → brain (sequential)
- **Fan-out**: maxyolo → [pinky, brain] (parallel)
- **Reduce**: [pinky, brain] → maxyolo (aggregation)

**Example:**
```bash
# Orchestrator assigns work
maxyolo: "Analyze code"
  ↓
# Parallel execution
pinky: "Build frontend"
brain: "Build backend"
  ↓
# Aggregation
maxyolo: "Run integration tests"
```

### Advanced Enhancements:

- [ ] Web dashboard showing task queue status
- [ ] Retry failed tasks automatically
- [ ] Task timeout enforcement
- [ ] Result storage (not just messages)
- [ ] Metrics (tasks/sec, success rate)
- [ ] Authentication for message bus
- [ ] Task scheduling (cron-like)
- [ ] Dead letter queue for failures

---

**Status**: Complete when you can send a task and see autonomous execution

**Achievement Unlocked**: Self-coordinating AI agents 🤖🔄🤖

Built with message queues, polling, and a lot of JSON.
