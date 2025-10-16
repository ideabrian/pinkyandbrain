# Deploy Pinky & Brain Cloud Message Bus

**Quick deployment guide for Cloudflare Workers**

---

## Prerequisites

1. Cloudflare account (free tier works!)
2. Wrangler CLI installed
3. API key for auth

---

## Step 1: Install Dependencies

```bash
cd cloudflare-message-bus
npm install
```

---

## Step 2: Login to Cloudflare

```bash
npx wrangler login
```

This opens browser to authenticate.

---

## Step 3: Create D1 Database

```bash
npx wrangler d1 create pinky-brain-messages
```

**Copy the database_id from output!**

Example output:
```
✅ Successfully created DB 'pinky-brain-messages'

[[d1_databases]]
binding = "DB"
database_name = "pinky-brain-messages"
database_id = "abc123-def456-ghi789"  ← COPY THIS
```

---

## Step 4: Update wrangler.toml

Edit `wrangler.toml`:

```toml
[[d1_databases]]
binding = "DB"
database_name = "pinky-brain-messages"
database_id = "YOUR_DATABASE_ID_HERE"  # Paste from Step 3

[vars]
API_KEY = "your-secret-key-change-me"  # Generate a random string
```

**Generate API key**:
```bash
openssl rand -hex 32
```

---

## Step 5: Initialize Database Schema

```bash
npx wrangler d1 execute pinky-brain-messages --file=./schema.sql
```

Should see:
```
✅ Executed schema.sql
```

---

## Step 6: Deploy to Cloudflare

```bash
npm run deploy
```

Output:
```
✨ Successfully deployed pinky-brain-hub
   https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev
```

**Save this URL!** This is your public endpoint.

---

## Step 7: Test Deployment

```bash
# Health check (no auth needed)
curl https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev/health

# Test build endpoint (needs API key)
curl -X POST https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev/build \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_API_KEY" \
  -d '{"idea":"Test from cloud"}'
```

---

## Step 8: Update Local Pollers

Edit `message-poller.sh` to add cloud polling:

```bash
# Add after local poll
CLOUD_URL="https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev"
API_KEY="your-api-key"

# Poll cloud for messages
CLOUD_MESSAGES=$(curl -s "$CLOUD_URL/poll/$ROLE" -H "X-API-Key: $API_KEY")
```

---

## Step 9: Test from iPhone

1. Update iOS Shortcut URL to:
   ```
   https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev/build
   ```

2. Add header:
   ```
   X-API-Key: YOUR_API_KEY
   ```

3. Run shortcut from iPhone (on cellular!)

4. Check cloud:
   ```bash
   curl https://pinky-brain-hub.YOUR-SUBDOMAIN.workers.dev/messages \
     -H "X-API-Key: YOUR_API_KEY"
   ```

---

## Endpoints

**Public**:
- `GET /health` - Health check (no auth)

**Authenticated** (needs `X-API-Key` header):
- `POST /build` - Trigger workflow from iPhone
- `GET /poll/:machine` - Poll for messages (brain/pinky/maxyolo)
- `POST /complete/:messageId` - Mark message complete
- `GET /workflow/:id` - Get workflow status
- `POST /update/:workflowId` - Update workflow
- `GET /messages` - List all messages (admin)

---

## Security Notes

1. **Never commit API key to git!**
2. **Rotate API key periodically**
3. **Use environment secrets for production**:
   ```bash
   npx wrangler secret put API_KEY
   ```

---

## Costs

**Free Tier Limits**:
- 100,000 requests/day
- 10ms CPU time per request
- D1: 5GB storage, 5M rows read/day

**Your usage** (estimated):
- ~1,000 requests/day
- Well within free tier! ✅

---

## Troubleshooting

### "Unauthorized" error
- Check X-API-Key header matches wrangler.toml
- Verify header name is exactly `X-API-Key`

### Database not found
- Run Step 5 again (initialize schema)
- Check database_id in wrangler.toml matches Step 3

### Deploy fails
- Run `npx wrangler login` again
- Check internet connection
- Verify Cloudflare account active

---

## Next Steps

1. Deploy ✅
2. Test from iPhone ✅
3. Update local pollers
4. Build from anywhere! 🌍

---

**Status**: Ready to deploy!
**Time**: ~10 minutes
**Cost**: Free tier
