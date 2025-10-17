# Cloudflare Infrastructure Inventory

**Generated:** 2025-10-17
**Account:** b@oh.mom (9f2fcf619e8e9758a4b7e95c878dd49c)

---

## Summary

| Type | Count | Status |
|------|-------|--------|
| **Cloudflare Pages** | 90 | ✅ Active |
| **Cloudflare Workers** | 2+ | ✅ Active |
| **Total Deployments** | 92+ | ✅ Operational |

---

## 🔧 Cloudflare Workers

### 1. pinky-brain-hub
- **URL:** https://pinky-brain-hub.b-9f2.workers.dev
- **Purpose:** Cloud message bus for Pinky & Brain multi-agent cluster
- **Local Path:** `~/pinkyandbrain/cloudflare-message-bus`
- **Database:** D1 (pinky-brain-messages)
- **Features:**
  - Message queue for inter-agent communication
  - Knowledge base with search
  - Voting system for agent decisions
  - Workflow tracking
  - Cluster status monitoring

**Endpoints:**
```
POST /build              - Trigger workflow from iPhone
GET  /poll/:machine      - Poll for messages (brain/pinky/maxyolo)
POST /complete/:id       - Mark message as read
GET  /workflow/:id       - Get workflow status
POST /update/:id         - Update workflow status
GET  /messages           - List all messages
POST /knowledge          - Share a learning
GET  /knowledge/search   - Search knowledge base
GET  /knowledge/recent   - Get recent learnings
POST /votes              - Create a new vote
GET  /votes/active       - Get active votes
POST /votes/:id/cast     - Cast a vote
POST /cluster-status     - Update cluster status
GET  /status             - Get all machine statuses
```

---

### 2. funjobs-ai
- **URL:** https://funjobs-ai.b-9f2.workers.dev
- **Purpose:** AI-powered job board API
- **Local Path:** `~/pinkyandbrain/funjobs-ai`
- **Database:** D1 (funjobs-db)
- **Storage:** R2 (funjobs-job-images)
- **AI:** Cloudflare AI Workers
- **Features:**
  - Job posting management
  - AI-powered image OCR (job flyer parsing)
  - Job scraping foundation
  - B2B lead generation tracking
  - User authentication (planned)

**Frontend:**
- **Pages URL:** https://funjobs-ai.pages.dev
- **Latest deployment:** https://9f4b8381.funjobs-ai.pages.dev

**API Endpoints:**
```
POST /api/jobs                - Create job posting
GET  /api/jobs                - List jobs
GET  /api/jobs/:id            - Get job details
POST /api/upload-job-image    - Upload & parse job image
POST /api/scrape              - Trigger job scraper (planned)
GET  /api/leads               - Get B2B leads (planned)
```

---

## 📄 Cloudflare Pages (90 Projects)

### Active Projects (Recently Updated)

| Project Name | Domain | Last Modified | Notes |
|--------------|--------|---------------|-------|
| **cluster-status** | cluster-status.pages.dev | 8 minutes ago | 🔥 Pinky & Brain cluster dashboard |
| **funjobs-ai** | funjobs-ai.pages.dev | 9 hours ago | ✅ Production job board |
| **pinky-brain-timeline** | pinky-brain-timeline.pages.dev | 1 day ago | Agent activity timeline |
| **taxday** | taxday.pages.dev | 2 days ago | - |
| **send-message-b3g** | send-message-b3g-6ey.pages.dev | 3 days ago | Messaging interface |
| **trello-powerup** | trello-powerup.pages.dev | 3 days ago | Trello integration |
| **send-message** | send-message-b3g.pages.dev | 3 days ago | - |
| **taptap-coffee** | taptap-coffee.pages.dev | 4 days ago | - |
| **attack100** | attack100.pages.dev | 4 days ago | - |
| **reddboy** | reddboy.com, reddboy.pages.dev | 5 days ago | 🌐 Custom domain |
| **sumreez** | sumreez.pages.dev | 5 days ago | - |
| **buysellpork** | buysellpork.com, buysellpork.pages.dev | 1 week ago | 🌐 Custom domain |
| **taskjury** | taskjury.pages.dev | 1 week ago | - |
| **rezzomaker** | rezzomaker.com, rezzomaker.pages.dev | 1 week ago | 🌐 Custom domain |
| **orchestrator** | orchestrator-be7.pages.dev | 1 week ago | Agent orchestration UI |
| **appzapper-pages** | appzapper-pages.pages.dev | 1 week ago | - |
| **heychat-lol** | heychat.lol, heychat-lol.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **selfi-fyi** | selfi.fyi, selfi-fyi.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **birthday-coffee** | birthday.coffee, birthday-coffee.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **bottle-delivery** | bottle.delivery, bottle-delivery.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **tasktap** | tasktap.com, tasktap.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **theme-engine** | theme-engine-czn.pages.dev | 2 weeks ago | - |
| **dollarstart** | dollarstartclub.com, dollarstart.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **futr-bet** | futr.bet, futr-bet.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **futr-bet-pitch** | futr-bet-pitch.pages.dev | 2 weeks ago | Pitch deck |
| **fastfiles** | fastfiles.app, fastfiles-72k.pages.dev | 2 weeks ago | 🌐 Custom domain |
| **happyhumantools** | happyhumantools.com, files.happyhumantools.com, mail.happyhumantools.com | 3 weeks ago | 🌐 Multiple domains |
| **luxofluxo-web** | luxofluxo-web.pages.dev | 3 weeks ago | - |
| **cf-web** | cf-web-435.pages.dev | 3 weeks ago | - |
| **biig-web** | biig-web.pages.dev | 3 weeks ago | - |

