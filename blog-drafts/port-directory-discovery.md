# Port Directory: When Your Dev Servers Start Lying to You

**Date**: 2025-10-17
**Problem**: "localhost:5173 is running something else"
**Solution**: Port directory and `strictPort: true`
**Sawdust**: Multiple stale processes, port fallbacks, and the chaos of concurrent development

---

## The Problem

> "I don't know if you can tell - but localhost:5173 is running something else -- message manager - which is great, and where is that. We need to use more unique ports for our projects - and create a directory of them so we can keep them running as we build (and create massive amounts of sawdust)"

We're building sawdust.ai using the buildstuff-ai-starter template. Cloned it, ran `npm install`, ran `npm run dev`. The terminal said everything started successfully. Time to check localhost:5173.

**Expected**: Sawdust.ai landing page
**Actual**: Message Manager UI

Wait, what?

## The Investigation

When you're running multiple dev servers on a distributed system with 3 Mac minis, Claude Code instances coordinating work, and projects accumulating like... well, sawdust... things get messy.

Here's what `lsof -i :5173` revealed:

```
node    28874 brain   16u  IPv4  TCP *:5173 (LISTEN)
```

But which project is PID 28874?

```bash
ps -p 28874 -o lstart=,args=
# Wed Oct 15 20:04:23 2025  node /Users/brain/message-manager/client/node_modules/.bin/vite
```

**Wednesday**. It's Thursday. That process has been running for over 24 hours.

## The Real Picture

Checking all the ports revealed the actual situation:

| Port | What's Actually Running | When Started |
|------|-------------------------|--------------|
| 5173 | Message Manager (OLD) | Wed Oct 15, 20:04 |
| 5174 | Sawdust.ai | Thu Oct 16, 09:01 |
| 5175 | Message Manager (NEW) | Thu Oct 16, 09:46 |
| 5176 | Knowledge Viewer | Thu Oct 16, 06:00 |

**Three simultaneous React dev servers**. **Two instances of the same project**.

Sawdust.ai WAS running. On 5174. Exactly where it should be.

## Why This Happened

### Problem 1: Vite's Default Port Fallback

Both sawdust-ai and message-manager had this in their vite configs:

```typescript
server: {
  port: 3000,
}
```

When port 3000 was taken, Vite helpfully fell back to 5173 (its default), then 5174, then 5175...

**Helpful? Maybe. Predictable? No.**

### Problem 2: Long-Running Background Processes

When you're switching between projects rapidly, starting dev servers, getting pulled into another task, starting another project... you end up with orphaned processes.

We never explicitly killed the old message-manager dev server. It just kept running. On 5173. Waiting.

### Problem 3: No Single Source of Truth

Which port is the message bus on? 3100.
Which port is the blog server on? 3888.
Which port is sawdust-ai on? ...check the terminal? Maybe 5174? Or is that knowledge-viewer?

**We had no port registry.**

## The Solution

### 1. Port Directory (`PORT-DIRECTORY.md`)

Created a living document tracking every service:

```markdown
| Port | Service | Project | Status | Started | Notes |
|------|---------|---------|--------|---------|-------|
| 3100 | Message Bus API | pinkyandbrain | ✅ Running | Thu 07AM | Central message coordination |
| 3888 | Blog Server | pinkyandbrain | ✅ Running | 08:56AM | Simple markdown blog |
| 5173 | Message Manager UI (OLD) | message-manager | ⚠️ Stale | Wed 08:04PM | DUPLICATE: Should kill |
| 5174 | Sawdust.ai UI | sawdust-ai | ✅ Running | Thu 09:01AM | CloudFlare full-stack blog |
| 5175 | Message Manager UI (NEW) | message-manager | ✅ Running | Thu 09:46AM | Current version |
```

### 2. Port Assignment Strategy

Defined port ranges:

- **3000-3999**: Backend APIs and services
- **5000-5999**: Frontend development servers
  - 5173: message-manager (locked in)
  - 5174: sawdust-ai
  - 5176: knowledge-viewer
  - 5177-5199: Available for new projects
- **8000-8999**: CloudFlare Workers development
- **9000-9999**: Debug/Inspector ports

