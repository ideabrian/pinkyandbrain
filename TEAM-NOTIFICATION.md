# 📱 Cloud Message Bus Now LIVE!

**Date**: 2025-10-16
**From**: Max
**To**: brain, pinky, maxyolo (the autonomous team)

---

## 🎉 Big News!

We just deployed a **global cloud message bus**! You can now receive build requests from **anywhere in the world** via iPhone.

---

## What Changed

### Before
- ❌ Only worked on home WiFi (192.168.5.76:3100)
- ❌ iPhone needed to be on same network
- ❌ No building while out and about

### After
- ✅ **Works from anywhere** (cellular, coffee shop, airport, vacation)
- ✅ **Global public URL**: `https://pinky-brain-hub.b-9f2.workers.dev`
- ✅ **Secure**: API key authentication
- ✅ **Free**: Cloudflare free tier
- ✅ **Fast**: Global edge network (< 50ms worldwide)

---

## 🔑 Credentials

**Public URL**: `https://pinky-brain-hub.b-9f2.workers.dev`

**API Key**: `3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5`

**⚠️ IMPORTANT**: Keep API key secret! Don't commit to git.

---

## 📡 New Message Flow

```
iPhone (anywhere)
  ↓ POST https://pinky-brain-hub.b-9f2.workers.dev/build
  ↓ X-API-Key header
Cloudflare Workers (LAX edge)
  ↓ Store in D1 database
You (brain/pinky/maxyolo)
  ↓ Poll cloud every 10 seconds
  ↓ GET /poll/:machine
  ↓ Process messages
  ↓ POST /complete/:messageId
Done! ✨
```

---

## 🚀 What You Need to Do

### brain, pinky, maxyolo - All Machines

**1. Set environment variables** (add to ~/.zshrc):
```bash
export CLOUD_BUS_URL="https://pinky-brain-hub.b-9f2.workers.dev"
export CLOUD_API_KEY="3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5"
```

**2. Deploy cloud poller**:
```bash
cd ~/pinkyandbrain
# Copy cloud-poller.sh if not already there
scp maxyolo:~/Documents/projects/pinkyandbrain/cloud-poller.sh ~/pinkyandbrain/
chmod +x ~/pinkyandbrain/cloud-poller.sh
```

**3. Start hybrid poller** (checks both local AND cloud):
```bash
# Stop old pollers first
pkill -f message-poller

# Start new cloud-aware poller
./cloud-poller.sh [your-role] > cloud-poller.log 2>&1 &

# brain does this:
./cloud-poller.sh brain > cloud-poller-brain.log 2>&1 &

# pinky does this:
./cloud-poller.sh pinky > cloud-poller-pinky.log 2>&1 &

# maxyolo does this:
./cloud-poller.sh maxyolo > cloud-poller-maxyolo.log 2>&1 &
```

**4. Test cloud polling**:
```bash
# Check if you can reach cloud
curl -s $CLOUD_BUS_URL/health

# Poll for messages
curl -s $CLOUD_BUS_URL/poll/brain -H "X-API-Key: $CLOUD_API_KEY"
```

---

## 📱 iPhone - iOS Shortcut Update

**Change URL**:
```
From: http://192.168.5.76:3100/build
To:   https://pinky-brain-hub.b-9f2.workers.dev/build
```

**Add Header**:
```
X-API-Key: 3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5
```

**Test**:
1. Turn off WiFi (use cellular)
2. Run shortcut
3. Type: "Test from cellular"
4. Should work! 🎉

---

## 🎯 API Endpoints (for your reference)

### Health Check (no auth needed)
```bash
GET https://pinky-brain-hub.b-9f2.workers.dev/health
```

### Trigger Workflow (from iPhone)
```bash
POST https://pinky-brain-hub.b-9f2.workers.dev/build
Headers: X-API-Key, Content-Type: application/json
Body: {"idea":"Build me X"}
```

### Poll for Messages (you use this)
```bash
GET https://pinky-brain-hub.b-9f2.workers.dev/poll/:machine
Headers: X-API-Key
# :machine = brain | pinky | maxyolo
```

### Mark Message Complete (after processing)
```bash
POST https://pinky-brain-hub.b-9f2.workers.dev/complete/:messageId
Headers: X-API-Key
```

### Check Workflow Status
```bash
GET https://pinky-brain-hub.b-9f2.workers.dev/workflow/:workflowId
Headers: X-API-Key
```

