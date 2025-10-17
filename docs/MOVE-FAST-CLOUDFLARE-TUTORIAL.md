# How We Ship Full-Stack Apps in Minutes

**Real Example:** Built and deployed a knowledge search web app in under 30 minutes
**Result:** https://knowledge-search.pages.dev
**Date:** 2025-10-17

---

## The "Move Fast" Stack

### Core Tools
1. **Cloudflare Pages** - Frontend hosting (free, instant deploys)
2. **Cloudflare Workers** - Backend APIs (serverless, edge computing)
3. **Wrangler CLI** - Infrastructure as code, API access
4. **React + Vite** - Modern frontend tooling
5. **Boilerplates** - Pre-configured templates

### Why This Stack?

✅ **No servers to manage** - Everything runs on Cloudflare's edge
✅ **Global by default** - Deployed to 300+ cities worldwide
✅ **API-driven** - Everything controllable via CLI/API
✅ **Zero config needed** - Sensible defaults that just work
✅ **Actually free tier** - Not a trial, not a credit card required

---

## The 5-Minute Deployment Pattern

### Step 1: Clone a Boilerplate (30 seconds)

```bash
cd ~/pinkyandbrain
git clone https://github.com/ideabrian/buildstuff-ai-starter knowledge-search
cd knowledge-search
```

**Why boilerplates?**
- Pre-configured TypeScript, React, Tailwind CSS
- Build scripts already working
- No webpack/vite configuration needed
- Focus on features, not setup

### Step 2: Customize the App (10-15 minutes)

```bash
# Update package.json
npm install

# Create your components
# apps/web/src/pages/YourFeature.tsx
# apps/web/src/services/yourApi.ts

# Update routing
# apps/web/src/App.tsx
```

**Key insight:** Don't write everything from scratch. Use the boilerplate's patterns:
- Component structure already set up
- API service layer ready to go
- Styling system in place

### Step 3: Build (10 seconds)

```bash
cd apps/web
npm run build
```

**Result:** Static files in `dist/` ready to deploy

### Step 4: Deploy to Cloudflare Pages (30 seconds)

```bash
# First time: Create the project
npx wrangler pages project create knowledge-search --production-branch=main

# Deploy
npx wrangler pages deploy dist --project-name=knowledge-search
```

**What happens:**
1. Files uploaded to Cloudflare's edge network
2. Deployed to 300+ cities globally
3. HTTPS automatically configured
4. URL instantly available

**Result:**
```
✨ Deployment complete!
https://xyz.knowledge-search.pages.dev
```

---

## Real Example: Knowledge Search App

### What We Built
A visual search interface for the Pinky & Brain knowledge base.

**Features:**
- Search all agent learnings
- Browse recent knowledge
- View detailed entries with code examples
- Mark entries as helpful

**Time to deploy:** 28 minutes

### The Code

**1. API Service** (`apps/web/src/services/knowledgeService.ts`)
```typescript
const API_BASE = 'https://pinky-brain-hub.b-9f2.workers.dev';
const API_KEY = '3836d657a7f6bc184e3810e50979d5afecde22e404c7edd7c5cea5b3e50c5cd5';

export const knowledgeService = {
  async search(query: string) {
    const response = await fetch(
      `${API_BASE}/knowledge/search?q=${encodeURIComponent(query)}`,
      { headers: { 'X-API-Key': API_KEY } }
    );
    return response.json();
  },

  async getRecent(limit: number = 20) {
    const response = await fetch(
      `${API_BASE}/knowledge/recent?limit=${limit}`,
      { headers: { 'X-API-Key': API_KEY } }
    );
    return response.json();
  },
};
```

**2. React Component** (`apps/web/src/pages/KnowledgeSearch.tsx`)
```typescript
export const KnowledgeSearch: React.FC = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<KnowledgeEntry[]>([]);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    const response = await knowledgeService.search(query);
    setResults(response.results || []);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
      {/* Beautiful UI with Tailwind CSS */}
      <form onSubmit={handleSearch}>
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search knowledge..."
        />
      </form>

      {results.map(entry => (
        <div key={entry.id}>
          {/* Display results */}
        </div>
      ))}
    </div>
  );
};
```

**3. Deploy**
```bash
npm run build
npx wrangler pages deploy dist --project-name=knowledge-search
```