### 3. Strict Port Configuration

Updated every vite.config to use `strictPort: true`:

```typescript
// sawdust-ai/apps/web/vite.config.ts
server: {
  port: 5174,
  strictPort: true,  // Fail if port unavailable instead of falling back
  proxy: {
    '/api': {
      target: 'http://localhost:8787',
      changeOrigin: true,
    },
  },
}
```

Now if port 5174 is taken, Vite will **fail loudly** instead of silently using a different port.

### 4. Port Check Commands

Added to the directory:

```bash
# Check specific port
lsof -i :5173

# Check all Node processes
ps aux | grep -E "(node|vite|npm)" | grep -v grep

# Check all listening ports
lsof -iTCP -sTCP:LISTEN | grep node

# Kill process on specific port
lsof -ti:5173 | xargs kill -9
```

## What We Learned

### 1. Explicit is Better Than Implicit

Vite's fallback behavior is convenient for solo development. But when you're running multiple projects simultaneously, especially with autonomous agents starting services, you need **explicit port assignments** and **strict failure modes**.

### 2. Living Documentation

`PORT-DIRECTORY.md` isn't a one-time document. It's the single source of truth, updated every time a service starts:

1. Choose port from available range
2. Update PORT-DIRECTORY.md
3. Configure vite.config with strictPort
4. Test that port is available
5. Document in project README

### 3. Process Hygiene Matters

On a traditional development machine, you restart it regularly. Stale processes get cleaned up.

On our distributed system, machines run 24/7. Services run indefinitely. **Orphaned processes accumulate**.

We need better process management:
- Health checks
- Automated cleanup of stale processes
- Process monitoring dashboard

### 4. The "Works on My Machine" Problem, Distributed

When brain starts sawdust-ai on port 5174, and pinky clones the repo and starts it... does it also use 5174? Or does Vite fall back to 5175?

With `strictPort: true`, it **fails**. Then we know there's a conflict. Without it, you get silent divergence.

## Still To Do

We haven't tested this system yet. The port directory exists. The configs are updated. But we need to:

1. **Kill the stale message-manager instance** on 5173
2. **Restart sawdust-ai** to verify it starts on 5174 with strictPort
3. **Start a new project** and assign it port 5177, document the process
4. **Clone a project to pinky or max** and verify port conflicts fail properly
5. **Build a port monitoring dashboard** (because we're building a status dashboard anyway)

## The Meta-Lesson

This is classic distributed systems sawdust. We needed a port directory because:

1. We're running multiple projects concurrently
2. Machines stay up 24/7
3. Multiple developers (Claude instances) are starting services
4. We're building fast and accumulating processes

**The solution isn't complex**: A markdown file, stricter configs, and better hygiene.

**But we only discovered the need for it when confusion hit**: "Wait, why is localhost:5173 showing the wrong thing?"

That's the sawdust. Not the polished tutorial that says "here's how to manage ports in a monorepo." But the real moment of confusion, investigation, and realization: **we need a system for this**.

---

## Quick Reference

### Check What's Running

```bash
lsof -i :5173                           # Specific port
lsof -iTCP -sTCP:LISTEN | grep node    # All Node servers
ps aux | grep vite | grep -v grep      # All Vite servers
```

### Port Directory Location

```
~/pinkyandbrain/PORT-DIRECTORY.md
```

### Current Service URLs

- Message Bus: http://localhost:3100
- Blog Server: http://localhost:3888
- Message Manager: http://localhost:5175
- **Sawdust.ai: http://localhost:5174**
- Knowledge Viewer: http://localhost:5176

---

**Status**: ⚠️ Untested
**Next**: Kill stale process, restart services, verify strictPort behavior
**Files**: `~/pinkyandbrain/PORT-DIRECTORY.md`

## Comments

This is the kind of thing that doesn't show up in tutorials. "Just run npm run dev!" they say. Sure. But when you're running 5 dev servers across 3 machines with autonomous agents coordinating work?

You need a port directory.

Not because it's exciting. Because after the 3rd time you open the wrong localhost URL and get confused, you realize: **we need a system for this**.

That's the sawdust.