### All Other Projects (60+ more)

<details>
<summary>Click to expand full list</summary>

- vector-study-web
- agency-boom-web
- agency-boom
- affiliate-game
- goalyet-web (goalyet.com)
- goalyet-app
- trustpoints-web
- taco-pics-web
- drunk-email-app (drunk.email)
- email-manager-app
- taco-pics (taco.pics)
- carneiros-chat
- wrkflo-ai
- samassist-web
- biig-biz
- biig-biz-pages
- biig-location-pulse
- biig-dev (biig.dev)
- qrsp-mobile (qrsp.app)
- qrsp-web
- biig-team
- richdad
- kitchenfit
- 1page-web
- 1page-platform
- orkway (orkway.com)
- try100-web
- buildstuff-ai-starter
- qr-auth-frontend
- carneiros-web
- rickshaw-tracker
- ascii-fun
- shipping-analytics-dashboard
- component-breaker
- one-shot-sales-academy
- people-stocks-social
- test-revenue-stack
- revenue-stack
- 4frame-method
- shipping-school
- oauth-saas-sales
- x-app-gallery
- idea-selection-tool
- x-profile-analytics
- test-oauth-project
- mobiledetail-pro
- x-oauth-guide
- oauth-debugger
- fum
- cloudflare-toml-configurator
- iffy-pics
- roasting-ai-frontend
- iffy-investments (iffy.investments)
- support-engineer (support.engineer)
- manvbot
- wongdates
- event-tracker
- trustpoints-simulation
- cf-pages-react-app

</details>

---

## 🎯 Key Discoveries

### Custom Domains (20+)
Many projects have custom domains configured:
- reddboy.com
- buysellpork.com
- rezzomaker.com
- heychat.lol
- selfi.fyi
- birthday.coffee
- bottle.delivery
- tasktap.com
- dollarstartclub.com
- futr.bet
- fastfiles.app
- happyhumantools.com (+ subdomains)
- goalyet.com
- drunk.email
- taco.pics
- biig.dev
- qrsp.app
- orkway.com
- iffy.investments
- support.engineer

### Recent Activity
- **cluster-status** updated 8 minutes ago - likely the newest deployment
- **funjobs-ai** updated 9 hours ago - active development
- **pinky-brain-timeline** updated 1 day ago - agent tracking

### Pinky & Brain Infrastructure
Active projects for the multi-agent system:
1. **pinky-brain-hub** (Worker) - Message bus backend
2. **cluster-status** (Pages) - Real-time dashboard
3. **pinky-brain-timeline** (Pages) - Activity timeline
4. **orchestrator** (Pages) - Agent coordination UI
5. **send-message** (Pages) - Communication interface

---

## 📊 Resource Usage

### Workers
- 2 active workers
- D1 databases: 2
- R2 buckets: 1
- AI Workers: 1 (funjobs-ai)

### Pages
- 90 total projects
- ~20 with custom domains
- High activity on cluster-related projects

---

## 🔍 Next Steps

### To Find More Workers
1. Search all your local projects for `wrangler.toml` files
2. Use Cloudflare dashboard to view all deployed workers
3. Check `~/Documents/projects/` directory for more worker projects

### hook-announce Integration
Based on your mention of `~/Documents/projects/hook-announce` on max.local:
- Need to inventory projects on Max's machine
- Likely has Cloudflare tunnel configured
- Should integrate with pinky-brain-hub for notifications

### Automation Opportunities
1. Auto-deploy from Git repos
2. Health monitoring for all deployments
3. Cost tracking across all projects
4. Unified dashboard for all 92+ deployments

---

## 📝 Commands

```bash
# List all Pages
wrangler pages project list

# List Workers (from project directory)
cd ~/pinkyandbrain/cloudflare-message-bus && wrangler deployments list
cd ~/pinkyandbrain/funjobs-ai && wrangler deployments list

# Check authentication
wrangler whoami

# View this inventory
cat ~/pinkyandbrain/CLOUDFLARE-INVENTORY.md
```

---

**Generated by:** Pinky Claude (autonomous inventory)
**Account:** b@oh.mom
**Date:** 2025-10-17