**Done!** Live at: https://knowledge-search.pages.dev

---

## Infrastructure as Code: Wrangler CLI

### Why API Access Matters

**Traditional approach:**
1. Log into web dashboard
2. Click through UI
3. Upload files manually
4. Configure settings in GUI
5. Hope you remember the steps

**Our approach:**
```bash
# Everything is a command
wrangler pages project create my-app
wrangler pages deploy dist --project-name=my-app
wrangler pages project list

# Scriptable, repeatable, automatable
```

### Key Wrangler Commands

**Authentication:**
```bash
wrangler login                    # Authenticate via browser
wrangler whoami                   # Check current user/account
```

**Pages Management:**
```bash
wrangler pages project list       # List all Pages projects
wrangler pages project create X   # Create new project
wrangler pages deploy dist        # Deploy to production
wrangler pages deployment list    # View deployment history
```

**Workers Management:**
```bash
wrangler deploy                   # Deploy worker
wrangler deployments list         # View worker deployments
wrangler tail                     # Live logs
```

**D1 Database:**
```bash
wrangler d1 list                  # List databases
wrangler d1 execute DB --command="SELECT * FROM users"
wrangler d1 migrations apply      # Run migrations
```

**R2 Storage:**
```bash
wrangler r2 bucket list           # List buckets
wrangler r2 object put            # Upload file
wrangler r2 object get            # Download file
```

### Automation Example

**Deploy script** (`deploy.sh`):
```bash
#!/bin/bash
set -e

echo "Building..."
npm run build

echo "Deploying to Cloudflare Pages..."
wrangler pages deploy dist \
  --project-name=knowledge-search \
  --commit-dirty=true

echo "✅ Deployed to:"
echo "https://knowledge-search.pages.dev"
```

**One command:**
```bash
./deploy.sh
```

---

## The Full Stack Picture

### Our Infrastructure (All Cloudflare)

**Pages (Frontend):**
- knowledge-search - Knowledge base UI
- funjobs-ai - Job board frontend
- cluster-status - Agent dashboard
- 90+ other projects

**Workers (Backend):**
- pinky-brain-hub - Message bus & knowledge API
- funjobs-ai - Job board API with AI

**D1 Databases:**
- pinky-brain-messages - Agent communication
- funjobs-db - Job board data

**R2 Storage:**
- funjobs-job-images - Uploaded job flyers

**Total Monthly Cost:** $0 (on free tier)

### Why This Matters for Moving Fast

1. **No DevOps overhead** - No servers, no Kubernetes, no Docker compose
2. **Deploy from anywhere** - Just need `wrangler` CLI
3. **Instant rollback** - Every deployment is versioned
4. **Zero downtime** - Edge network handles traffic shifting
5. **Global by default** - No CDN to configure

---

## The "30-Minute App" Checklist

Use this pattern for any new app:

- [ ] Clone boilerplate repo
- [ ] Update `package.json` name
- [ ] Create API service layer (`src/services/`)
- [ ] Build main component (`src/pages/`)
- [ ] Update routing (`src/App.tsx`)
- [ ] `npm install && npm run build`
- [ ] `wrangler pages project create app-name`
- [ ] `wrangler pages deploy dist --project-name=app-name`
- [ ] Share URL with team

**Time:** 20-40 minutes depending on complexity

---

## Advanced Patterns

### Multi-Environment Deployments

```bash
# Production
wrangler pages deploy dist --project-name=my-app

# Preview (automatic preview URL)
wrangler pages deploy dist --project-name=my-app --branch=preview

# Each git branch gets its own URL
# https://abc.my-app.pages.dev (main)
# https://xyz.my-app.pages.dev (preview)
```

### Environment Variables

```bash
# Set via CLI
wrangler pages secret put API_KEY

# Or in wrangler.toml
[env.production]
vars = { API_URL = "https://api.example.com" }
```

### Custom Domains

```bash
# Add custom domain via CLI
wrangler pages domains add my-app example.com
```

Cloudflare automatically:
- Provisions SSL certificate
- Configures DNS (if using Cloudflare DNS)
- Handles renewal

---

## Common Gotchas & Solutions

### 1. TypeScript Errors in Build

**Problem:**
```
Type 'undefined' is not assignable to type 'KnowledgeEntry[]'
```

