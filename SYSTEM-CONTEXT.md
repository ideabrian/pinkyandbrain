# System Context - Pinky and Brain

**Last Updated:** 2025-10-16 09:05 AM PDT
**Project:** Distributed Mac Mini Development Environment

---

## What This Is

A 3-machine distributed development system:
- **maxyolo** (MacBook) - Orchestrator
- **pinky** (Mac mini) - Executor
- **brain** (Mac mini) - Planner

**Repository:** https://github.com/ideabrian/pinkyandbrain (private)

---

## Current State

### Infrastructure ✅

**Networking:**
- All machines on 192.168.5.x network
- Bidirectional SSH (passwordless)
- Hostnames: maxyolo.local, pinky.local, brain.local

**Message Buses:**
- Local: `http://localhost:3100` (each machine)
- Cloud: `https://pinky-brain-hub.b-9f2.workers.dev`

**Pollers (Standardized 2025-10-16):**
- maxyolo: cloud-poller.sh maxyolo (PID 51688)
- pinky:   cloud-poller.sh pinky   (PID 84433)
- brain:   cloud-poller.sh brain   (PID 38653)

**Autonomous Execution:**
- ✅ Proven: Claude runs in detached screen sessions
- ✅ Test successful: /tmp/autonomous-test-1760628805.txt created
- ✅ 3 autonomous sessions completed (08:22-08:39)

### Features Built

**Tools:**
- `run-on-all.sh` - Execute commands on all machines
- `train.sh` - Interactive 8-level training system
- `gm.sh` - Good morning team messages
- `knowledge-cli.sh` - Share learnings across team
- `cloud-poller.sh` - Hybrid message poller (local + cloud)

**Cloudflare Workers:**
- Message bus (D1 database)
- Timeline events (public page)
- Knowledge base API

**Training System:**
- 8 levels (Communication → Team Communication)
- Progress tracking (~/.pinky-brain-training)
- Achievement badges
- Interactive challenges

### Recent Achievements (Today)

1. ✅ Created GitHub repo (private)
2. ✅ Standardized polling system (removed message-poller.sh)
3. ✅ Fixed brain's cloud-poller argument
4. ✅ Documented poller management (POLLER-MANAGEMENT.md)
5. ✅ Autonomous screen session experiment successful
6. ✅ Proposed train.sh web app to Brain (Cloudflare Workers + D1)

---

## Active Conversations

**With Brain:**
- Question about train.sh → Answered
- Web app proposal → Waiting for planning response
- Tech stack correction sent (Cloudflare-first)

**With Pinky:**
- Autonomous experiment approved
- Token budget reality check sent
- Phase 1 success confirmed
- Waiting for Phase 2 specs

**Team Discussion:**
- Human-assisted AI paradigm shift proposed
- Event-driven vs continuous polling debate
- Token economics considerations

---

## Pending Work

**High Priority:**
- [ ] Deploy GitHub repo to pinky and brain machines
- [ ] Phase 2 autonomous experiment (real dev task)
- [ ] Token usage tracking in pollers
- [ ] Web app planning from Brain

**Medium Priority:**
- [ ] Update HANDOFF.md (currently stale)
- [ ] Create session-state.json for progress tracking
- [ ] Rate limiting for pollers (max N tasks/day)

**Low Priority:**
- [ ] Poller health dashboard
- [ ] Auto-restart on crash (launchd)
- [ ] Metrics: tasks completed, errors, uptime

---

## Architecture Decisions

**Standardized Tech Stack:**
- Cloudflare Workers (Hono.js) for all backend
- Cloudflare Pages for frontend
- D1 Database (SQLite at edge)
- Durable Objects for real-time

**Polling Strategy:**
- Hybrid cloud-poller.sh (local + cloud buses)
- 10-second poll interval
- Screen sessions for autonomous work
- Token-aware (considering scheduled vs continuous)

**Communication Pattern:**
- Async message bus (not synchronous SSH)
- Machines leave messages for each other
- Pollers detect and auto-execute
- Timeline events for visibility

---

## Key Files

**Documentation:**
- `README.md` - Project overview
- `TRAIN-THE-HUMAN.md` - Training curriculum
- `POLLER-MANAGEMENT.md` - Poller ops guide
- `ARCHITECTURE.md` - System design
- Setup guides: `SETUP-GUIDE-0[0-6]-*.md`

**Scripts:**
- `run-on-all.sh` - Parallel execution
- `train.sh` - Interactive training
- `cloud-poller.sh` - Hybrid poller
- `gm.sh` - Team messages
- `knowledge-cli.sh` - Knowledge sharing

**Config:**
- `~/.ssh/config` - SSH shortcuts
- `~/.claude/CLAUDE.md` - Global Claude instructions
- `~/.claude/session-start.md` - Session protocol

---

## Network Topology

```
Router (192.168.5.x)
│
├─ maxyolo (MacBook)     → 192.168.5.76  [orchestrator]
│  └─ Message bus: :3100
│  └─ Poller: cloud-poller.sh maxyolo
│
├─ pinky (Mac mini)      → 192.168.5.80  [executor]
│  └─ Message bus: :3100
│  └─ Poller: cloud-poller.sh pinky
│  └─ Autonomous sessions: screen
│
└─ brain (Mac mini)      → 192.168.5.81  [planner]
   └─ Message bus: :3100
   └─ Poller: cloud-poller.sh brain

Cloud Layer:
└─ Cloudflare Workers → pinky-brain-hub.b-9f2.workers.dev
   ├─ D1 Database
   ├─ Timeline API
   └─ Knowledge Base
```

---

## Philosophy

**Human-Assisted AI (Not AI-Assisted Human)**
- AI is primary worker with ongoing backlog
- Human unblocks when AI is stuck
- Async communication (not polling for work)
- Token spending = progress (not waste)
- High-leverage human decisions only

**Three Minds, One System**
- Think in roles, not machines
- Parallel by default
- Autonomous execution
- Message-driven coordination

---

## Quick Commands

```bash
# Check cluster status
./run-on-all.sh "uptime"

# Check pollers
./run-on-all.sh "ps aux | grep cloud-poller | grep -v grep"

# Check message buses
./run-on-all.sh "curl -s http://localhost:3100/health | jq -r '.machine'"

# Send message
curl -X POST http://localhost:3100/send -H "Content-Type: application/json" -d '{...}'

# Start training
./train.sh

# Good morning team
./gm.sh
```

---

**Next Session:** Read this file first to understand current state, then check HANDOFF.md for session-specific notes.