### Update Workflow (after you're done)
```bash
POST https://pinky-brain-hub.b-9f2.workers.dev/update/:workflowId
Headers: X-API-Key, Content-Type: application/json
Body: {"status":"complete","completed":true}
```

---

## 🧠 NEW: Team Knowledge Sharing

**What**: Share learnings across brain/pinky/maxyolo instantly!

**Why**: When brain learns something useful, pinky and maxyolo should know it too.

### Knowledge CLI Tool

**Setup**:
```bash
cd ~/pinkyandbrain
# Copy knowledge-cli.sh if not already there
scp maxyolo:~/Documents/projects/pinkyandbrain/knowledge-cli.sh ~/pinkyandbrain/
chmod +x ~/pinkyandbrain/knowledge-cli.sh
```

**Usage Examples**:

**Share a learning**:
```bash
./knowledge-cli.sh share "React" "useState pattern" "Use for simple state" "const [x,setX]=useState(0)" "best-practice" "react,hooks"
```

**Search knowledge base**:
```bash
./knowledge-cli.sh search "useState"
./knowledge-cli.sh search "type guards"
```

**See recent team learnings**:
```bash
./knowledge-cli.sh recent        # Last 10
./knowledge-cli.sh recent 5      # Last 5
```

**Mark knowledge as helpful**:
```bash
./knowledge-cli.sh helpful knowledge-1760578901473
```

**Get specific learning**:
```bash
./knowledge-cli.sh get knowledge-1760578901473
```

### Knowledge API Endpoints

**Share knowledge**:
```bash
POST https://pinky-brain-hub.b-9f2.workers.dev/knowledge
Headers: X-API-Key, Content-Type: application/json
Body: {
  "from_machine": "brain",
  "topic": "React",
  "category": "best-practice",
  "title": "useState vs useReducer",
  "learning": "Use useState for simple state, useReducer for complex state",
  "code_example": "const [state, dispatch] = useReducer(reducer, initialState);",
  "tags": "react,hooks,state"
}
```

**Search knowledge**:
```bash
GET https://pinky-brain-hub.b-9f2.workers.dev/knowledge/search?q=useState
GET https://pinky-brain-hub.b-9f2.workers.dev/knowledge/search?topic=React
GET https://pinky-brain-hub.b-9f2.workers.dev/knowledge/search?category=best-practice
Headers: X-API-Key
```

**Get recent learnings**:
```bash
GET https://pinky-brain-hub.b-9f2.workers.dev/knowledge/recent?limit=10
Headers: X-API-Key
```

**Get specific knowledge**:
```bash
GET https://pinky-brain-hub.b-9f2.workers.dev/knowledge/:id
Headers: X-API-Key
```

**Mark as helpful**:
```bash
POST https://pinky-brain-hub.b-9f2.workers.dev/knowledge/:id/helpful
Headers: X-API-Key
```

### Knowledge Categories

- `best-practice` - Recommended patterns
- `gotcha` - Common pitfalls to avoid
- `tip` - Quick useful tip
- `pattern` - Design pattern
- `tool` - Tool usage
- `general` - Other learnings

### When to Share Knowledge

- Solved a tricky bug
- Discovered a useful pattern
- Learned a better way to do something
- Found a tool that saves time
- Hit a gotcha that others should avoid

**Example Flow**:
1. Brain learns: "TypeScript type guards with 'typeof'"
2. Brain shares: `./knowledge-cli.sh share "TypeScript" "Type guards" "Use typeof for primitives" "if(typeof x === 'string')" "pattern" "ts,types"`
3. Pinky searches later: `./knowledge-cli.sh search "type guards"`
4. Pinky finds brain's learning instantly!
5. Pinky marks helpful: `./knowledge-cli.sh helpful knowledge-123`

---

## 🔍 Monitoring

**View all messages** (admin):
```bash
curl -s https://pinky-brain-hub.b-9f2.workers.dev/messages \
  -H "X-API-Key: $CLOUD_API_KEY" | jq '.'
```

**Check your logs**:
```bash
tail -f ~/pinkyandbrain/cloud-poller-[your-role].log
```

**Cloudflare Dashboard**:
https://dash.cloudflare.com → Workers & Pages → pinky-brain-hub

---

## 💡 What This Means

### For You (brain/pinky/maxyolo)
- No change to your workflow!
- You still process messages the same way
- Just now you check TWO places: local + cloud
- When cloud message arrives → process it
- Update cloud status when done

### For Max (iPhone)
- Build from **anywhere** now!
- Coffee shop, airport, vacation, commute
- Same iOS Shortcut, just new URL
- Messages go to cloud → you pick them up

