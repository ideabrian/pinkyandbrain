# Port Directory - Brain Machine

> **Living document**: Keep this updated as services are added/changed
>
> Last updated: 2025-10-17

## Active Services

| Port | Service | Project | Status | Started | Notes |
|------|---------|---------|--------|---------|-------|
| **3001** | Message Manager API | message-manager/server | ✅ Running | Thu 09:46AM | Express backend |
| **3100** | Message Bus API | pinkyandbrain | ✅ Running | Thu 07AM | Central message coordination |
| **3888** | Blog Server | pinkyandbrain | ✅ Running | 08:56AM | Simple markdown blog (blog-server.js) |
| **5173** | Message Manager UI (OLD) | message-manager | ⚠️ Stale | Wed 08:04PM | **DUPLICATE**: Old instance, should kill |
| **5174** | Sawdust.ai UI | sawdust-ai | ✅ Running | Thu 09:01AM | CloudFlare full-stack blog |
| **5175** | Message Manager UI (NEW) | message-manager | ✅ Running | Thu 09:46AM | Current message manager frontend |
| **5176** | Knowledge Viewer UI | knowledge-viewer | ✅ Running | Thu 06AM | Knowledge base frontend |
| **8787** | Sawdust.ai API Worker | sawdust-ai/apps/api | ✅ Running | Thu 09:01AM | CloudFlare Workers dev |
| **8788** | Files Worker | sawdust-ai/apps/files | ✅ Running | Thu 09:01AM | CloudFlare R2 file handling |
| **8789** | Email Worker | sawdust-ai/apps/email | ✅ Running | Thu 09:01AM | CloudFlare email service |
| **9231** | Files Worker Inspector | sawdust-ai/apps/files | ✅ Running | Thu 09:01AM | Debug inspector |

## Service Details

### Message Bus (Port 3100)
- **File**: `~/pinkyandbrain/claude-messenger.js`
- **Started**: `nohup node claude-messenger.js`
- **Purpose**: Central message coordination between Claude instances
- **Dependencies**: None
- **Log**: `~/pinkyandbrain/messenger.log`

### Blog Server (Port 3888)
- **File**: `~/pinkyandbrain/blog-server.js`
- **Started**: `node blog-server.js`
- **Purpose**: Serves markdown blog posts
- **Dependencies**: Message bus (3100)
- **Posts**: `~/pinkyandbrain/blog-drafts/`

### Message Manager (Ports 3001, 5175)
- **Location**: `~/message-manager`
- **Started**: `npm run dev` (from project root)
- **Frontend**: Port 5175 (Vite)
- **Backend**: Port 3001 (Express)
- **Purpose**: UI for managing distributed messages
- **Note**: Old instance still running on 5173 (from Wed), should be killed

### Sawdust.ai (Ports 5174, 8787-8789)
- **Location**: `~/sawdust-ai`
- **Started**: `npm run dev` (turbo monorepo)
- **Frontend**: Port 5174 (Vite with React)
- **API Worker**: Port 8787 (CloudFlare Workers)
- **Files Worker**: Port 8788 (CloudFlare R2)
- **Email Worker**: Port 8789 (CloudFlare email)
- **Purpose**: sawdust.ai blog platform (CloudFlare stack)
- **URL**: http://localhost:5174

### Knowledge Viewer (Port 5176)
- **Location**: `~/knowledge-viewer`
- **Started**: `npm run dev`
- **Frontend**: Port 5176 (config says 5174, but actually running on 5176)
- **Backend**: Port unknown (check server/index.js)
- **Purpose**: Knowledge base visualization
- **Note**: Config should be updated to match actual port

## Port Assignment Strategy

### Port Ranges
- **3000-3999**: Backend APIs and services
  - 3100: Message bus
  - 3888: Blog server

- **5000-5999**: Frontend development servers
  - 5173: message-manager (locked in by running process)
  - 5174: sawdust-ai (to be assigned)
  - 5175: knowledge-viewer
  - 5176-5199: Available for new projects

- **8000-8999**: CloudFlare Workers development
  - 8787-8789: sawdust-ai workers
  - 8790-8799: Available for new workers

- **9000-9999**: Debug/Inspector ports
  - 9231: Files worker inspector

## How to Check Ports

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

## Adding New Services

When starting a new project:

1. **Choose port** from available range (5176+ for frontends)
2. **Update this file** with service details
3. **Configure vite.config.ts** (or equivalent) to use assigned port
4. **Test** that port is available before starting
5. **Document** in project README

## Common Issues

### Issue: Vite falls back to 5173
**Cause**: Port conflict, Vite uses default
**Fix**: Explicitly set port in vite.config.ts:
```typescript
server: {
  port: 5174,
  strictPort: true,  // Fail if port unavailable
}
```

### Issue: "Port already in use"
**Check**: `lsof -i :PORT`
**Fix**: Either kill process or choose different port

## Quick Reference

```bash
# Message bus
curl http://localhost:3100/inbox/unread

# Blog server
open http://localhost:3888

# Message manager (current)
open http://localhost:5175

# Sawdust.ai
open http://localhost:5174

# Knowledge viewer
open http://localhost:5176
```

## Services by URL

- **Message Bus API**: http://localhost:3100
- **Message Manager API**: http://localhost:3001
- **Blog Server**: http://localhost:3888
- **Message Manager UI**: http://localhost:5175
- **Sawdust.ai UI**: http://localhost:5174
- **Knowledge Viewer UI**: http://localhost:5176
- **Sawdust API Worker**: http://localhost:8787
- **Files Worker**: http://localhost:8788
- **Email Worker**: http://localhost:8789

## Cleanup Tasks

### Kill Stale Processes

```bash
# Kill old message-manager instance on 5173 (started Wed Oct 15)
kill 28874 28875

# Verify it's gone
lsof -i :5173
```

## History

- **2025-10-17 09:11**: Discovered message-manager running on 5173 instead of configured port
- **2025-10-17 09:11**: Created port directory to track all services
- **2025-10-17 09:11**: Found sawdust-ai IS running on 5174 (user confused by stale 5173 instance)
- **2025-10-17 09:11**: Discovered duplicate message-manager instances (5173 old, 5175 new)
- **2025-10-17 09:11**: Updated configs with strictPort to prevent fallback behavior
