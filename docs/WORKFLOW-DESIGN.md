# First Autonomous Workflow - Three Machines Co-Creating

**Goal**: Build a workflow where each machine contributes autonomously to a shared goal

---

## 🎯 The 3-Step Plan

### **Workflow: "Build Me a Feature"**

**User Input**: Simple prompt like "Build me a todo list component"

**Machine Roles**:
1. **brain** (Planner) - Analyzes requirements, creates technical plan
2. **pinky** (Executor) - Implements the code based on brain's plan
3. **maxyolo** (Reviewer) - Reviews, tests, and integrates the final result

---

## 📋 Detailed Workflow Design

### **Step 1: brain - Planning Phase** (5 minutes)
**Input**: User prompt
**Actions**:
1. Launch Claude Code session on brain
2. Analyze the request
3. Break down into components
4. Create technical specification
5. Send plan to message bus

**Output**:
- Technical specification (JSON or markdown)
- Component list
- Implementation requirements
- Test criteria

**Message Sent To**: pinky
```json
{
  "from": "brain",
  "to": "pinky",
  "subject": "Implementation Plan Ready",
  "body": {
    "feature": "Todo List Component",
    "spec": "path/to/spec.md",
    "components": ["TodoList.tsx", "TodoItem.tsx", "useTodos.ts"],
    "requirements": [...],
    "testCriteria": [...]
  }
}
```

---

### **Step 2: pinky - Execution Phase** (10 minutes)
**Input**: Plan from brain (via message bus)
**Actions**:
1. Launch Claude Code session on pinky
2. Read plan from message bus
3. Generate all files according to spec
4. Run build/compile checks
5. Send completion notice to message bus

**Output**:
- Implementation files
- Build logs
- Self-test results

**Message Sent To**: maxyolo
```json
{
  "from": "pinky",
  "to": "maxyolo",
  "subject": "Implementation Complete",
  "body": {
    "feature": "Todo List Component",
    "files": ["src/components/TodoList.tsx", "src/components/TodoItem.tsx"],
    "buildStatus": "success",
    "location": "~/pinkyandbrain/output/",
    "readyForReview": true
  }
}
```

---

### **Step 3: maxyolo - Review & Integration Phase** (5 minutes)
**Input**: Implementation from pinky (via message bus)
**Actions**:
1. Launch Claude Code session on maxyolo
2. Read completion message
3. Copy files to local project
4. Review code quality
5. Run tests
6. Integrate into main project
7. Report final status

**Output**:
- Final integrated code
- Test results
- Summary report for user

**Message Sent To**: User (console output)
```
✅ Feature Complete: Todo List Component
📁 Files: src/components/TodoList.tsx, src/components/TodoItem.tsx
🧪 Tests: Passing (8/8)
🎯 Ready to use!
```

---

## 🔄 Communication Flow

```
User Prompt
    ↓
┌─────────────────────────────────────────┐
│ brain: Planning                          │
│ • Analyze request                        │
│ • Create technical spec                  │
│ • Define components                      │
└───────────────┬─────────────────────────┘
                ↓ (message bus)
┌─────────────────────────────────────────┐
│ pinky: Implementation                    │
│ • Read spec from bus                     │
│ • Generate all files                     │
│ • Build & self-test                      │
└───────────────┬─────────────────────────┘
                ↓ (message bus)
┌─────────────────────────────────────────┐
│ maxyolo: Review & Integration            │
│ • Read completion notice                 │
│ • Copy files locally                     │
│ • Run tests                              │
│ • Report to user                         │
└─────────────────────────────────────────┘
                ↓
            User sees result
```

---

## 🛠 Technical Architecture

### Message Bus API
**Endpoints we'll use**:
- `POST /send` - Send messages between machines
- `GET /inbox` - Check for new messages
- `GET /inbox/unread` - Poll for unread messages

### Workflow Orchestrator
**File**: `workflow-orchestrator.sh`
```bash
# Start workflow
./workflow-orchestrator.sh "Build me a todo list component"

# What it does:
# 1. Send initial prompt to brain via message bus
# 2. Launch Claude Code session on brain
# 3. Brain processes and sends plan to pinky
# 4. Monitor message bus for pinky completion
# 5. Launch Claude Code session on pinky
# 6. Pinky implements and sends to maxyolo
# 7. Maxyolo reviews and reports back
```

### Claude Code Sessions
Each machine runs Claude Code with:
- **brain**: `claude --no-browser` with planning prompt
- **pinky**: `claude --no-browser` with implementation prompt
- **maxyolo**: `claude --no-browser` with review prompt

---

## 📝 Implementation Plan

### Phase 1: Message Polling System (Build First)
**File**: `message-poller.sh`
```bash
#!/bin/bash
# Poll message bus for new messages
# When message arrives, trigger Claude Code session

while true; do
  # Check for unread messages
  MESSAGE=$(curl -s http://localhost:3100/inbox/unread)

  if [ $(echo $MESSAGE | jq '.unread') -gt 0 ]; then
    # Trigger Claude Code with message context
    # Process the task
    # Send result to next machine
  fi

  sleep 5
done
```

