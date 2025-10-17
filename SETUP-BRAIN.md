# Setup Brain - The Third Agent

**Goal**: Add brain (Mac mini #2) to complete your three-agent autonomous system

---

## 🧠 What Brain Adds

**With 2 agents** (maxyolo + pinky):
- Orchestrator + Executor
- Frontend + Backend
- Dev + Build

**With 3 agents** (maxyolo + pinky + brain):
- **Orchestrator** (maxyolo) - Coordinates everything
- **Executor** (pinky) - Does the work
- **Planner** (brain) - Analyzes, validates, strategizes

**New patterns unlocked**:
- Pipeline: maxyolo → pinky → brain (sequential)
- Fan-out: maxyolo → [pinky, brain] (parallel)
- Map-Reduce: [pinky, brain] → maxyolo (aggregation)
- Redundancy: Same task on pinky + brain, compare outputs
- Specialization: Each agent has dedicated role

---

## 📋 Pre-Flight Checklist

Before starting, make sure you have:
- [ ] brain powered on and connected to network
- [ ] macOS setup complete on brain
- [ ] User account created on brain
- [ ] WiFi/Ethernet connected to same network
- [ ] Terminal access to brain (monitor + keyboard OR screen sharing)

---

## Step 1: Get Brain's IP Address

**On brain** (connect monitor/keyboard or use Screen Sharing):

```bash
# Open Terminal
# Get IP address
ipconfig getifaddr en0

# Or if WiFi:
ipconfig getifaddr en1

# Should be something like: 192.168.5.XX
```

**Write it down**: `192.168.5.81`

**Test connectivity from maxyolo**:
```bash
# On maxyolo
ping 192.168.5.81  # Replace XX with brain's IP

# Should see responses
# Ctrl+C to stop
```

---

## Step 2: Enable Remote Login on Brain

**On brain**:

1. Open **System Settings**
2. Go to **General** → **Sharing**
3. Enable **Remote Login**
4. Click info button (ⓘ)
5. Select **Allow full disk access for remote users**
6. Make sure your user is in the allowed list

**Verify from maxyolo**:
```bash
# Try to SSH (will ask for password)
ssh username@192.168.5.XX

# If it works, you're in! Type 'exit' to return to maxyolo
```

---

## Step 3: Set Up SSH Keys

**On maxyolo**:

```bash
# Copy your SSH key to brain
ssh-copy-id -i ~/.ssh/id_machines.pub username@192.168.5.XX

# Enter password when prompted
# This is the LAST time you'll need the password
```

**Test password-less SSH**:
```bash
ssh brain-username@192.168.5.XX
# Should login without password!
```

**Add to SSH config**:
```bash
# Edit SSH config
vim ~/.ssh/config

# Add this entry:
Host brain
    HostName 192.168.5.XX
    User your-brain-username
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes

# Save and exit (:wq)
```

**Test shortcut**:
```bash
ssh brain
# Should work!
```

---

## Step 4: Install Development Tools on Brain

**On maxyolo, copy setup script to brain**:
```bash
scp ~/Documents/projects/pinkyandbrain/setup-dev-tools.sh brain:~/
```

**On brain (SSH into it)**:
```bash
ssh brain

# Run setup script
bash ~/setup-dev-tools.sh

# This installs:
# - Homebrew
# - Git
# - jq
# - Node.js via nvm
```

**Verify installation**:
```bash
node --version
npm --version
jq --version
```

---

## Step 5: Install Claude Code on Brain

**Still on brain**:
```bash
npm install -g @anthropic-ai/claude-code

# Verify
claude --version
```

**Authorize Claude Code**:
```bash
# Start Claude
claude

# You'll see: "Please visit: https://console.anthropic.com/device?code=ABC123"

# Copy that URL
# Open it in Safari on maxyolo (your laptop)
# Authorize the device

# Back on brain terminal, Claude should start
# Type /exit to close for now
```

---

## Step 6: Deploy Message Bus to Brain

**On maxyolo**:
```bash
# Copy message bus
scp ~/Documents/projects/pinkyandbrain/claude-messenger.js brain:~/

# Copy package.json or install express
ssh brain "npm install express"
```

**Start message bus on brain**:
```bash
ssh brain "node ~/claude-messenger.js > ~/messenger.log 2>&1 &"

# Verify it's running
curl http://192.168.5.XX:3100/health

# Should see: {"status":"ok","machine":"brain",...}
```

---

## Step 7: Update Orchestrator for 3 Agents

**On maxyolo**:
```bash
cd ~/Documents/projects/pinkyandbrain

# Edit orchestrator.sh
vim orchestrator.sh
```

**Add brain to orchestrator** (around line 112):
```bash
# Add after pinky check
# Check/start message bus on brain
if ! check_message_bus "192.168.5.XX"; then
    start_message_bus "brain"
    check_message_bus "192.168.5.XX" || echo "Failed to start on brain"
fi
```

**Add brain terminal window** (around line 128):
```bash
# Add after pinky terminal
sleep 2

# Open Claude session on brain
open_claude_terminal "brain" "brain-claude" "I am the planner on brain"
```

**Update the start_message_bus function** (around line 42):
```bash
elif [ "$machine" = "brain" ]; then
    ssh "$machine" "bash -l -c 'cd ~ && node claude-messenger.js > ~/messenger.log 2>&1 &'"
```

---

## Step 8: Update run-on-all.sh

**Edit run-on-all.sh**:
```bash
vim ~/Documents/projects/pinkyandbrain/run-on-all.sh
```

**Add brain to machines array**:
```bash
# Change this:
MACHINES=("localhost" "pinky")

# To this:
MACHINES=("localhost" "pinky" "brain")
```

**Test it**:
```bash
./run-on-all.sh "hostname && date"

# Should run on all three machines!
```

---

## Step 9: Update Dashboard

**Edit dashboard.html**:
```bash
vim ~/Documents/projects/pinkyandbrain/dashboard.html
```

**Add brain to agents array** (around line 150):
```javascript
const agents = [
    { name: 'maxyolo-claude', bus: 'http://192.168.5.76:3100', color: '#64b5f6' },
    { name: 'pinky-claude', bus: 'http://192.168.5.80:3100', color: '#e91e63' },
    { name: 'brain-claude', bus: 'http://192.168.5.XX:3100', color: '#4caf50' }
];
```

**Open dashboard**:
```bash
open ~/Documents/projects/pinkyandbrain/dashboard.html

# You should now see THREE agents!
```

---

## Step 10: Update CLI Tool

**Edit pinky-cli.sh** (around line 20):
```bash
vim ~/Documents/projects/pinkyandbrain/pinky-cli.sh
```

**Add brain bus**:
```bash
# Add after PINKY_BUS
BRAIN_BUS="http://192.168.5.XX:3100"
```

**Update agent detection** (around line 35):
```bash
# Add brain case
elif [ "$MACHINE_NAME" = "brain" ] || [ "$MACHINE_NAME" = "Brains-Mac-mini" ]; then
    CURRENT_AGENT="brain-claude"
    REMOTE_AGENTS=("maxyolo-claude" "pinky-claude")
    REMOTE_BUSES=("$MAXYOLO_BUS" "$PINKY_BUS")
```

**Update get_agent_bus function** (around line 90):
```bash
get_agent_bus() {
    local agent=$1

    if [[ "$agent" == *"maxyolo"* ]]; then
        echo "$MAXYOLO_BUS"
    elif [[ "$agent" == *"pinky"* ]]; then
        echo "$PINKY_BUS"
    elif [[ "$agent" == *"brain"* ]]; then
        echo "$BRAIN_BUS"
    else
        echo "$LOCAL_BUS"
    fi
}
```

---

## Step 11: Deploy Utilities to Brain

**Copy everything from maxyolo to brain**:
```bash
# Copy hooks
scp ~/.claude/hooks/session-end.sh brain:~/.claude/hooks/
ssh brain "chmod +x ~/.claude/hooks/session-end.sh"

# Copy poller
scp ~/Documents/projects/pinkyandbrain/message-poller.sh brain:~/
ssh brain "chmod +x ~/message-poller.sh"

# Copy launcher
scp ~/Documents/projects/pinkyandbrain/claude-auto-launcher.sh brain:~/
ssh brain "chmod +x ~/claude-auto-launcher.sh"

# Copy CLI
scp ~/Documents/projects/pinkyandbrain/pinky-cli.sh brain:~/
ssh brain "chmod +x ~/pinky-cli.sh"
ssh brain "echo 'alias pinky=\"~/pinky-cli.sh\"' >> ~/.zshrc"

# Copy templates
ssh brain "mkdir -p ~/templates"
scp ~/Documents/projects/pinkyandbrain/templates/*.json brain:~/templates/
```

---

## Step 12: Test Three-Agent Communication

**Launch orchestrator**:
```bash
./orchestrator.sh
```

**You should see THREE iTerm windows open**:
1. maxyolo-claude
2. pinky-claude
3. brain-claude (NEW!)

**In maxyolo-claude terminal**:
```bash
pinky send "Hello brain!" --to brain-claude
```

**In brain-claude terminal**:
```bash
pinky inbox

# Should see message from maxyolo!
```

**In pinky-claude terminal**:
```bash
pinky send "Brain, analyze our codebase" --to brain-claude
```

**Check dashboard**:
```bash
open ~/Documents/projects/pinkyandbrain/dashboard.html

# All THREE agents should show as online!
# Messages should flow between all of them!
```

---

## 🎯 Three-Agent Workflows

### Pattern 1: Pipeline (Sequential)

```bash
# maxyolo: Coordinate
pinky send "Analyze code quality" --to brain-claude

# brain: Analyze
# (receives task, analyzes, sends results)
pinky send "Build based on analysis" --to pinky-claude

# pinky: Execute
# (receives task, builds, reports back)
```

### Pattern 2: Fan-Out (Parallel)

```bash
# Send same task to both executors
pinky send "Run tests" --to pinky-claude
pinky send "Run tests" --to brain-claude

# Compare results
pinky inbox --type completion
```

### Pattern 3: Map-Reduce

```bash
# Split work
template run test-runner to=pinky-claude
template run build-frontend to=brain-claude

# Orchestrator collects results
# Makes decision based on both
```

### Pattern 4: Specialized Roles

```bash
# maxyolo: Frontend work
# pinky: Backend work
# brain: Database/analysis work

template run build-frontend to=maxyolo-claude
template run build-backend to=pinky-claude
template run performance-audit to=brain-claude
```

---

## 🔥 Power Moves with Three Agents

**1. Redundant Execution**
```bash
# Run critical task on both pinky and brain
# Compare outputs for consensus

pinky send "Deploy to prod" --to pinky-claude
pinky send "Deploy to prod" --to brain-claude

# If both succeed, confident deploy worked
# If one fails, investigate
```

**2. Load Balancing**
```bash
# Check which agent has fewer tasks
pinky status

# Send to least busy
pinky send "Heavy computation" --to brain-claude
```

**3. Specialized Chains**
```bash
# Analysis → Planning → Execution

# brain analyzes
template run code-review to=brain-claude

# brain sends plan to pinky
# pinky executes

# pinky reports to maxyolo
```

---

## 📊 Updated Network Map

```
Router (192.168.5.x)
│
├─ maxyolo (MacBook)     → 192.168.5.76  [orchestrator]
├─ pinky (Mac mini #1)   → 192.168.5.80  [executor]
└─ brain (Mac mini #2)   → 192.168.5.XX  [planner]
```

**Message Buses**:
- maxyolo: `http://192.168.5.76:3100`
- pinky: `http://192.168.5.80:3100`
- brain: `http://192.168.5.XX:3100`

---

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] `ssh brain` works without password
- [ ] `curl http://192.168.5.XX:3100/health` returns OK
- [ ] `./run-on-all.sh "hostname"` shows all 3 machines
- [ ] `./orchestrator.sh` opens 3 terminal windows
- [ ] Dashboard shows 3 agents online
- [ ] `pinky send "test" --to brain-claude` delivers message
- [ ] `pinky status` shows all 3 agents

