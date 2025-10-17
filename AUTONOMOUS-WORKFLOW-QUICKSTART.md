# Autonomous Workflow - Quick Start Guide

**Built**: 2025-10-15
**Status**: Ready for testing

---

## What You Built

A **fully autonomous 3-machine workflow** where you type ONE command and three machines coordinate to build features for you.

No manual SSH. No copy-pasting. Pure autonomous coordination via message bus.

---

## The Components

### 1. Message Poller (`message-poller.sh`)
- Runs on each machine
- Polls message bus every 5 seconds
- When message arrives → triggers Claude Code automatically
- Handles role-based prompt loading

### 2. Prompt Templates (`prompts/`)
- **brain-prompt.md**: Planner role - analyzes requests, creates specs
- **pinky-prompt.md**: Executor role - implements code based on specs
- **maxyolo-prompt.md**: Reviewer role - tests and integrates

### 3. Workflow Orchestrator (`workflow-orchestrator.sh`)
- Master coordinator
- Health checks all message buses
- Deploys pollers to all machines
- Sends initial request to brain
- Monitors workflow progress

---

## How It Works

```
User Command:
  ./workflow-orchestrator.sh "Build me a todo list component"

Flow:
  1. Orchestrator sends request to brain's message bus
  2. Orchestrator starts pollers on all 3 machines
  3. brain's poller detects message
     → Launches Claude Code with planning prompt
     → Claude analyzes request
     → Creates technical specification
     → Sends plan to pinky via message bus
  4. pinky's poller detects message from brain
     → Launches Claude Code with executor prompt
     → Claude reads the plan
     → Implements all files
     → Sends completion to maxyolo via message bus
  5. maxyolo's poller detects message from pinky
     → Launches Claude Code with reviewer prompt
     → Claude reviews code
     → Tests implementation
     → Reports final status

Result: Feature built, tested, and ready to use! 🎉
```

---

## Pre-Flight Checklist

Before running your first workflow:

### ✅ Step 1: Verify Message Buses Running
```bash
# Check all buses
./run-on-all.sh "curl -s http://localhost:3100/health | jq '.machine'"

# Should see:
# maxyolo ✓
# pinky ✓
# brain ✓
```

**If any are offline**:
```bash
# Start on brain
ssh brain "cd ~/pinkyandbrain && nohup node claude-messenger.js > messenger.log 2>&1 &"

# Start on pinky
ssh pinky "cd ~/pinkyandbrain && nohup node claude-messenger.js > messenger.log 2>&1 &"

# Start on maxyolo (if needed)
cd ~/pinkyandbrain && nohup node claude-messenger.js > messenger.log 2>&1 &
```

### ✅ Step 2: Verify SSH Access
```bash
# Quick test
ssh brain "hostname"
ssh pinky "hostname"

# Should connect without password
```

### ✅ Step 3: Verify Prompts Exist
```bash
ls -la prompts/
# Should see:
#   brain-prompt.md
#   pinky-prompt.md
#   maxyolo-prompt.md
```

---

## Running Your First Workflow

### Test #1: Simple Counter Component

```bash
./workflow-orchestrator.sh "Build me a simple counter component with increment and decrement buttons"
```

**What happens**:
1. Health check (5 seconds)
2. Request sent to brain
3. Pollers start on all machines
4. Autonomous coordination begins
5. Monitor shows message activity
6. Completion detected
7. Results displayed

**Expected outcome**:
- brain creates plan
- pinky implements React component
- maxyolo reviews and confirms ready

**Output location**: `~/pinkyandbrain/workflow-output/`

### Test #2: Todo List Component

```bash
./workflow-orchestrator.sh "Create a todo list component with add, delete, and mark complete functionality"
```

**More complex** - tests full coordination:
- Multiple files
- State management
- Type definitions
- Component composition

### Test #3: Your Own Request

```bash
./workflow-orchestrator.sh "YOUR REQUEST HERE"
```

---

## Monitoring the Workflow

### Real-time Logs

**Watch maxyolo poller** (local):
```bash
tail -f ~/pinkyandbrain/poller-maxyolo.log
```

**Watch brain poller**:
```bash
ssh brain "tail -f ~/pinkyandbrain/poller-brain.log"
```

**Watch pinky poller**:
```bash
ssh pinky "tail -f ~/pinkyandbrain/poller-pinky.log"
```

### Check Message Buses

**All machines at once**:
```bash
./run-on-all.sh "curl -s http://localhost:3100/inbox | jq '{machine, total: .total, unread: .unread}'"
```

**Specific machine**:
```bash
# Brain's inbox
curl -s http://192.168.5.81:3100/inbox | jq '.messages'

# Pinky's inbox
curl -s http://192.168.5.80:3100/inbox | jq '.messages'

# Maxyolo's inbox
curl -s http://localhost:3100/inbox | jq '.messages'
```