### Phase 2: Claude Prompt Templates (Build Second)
**brain-planner-prompt.md**:
```markdown
You are the BRAIN - the planner of a 3-machine distributed system.

You just received this request: {{USER_PROMPT}}

Your task:
1. Analyze the request
2. Break it into components
3. Create a technical specification
4. Define clear implementation requirements

When done, send your plan to pinky via message bus:
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"brain","to":"pinky","body":"{{YOUR_PLAN}}"}'
```

**pinky-executor-prompt.md**:
```markdown
You are PINKY - the executor of a 3-machine distributed system.

You just received this plan from brain:
{{BRAIN_PLAN}}

Your task:
1. Implement exactly what brain specified
2. Create all files
3. Build/compile
4. Self-test

When done, send completion notice to maxyolo via message bus:
curl -X POST http://192.168.5.76:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"pinky","to":"maxyolo","body":"Implementation complete: {{FILES}}"}'
```

**maxyolo-reviewer-prompt.md**:
```markdown
You are MAXYOLO - the reviewer of a 3-machine distributed system.

Pinky just completed implementation:
{{PINKY_OUTPUT}}

Your task:
1. Copy files from pinky
2. Review code quality
3. Run tests
4. Integrate into main project
5. Report final status to user

Output a summary of what was built and whether it's ready to use.
```

### Phase 3: Orchestrator Script (Build Third)
**File**: `workflow-orchestrator.sh`
```bash
#!/bin/bash
# Master orchestrator that coordinates all 3 machines

USER_PROMPT="$1"

# Step 1: Send prompt to brain
curl -X POST http://192.168.5.81:3100/send \
  -H "Content-Type: application/json" \
  -d "{\"from\":\"orchestrator\",\"to\":\"brain\",\"body\":\"$USER_PROMPT\"}"

# Step 2: Trigger brain's Claude Code session (polls for messages)
ssh brain "cd ~/pinkyandbrain && ./message-poller.sh brain" &

# Step 3: Trigger pinky's Claude Code session (polls for messages)
ssh pinky "cd ~/pinkyandbrain && ./message-poller.sh pinky" &

# Step 4: Monitor for final result on maxyolo
./message-poller.sh maxyolo
```

---

## 🎮 User Experience

**What the user sees**:
```bash
$ ./workflow-orchestrator.sh "Build me a todo list component"

🧠 brain: Analyzing request...
📋 brain: Creating technical specification...
✓ brain: Plan sent to pinky

⚙️  pinky: Received plan from brain
📝 pinky: Generating TodoList.tsx...
📝 pinky: Generating TodoItem.tsx...
📝 pinky: Generating useTodos.ts...
🔨 pinky: Building...
✓ pinky: Implementation complete, sent to maxyolo

👀 maxyolo: Received files from pinky
🧪 maxyolo: Running tests...
✅ maxyolo: All tests passing (8/8)
📦 maxyolo: Integrated into project

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Feature Complete: Todo List Component
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files Created:
  • src/components/TodoList.tsx (87 lines)
  • src/components/TodoItem.tsx (45 lines)
  • src/hooks/useTodos.ts (62 lines)

Tests: Passing (8/8)
Build: Success
Ready to use! 🎉
```

---

## 🚀 Next Steps to Build

### Step 1: Build Message Poller
**Priority**: HIGH
**File**: `message-poller.sh`
**Time**: 30 minutes

### Step 2: Create Prompt Templates
**Priority**: HIGH
**Files**: `prompts/brain-planner.md`, `prompts/pinky-executor.md`, `prompts/maxyolo-reviewer.md`
**Time**: 20 minutes

### Step 3: Build Orchestrator
**Priority**: MEDIUM
**File**: `workflow-orchestrator.sh`
**Time**: 30 minutes

### Step 4: Test End-to-End
**Priority**: HIGH
**Time**: 30 minutes
**Test with**: "Build me a simple counter component"

---

## 🎯 Success Criteria

**Workflow is successful if**:
1. ✅ User provides single prompt
2. ✅ brain creates plan autonomously
3. ✅ pinky implements without human intervention
4. ✅ maxyolo reviews and integrates automatically
5. ✅ Final output is usable code
6. ✅ Total time < 20 minutes
7. ✅ All communication via message bus (no manual steps)

---

## 💡 Future Enhancements

Once basic workflow works:
1. **Error handling** - Retry failed steps
2. **Parallel workflows** - Multiple features simultaneously
3. **Human approval gates** - Pause for user review
4. **Quality metrics** - Code coverage, complexity analysis
5. **Learning system** - Improve prompts based on success rate
6. **Dashboard** - Real-time workflow visualization

---

**Status**: Design complete, ready to build! 🚀
**Next**: Build message-poller.sh
