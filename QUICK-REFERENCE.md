# Pinky and Brain - Quick Reference Card

## 🚀 Common Commands

### SSH & Connectivity
```bash
# Connect to pinky
ssh pinky

# Check machine IP
ipconfig getifaddr en0

# Test connectivity
ping 192.168.5.80
```

### Message Bus
```bash
# Start message bus
node claude-messenger.js &

# Check health
curl http://localhost:3100/health
curl http://192.168.5.80:3100/health  # pinky

# View inbox
curl http://localhost:3100/inbox | jq

# Check unread
curl http://localhost:3100/inbox/unread | jq
```

### Send Messages
```bash
# From maxyolo to pinky
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "maxyolo-claude",
    "to": "pinky-claude",
    "body": "YOUR MESSAGE HERE"
  }'

# From pinky to maxyolo
curl -X POST http://192.168.5.76:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "pinky-claude",
    "to": "maxyolo-claude",
    "body": "YOUR MESSAGE HERE"
  }'
```

### Orchestration
```bash
# Launch multi-agent session
./orchestrator.sh

# Run command on all machines
./run-on-all.sh "hostname && date"

# Send task via workflow
./workflows/01-simple-test.sh
```

### Autonomous Workflows
```bash
# Start message poller
./message-poller.sh &

# Check poller status
ps aux | grep message-poller
tail -f ~/poller-$(hostname -s).log

# Stop poller
kill $(cat /tmp/poller-$(hostname -s).pid)

# Launch task manually
./claude-auto-launcher.sh "Run npm test" task-123
```

## 📡 IP Addresses

- **maxyolo** (MacBook): `192.168.5.76`
- **pinky** (Mac mini): `192.168.5.80`
- **brain** (Mac mini): TBD

## 🔌 Ports

- **SSH**: 22
- **Message Bus**: 3100
- **HTTP**: 80
- **HTTPS**: 443

## 📂 File Locations

### Scripts
- `~/Documents/projects/pinkyandbrain/orchestrator.sh` - Launch multi-agent
- `~/Documents/projects/pinkyandbrain/run-on-all.sh` - Parallel execution
- `~/Documents/projects/pinkyandbrain/message-poller.sh` - Task queue poller
- `~/Documents/projects/pinkyandbrain/claude-messenger.js` - Message bus server

### Workflows
- `~/Documents/projects/pinkyandbrain/workflows/01-simple-test.sh`
- `~/Documents/projects/pinkyandbrain/workflows/02-build-pipeline.sh`
- `~/Documents/projects/pinkyandbrain/workflows/03-autonomous-chain.sh`

### Configuration
- `~/.ssh/config` - SSH shortcuts
- `~/.claude/hooks/session-end.sh` - Auto-send completion
- `~/inbox-$(hostname).json` - Message storage

### Logs
- `~/messenger.log` - Message bus activity
- `~/poller-$(hostname -s).log` - Poller activity
- `~/launcher-$(hostname -s).log` - Auto-launcher activity

## 🎯 Common Workflows

### 1. Start Multi-Agent Session
```bash
cd ~/Documents/projects/pinkyandbrain
./orchestrator.sh
# Two windows open - run `claude` in each
```

### 2. Send Task to Pinky
```bash
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "to": "pinky-claude",
    "type": "task",
    "body": "Run npm test and report results",
    "priority": "high"
  }'
```

### 3. Check for Tasks (on pinky)
```bash
curl http://localhost:3100/inbox/unread | jq '.messages[] | select(.type == "task")'
```

### 4. Run Autonomous Workflow
```bash
# Enable poller
./message-poller.sh &

# Send auto-execute task
curl -X POST http://192.168.5.80:3100/send \
  -d '{"to":"pinky-claude","body":"Run tests","metadata":{"auto_execute":true}}'

# Poller detects and launches automatically
```

## 🐛 Debugging

### Message bus not responding
```bash
# Check process
ps aux | grep claude-messenger

# Restart
pkill -f claude-messenger
node claude-messenger.js &
```

### Can't SSH to pinky
```bash
# Test connectivity
ping 192.168.5.80

# Test SSH port
nc -zv 192.168.5.80 22

# Verbose SSH
ssh -v pinky
```

### Poller not working
```bash
# Check logs
tail -50 ~/poller-$(hostname -s).log

# Check if running
ps aux | grep message-poller

# Restart
kill $(cat /tmp/poller-*.pid)
./message-poller.sh &
```

### Session-end hook not firing
```bash
# Make executable
chmod +x ~/.claude/hooks/session-end.sh

# Test manually
~/.claude/hooks/session-end.sh

# Check for errors
bash -x ~/.claude/hooks/session-end.sh
```

## 📊 Monitoring

### Message Bus Stats
```bash
# Message count
curl -s http://localhost:3100/inbox | jq '.total'

# Unread count
curl -s http://localhost:3100/inbox | jq '.unread'

# Recent messages
curl -s http://localhost:3100/inbox | jq '.messages[-5:]'
```

### System Resources
```bash
# All machines
./run-on-all.sh "top -l 1 | head -10"

# Disk space
./run-on-all.sh "df -h | head -2"

# Memory
./run-on-all.sh "vm_stat | head -5"
```

## 🎓 Learning Resources

1. **SETUP-GUIDE-00-PERMISSIONS.md** - macOS security setup
2. **SETUP-GUIDE-01-SSH.md** - Password-less SSH
3. **SETUP-GUIDE-02-NETWORKING.md** - IP addresses, ports
4. **SETUP-GUIDE-03-ORCHESTRATION.md** - Parallel execution
5. **SETUP-GUIDE-04-CLAUDE-CODE.md** - Install Claude everywhere
6. **SETUP-GUIDE-05-MULTI-AGENT.md** - Message bus communication
7. **SETUP-GUIDE-06-AUTONOMOUS-ORCHESTRATION.md** - Task queues

## 🔐 Security Notes

- SSH keys stored in `~/.ssh/id_machines`
- No passphrase (for automation)
- Message bus has NO authentication (local network only)
- Don't expose port 3100 to internet

## 💡 Tips

1. **Test locally first** - Run commands on localhost before remote
2. **Check logs** - Most issues show up in logs
3. **Use jq** - Makes JSON readable: `| jq`
4. **Background processes** - Use `&` and check with `ps aux`
5. **Clean up** - Kill processes when done: `pkill -f process-name`

## 🚦 Status Checklist

Before starting work:
- [ ] Message buses running on both machines?
- [ ] Can SSH to pinky without password?
- [ ] Claude Code authenticated on both?
- [ ] Pollers running (if using automation)?

Quick check:
```bash
# All in one
curl http://localhost:3100/health && \
curl http://192.168.5.80:3100/health && \
ssh pinky "echo 'SSH works'" && \
echo "✅ All systems operational"
```

---

**Emergency Reset**: If everything breaks, restart from scratch:
```bash
# Kill all processes
pkill -f claude-messenger
pkill -f message-poller

# Restart message buses
node claude-messenger.js &
ssh pinky "node ~/claude-messenger.js &"

# Verify
curl http://localhost:3100/health
curl http://192.168.5.80:3100/health
```

Built for speed. Reference when needed. 🚀
