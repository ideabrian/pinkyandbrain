# Brain Setup - Cheatsheet

## 🚀 One-Command Setup

```bash
cd ~/Documents/projects/pinkyandbrain
./deploy-to-brain.sh brain-user@192.168.5.XX
```

**Wait 10-15 minutes → Done!**

---

## 📋 Prerequisites (5 minutes)

### On Brain:
1. System Settings → Privacy & Security → Full Disk Access → Terminal ✓
2. System Settings → General → Sharing → Remote Login ✓
3. Get IP: `ipconfig getifaddr en0` → Write it down

### From Max:
```bash
# Test SSH
ssh brain-user@192.168.5.XX
# (enter password, then exit)
```

---

## ✅ Verification (2 minutes)

```bash
# SSH works?
ssh brain
exit

# Message bus running?
curl http://192.168.5.XX:3100/health

# Send test message
./pinky-cli.sh send "Hello brain!" --to brain-claude

# All machines responding?
./run-on-all.sh "hostname"
```

---

## 🎤 Audio Test (3 voices)

```bash
# Max speaks (Evan)
./pinky-cli.sh send "Max here" --to pinky-claude

# Pinky speaks (Allison Enhanced)
ssh pinky "./pinky-cli.sh send 'Pinky here' --to maxyolo-claude"

# Brain speaks (Daniel - British)
ssh brain "./pinky-cli.sh send 'Brain here' --to maxyolo-claude"

# Play all
sleep 5
curl -X POST http://localhost:3200/api/inbox/play-all
```

---

## 🔧 Post-Setup Tasks

### 1. Authorize Claude on Brain
```bash
ssh brain
claude
# Visit URL, authorize, then /exit
```

### 2. Add Brain to Audio Bridge
```bash
vim ~/Documents/projects/pinkyandbrain/audio-bridge.js

# Add to MESSAGE_BUSES (line 12):
{ name: 'brain', url: 'http://192.168.5.XX:3100' }

# Restart
pkill -f audio-bridge
node audio-bridge.js > audio-bridge.log 2>&1 &
```

### 3. Test 3-Agent Workflow
```bash
# Parallel tasks
./pinky-cli.sh send "Task A" --to pinky-claude
./pinky-cli.sh send "Task B" --to brain-claude

# Pipeline
./pinky-cli.sh send "Analyze and send to brain" --to pinky-claude
```

---

## 🐛 Quick Fixes

### SSH fails
```bash
# On brain: enable Remote Login
# System Settings → General → Sharing → Remote Login
```

### Message bus not running
```bash
ssh brain "node ~/claude-messenger.js > ~/messenger.log 2>&1 &"
```

### No audio from brain
```bash
# Check audio-bridge includes brain
grep "brain" ~/Documents/projects/pinkyandbrain/audio-bridge.js
```

---

## 📊 Final Network

```
maxyolo: 192.168.5.76:3100 (orchestrator)
pinky:   192.168.5.80:3100 (executor)
brain:   192.168.5.XX:3100 (planner)
```

---

## 🎯 Success = All Green

- [ ] `ssh brain` (no password)
- [ ] `curl http://brain-ip:3100/health` (OK)
- [ ] `./run-on-all.sh "date"` (3 responses)
- [ ] Messages to brain-claude work
- [ ] 3 distinct voices in audio

---

**Done! 🧠 Ready to take over the world.**

Full docs: `GETTING-BRAIN-ONLINE.md`
