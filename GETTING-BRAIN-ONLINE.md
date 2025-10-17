#!/bin/bash

# Getting Brain Online - Complete Guide

**Goal**: Add your third Mac mini (brain) to the Pinky & Brain distributed system

**Time**: 15-30 minutes (mostly automated)

---

## 🎯 Prerequisites

Before starting, ensure you have:

- [ ] **Brain** powered on and connected to WiFi/Ethernet
- [ ] **Brain** has a user account set up
- [ ] **Terminal** has Full Disk Access on brain
- [ ] **Remote Login** enabled on brain
- [ ] **Brain's IP address** (find with: `ipconfig getifaddr en0`)
- [ ] **SSH access** from maxyolo to brain (test: `ssh user@ip`)

---

## 🚀 Quick Start (Automated)

### Option 1: Deploy from Orchestrator (RECOMMENDED)

On **maxyolo** (orchestrator):

```bash
cd ~/Documents/projects/pinkyandbrain

# Deploy everything to brain
./deploy-to-brain.sh username@192.168.5.XX

# Example:
./deploy-to-brain.sh brain@192.168.5.82
```

**This script will:**
1. ✅ Test SSH connectivity
2. ✅ Copy SSH keys
3. ✅ Install Homebrew
4. ✅ Install dev tools (git, jq, curl)
5. ✅ Install Node.js via nvm
6. ✅ Install Claude Code
7. ✅ Deploy message bus
8. ✅ Deploy CLI tools
9. ✅ Start services
10. ✅ Update orchestrator config

Takes ~10-15 minutes (mostly unattended).

---

### Option 2: Manual Setup on Brain

On **brain** itself:

```bash
# Download and run setup script
cd ~/Downloads
curl -O https://raw.githubusercontent.com/YOUR-REPO/setup-new-machine.sh
chmod +x setup-new-machine.sh
./setup-new-machine.sh
```

Or copy the script from maxyolo:

```bash
# On maxyolo
scp ~/Documents/projects/pinkyandbrain/setup-new-machine.sh brain-user@brain-ip:~/

# On brain
~/setup-new-machine.sh
```

---

## 📋 Step-by-Step Manual Process

If you prefer to understand each step:

### Step 1: Enable Remote Access (on Brain)

1. Open **System Settings**
2. Go to **General → Sharing**
3. Enable **Remote Login**
4. Click info button (ⓘ)
5. Enable **"Allow full disk access for remote users"**
6. Note your username

### Step 2: Get Brain's IP Address (on Brain)

```bash
# WiFi
ipconfig getifaddr en1

# Ethernet
ipconfig getifaddr en0

# Should output something like: 192.168.5.82
```

Write it down: `192.168.5._____`

### Step 3: Test SSH Connection (from Max)

```bash
# On maxyolo
ssh username@192.168.5.XX

# If it works, you'll be logged into brain!
# Type 'exit' to return to maxyolo
```

If this fails, check:
- Remote Login is enabled on brain
- Firewall isn't blocking SSH (port 22)
- Correct IP address and username

### Step 4: Copy SSH Key (from Max)

```bash
# On maxyolo
ssh-copy-id -i ~/.ssh/id_machines.pub username@192.168.5.XX

# Enter password when prompted
# This is the LAST time you need the password
```

Test password-less login:

```bash
ssh username@192.168.5.XX
# Should work without password!
```

### Step 5: Add to SSH Config (on Max)

```bash
# On maxyolo
vim ~/.ssh/config

# Add this entry:
Host brain
    HostName 192.168.5.XX
    User your-brain-username
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes

# Save and exit (:wq)
```

Test shortcut:

```bash
ssh brain
# Works!
```

### Step 6: Install Homebrew (on Brain)

```bash
# On brain
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH
if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
fi
```

### Step 7: Install Dev Tools (on Brain)

```bash
# On brain
brew install git jq curl wget
```

### Step 8: Install Node.js (on Brain)

```bash
# On brain
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
source ~/.zshrc

# Install Node
nvm install --lts
nvm use --lts
nvm alias default node

# Verify
node --version
npm --version
```

