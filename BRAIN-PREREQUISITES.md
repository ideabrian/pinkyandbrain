# Brain Prerequisites - Visual Guide

**Complete these steps ON BRAIN before running deployment**

---

## ✅ Checklist

- [ ] Terminal has Full Disk Access
- [ ] Remote Login enabled
- [ ] Remote users have full disk access
- [ ] Brain connected to network (WiFi or Ethernet)
- [ ] Know brain's IP address

---

## 🔐 Step 1: Terminal Full Disk Access (CRITICAL)

### Path:
```
System Settings → Privacy & Security → Full Disk Access
```

### Instructions:

1. **Open System Settings** on brain
2. Click **Privacy & Security** in sidebar
3. Scroll down to **Full Disk Access**
4. Click the **(i)** or **(+)** button
5. Find and toggle ON: **Terminal**
6. If Terminal is open, **quit and reopen it**

### Why?
Setup scripts need to access system directories and create files. Without this, deployment will fail.

### Verify:
```bash
# On brain, in Terminal:
ls ~/Library
# Should work without permission error
```

---

## 🌐 Step 2: Remote Login (CRITICAL)

### Path:
```
System Settings → General → Sharing → Remote Login
```

### Instructions:

1. **Open System Settings** on brain
2. Click **General** in sidebar
3. Click **Sharing**
4. Toggle ON: **Remote Login**
5. Click the **(i)** info button next to Remote Login
6. Check: **"Allow full disk access for remote users"**
7. Verify your username is in the **"Only these users"** list

### Why?
This enables SSH access so maxyolo can deploy to brain remotely.

### Verify:
```bash
# From maxyolo:
ssh brain@192.168.5.81
# Should prompt for password (first time only)
```

---

## 🔌 Step 3: Network Setup

### Get Brain's IP Address

**On brain, open Terminal:**

```bash
# For Ethernet:
ipconfig getifaddr en0

# For WiFi:
ipconfig getifaddr en1

# Should output: 192.168.5.81 (or similar)
```

### Test Connectivity

**From maxyolo:**

```bash
# Test ping
ping 192.168.5.81

# Should see responses:
# 64 bytes from 192.168.5.81: icmp_seq=0 time=2.123 ms
# (Press Ctrl+C to stop)
```

---

## 🧪 Automated Pre-Flight Check

**Run this script to verify everything:**

```bash
cd ~/Documents/projects/pinkyandbrain
./preflight-check-brain.sh
```

This will:
- ✅ Prompt you through each prerequisite
- ✅ Test network connectivity
- ✅ Test SSH connection
- ✅ Verify brain is ready for deployment

---

## 📝 Quick Reference

### System Settings Paths (macOS Sonoma/Ventura)

| Setting | Path |
|---------|------|
| Full Disk Access | System Settings → Privacy & Security → Full Disk Access |
| Remote Login | System Settings → General → Sharing → Remote Login |
| Network Info | System Settings → Network → (select connection) → Details |

### macOS Versions

**Sonoma (14.x) / Ventura (13.x):**
- "System Settings" app (new design)

**Monterey (12.x) and earlier:**
- "System Preferences" app (old design)
- Paths similar but may vary slightly

---

## ⚠️ Common Issues

### "Terminal doesn't have Full Disk Access"

**Solution:**
1. System Settings → Privacy & Security → Full Disk Access
2. Find Terminal in the list
3. Toggle it OFF, then ON again
4. Quit Terminal completely (⌘Q)
5. Reopen Terminal

### "Remote Login not working"

**Check:**
- Remote Login toggle is ON (green)
- "Allow full disk access for remote users" is checked
- Your username appears in allowed users list
- Firewall isn't blocking SSH (port 22)

### "Can't connect via SSH"

**Try:**
```bash
# Manual first-time connection
ssh brain@192.168.5.81

# Accept fingerprint (type: yes)
# Enter password
# Type: exit

# Then test again
```

### "Wrong IP address"

**Find it again:**
```bash
# On brain
ipconfig getifaddr en0  # Ethernet
ipconfig getifaddr en1  # WiFi
```

---

## 🎯 Ready?

Once all prerequisites are complete:

```bash
cd ~/Documents/projects/pinkyandbrain

# Run pre-flight check
./preflight-check-brain.sh

# If all checks pass, deploy!
./deploy-to-brain.sh brain@192.168.5.81
```

---

## 📸 Screenshot Reference

### Full Disk Access Screen:
```
System Settings
└─ Privacy & Security
   └─ Full Disk Access
      ├─ Terminal ✓ (toggle ON)
      ├─ iTerm2 ✓ (if using)
      └─ Other apps...
```

### Remote Login Screen:
```
System Settings
└─ General
   └─ Sharing
      ├─ Remote Login ✓ (toggle ON)
      │  └─ (i) Info button
      │     ├─ ✓ Allow full disk access for remote users
      │     └─ Only these users: brain ✓
      └─ Other sharing options...
```

---

## 🆘 Need Help?

If you're stuck:

1. Run `./preflight-check-brain.sh` - it will guide you
2. Check `GETTING-BRAIN-ONLINE.md` - full troubleshooting section
3. Verify brain is powered on and connected to network
4. Try manual SSH first to verify basic connectivity

---

**Time to complete prerequisites: 5-10 minutes**

**Once done, deployment is automatic!**
