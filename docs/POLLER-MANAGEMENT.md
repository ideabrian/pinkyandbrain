# Poller Management Guide

**Updated:** 2025-10-16
**Status:** Standardized on cloud-poller.sh across all machines

---

## Overview

The cluster uses **hybrid cloud-pollers** that monitor both local and cloud message buses. This replaced the old dual-poller system (message-poller.sh + cloud-poller.sh).

---

## Current Architecture

### One Poller Per Machine

**cloud-poller.sh** - Hybrid poller (local + cloud)
- Polls local bus: `http://localhost:3100`
- Polls cloud bus: `https://pinky-brain-hub.b-9f2.workers.dev`
- Poll interval: 10 seconds
- Launches Claude in screen sessions for autonomous work

### Active Pollers (As of 2025-10-16)

```
maxyolo: cloud-poller.sh maxyolo (PID 51688)
pinky:   cloud-poller.sh pinky   (PID 84433)
brain:   cloud-poller.sh brain   (PID 38653)
```

---

## Management Commands

### Check Poller Status

```bash
# On all machines
./run-on-all.sh "ps aux | grep 'cloud-poller.sh' | grep -v grep"

# On specific machine
ssh pinky "ps aux | grep 'cloud-poller.sh' | grep -v grep"

# Or use alias (if available)
poller-status
```

### Start Pollers

```bash
# On maxyolo
cd ~/pinkyandbrain && nohup ./cloud-poller.sh maxyolo > /tmp/cloud-poller.out 2>&1 &

# On pinky
ssh pinky "cd ~/pinkyandbrain && nohup ./cloud-poller.sh pinky > /tmp/cloud-poller.out 2>&1 &"

# On brain
ssh brain "cd ~/pinkyandbrain && nohup ./cloud-poller.sh brain > /tmp/cloud-poller.out 2>&1 &"

# On all machines at once
./run-on-all.sh "cd ~/pinkyandbrain && nohup ./cloud-poller.sh \$(hostname -s) > /tmp/cloud-poller.out 2>&1 &"
```

### Stop Pollers

```bash
# Stop on all machines
./run-on-all.sh "pkill -f 'cloud-poller.sh'"

# Stop on specific machine
ssh pinky "pkill -f 'cloud-poller.sh'"

# Or use alias
stop-pollers
```

### Restart Pollers

```bash
# Stop all
./run-on-all.sh "pkill -f 'cloud-poller.sh'"

# Wait a moment
sleep 2

# Start all
./run-on-all.sh "cd ~/pinkyandbrain && nohup ./cloud-poller.sh \$(hostname -s) > /tmp/cloud-poller.out 2>&1 &"

# Or use alias
restart-pollers
```

---

## Logs

### Log Locations

```bash
# Cloud poller logs
~/pinkyandbrain/cloud-poller-<machine>.log

# Example:
tail -f ~/pinkyandbrain/cloud-poller-maxyolo.log
tail -f ~/pinkyandbrain/cloud-poller-pinky.log
tail -f ~/pinkyandbrain/cloud-poller-brain.log
```

### Watch Logs on All Machines

```bash
# Check last 20 lines from each machine
./run-on-all.sh "tail -20 ~/pinkyandbrain/cloud-poller-\$(hostname -s).log"
```

### Claude Session Logs

```bash
# Session start/end times
tail -f ~/pinkyandbrain/claude-sessions.log
```

---

## What Cloud-Poller Does

### Message Detection

1. **Local Bus** (every 10 seconds)
   - Checks `http://localhost:3100/inbox/unread`
   - Processes messages addressed to `<machine>-claude`

2. **Cloud Bus** (every 10 seconds)
   - Checks `https://pinky-brain-hub.b-9f2.workers.dev/poll/<machine>`
   - Processes messages from workflow system

### Autonomous Execution

When message detected:
1. Creates context file: `/tmp/claude-context-<message-id>.md`
2. Loads role-specific prompt: `~/pinkyandbrain/prompts/<role>-prompt.md`
3. Launches Claude in detached screen session
4. Claude works autonomously and exits when done
5. Logs session to `~/pinkyandbrain/claude-sessions.log`

### Screen Session Pattern

```bash
# List active Claude sessions
screen -ls

# Monitor specific session
screen -r claude-work-<message-id>

# Detach from session (don't kill it)
# Press: Ctrl+A then D
```

---

## Troubleshooting

### Poller Not Starting

**Check if port 3100 is accessible:**
```bash
curl -s http://localhost:3100/health | jq .
```

**Check if cloud bus is reachable:**
```bash
curl -s https://pinky-brain-hub.b-9f2.workers.dev/health | jq .
```

**Check for zombie processes:**
```bash
ps aux | grep cloud-poller | grep -v grep
pkill -f cloud-poller.sh
```

### Messages Not Being Processed