---

## 🚨 Troubleshooting

### "Can't connect to cloud"
```bash
# Check environment variables set
echo $CLOUD_BUS_URL
echo $CLOUD_API_KEY

# Test connection
curl -s $CLOUD_BUS_URL/health
```

### "Unauthorized" error
```bash
# Make sure X-API-Key header exact
curl -s $CLOUD_BUS_URL/poll/brain -H "X-API-Key: $CLOUD_API_KEY"
```

### "Old poller still running"
```bash
# Kill old pollers
pkill -f message-poller
pkill -f cloud-poller

# Start fresh
./cloud-poller.sh [your-role] > cloud-poller.log 2>&1 &
```

---

## 📊 Stats

**Deployed**: 2025-10-16 01:30 UTC
**Location**: Cloudflare Workers (LAX edge)
**Database**: D1 (8853b3dd-2813-49c9-83a3-7286d5cd3834)
**API Key**: Set in environment
**Status**: ✅ Live and tested

**Test Results**:
- ✅ Health check: OK
- ✅ POST /build: Working
- ✅ Workflow tracking: Working
- ✅ Database: Initialized

---

## 🎁 Benefits

1. **Build from anywhere** 🌍
   - Cellular, WiFi, anywhere with internet

2. **No infrastructure** 💪
   - Cloudflare handles servers, SSL, scaling

3. **Fast** ⚡
   - Global edge network, < 50ms response

4. **Free** 💰
   - Within Cloudflare free tier

5. **Secure** 🔒
   - API key authentication

6. **Reliable** 🎯
   - 99.99% uptime SLA

---

## 📚 Documentation

**Full docs**: `~/pinkyandbrain/cloudflare-message-bus/README.md`
**Deployment guide**: `~/pinkyandbrain/cloudflare-message-bus/DEPLOY.md`
**Summary**: `~/pinkyandbrain/CLOUD-MESSAGE-BUS-SUMMARY.md`

---

## ✅ Action Items

### brain
- [ ] Set CLOUD_BUS_URL and CLOUD_API_KEY in ~/.zshrc
- [ ] Copy cloud-poller.sh to ~/pinkyandbrain
- [ ] Copy knowledge-cli.sh to ~/pinkyandbrain
- [ ] Stop old poller: `pkill -f message-poller`
- [ ] Start cloud poller: `./cloud-poller.sh brain > cloud-poller-brain.log 2>&1 &`
- [ ] Test polling: `curl $CLOUD_BUS_URL/poll/brain -H "X-API-Key: $CLOUD_API_KEY"`
- [ ] Test knowledge: `./knowledge-cli.sh recent`

### pinky
- [ ] Set CLOUD_BUS_URL and CLOUD_API_KEY in ~/.zshrc
- [ ] Copy cloud-poller.sh to ~/pinkyandbrain
- [ ] Copy knowledge-cli.sh to ~/pinkyandbrain
- [ ] Stop old poller: `pkill -f message-poller`
- [ ] Start cloud poller: `./cloud-poller.sh pinky > cloud-poller-pinky.log 2>&1 &`
- [ ] Test polling: `curl $CLOUD_BUS_URL/poll/pinky -H "X-API-Key: $CLOUD_API_KEY"`
- [ ] Test knowledge: `./knowledge-cli.sh recent`

### maxyolo
- [ ] Set CLOUD_BUS_URL and CLOUD_API_KEY in ~/.zshrc
- [ ] Copy knowledge-cli.sh to ~/pinkyandbrain
- [ ] Stop old poller: `pkill -f message-poller`
- [ ] Start cloud poller: `./cloud-poller.sh maxyolo > cloud-poller-maxyolo.log 2>&1 &`
- [ ] Update iOS Shortcut with new URL and API key header
- [ ] Test from iPhone on cellular!
- [ ] Test knowledge: `./knowledge-cli.sh recent`

---

## 🤝 Questions?

Check logs:
```bash
tail -f ~/pinkyandbrain/cloud-poller-[your-role].log
```

Check cloud messages:
```bash
curl -s $CLOUD_BUS_URL/messages -H "X-API-Key: $CLOUD_API_KEY" | jq '.'
```

---

**Welcome to global autonomous workflows!** 🌍🚀

You're now part of a distributed system that can build software from anywhere in the world.

**Build something amazing!** ✨

---

**Deployed by**: Max
**Status**: ✅ Live
**Edge Location**: LAX (Cloudflare)
**Database**: D1
**Cost**: $0/month

**Let's go!** 🎉
