# Pinky & Brain Cloud Message Bus

**Cloudflare Workers + D1 Database**

Enables autonomous workflows from **anywhere in the world** via iPhone!

---

## What This Does

Replaces local-only message bus with **global cloud message bus**:

**Before**:
- ❌ Only works on home WiFi
- ❌ Can't build from iPhone on cellular
- ❌ Requires VPN for remote access

**After**:
- ✅ Works from anywhere (cellular, coffee shop, travel)
- ✅ Public HTTPS endpoint
- ✅ Simple API key auth
- ✅ Free Cloudflare tier
- ✅ Global edge network (fast everywhere)

---

## Architecture

```
iPhone (anywhere)
  ↓ HTTPS POST
Cloudflare Workers (global edge)
  ↓ Store in D1 database
Local pollers (every 10s)
  ↓ Pull from cloud
  ↓ Process locally
  ↓ Update cloud status
iPhone
  ↓ Check status
```

---

## Files

### Cloudflare Workers

- **`src/index.ts`** - Main Worker code (350 lines)
- **`schema.sql`** - D1 database schema
- **`wrangler.toml`** - Configuration
- **`package.json`** - Dependencies

### Deployment

- **`DEPLOY.md`** - Step-by-step deployment guide
- **`README.md`** - This file

### Local Integration

- **`../cloud-poller.sh`** - Hybrid poller (local + cloud)

---

## Quick Start

### 1. Deploy to Cloudflare (10 minutes)

```bash
cd cloudflare-message-bus
npm install
npx wrangler login
npx wrangler d1 create pinky-brain-messages
# Copy database_id to wrangler.toml
npx wrangler d1 execute pinky-brain-messages --file=./schema.sql
npm run deploy
```

**Result**: `https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev`

### 2. Test from iPhone

Update iOS Shortcut:
- URL: `https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev/build`
- Add header: `X-API-Key: YOUR_KEY`

### 3. Update Local Pollers

```bash
# Set environment variables
export CLOUD_BUS_URL="https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev"
export CLOUD_API_KEY="your-api-key"

# Run hybrid poller
./cloud-poller.sh maxyolo
```

---

## API Endpoints

### Public (no auth)

**GET /health**
- Health check
- Response: `{"status":"ok","service":"pinky-brain-hub"}`

### Authenticated (needs `X-API-Key` header)

**POST /build**
- Trigger workflow from iPhone
- Body: `{"idea":"Build me X","description":"optional"}`
- Response: `{"workflowId":"workflow-123",...}`

**GET /poll/:machine**
- Poll for new messages
- Machines: brain, pinky, maxyolo
- Response: `{"unread":1,"messages":[...]}`

**POST /complete/:messageId**
- Mark message as processed
- Response: `{"success":true}`

**GET /workflow/:id**
- Get workflow status
- Response: `{"workflow":{...},"messages":[...]}`

**POST /update/:workflowId**
- Update workflow status
- Body: `{"status":"implementing","completed":false}`

**GET /messages**
- List all messages (admin)
- Response: `{"total":10,"messages":[...]}`

---

## Database Schema

### `messages` table
- id (primary key)
- workflow_id
- from_machine
- to_machine
- subject
- body
- priority
- status (pending/completed)
- created_at
- read_at
- metadata (JSON)

### `workflows` table
- workflow_id (primary key)
- idea
- description
- priority
- status (planning/implementing/reviewing/complete)
- created_at
- updated_at
- completed_at
- result_url
- metadata (JSON)

---

## Security

**API Key Authentication**:
- Header: `X-API-Key: your-secret-key`
- Stored in wrangler.toml (dev) or Wrangler secrets (prod)
- Generate: `openssl rand -hex 32`

**Best Practices**:
1. Never commit API key to git
2. Use Wrangler secrets for production:
   ```bash
   npx wrangler secret put API_KEY
   ```
3. Rotate keys periodically
4. Monitor usage in Cloudflare dashboard

---

## Costs

**Cloudflare Free Tier**:
- 100,000 requests/day
- 10ms CPU time per request
- D1: 5GB storage, 5M rows read/day

**Estimated Usage**:
- ~1,000-2,000 requests/day
- Well within free tier! ✅

**If you exceed free tier** (~$5/month for first paid tier):
- Still cheaper than any VPS
- Global edge network included
- Auto-scaling
- DDoS protection

---

## Development

### Local Testing

```bash
npm run dev
```

Runs on `http://localhost:8787`

### Deploy

```bash
npm run deploy
```

### Database Operations

```bash
# Create database
npm run db:create

# Initialize schema (production)
npm run db:init

# Initialize schema (local dev)
npm run db:local
```

---

## Troubleshooting

### "Unauthorized" error
- Check X-API-Key header
- Verify API_KEY in wrangler.toml matches request

### Database not found
- Run `npm run db:init`
- Check database_id in wrangler.toml

### Deploy fails
- Run `npx wrangler login` again
- Check Cloudflare account active
- Verify internet connection

### Pollers not picking up cloud messages
- Check CLOUD_BUS_URL environment variable
- Verify CLOUD_API_KEY is correct
- Test manually: `curl $CLOUD_BUS_URL/poll/brain -H "X-API-Key: $API_KEY"`

---

## Next Steps

1. **Deploy** following DEPLOY.md
2. **Test** from iPhone on cellular
3. **Update** local pollers with cloud config
4. **Build** from anywhere in the world! 🌍

---

## Technical Details

**Stack**:
- Cloudflare Workers (V8 isolates)
- D1 Database (SQLite on edge)
- TypeScript
- Wrangler CLI

**Performance**:
- Global edge deployment
- < 50ms response time worldwide
- Auto-scaling
- 99.99% uptime SLA

**Limits**:
- Max request size: 100MB
- Max response size: 100MB
- Max execution time: 30s CPU time

---

**Status**: ✅ Ready to deploy
**Time to deploy**: 10 minutes
**Cost**: Free tier
**Global**: Yes! Works anywhere 🌍