**Full system test**:
```bash
# 1. Run orchestrator
./orchestrator.sh

# 2. Open dashboard
open dashboard.html

# 3. Send test messages
pinky send "Hello pinky" --to pinky-claude
pinky send "Hello brain" --to brain-claude

# 4. Check dashboard
# Should see messages arrive in real-time!

# 5. Run workflow
template run test-runner

# 6. Watch it flow through the system
```

---

## 🎉 You Did It!

**You now have**:
- ✅ Three Mac computers working as one
- ✅ Distributed AI agent orchestration
- ✅ Message passing between all agents
- ✅ Real-time dashboard showing all activity
- ✅ CLI tools for easy control
- ✅ Template library for workflows
- ✅ Git hooks for automation

**What you can do**:
- Distribute work across 3 machines
- Run parallel workflows
- Build redundancy and fault tolerance
- Specialize each agent
- Learn distributed systems hands-on

**What you're learning**:
- Distributed computing
- Message-based architecture
- Orchestration patterns
- Real networking (not cloud/simulated)
- Systems thinking

**Skills that transfer to**:
- Kubernetes
- AWS/GCP/Azure
- Microservices
- Enterprise architecture

---

**Welcome to the three-agent club.** 🧠🤝🐭

Your distributed AI command center is complete.

Time to take over the world... of distributed computing. 🌍
