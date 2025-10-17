# TRAIN THE HUMAN: Cloudflare Deployment Strategy

## Purpose
This guide teaches humans how to deploy full-stack applications to Cloudflare's edge platform using Workers, Pages, and D1. It covers authentication, architecture decisions, and the workflow for autonomous + human collaboration.

---

## Table of Contents
1. [The Mental Model](#the-mental-model)
2. [Authentication Setup](#authentication-setup)
3. [Architecture Patterns](#architecture-patterns)
4. [Deployment Workflow](#deployment-workflow)
5. [Troubleshooting](#troubleshooting)
6. [Exercises](#exercises)

---

## The Mental Model

### Before: Monolithic Traditional Hosting
```
┌─────────────────────────────────────┐
│   Single Server (Heroku, DigitalOcean)   │
│                                     │
│   Frontend + Backend + Database     │
│   (all in one place, slow deploys)   │
└─────────────────────────────────────┘
         ↑
    [Your Computer]
    - git push heroku main
    - Wait 2-5 minutes
    - Hope it works
```

### After: Cloudflare Edge Architecture
```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Cloudflare     │     │  Cloudflare      │     │  Cloudflare │
│  Pages          │────▶│  Workers         │────▶│  D1         │
│  (Frontend)     │     │  (Backend API)   │     │  (Database) │
│                 │     │                  │     │             │
│  React/Vite     │     │  Hono Framework  │     │  SQLite     │
│  Static Assets  │     │  Serverless      │     │  At Edge    │
└─────────────────┘     └──────────────────┘     └─────────────┘
         ↑
    [Your Computer]
    - wrangler pages deploy dist/
    - wrangler deploy
    - Live in ~10 seconds
    - 300+ edge locations globally
```

**Key Differences:**
- **Separation of concerns**: Frontend (Pages) vs Backend (Workers) vs Data (D1)
- **Speed**: Deploys in seconds, not minutes
- **Global**: Runs at 300+ edge locations worldwide
- **Cost**: Free tier is VERY generous (100K requests/day)
- **Scale**: Auto-scales to billions of requests

---

## Authentication Setup

### Problem: Wrangler Needs Credentials

When you run `wrangler deploy`, it needs to know:
1. **Who you are** (your Cloudflare account)
2. **What you can access** (API permissions)

Without authentication, you get:
```
✘ [ERROR] You are not authenticated. Please run `wrangler login`.
```

### Solution 1: Interactive Login (Recommended for Humans)

**Best for:** Manual deployments from your laptop

```bash
# One-time setup
wrangler login

# Opens browser, you click "Authorize"
# Saves credentials to ~/.wrangler/config/
# Now all wrangler commands work
```

**How it works:**
1. `wrangler login` opens browser
2. You log in to Cloudflare dashboard
3. Click "Authorize Wrangler"
4. Token saved locally (~/.wrangler/config/)
5. All future commands use this token

### Solution 2: API Token (Recommended for Automation)

**Best for:** CI/CD, autonomous Claude, scripts

```bash
# 1. Generate API token (do this once)
# Visit: https://dash.cloudflare.com/profile/api-tokens
# Click: Create Token -> Edit Cloudflare Workers
# Permissions: Account.Workers Scripts (Edit), Account.D1 (Edit), Zone.Workers Routes (Edit)
# Copy the token (looks like: v8HgJ3K9mN4pQr2sT5vW7xY0zA1bC3dE4fG6hI8jK)

# 2. Set environment variable (add to ~/.zshrc)
export CLOUDFLARE_API_TOKEN="your-token-here"

# 3. Reload shell
source ~/.zshrc

# 4. Test
wrangler whoami
# Should show: You are logged in with an API Token
```

**Add to ~/.zshrc:**
```bash
# Cloudflare Deployment
export CLOUDFLARE_API_TOKEN="v8HgJ3K9mN4pQr2sT5vW7xY0zA1bC3dE4fG6hI8jK"
export CLOUDFLARE_ACCOUNT_ID="your-account-id-here"  # Optional but helpful
```

### Solution 3: Account ID (For Multi-Account Users)

If you have multiple Cloudflare accounts:
```bash
export CLOUDFLARE_ACCOUNT_ID="abc123def456"
```

Find your account ID:
```bash
wrangler whoami
# Or visit: https://dash.cloudflare.com/ (in URL after /accounts/)
```

---

## Architecture Patterns

### Pattern 1: Everything in Workers (Simple Projects)

**Good for:** Small APIs, single-page apps with minimal frontend

```
┌─────────────────────────────────────┐
│   Cloudflare Workers                │
│                                     │
│   Backend API + Static Assets       │
│   (wrangler.toml with [site] config)│
└─────────────────────────────────────┘
```

**wrangler.toml:**
```toml
name = "my-app"
main = "src/index.ts"

[site]
bucket = "./dist"  # Static files served by Workers
```

**Deployment:**
```bash
npm run build      # Build frontend to dist/
wrangler deploy    # Deploy everything together
```

**Pros:**
- Simple (one deploy command)
- Single URL (my-app.workers.dev)

**Cons:**
- Workers have 1MB size limit (can be tight with large frontends)
- Static assets count against Worker size
- No automatic CDN caching optimization

### Pattern 2: Pages + Workers (Recommended for Full-Stack)

**Good for:** React/Vue/Svelte apps with backend APIs

```
┌─────────────────┐     ┌──────────────────┐
│  Pages          │────▶│  Workers         │
│  (Frontend)     │     │  (Backend API)   │
│                 │     │                  │
│  *.pages.dev    │     │  *.workers.dev   │
└─────────────────┘     └──────────────────┘
```

**Frontend (Pages):**
```bash
# Build your React/Vite app
npm run build  # Creates dist/

# Deploy to Pages
wrangler pages deploy dist/ --project-name=my-app

# Live at: https://my-app.pages.dev
```

**Backend (Workers):**
```bash
# Deploy your Hono/Workers API
wrangler deploy

# Live at: https://my-app.workers.dev
```

**Frontend connects to Backend:**
```typescript
// client/config.ts
export const API_BASE_URL = 'https://my-app.workers.dev';

// client/pages/Home.tsx
fetch(`${API_BASE_URL}/api/workers`)
  .then(res => res.json())
  .then(data => console.log(data));
```

**Backend allows Frontend (CORS):**
```typescript
// src/index.ts
import { Hono } from 'hono';
import { cors } from 'hono/cors';

const app = new Hono();

app.use('/*', cors({
  origin: ['https://my-app.pages.dev', 'http://localhost:5173'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type'],
}));
```

**Pros:**
- No size limits on frontend (Pages handles CDN)
- Automatic caching and optimization
- Separate deployments (update frontend without touching backend)
- Better performance

**Cons:**
- Two deploy commands
- Need to configure CORS
- Two URLs to manage

### Pattern 3: Pages with Functions (Hybrid)

**Good for:** Mostly static sites with some serverless functions

```
┌─────────────────────────────────────┐
│   Cloudflare Pages                  │
│                                     │
│   Static Assets + Functions/        │
│   (Pages Functions = mini-Workers)  │
└─────────────────────────────────────┘
```

**Structure:**
```
my-app/
├── functions/          # API routes as files
│   ├── api/
│   │   ├── hello.ts   # /api/hello endpoint
│   │   └── users.ts   # /api/users endpoint
└── public/            # Static files
    ├── index.html
    └── styles.css
```

**Deployment:**
```bash
wrangler pages deploy public/ --project-name=my-app
# Functions automatically deployed too
```

**Pros:**
- Single deployment
- Single URL
- Simple for small APIs

**Cons:**
- Less powerful than full Workers
- Tied to Pages project
- Limited middleware support

---

## Deployment Workflow

### The Autonomous + Human Collaboration Model

**What Claude Does (Autonomous):**
1. ✅ Build the entire application (frontend + backend)
2. ✅ Create database migrations
3. ✅ Write comprehensive README
4. ✅ Test build locally
5. ✅ Commit to git
6. ✅ Document deployment steps
7. ❌ **Cannot authenticate with Cloudflare** (requires human credentials)

**What Human Does (Manual):**
1. ✅ Authenticate with Cloudflare (`wrangler login` or set API token)
2. ✅ Create D1 database (if needed)
3. ✅ Run migrations
4. ✅ Deploy frontend to Pages
5. ✅ Deploy backend to Workers
6. ✅ Verify it's live

### Real Example: FunJobs.ai Deployment

**Context:**
- Autonomous Claude built full-stack app in 45 minutes
- 6,403 lines of code, 26 files, 8 API endpoints
- Ready to deploy but not authenticated

**Step-by-Step (Human):**

```bash
# 1. Navigate to project
cd ~/pinkyandbrain/funjobs-ai

# 2. Verify you're authenticated
wrangler whoami
# If not: wrangler login

# 3. Create D1 database (one-time)
wrangler d1 create funjobs-db
# Output:
# database_name = "funjobs-db"
# database_id = "b56c2c89-7cd8-47cf-b560-890dea74650f"

# 4. Update wrangler.toml with database ID (if not already set)
# (Claude already did this in the autonomous build)

# 5. Run migrations on production database
wrangler d1 migrations apply funjobs-db --remote
# Creates tables: workers, inquiries, reviews
# Seeds data: 8 AI workers, sample reviews

# 6. Build frontend (if not already built)
npm run build
# Creates: dist/

# 7. Deploy frontend to Pages
wrangler pages deploy dist/ --project-name=funjobs-ai
# Output: https://funjobs-ai.pages.dev
#         https://3605bfb7.funjobs-ai.pages.dev (specific deployment)

# 8. Deploy backend to Workers
wrangler deploy
# Output: https://funjobs-ai.b-9f2.workers.dev

# 9. Verify API is working
curl https://funjobs-ai.b-9f2.workers.dev/api/health
# Should return: {"status":"ok","timestamp":1760647037167}

# 10. Verify frontend is working
open https://funjobs-ai.pages.dev
# Should see: AI workers job board with 8 workers
```

**What Actually Happened (from git history):**

The commit message shows:
```
Separate frontend and backend: Pages + Workers architecture

- Frontend deployed to Cloudflare Pages (https://funjobs-ai.pages.dev)
- Backend API on Cloudflare Workers (https://funjobs-ai.b-9f2.workers.dev)
- Frontend: https://3605bfb7.funjobs-ai.pages.dev
- API: 8 endpoints working with D1 database

Architecture: React (Pages) -> API (Workers) -> D1 Database
```

This means:
1. ✅ Autonomous Claude built everything
2. ✅ Human (you) deployed it manually
3. ✅ Frontend and backend are live
4. ✅ D1 database is connected and working

---

## Troubleshooting

### Error: "You are not authenticated"

**Symptom:**
```
✘ [ERROR] You are not authenticated. Please run `wrangler login`.
```

**Solution:**
```bash
# Option 1: Interactive login
wrangler login

# Option 2: Set API token
export CLOUDFLARE_API_TOKEN="your-token-here"
```

### Error: "Database not found"

**Symptom:**
```
✘ [ERROR] D1 database "funjobs-db" not found
```

**Solution:**
```bash
# Create the database
wrangler d1 create funjobs-db

# Copy the database_id from output
# Update wrangler.toml:
[[d1_databases]]
binding = "DB"
database_name = "funjobs-db"
database_id = "paste-id-here"
```

### Error: "CORS policy blocked"

**Symptom:**
```
Access to fetch at 'https://my-app.workers.dev/api/workers' from origin
'https://my-app.pages.dev' has been blocked by CORS policy
```

**Solution:**
Add CORS middleware to your Workers backend:
```typescript
import { cors } from 'hono/cors';

app.use('/*', cors({
  origin: ['https://my-app.pages.dev', 'http://localhost:5173'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
}));
```

### Error: "Worker exceeded size limit"

**Symptom:**
```
✘ [ERROR] Worker size exceeds 1 MB limit
```

**Solution:**
Use the Pages + Workers pattern (separate deployments):
```bash
# Deploy static assets to Pages (no size limit)
wrangler pages deploy dist/ --project-name=my-app

# Deploy only backend to Workers (much smaller)
wrangler deploy
```

### Error: "Migrations failed"

**Symptom:**
```
✘ [ERROR] Error applying migrations: table already exists
```

**Solution:**
Check if migrations were already applied:
```bash
# List migrations
wrangler d1 migrations list funjobs-db --remote

# If already applied, skip or use --force
wrangler d1 migrations apply funjobs-db --remote --force
```

---

## Exercises

### Exercise 1: Deploy a Simple Worker

**Goal:** Get comfortable with basic wrangler commands

```bash
# 1. Create a new project
mkdir hello-worker
cd hello-worker

# 2. Create a simple Worker
cat > src/index.ts <<'EOF'
export default {
  async fetch(request: Request): Promise<Response> {
    return new Response('Hello from Cloudflare Workers!', {
      headers: { 'Content-Type': 'text/plain' },
    });
  },
};
EOF

# 3. Create wrangler.toml
cat > wrangler.toml <<'EOF'
name = "hello-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"
EOF

# 4. Deploy
wrangler deploy

# 5. Test
curl https://hello-worker.YOUR-SUBDOMAIN.workers.dev
```

**Expected Output:**
```
Hello from Cloudflare Workers!
```

**Self-Check:**
- [ ] Did the deployment succeed?
- [ ] Can you access the URL?
- [ ] Do you understand what each file does?

### Exercise 2: Deploy a Static Site to Pages

**Goal:** Deploy a simple HTML/CSS/JS site to Pages

```bash
# 1. Create a project
mkdir my-static-site
cd my-static-site

# 2. Create index.html
cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>My Static Site</title>
  <style>
    body { font-family: system-ui; max-width: 600px; margin: 100px auto; text-align: center; }
    h1 { color: #f6821f; }
  </style>
</head>
<body>
  <h1>Hello from Cloudflare Pages!</h1>
  <p>This site is deployed to the edge.</p>
</body>
</html>
EOF

# 3. Deploy to Pages
wrangler pages deploy . --project-name=my-static-site

# 4. Open in browser
open https://my-static-site.pages.dev
```

**Self-Check:**
- [ ] Did you see the deployment URL?
- [ ] Can you access the site?
- [ ] Does it load instantly from the edge?

### Exercise 3: Create and Query a D1 Database

**Goal:** Set up a database and run queries

```bash
# 1. Create database
wrangler d1 create my-test-db
# Copy the database_id from output

# 2. Create migration
mkdir -p migrations
cat > migrations/0001_create_users.sql <<'EOF'
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE
);

INSERT INTO users (name, email) VALUES
  ('Alice', 'alice@example.com'),
  ('Bob', 'bob@example.com');
EOF

# 3. Create wrangler.toml
cat > wrangler.toml <<'EOF'
name = "db-test"
main = "src/index.ts"

[[d1_databases]]
binding = "DB"
database_name = "my-test-db"
database_id = "paste-your-id-here"
EOF

# 4. Apply migrations locally
wrangler d1 migrations apply my-test-db --local

# 5. Query the database
wrangler d1 execute my-test-db --local --command "SELECT * FROM users"
```

**Expected Output:**
```
┌────┬───────┬──────────────────────┐
│ id │ name  │ email                │
├────┼───────┼──────────────────────┤
│ 1  │ Alice │ alice@example.com    │
│ 2  │ Bob   │ bob@example.com      │
└────┴───────┴──────────────────────┘
```

**Self-Check:**
- [ ] Did the database get created?
- [ ] Did migrations run successfully?
- [ ] Can you query the data?
- [ ] Do you understand the binding concept?

### Exercise 4: Full-Stack App (Pages + Workers + D1)

**Goal:** Deploy the FunJobs.ai app (or similar)

```bash
# 1. Clone/navigate to project
cd ~/pinkyandbrain/funjobs-ai

# 2. Verify authentication
wrangler whoami

# 3. Check if D1 database exists
wrangler d1 list | grep funjobs

# 4. If not, create it
wrangler d1 create funjobs-db

# 5. Update wrangler.toml with database_id

# 6. Run migrations
wrangler d1 migrations apply funjobs-db --remote

# 7. Build frontend
npm install
npm run build

# 8. Deploy frontend to Pages
wrangler pages deploy dist/ --project-name=funjobs-ai

# 9. Deploy backend to Workers
wrangler deploy

# 10. Test API
curl https://funjobs-ai.YOUR-SUBDOMAIN.workers.dev/api/health

# 11. Test frontend
open https://funjobs-ai.pages.dev
```

**Self-Check:**
- [ ] Is the API responding?
- [ ] Does the frontend load?
- [ ] Can you see the 8 AI workers?
- [ ] Do API calls work (check Network tab)?
- [ ] Are there any CORS errors?

---

## Summary: Key Takeaways

1. **Authentication is Required:**
   - Use `wrangler login` for manual deployments
   - Use `CLOUDFLARE_API_TOKEN` env var for automation/CI/CD

2. **Architecture Matters:**
   - Simple projects: Everything in Workers (with [site] config)
   - Full-stack projects: Pages (frontend) + Workers (backend)
   - Hybrid: Pages with Functions

3. **Deployment is Fast:**
   - Pages: `wrangler pages deploy dist/`
   - Workers: `wrangler deploy`
   - Live in ~10 seconds

4. **CORS is Important:**
   - Workers must allow Pages origin
   - Add CORS middleware to backend

5. **D1 Setup:**
   - Create database: `wrangler d1 create <name>`
   - Run migrations: `wrangler d1 migrations apply <name> --remote`
   - Bind in wrangler.toml

6. **Autonomous + Human = Perfect:**
   - Claude builds the app (code, tests, docs)
   - Human deploys with credentials (wrangler commands)
   - Best of both worlds

---

## Graduation Checklist

You've mastered Cloudflare deployment when you can:

- [ ] Authenticate with wrangler (login or API token)
- [ ] Deploy a simple Worker
- [ ] Deploy a static site to Pages
- [ ] Create and query a D1 database
- [ ] Deploy a full-stack app (Pages + Workers + D1)
- [ ] Configure CORS correctly
- [ ] Debug common deployment errors
- [ ] Explain the separation of concerns architecture
- [ ] Set up environment variables for automation
- [ ] Verify deployments are live and working

---

## Next Steps

Once you've mastered deployment:

1. **Custom Domains:** Connect your own domain to Pages/Workers
2. **Environment Variables:** Use `wrangler.toml` for secrets
3. **Cron Triggers:** Schedule Workers to run automatically
4. **Durable Objects:** Add real-time state management
5. **Analytics:** Monitor performance with Cloudflare Analytics
6. **Preview Deployments:** Use Pages branches for PR previews
7. **CI/CD Integration:** Automate deployments with GitHub Actions

---

**Built by Pinky + Claude Code to make humans deployment-competent in 30 minutes.**