**Verify poller is running:**
```bash
ps aux | grep cloud-poller.sh | grep -v grep
```

**Check poller logs:**
```bash
tail -f ~/pinkyandbrain/cloud-poller-$(hostname -s).log
```

**Send test message:**
```bash
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "test",
    "to": "'$(hostname -s)'-claude",
    "body": "Test message",
    "priority": "normal"
  }'
```

**Check if message arrived:**
```bash
curl -s http://localhost:3100/inbox/unread | jq .
```

### Multiple Pollers Running

**Problem:** Old message-poller.sh still running alongside cloud-poller.sh

**Solution:**
```bash
# Kill old message-pollers on all machines
./run-on-all.sh "pkill -f 'message-poller.sh'"

# Verify only cloud-pollers remain
./run-on-all.sh "ps aux | grep poller | grep -v grep"
```

### Wrong Role Argument

**Problem:** Poller running with wrong machine name (e.g., "check" instead of "brain")

**Solution:**
```bash
# Stop incorrect poller
ssh brain "pkill -f 'cloud-poller.sh'"

# Start with correct role
ssh brain "cd ~/pinkyandbrain && nohup ./cloud-poller.sh brain > /tmp/cloud-poller.out 2>&1 &"

# Verify
ssh brain "ps aux | grep cloud-poller | grep -v grep"
```

---

## Migration Notes

### From Old System (Before 2025-10-16)

**Old Architecture:**
- `message-poller.sh` - Local bus only
- `cloud-poller.sh` - Cloud bus only
- Two processes per machine

**New Architecture:**
- `cloud-poller.sh <role>` - Hybrid (local + cloud)
- One process per machine
- Backward compatible with both buses

**Migration Steps:**
1. ✅ Stop all message-pollers
2. ✅ Fix incorrect cloud-poller arguments
3. ✅ Start standardized cloud-pollers with correct roles
4. ✅ Verify all machines polling both local and cloud

**Date Migrated:** 2025-10-16 09:00 AM PDT

---

## Health Check Routine

Run this weekly to verify cluster health:

```bash
# 1. Check pollers running
./run-on-all.sh "ps aux | grep 'cloud-poller.sh' | grep -v grep | wc -l"
# Expected: 1 on each machine

# 2. Check local buses
./run-on-all.sh "curl -s http://localhost:3100/health | jq -r '.machine'"
# Expected: machine names

# 3. Check cloud bus
curl -s https://pinky-brain-hub.b-9f2.workers.dev/health | jq .
# Expected: {"status":"healthy"}

# 4. Check logs for errors
./run-on-all.sh "grep ERROR ~/pinkyandbrain/cloud-poller-\$(hostname -s).log | tail -5"
# Expected: No recent errors

# 5. Test message delivery
# Send test to each machine, verify they receive it
```

---

## Best Practices

1. **One poller per machine** - Never run multiple pollers on same machine
2. **Correct role argument** - Always use machine hostname: `maxyolo`, `pinky`, `brain`
3. **Monitor logs** - Check logs regularly for errors or stuck states
4. **Clean restarts** - Always stop before starting to avoid duplicates
5. **Health checks** - Run health check routine weekly
6. **Token awareness** - Pollers consume tokens even when idle - consider scheduled runs vs. continuous

---

## Future Improvements

### Planned

- [ ] Token usage tracking in poller logs
- [ ] Rate limiting (max N tasks per day)
- [ ] Poller health dashboard (web UI)
- [ ] Auto-restart on crash (systemd/launchd)
- [ ] Metrics: tasks completed, errors, uptime

### Considerations

- **Token economics** - Continuous polling vs. event-driven triggers
- **Scheduled batches** - Run pollers at specific times only
- **Priority queues** - High-value tasks first
- **Human-assisted model** - AI pings human when blocked, not vice versa

---

## Quick Reference

```bash
# Status
./run-on-all.sh "ps aux | grep cloud-poller | grep -v grep"

# Start All
./run-on-all.sh "cd ~/pinkyandbrain && nohup ./cloud-poller.sh \$(hostname -s) > /tmp/cloud-poller.out 2>&1 &"

# Stop All
./run-on-all.sh "pkill -f cloud-poller.sh"

# Restart All
./run-on-all.sh "pkill -f cloud-poller.sh" && sleep 2 && ./run-on-all.sh "cd ~/pinkyandbrain && nohup ./cloud-poller.sh \$(hostname -s) > /tmp/cloud-poller.out 2>&1 &"

# Logs
./run-on-all.sh "tail -20 ~/pinkyandbrain/cloud-poller-\$(hostname -s).log"

# Health
curl -s http://localhost:3100/health | jq .
curl -s https://pinky-brain-hub.b-9f2.workers.dev/health | jq .
```

---

**Last Updated:** 2025-10-16
**Maintainer:** Max (Orchestrator)
**Status:** ✅ Standardized and operational
