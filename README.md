# Pinky and Brain - Distributed Mac Mini Setup

**Three machines. One brain. Infinite possibilities.**

## What Is This?

A distributed development environment using 3 Mac computers:
- **maxyolo** (MacBook) - The orchestrator
- **pinky** (Mac mini) - The executor
- **brain** (Mac mini) - The planner

**Philosophy**: Three less-powerful machines at the same price as one powerful machine, with the added benefit of learning networking, orchestration, and distributed systems.

## Quick Start

```bash
# Connect to pinky
ssh pinky

# Run command on all machines
./run-on-all.sh "hostname && date"

# Check system resources everywhere
./run-on-all.sh "top -l 1 | head -5"
```

## Setup Guides (In Order)

1. **[SETUP-GUIDE-00-PERMISSIONS.md](./SETUP-GUIDE-00-PERMISSIONS.md)**
   - Grant Full Disk Access to Terminal
   - Enable Remote Login
   - Security settings

2. **[SETUP-GUIDE-01-SSH.md](./SETUP-GUIDE-01-SSH.md)**
   - Password-less SSH setup
   - Key generation & copying
   - SSH config for easy access

3. **[SETUP-GUIDE-02-NETWORKING.md](./SETUP-GUIDE-02-NETWORKING.md)**
   - Understanding IP addresses
   - Network topology
   - Ports & services
   - Hostname resolution

4. **[SETUP-GUIDE-03-ORCHESTRATION.md](./SETUP-GUIDE-03-ORCHESTRATION.md)**
   - Run commands across all machines
   - Parallel execution
   - Real-world use cases
   - Troubleshooting

5. **[SETUP-GUIDE-04-CLAUDE-CODE.md](./SETUP-GUIDE-04-CLAUDE-CODE.md)**
   - Install Homebrew on all machines
   - Install Node.js and nvm
   - Install Claude Code everywhere
   - Login and parallel sessions

6. **[SETUP-GUIDE-05-MULTI-AGENT.md](./SETUP-GUIDE-05-MULTI-AGENT.md)**
   - Build HTTP message bus
   - Deploy across machines
   - Multi-agent Claude Code communication
   - Orchestrator automation

7. **[SETUP-GUIDE-06-AUTONOMOUS-ORCHESTRATION.md](./SETUP-GUIDE-06-AUTONOMOUS-ORCHESTRATION.md)**
   - Task queue system
   - Autonomous agent coordination
   - Session-end hooks
   - Workflow automation

8. **[UTILITIES-GUIDE.md](./UTILITIES-GUIDE.md)**
   - `pinky` CLI tool
   - Template library
   - Git integration
   - Live dashboard

9. **[SETUP-BRAIN.md](./SETUP-BRAIN.md)** ⭐
   - Add third Mac mini to system
   - Complete three-agent orchestration
   - Advanced workflows

## Network Map

```
Router (192.168.5.x)
│
├─ maxyolo (laptop)    → 192.168.5.76  [orchestrator]
├─ pinky (Mac mini)    → 192.168.5.80  [executor]
└─ brain (Mac mini)    → [TBD]         [planner]
```

## Current Capabilities

✅ **SSH Access**: Password-less SSH from maxyolo to pinky
✅ **Orchestration**: Run commands on multiple machines in parallel
✅ **Network Understanding**: IP addresses, ports, hostname resolution
✅ **Multi-Agent Communication**: Claude Code sessions talking via HTTP message bus
✅ **Autonomous Workflows**: Task queues, pollers, auto-execution
⏳ **Brain Setup**: Pending when third Mac mini comes online

## Use Cases

### 1. Multi-Project Development
```bash
# maxyolo: Frontend dev server
# pinky: Backend API
# brain: Database & monitoring
```

### 2. Parallel Testing
```bash
./run-on-all.sh "cd ~/project && npm test"
# All machines run tests simultaneously
```

### 3. Learning Distributed Systems
- Real hardware, real network
- No cloud costs
- Hands-on experience with orchestration
- Fault tolerance & reliability testing

### 4. Load Testing
```bash
# Each machine simulates users
./run-on-all.sh "ab -n 1000 -c 10 http://localhost:3000/"
```

## Scripts & Tools

### `run-on-all.sh`
Execute commands across all machines in parallel
```bash
./run-on-all.sh "command here"
```

### SSH Config (`~/.ssh/config`)
Quick access to machines:
```
Host pinky
    HostName 192.168.5.80
    User pinky
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
```

Usage: `ssh pinky`

## Key Learnings

**Networking Basics**
- Private IP addresses (192.168.x.x)
- Ports (SSH=22, HTTP=80, HTTPS=443)
- Hostname resolution (.local domains)
- Broadcast addresses & subnets

**SSH & Security**
- Key-based authentication
- SSH agent for key management
- Config files for easy access
- Password-less connections

**Parallel Execution**
- Background processes (&)
- Wait command
- Exit code handling
- Color-coded output

## Next Steps

### When Brain Comes Online
1. Get brain's IP address
2. Run SSH setup (SETUP-GUIDE-01-SSH.md)
3. Add to `run-on-all.sh`
4. Test three-machine orchestration

### Advanced Ideas
- [x] Run Claude Code sessions on each machine
- [x] Multi-agent communication via HTTP message bus
- [x] Autonomous task queue orchestration
- [x] Session-end hooks for task chaining
- [ ] Shared file system (NFS or syncthing)
- [ ] Monitoring dashboard with metrics
- [ ] Load balancer setup
- [ ] Database replication
- [ ] Container orchestration

## Troubleshooting

**Can't SSH to a machine?**
```bash
# Check if it's reachable
ping 192.168.5.80

# Check if SSH is enabled
nc -zv 192.168.5.80 22

# Test with verbose output
ssh -v pinky
```

**Command fails on one machine?**
- Test command locally first
- Check if software is installed
- Verify file paths exist
- Check permissions

**Want to reset SSH setup?**
```bash
# On the remote machine
rm ~/.ssh/authorized_keys

# Start over from SETUP-GUIDE-01-SSH.md
```

## Resources

**What We Built**
- Distributed command execution
- Network communication
- Parallel processing
- System administration skills

**What You're Learning**
- Networking fundamentals
- SSH & security
- Shell scripting
- Distributed systems concepts
- Infrastructure as code

**Skills That Transfer**
- Everything here scales to cloud servers
- Same SSH principles work with AWS/GCP/Azure
- Orchestration patterns apply to Kubernetes
- Parallel execution = understanding async programming

## The Philosophy

> "Three less-powerful computers at the same price as one powerful machine"

**Why this works:**
1. **Separate contexts** - No mixing concerns, each machine has a purpose
2. **Real distributed system** - Learn by doing, not simulating
3. **Cost effective** - Same total price, more flexibility
4. **Skills compound** - Learning now pays off for cloud/enterprise work

**The Name:**
- **Pinky**: "Gee, Brain, what do you want to do tonight?"
- **Brain**: "The same thing we do every night, Pinky - try to take over the world!"

Except here, we're taking over the world... of distributed computing. 🌍

---

**Project Status**: Phase 3 Complete (Autonomous orchestration!)
**Current Achievement**:
- ✅ Multi-agent communication via HTTP message bus
- ✅ Task queue system with autonomous execution
- ✅ Workflow automation with session hooks
- ✅ Example workflows: test, build, deploy

**Next Phase**: Add brain to create three-agent autonomous system

Built with curiosity, automation, and a lot of SSH keys.
