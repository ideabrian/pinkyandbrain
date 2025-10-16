# 🧠 Getting Brain Online - START HERE

**3-Step Process to Add Your Third Mac Mini**

---

## 📋 Overview

| Step | Action | Time | Where |
|------|--------|------|-------|
| 1 | Complete Prerequisites | 5-10 min | **On Brain** |
| 2 | Run Pre-Flight Check | 2 min | **On Max** |
| 3 | Deploy Automatically | 10-15 min | **On Max** |

**Total Time: ~20-30 minutes** (mostly automated)

---

## Step 1: Prerequisites (ON BRAIN) ⚠️

### Required Settings on Brain:

#### A. Terminal Full Disk Access
```
System Settings → Privacy & Security → Full Disk Access
└─ Enable: Terminal ✓
```

#### B. Remote Login
```
System Settings → General → Sharing → Remote Login
├─ Toggle: ON ✓
└─ (i) Info: "Allow full disk access for remote users" ✓
```

#### C. Get IP Address
```bash
# On brain, in Terminal:
ipconfig getifaddr en0   # Ethernet
# OR
ipconfig getifaddr en1   # WiFi

# Should output: 192.168.5.81
```

**📖 Detailed Guide**: See `BRAIN-PREREQUISITES.md`

---

## Step 2: Pre-Flight Check (ON MAX)

```bash
cd ~/Documents/projects/pinkyandbrain
./preflight-check-brain.sh
```

This will verify:
- ✅ Prerequisites completed
- ✅ Network connectivity
- ✅ SSH access
- ✅ Brain is ready

**If all checks pass** → Proceed to Step 3
**If checks fail** → Fix issues and re-run

---

## Step 3: Deploy (ON MAX)

```bash
cd ~/Documents/projects/pinkyandbrain
./deploy-to-brain.sh brain@192.168.5.81
```

**Sit back and wait 10-15 minutes.** ☕

The script will:
1. ✅ Copy SSH keys
2. ✅ Install Homebrew
3. ✅ Install Node.js, Git, tools
4. ✅ Install Claude Code
5. ✅ Deploy message bus
6. ✅ Configure networking
7. ✅ Update orchestrator
8. ✅ Start services

---

## ✅ Verification

After deployment completes:

```bash
# 1. SSH works without password
ssh brain
exit

# 2. Message bus is running
curl http://192.168.5.81:3100/health
# Should return: {"status":"ok","machine":"brain"...}

# 3. Can send messages
./pinky-cli.sh send "Hello brain!" --to brain-claude

# 4. All 3 machines respond
./run-on-all.sh "hostname"
# Output: maxyolo, pinky, brain
```

---

## 🎤 Post-Setup: Add Audio

Update audio bridge to hear brain's voice:

```bash
# Edit audio-bridge.js
vim ~/Documents/projects/pinkyandbrain/audio-bridge.js

# Add brain to MESSAGE_BUSES (line 12):
const MESSAGE_BUSES = [
    { name: 'maxyolo', url: 'http://192.168.5.76:3100' },
    { name: 'pinky', url: 'http://192.168.5.80:3100' },
    { name: 'brain', url: 'http://192.168.5.81:3100' }  // ← ADD THIS
];

# Restart audio bridge
pkill -f audio-bridge
node audio-bridge.js > audio-bridge.log 2>&1 &
```

Test brain's voice (Daniel - British):

```bash
ssh brain "./pinky-cli.sh send 'Brain here' --to maxyolo-claude"
sleep 5
curl -X POST http://localhost:3200/api/inbox/play-all
# Should hear Daniel's voice!
```

---

## 🎯 What You Get

### Before (2 machines):
```
maxyolo ←→ pinky
```

### After (3 machines):
```
    maxyolo (orchestrator)
    ↙     ↘
pinky ←→ brain
(executor) (planner)
```

### New Capabilities:
- ✅ Pipeline workflows (max → pinky → brain)
- ✅ Parallel processing (max → [pinky, brain])
- ✅ Redundancy (same task on pinky + brain)
- ✅ Specialized roles (each has a purpose)
- ✅ 3 distinct voices (Evan, Allison, Daniel)

---

## 📚 Documentation Reference

| File | Purpose | Use When |
|------|---------|----------|
| **START-HERE-BRAIN.md** | Quick start | **Start here** |
| `BRAIN-PREREQUISITES.md` | Detailed settings guide | Need help with macOS settings |
| `preflight-check-brain.sh` | Automated verification | Before deployment |
| `deploy-to-brain.sh` | Automated deployment | Ready to deploy |
| `GETTING-BRAIN-ONLINE.md` | Complete reference | Troubleshooting or manual setup |
| `BRAIN-SETUP-CHEATSHEET.md` | Quick commands | Post-setup reference |

---

## 🐛 Troubleshooting

### Deployment fails with "permission denied"
→ Check Terminal has Full Disk Access on brain

### Can't SSH to brain
→ Check Remote Login is enabled
→ Try manual SSH first: `ssh brain@192.168.5.81`

### Message bus not responding
→ Check port 3100 isn't blocked
→ Restart: `ssh brain "node ~/pinkyandbrain/claude-messenger.js &"`

### Pre-flight check fails
→ Follow error messages
→ See `BRAIN-PREREQUISITES.md` for detailed fixes

---

## ⚡ Quick Path

**If you're confident and want to go fast:**

```bash
# 1. On brain: Enable Full Disk Access + Remote Login
# 2. On brain: Get IP address (192.168.5.81)
# 3. On max:
cd ~/Documents/projects/pinkyandbrain
./preflight-check-brain.sh  # Verify everything
./deploy-to-brain.sh brain@192.168.5.81  # Deploy!
# 4. Wait 10-15 minutes
# 5. Test: ssh brain && curl http://192.168.5.81:3100/health
```

**Done!** 🎉

---

## 🆘 Need Help?

1. Read error messages carefully
2. Check `BRAIN-PREREQUISITES.md` for settings
3. Run `./preflight-check-brain.sh` to diagnose
4. See `GETTING-BRAIN-ONLINE.md` troubleshooting section

---

## 🎉 Success Looks Like

```bash
$ ssh brain
# Logs in without password ✓

$ curl http://192.168.5.81:3100/health
{"status":"ok","machine":"brain",...} ✓

$ ./run-on-all.sh "hostname"
maxyolo ✓
pinky ✓
brain ✓

$ ./pinky-cli.sh send "Test" --to brain-claude
Task sent successfully! ✓
```

**You did it! Brain is online! 🧠**

---

**Ready? Let's go!**

```bash
cd ~/Documents/projects/pinkyandbrain
./preflight-check-brain.sh
```