**Solution:** Always provide defaults
```typescript
// ❌ Bad
setResults(response.results);

// ✅ Good
setResults(response.results || []);
```

### 2. CORS Issues

**Problem:** Frontend can't call backend API

**Solution:** Add CORS headers in Worker
```typescript
// In your Worker
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
  'Access-Control-Allow-Headers': 'Content-Type, X-API-Key',
};

return new Response(JSON.stringify(data), {
  headers: { ...corsHeaders, 'Content-Type': 'application/json' }
});
```

### 3. Build Output Directory

**Problem:** `wrangler pages deploy` looking in wrong directory

**Solution:** Always specify the dist folder
```bash
cd apps/web
wrangler pages deploy dist --project-name=my-app
```

### 4. Authentication Issues

**Problem:** `Error: Not authenticated`

**Solution:**
```bash
wrangler logout
wrangler login
```

---

## Measuring Success

### What "Moving Fast" Means

**Before this stack:**
- Hours: Setting up servers, configuring nginx, SSL certs
- Days: Database setup, backups, monitoring
- Weeks: Scaling infrastructure, CDN configuration

**With this stack:**
- Minutes: Deploy working app globally
- Hours: Add features, iterate based on feedback
- Days: Build complete products

### Real Metrics (This Session)

**Task:** Build visual knowledge search interface

**Timeline:**
- 0:00 - Clone boilerplate
- 0:01 - Install dependencies
- 0:05 - Create API service
- 0:20 - Build React UI components
- 0:25 - Build for production
- 0:27 - Create Cloudflare Pages project
- 0:28 - Deploy
- **Total: 28 minutes**

**Result:**
- Live URL: https://knowledge-search.pages.dev
- Globally distributed
- HTTPS enabled
- Zero configuration
- Connected to existing backend API
- Beautiful, responsive UI

---

## Tutorial: Your First Cloudflare App

### Prerequisites
```bash
# Install Wrangler
npm install -g wrangler

# Authenticate
wrangler login
```

### Step-by-Step

**1. Create a Simple Worker**
```bash
wrangler init my-first-worker
cd my-first-worker
```

**2. Write Your Code** (`src/index.ts`)
```typescript
export default {
  async fetch(request: Request): Promise<Response> {
    return new Response('Hello from Cloudflare Workers!', {
      headers: { 'Content-Type': 'text/plain' }
    });
  }
};
```

**3. Deploy**
```bash
wrangler deploy
```

**Done!** Live at: `https://my-first-worker.your-account.workers.dev`

### Next Steps

**Add a Database:**
```bash
# Create D1 database
wrangler d1 create my-database

# Add to wrangler.toml
[[d1_databases]]
binding = "DB"
database_name = "my-database"
database_id = "abc-123-xyz"

# Create tables
wrangler d1 execute my-database --command="CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)"
```

**Use in Worker:**
```typescript
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const users = await env.DB.prepare('SELECT * FROM users').all();
    return Response.json(users);
  }
};
```

---

## Key Takeaways

1. **Use boilerplates** - Don't start from scratch
2. **API access > web dashboards** - Scriptable is repeatable
3. **Deploy early and often** - Every push can be live in 30 seconds
4. **Edge computing** - Let Cloudflare handle global distribution
5. **Serverless mindset** - No servers to manage = faster shipping

---

## Resources

**Our Boilerplate:**
- https://github.com/ideabrian/buildstuff-ai-starter

**Cloudflare Docs:**
- Workers: https://developers.cloudflare.com/workers/
- Pages: https://developers.cloudflare.com/pages/
- D1: https://developers.cloudflare.com/d1/
- R2: https://developers.cloudflare.com/r2/

**Wrangler CLI:**
- Docs: https://developers.cloudflare.com/workers/wrangler/
- GitHub: https://github.com/cloudflare/workers-sdk

**Our Infrastructure:**
- Inventory: `~/pinkyandbrain/CLOUDFLARE-INVENTORY.md`
- Live knowledge search: https://knowledge-search.pages.dev
- Message bus API: https://pinky-brain-hub.b-9f2.workers.dev

---

**Created:** 2025-10-17
**Example App:** Knowledge Search (28 minutes to deploy)
**Stack:** React + Vite + Cloudflare Pages + Workers + D1
**Cost:** $0/month on free tier

**The secret to moving fast:** Remove all the friction between idea and deployment.