### Step 9: Install Claude Code (on Brain)

```bash
# On brain
npm install -g @anthropic-ai/claude-code

# Verify
claude --version
```

### Step 10: Deploy Message Bus (from Max)

```bash
# On maxyolo
scp ~/Documents/projects/pinkyandbrain/claude-messenger.js brain:~/
scp ~/Documents/projects/pinkyandbrain/pinky-cli.sh brain:~/

# On brain
chmod +x ~/pinky-cli.sh
npm install express

# Start message bus
node ~/claude-messenger.js > ~/messenger.log 2>&1 &
```

Verify it's running:

```bash
# From maxyolo
curl http://192.168.5.XX:3100/health

# Should see: {"status":"ok","machine":"brain",...}
```

---

## ✅ Verification Checklist

After setup, verify everything works:

### From Maxyolo:

```bash
# Test SSH shortcut
ssh brain
# Should log in without password
exit

# Test message bus
curl http://192.168.5.XX:3100/health
# Should return JSON with status "ok"

# Test message sending
cd ~/Documents/projects/pinkyandbrain
./pinky-cli.sh send "Hello brain!" --to brain-claude
```

### On Brain:

```bash
# Start Claude Code
claude

# Visit authorization URL in browser
# Complete device authorization

# Once authorized, exit
/exit

# Check inbox
./pinky-cli.sh inbox
# Should see test message from maxyolo
```

### Run-on-All Test:

```bash
# On maxyolo
cd ~/Documents/projects/pinkyandbrain
./run-on-all.sh "hostname && date"

# Should output from all 3 machines:
# - maxyolo
# - pinky
# - brain
```

---

## 🔧 Update Orchestrator for 3 Agents

### 1. Update run-on-all.sh

```bash
# On maxyolo
vim ~/Documents/projects/pinkyandbrain/run-on-all.sh

# Change line 8 from:
MACHINES=("localhost" "pinky")

# To:
MACHINES=("localhost" "pinky" "brain")
```

### 2. Update audio-bridge.js

```bash
# On maxyolo
vim ~/Documents/projects/pinkyandbrain/audio-bridge.js

# Add brain to MESSAGE_BUSES array (around line 12):
const MESSAGE_BUSES = [
    { name: 'maxyolo', url: 'http://192.168.5.76:3100' },
    { name: 'pinky', url: 'http://192.168.5.80:3100' },
    { name: 'brain', url: 'http://192.168.5.XX:3100' }  // ← ADD THIS
];

# Restart audio bridge
pkill -f audio-bridge
node audio-bridge.js > audio-bridge.log 2>&1 &
```

### 3. Update dashboard.html (optional)

```bash
# On maxyolo
vim ~/Documents/projects/pinkyandbrain/dashboard.html

# Add brain to agents array (around line 150):
const agents = [
    { name: 'maxyolo-claude', bus: 'http://192.168.5.76:3100', color: '#64b5f6' },
    { name: 'pinky-claude', bus: 'http://192.168.5.80:3100', color: '#e91e63' },
    { name: 'brain-claude', bus: 'http://192.168.5.XX:3100', color: '#4caf50' }  // ← ADD THIS
];
```

---

## 🚀 Launch 3-Agent Orchestration

Now you can run the orchestrator with all 3 agents!

### Option 1: Manual Launch

```bash
# Terminal 1: Max
cd ~/Documents/projects/pinkyandbrain
claude

# Terminal 2: Pinky
ssh pinky
claude

# Terminal 3: Brain
ssh brain
claude
```

### Option 2: Orchestrator Script (if you have one)

```bash
cd ~/Documents/projects/pinkyandbrain
./orchestrator.sh
```

Should open 3 iTerm windows:
1. maxyolo-claude
2. pinky-claude
3. brain-claude

---

## 🎤 Test Audio with All 3 Agents

### Test Different Voices:

