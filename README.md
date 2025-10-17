# Pinky and Brain - Distributed Mac Mini Setup

**Three machines. One brain. Infinite possibilities.**

## What Is This?

A distributed development environment using 3 Mac computers coordinating via Claude agents:
- **brain** (Mac mini) - The planner and decision-maker
- **pinky** (Mac mini) - The code executor
- **maxyolo** (MacBook) - The reviewer and integrator

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

## Architecture

### Network Map
```
Router (192.168.5.x)
│
├─ brain.local (Mac mini)     → 192.168.5.6   [planner]
├─ pinky.local (Mac mini)     → 192.168.5.4   [executor]
└─ max.local (MacBook)        → 192.168.5.2   [reviewer]
```

### Communication Flow
```
brain (planner)
  ↓ technical specs
pinky (executor)
  ↓ implementation
max (reviewer)
  ↓ integration
  ↑ feedback loop
```

### Cloud Infrastructure
- **Message Bus**: Cloudflare Workers (pinky-brain-hub.b-9f2.workers.dev)
- **Knowledge Base**: Cloudflare Pages (knowledge-search.pages.dev)
- **Job Board**: FunJobs.ai (funjobs-ai.b-9f2.workers.dev)

## Current Capabilities

✅ **Three-Machine Cluster**: All machines online and coordinated
✅ **SSH Access**: Password-less SSH between all machines
✅ **Claude Agent Orchestration**: Specialized roles (planner/executor/reviewer)
✅ **Multi-Agent Communication**: Local HTTP message bus + Cloud Cloudflare Workers
✅ **Autonomous Polling**: Cloud-based message queue with auto-execution
✅ **Voting System**: Democratic decision-making for critical actions
✅ **Knowledge Base**: Searchable documentation via Cloudflare Pages
✅ **Workflow Automation**: Task queues, session hooks, auto-chaining

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

## Key Services & Scripts

### Voting System
Democratic decision-making for critical actions:
```bash
# Initialize a vote
./vote-simple.sh "Should we deploy to production?" brain pinky max

# Check vote status
cat votes/vote-*.json | jq .
```

### Cloud Poller
Autonomous message polling from Cloudflare Workers:
```bash
# Check poller status
ps aux | grep cloud-poller

# View logs
tail -f cloud-poller-*.log
```

### Message Bus
Local and cloud-based agent communication:
```bash
# Send local message
curl -X POST http://max.local:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"pinky","to":"max","body":"Hello!"}'

# Send via cloud (with approval)
curl -X POST https://pinky-brain-hub.b-9f2.workers.dev/send \
  -H "Content-Type: application/json" \
  -d '{"from":"pinky","to":"brain","body":"Cloud message"}'
```

### `run-on-all.sh`
Execute commands across all machines in parallel:
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

### Completed Milestones
- [x] Three-machine cluster fully operational
- [x] Claude Code sessions on each machine with specialized roles
- [x] Multi-agent communication (local + cloud)
- [x] Autonomous task queue orchestration
- [x] Voting system for democratic decisions
- [x] Cloud polling for async workflows
- [x] Knowledge base with search UI
- [x] Session-end hooks for task chaining

### Upcoming Features
- [ ] Live metrics dashboard (timeline.html + dashboard.html)
- [ ] Shared file system (NFS or syncthing)
- [ ] Load balancer for distributed workloads
- [ ] Automated testing pipeline across machines
- [ ] Container orchestration (Docker Swarm)
- [ ] Blog deployment (sawdust.ai strategy)

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

## Project Status

**Phase**: Production (Three-agent autonomous system operational!)

**Latest Achievement**:
- ✅ Three-machine cluster with specialized Claude agents
- ✅ Democratic voting system for critical decisions
- ✅ Cloud-based async communication via Cloudflare Workers
- ✅ Knowledge base with searchable documentation
- ✅ Autonomous workflow orchestration

**Current Project**: GitHub repository setup (approved via unanimous vote 3/3)

**Next Phase**: Blog deployment (sawdust.ai) documenting the infinite loop debugging adventure

---

Built with curiosity, automation, and an abundance of SSH keys.

**Repository**: [github.com/ideabrian/pinkyandbrain](https://github.com/ideabrian/pinkyandbrain)