---

## Stopping the Workflow

### Stop Pollers on All Machines
```bash
./run-on-all.sh "pkill -f message-poller"
```

### Stop Specific Poller
```bash
# On brain
ssh brain "pkill -f message-poller"

# On pinky
ssh pinky "pkill -f message-poller"

# On maxyolo
pkill -f message-poller
```

### Clear Message Queues
```bash
./run-on-all.sh "curl -s -X DELETE http://localhost:3100/messages/all"
```

---

## Troubleshooting

### Problem: "Message bus offline"

**Solution**:
```bash
# Restart message bus on specific machine
ssh brain "cd ~/pinkyandbrain && node claude-messenger.js &"
```

### Problem: "Pollers not responding"

**Solution**:
```bash
# Kill and restart
./run-on-all.sh "pkill -f message-poller"
sleep 2
./workflow-orchestrator.sh "YOUR REQUEST"
```

### Problem: "No output files created"

**Check**:
```bash
# Poller logs for errors
tail -50 ~/pinkyandbrain/poller-*.log

# Message bus activity
curl -s http://localhost:3100/inbox | jq '.messages[-3:]'
```

### Problem: "Workflow seems stuck"

**Debug**:
```bash
# Check which machine has unread messages
./run-on-all.sh "curl -s http://localhost:3100/inbox/unread | jq '.'"

# Manually trigger next step
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"debug","to":"pinky","body":"test message"}'
```

---

## Understanding the Output

### Successful Workflow Indicators

1. **Message count increases** across buses
2. **Unread count goes to 0** on each machine after processing
3. **Files appear** in `~/pinkyandbrain/workflow-output/`
4. **Logs show** "Message processed" on each machine

### Expected Timeline

- **0-10 seconds**: Orchestrator setup and health checks
- **10-20 seconds**: brain receives message, creates plan
- **20-40 seconds**: pinky implements based on plan
- **40-60 seconds**: maxyolo reviews and finalizes
- **Total**: ~1-2 minutes for simple features

---

## Next Steps After First Success

### 1. Refine Prompts
Edit prompt templates to improve quality:
```bash
vim prompts/brain-prompt.md    # Make brain's planning better
vim prompts/pinky-prompt.md    # Improve code generation
vim prompts/maxyolo-prompt.md  # Enhance review criteria
```

### 2. Add Error Handling
Enhance workflows to retry failed steps

### 3. Build Specialized Workflows
Create workflow templates for:
- API endpoint generation
- Database schema creation
- Test suite generation
- Documentation creation

### 4. Add Human Approval Gates
Modify orchestrator to pause for user confirmation:
```bash
# In workflow-orchestrator.sh, add:
read -p "Approve brain's plan? [y/N]:" approval
```

### 5. Build Dashboard
Create real-time visualization:
- Message flow diagram
- Status of each machine
- Output preview
- Timeline view

---

## Advanced Usage

### Custom Workflow with Modified Roles

**Example**: Change pinky to use Python instead of TypeScript

```bash
# Edit pinky's prompt
vim prompts/pinky-prompt.md

# Change to Python-specific instructions
# Run workflow
./workflow-orchestrator.sh "Build me a Flask API endpoint"
```

### Parallel Workflows

Run multiple workflows simultaneously:
```bash
# Terminal 1
./workflow-orchestrator.sh "Build component A" &

# Terminal 2
./workflow-orchestrator.sh "Build component B" &

# Both run in parallel!
```

### Integration with Existing Projects

```bash
# In your project directory
ln -s ~/pinkyandbrain/workflow-orchestrator.sh ./build-feature.sh

# Now use directly in project
./build-feature.sh "Add user settings page"
```

---

## Files Reference

```
pinkyandbrain/
├── workflow-orchestrator.sh       # Master coordinator
├── message-poller.sh              # Autonomous agent runner
├── prompts/
│   ├── brain-prompt.md           # Planning instructions
│   ├── pinky-prompt.md           # Implementation instructions
│   └── maxyolo-prompt.md         # Review instructions
├── workflow-output/              # Generated code appears here
│   └── [feature-name]/
│       └── src/
│           └── components/
│               └── Component.tsx
└── poller-*.log                  # Execution logs
```

---

## Philosophy

**You are no longer one person writing code.**

**You are a distributed system coordinating three AI agents to build for you.**

Think in workflows. Think in delegation. Think autonomous.

---

**Status**: System ready for autonomous execution 🤖🚀

**First Command**: `./workflow-orchestrator.sh "Build me a counter component"`

**Watch It Work**: `tail -f ~/pinkyandbrain/poller-*.log`