```bash
# Max sends (Evan voice)
./pinky-cli.sh send "This is Max speaking" --to pinky-claude

# Pinky sends (Allison Enhanced voice)
ssh pinky "./pinky-cli.sh send 'This is Pinky speaking' --to maxyolo-claude"

# Brain sends (Daniel voice - British)
ssh brain "./pinky-cli.sh send 'This is Brain speaking' --to maxyolo-claude"

# Wait ~5 seconds for audio bridge to poll
# Then trigger playback
curl -X POST http://localhost:3200/api/inbox/play-all

# You should hear all 3 distinct voices!
```

---

## 🎯 Three-Agent Workflows

Now you can do distributed tasks like:

### Example 1: Parallel Processing

```bash
./pinky-cli.sh send "Task: Build frontend" --to pinky-claude
./pinky-cli.sh send "Task: Run tests" --to brain-claude

# Both execute in parallel!
```

### Example 2: Pipeline

```bash
# Max → Pinky → Brain workflow
./pinky-cli.sh send "Analyze codebase, send report to brain" --to pinky-claude

# (Pinky analyzes, sends to brain)

# (Brain receives, processes, sends back to Max)
```

### Example 3: URL Reading

```bash
# Use all 3 agents to fetch, summarize, and read URLs
./read-url.sh https://example.com

# Brain could fetch, Pinky could summarize, Max could coordinate
```

---

## 🐛 Troubleshooting

### SSH not working?

```bash
# Check SSH service on brain
ssh username@ip "sudo systemsetup -getremotelogin"

# Should show: Remote Login: On
```

### Message bus not responding?

```bash
# On brain
ps aux | grep claude-messenger
# If not running, restart:
node ~/claude-messenger.js > ~/messenger.log 2>&1 &

# Check logs
tail -f ~/messenger.log
```

### Claude Code authorization fails?

```bash
# On brain
claude

# Copy the authorization URL
# Open in browser ON MAXYOLO (your laptop with Claude account)
# Complete authorization there
```

### Audio not working for brain?

Check audio-bridge.js includes brain:

```bash
cat ~/Documents/projects/pinkyandbrain/audio-bridge.js | grep brain
```

Should see brain in MESSAGE_BUSES array.

---

## 📊 Network Map After Setup

```
Router (192.168.5.x)
│
├─ maxyolo (MacBook)     → 192.168.5.76  [orchestrator]
│  ├─ Message Bus: 3100
│  ├─ Audio Server: 3200
│  └─ Role: Coordinates tasks
│
├─ pinky (Mac mini #1)   → 192.168.5.80  [executor]
│  ├─ Message Bus: 3100
│  └─ Role: Performs tasks
│
└─ brain (Mac mini #2)   → 192.168.5.XX  [planner]
   ├─ Message Bus: 3100
   └─ Role: Analyzes, strategizes
```

---

## 🎉 Success Criteria

You'll know brain is fully integrated when:

- [ ] `ssh brain` works without password
- [ ] `curl http://brain-ip:3100/health` returns OK
- [ ] `./run-on-all.sh "hostname"` shows all 3 machines
- [ ] Messages can be sent to brain-claude
- [ ] Brain's messages are heard in audio system
- [ ] Dashboard shows all 3 agents online

---

## 📚 Next Steps

With brain online, you can:

1. **Build Complex Workflows** - 3-stage pipelines
2. **Implement Redundancy** - Run same task on 2 machines, compare
3. **Load Balancing** - Distribute work across pinky and brain
4. **Specialized Roles** - Each agent has specific responsibilities
5. **Learn Consensus** - Multiple agents vote on decisions

See: `SETUP-BRAIN.md` for advanced three-agent patterns

---

**Welcome to the three-agent club!** 🧠🤝🐭

Your distributed AI command center is complete.

---

## 🛠️ Files Reference

- `setup-new-machine.sh` - Interactive setup (run on brain)
- `deploy-to-brain.sh` - Automated deployment (run from maxyolo)
- `SETUP-BRAIN.md` - Advanced patterns and workflows
- `run-on-all.sh` - Execute commands on all machines
- `audio-bridge.js` - Message bus → audio bridge
- `claude-messenger.js` - HTTP message bus
- `pinky-cli.sh` - CLI for message passing

---

**Time to take over the world... of distributed computing!** 🌍
