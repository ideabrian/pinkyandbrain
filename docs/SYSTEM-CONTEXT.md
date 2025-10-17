# System Context - Pinky and Brain

**Last Updated:** 2025-10-16 10:59 PM PDT
**Project:** Distributed Mac Mini Development Environment

---

## What This Is

A 3-machine distributed development system with **fully autonomous AI messaging**:
- **brain** (Mac mini) - Planner and strategic coordinator
- **pinky** (Mac mini) - Executor and code implementer
- **maxyolo** (MacBook) - Orchestrator and reviewer

**Repository:** https://github.com/ideabrian/pinkyandbrain (private)

---

## Current State

### Infrastructure ✅

**Networking:**
- All machines on 192.168.5.x network
- Unified SSH key (brain-cluster) across all machines
- Bidirectional SSH (passwordless ssh/scp/rsync)
- Hostnames: brain.local (192.168.5.4), pinky.local (192.168.5.80), maxyolo.local (192.168.5.76)

**Message Buses:**
- Local: `http://localhost:3100` (each machine has its own)
- Cloud: `https://pinky-brain-hub.b-9f2.workers.dev`
- **Architecture:** Each machine's local bus is independent; pollers watch their own local bus

**Pollers (Fixed 2025-10-16 PM):**
- brain:   cloud-poller.sh brain (with claude -p execution)
- pinky:   cloud-poller.sh pinky (PID 95404, PATH fix applied)
- maxyolo: cloud-poller.sh maxyolo (status needs verification)

**Autonomous Execution:** ✅ FULLY OPERATIONAL
- ✅ **BREAKTHROUGH:** claude -p executes in background without TTY
- ✅ **AUTO-RESPONSE:** send-response.sh waits for completion and sends replies
- ✅ **COMPLETE LOOP:** Message → Detect (10s) → Process (8-12s) → Respond → Total: 18-22s
- ✅ **PATH FIX:** Export PATH before claude to include /opt/homebrew/bin
- ✅ **TESTED:** Multiple successful end-to-end message exchanges
- ❌ **DEPRECATED:** Screen sessions (replaced by claude -p)

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

### Recent Achievements (Today - Evening Session)

**MAJOR BREAKTHROUGH - Autonomous Messaging System:**
1. ✅ **Found and Fixed Critical Bug:** cloud-poller was creating context files but never launching Claude
2. ✅ **Implemented claude -p Solution:** Background execution without TTY complexity
3. ✅ **Created send-response.sh:** Automatic response handler that waits and sends replies
4. ✅ **Solved PATH Issue:** Background processes need explicit PATH=/opt/homebrew/bin:$PATH
5. ✅ **End-to-End Testing:** Verified complete autonomous loop on brain and pinky
6. ✅ **Comprehensive Documentation:**
   - CONVERSATION-SUMMARY.md (9-phase journey)
   - BLOG-AUTONOMOUS-CLAUDE-MESSAGING.md (public tutorial)
   - AUTONOMOUS-MESSAGING-BREAKTHROUGH.md (technical docs)
7. ✅ **SSH Cluster Unified:** brain-cluster key distributed to all machines
8. ✅ **System Now Production-Ready:** 18-20 second end-to-end message processing

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
