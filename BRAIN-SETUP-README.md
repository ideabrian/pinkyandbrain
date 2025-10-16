# 🧠 Getting Brain Online - Setup System

**Complete automation for adding the third Mac mini to your distributed system**

---

## 📦 What We Built

A comprehensive setup system with:

### 1. **Automated Deployment** (`deploy-to-brain.sh`)
- One command from orchestrator
- Installs everything remotely
- Updates orchestrator config
- Takes 10-15 minutes

### 2. **Interactive Setup** (`setup-new-machine.sh`)
- Run directly on brain
- Step-by-step with explanations
- Generates setup log
- Perfect for understanding the process

### 3. **Complete Documentation**
- `GETTING-BRAIN-ONLINE.md` - Full guide
- `BRAIN-SETUP-CHEATSHEET.md` - Quick reference
- `SETUP-BRAIN.md` - Advanced patterns

---

## 🚀 Choose Your Path

### Path A: Automated (RECOMMENDED)

**On maxyolo:**
```bash
cd ~/Documents/projects/pinkyandbrain
./deploy-to-brain.sh brain@192.168.5.81
```

**Sit back and wait 10-15 minutes.**

### Path B: Interactive

**On brain:**
```bash
./setup-new-machine.sh
```

**Follow the prompts.**

### Path C: Manual

**Follow step-by-step:**
See `GETTING-BRAIN-ONLINE.md`

---

## ✅ What Gets Installed

### System Tools
- ✅ Homebrew package manager
- ✅ Git, jq, curl, wget
- ✅ Node.js via nvm
- ✅ Claude Code CLI

### Distributed Services
- ✅ Message bus (port 3100)
- ✅ pinky CLI tool
- ✅ Project directory structure
- ✅ SSH key exchange

### Configuration
- ✅ SSH config entry
- ✅ Passwordless authentication
- ✅ Service auto-start
- ✅ Orchestrator integration

---

## 📊 Before vs After

### Before (2 Machines)
```
maxyolo ←→ pinky
```

**Patterns:**
- Orchestrator ↔ Executor
- Request ↔ Response

### After (3 Machines)
```
    maxyolo
    ↙   ↘
pinky ←→ brain
```

**Patterns:**
- Pipeline: max → pinky → brain
- Fan-out: max → [pinky, brain]
- Map-Reduce: [pinky, brain] → max
- Redundancy: Same task, compare results
- Specialization: Each has a role

---

## 🎤 Voice System Integration

Brain gets its own distinct voice:

- **Max** → Evan (male, orchestrator)
- **Pinky** → Allison Enhanced (female, executor)
- **Brain** → Daniel (British, planner)

Messages from brain will be heard in Daniel's voice!

---

## 🎯 Success Criteria

After setup, you should be able to:

```bash
# 1. SSH without password
ssh brain

# 2. Check health
curl http://brain-ip:3100/health

# 3. Send messages
./pinky-cli.sh send "Hello brain!" --to brain-claude

# 4. Run on all machines
./run-on-all.sh "hostname"
# Output: maxyolo, pinky, brain

# 5. Hear all 3 voices
# (Messages from each agent play in their distinct voice)
```

---

## 🛠️ Files Created

### Automation Scripts
- `deploy-to-brain.sh` - Remote deployment (run from max)
- `setup-new-machine.sh` - Interactive setup (run on brain)

### Documentation
- `GETTING-BRAIN-ONLINE.md` - Complete guide (30 pages)
- `BRAIN-SETUP-CHEATSHEET.md` - Quick reference (2 pages)
- `BRAIN-SETUP-README.md` - This file

### Configuration Updates
- `run-on-all.sh` - Add brain to MACHINES array
- `audio-bridge.js` - Add brain to MESSAGE_BUSES
- `~/.ssh/config` - Add brain entry

---

## 📚 Quick Links

**Start Here:**
- 🚀 [Quick Start Cheatsheet](./BRAIN-SETUP-CHEATSHEET.md) (5 min read)
- 📖 [Complete Setup Guide](./GETTING-BRAIN-ONLINE.md) (full reference)
- 🧠 [Advanced Patterns](./SETUP-BRAIN.md) (3-agent workflows)

**Scripts:**
- `./deploy-to-brain.sh` - Automated deployment
- `./setup-new-machine.sh` - Interactive setup

---

## 🎓 What You'll Learn

By setting up brain, you learn:

1. **Automation** - Infrastructure as code
2. **Remote Administration** - SSH, package managers
3. **Service Orchestration** - Multi-machine coordination
4. **Network Architecture** - Message buses, health checks
5. **System Integration** - Making 3 machines work as one

---

## 💡 Philosophy

> "The best setup script is one you never have to look at twice."

**Design Principles:**
- **Idempotent** - Can run multiple times safely
- **Self-documenting** - Clear output explains what's happening
- **Recoverable** - Can resume from failure points
- **Verifiable** - Built-in health checks
- **Extensible** - Easy to add more machines later

---

## 🚦 Next Steps

### 1. Right Now
```bash
cd ~/Documents/projects/pinkyandbrain
./deploy-to-brain.sh brain@192.168.5.XX
```

### 2. After Setup
- Authorize Claude on brain
- Test 3-agent messaging
- Build your first 3-agent workflow

### 3. Advanced
- Add audio file generation
- Build consensus algorithms
- Implement load balancing
- Create redundant execution patterns

---

## 🆘 Getting Help

**If something breaks:**

1. Check the setup log: `~/setup-brain-*.log`
2. Read troubleshooting: `GETTING-BRAIN-ONLINE.md` (bottom section)
3. Verify prerequisites: `BRAIN-SETUP-CHEATSHEET.md`
4. Test each component individually

**Common Issues:**
- SSH: Check Remote Login enabled
- Message bus: Check port 3100 not in use
- Audio: Check audio-bridge includes brain
- Claude: Authorize from maxyolo's browser

---

## 🎉 Ready?

```bash
cd ~/Documents/projects/pinkyandbrain
./deploy-to-brain.sh brain@192.168.5.81
```

**Let's get brain online!** 🧠

---

Built with: automation, thoughtful defaults, and a lot of shell scripting.

**Philosophy**: "Make it work, make it right, make it automatic."
