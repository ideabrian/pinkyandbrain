# Utilities Guide: Face-Melting Tools 😁

**"Smile until your face hurts"** - These utilities make distributed AI orchestration so good, you'll grin from ear to ear.

---

## 🚀 The Complete Toolkit

### 1. **`pinky` CLI** - Command Everything

**What it does**: Unified command-line interface for the entire system

**Commands**:
```bash
pinky send "Run tests" --to pinky-claude --priority high
pinky inbox --unread
pinky status
pinky health
pinky logs --follow
pinky agents
pinky clear
```

**Shortcuts**:
```bash
pinky s <msg>     # send
pinky i           # inbox
pinky st          # status
pinky h           # health
pinky l           # logs
```

**Examples**:
```bash
# Send task to pinky
pinky send "Build the frontend" --to pinky-claude

# Check your inbox
pinky inbox --unread --type task

# Full system health check
pinky health

# Watch logs in real-time
pinky logs --follow
```

**Why it's awesome**: No more typing long curl commands. Everything in one simple CLI.

---

### 2. **Template Library** - Pre-built Workflows

**What it does**: Execute common tasks with zero configuration

**Commands**:
```bash
template list                          # Show all templates
template show test-runner              # View template details
template run test-runner               # Execute template
template run build-frontend build_command="npm run build:prod"
template run deploy-pipeline environment=staging
```

**Available Templates**:

1. **test-runner** - Run test suite and report results
2. **build-frontend** - Build React/Vue/Angular app
3. **code-review** - Automated code review with suggestions
4. **deploy-pipeline** - Full test → build → deploy pipeline
5. **performance-audit** - Comprehensive performance analysis

**Examples**:
```bash
# Run tests on pinky
template run test-runner

# Build with custom command
template run build-frontend build_command="yarn build"

# Deploy to production
template run deploy-pipeline environment=production

# Get code review
template run code-review files="src/api/*.ts"
```

**Why it's awesome**: Complex workflows become one-line commands.

---

### 3. **Git Integration Hooks** - Automate Everything

**What it does**: Trigger tasks automatically on git events

**Installation**:
```bash
cd your-project
~/Documents/projects/pinkyandbrain/git-hooks/install-hooks.sh
```

**Usage**:

**Option 1: Explicit triggers in commit messages**
```bash
git commit -m "[test:pinky] Add new feature"
git commit -m "[build:maxyolo] Update dependencies"
git commit -m "[deploy:pinky] Release v2.0"
git commit -m "[review:pinky] Refactor API"
```

**Option 2: Auto-trigger on code changes**
```bash
git commit -m "Fix bug in user service"
# Automatically sends test task if .ts/.js files changed
```

**Option 3: Pre-push validation**
```bash
git push origin main
# Automatically runs tests + lint before push to main/master
```

**Available Triggers**:
- `[test:agent]` - Run test suite
- `[build:agent]` - Build project
- `[deploy:agent]` - Deploy to staging
- `[review:agent]` - Code review

**Why it's awesome**: Your git workflow becomes your CI/CD pipeline.

---

### 4. **Live Dashboard** - Watch It All

**What it does**: Real-time visualization of your distributed system

**Open it**:
```bash
open ~/Documents/projects/pinkyandbrain/dashboard.html
```

**Features**:
- ✅ Real-time agent status (online/offline)
- ✅ Message counts (total/unread per agent)
- ✅ Live message feed with filtering
- ✅ Auto-refresh every 5 seconds
- ✅ Beautiful gradient UI
- ✅ Message filtering (all/tasks/completions/unread)
- ✅ One-click clear all messages

**Why it's awesome**: See your entire distributed system at a glance. Watch tasks flow between agents in real-time.

---

## 🎯 Real-World Workflows

### Workflow 1: Feature Development

```bash
# 1. Start working on a feature
cd your-project

# 2. Make changes
vim src/api/users.ts

# 3. Commit with test trigger
git commit -m "[test:pinky] Add user authentication"
# → Automatically sends test task to pinky-claude

# 4. Check dashboard to see test results
open ~/Documents/projects/pinkyandbrain/dashboard.html

# 5. If tests pass, send build task
template run build-frontend

# 6. Review status
pinky status
pinky inbox --type completion
```

### Workflow 2: Deployment Pipeline

```bash
# 1. Check system health
pinky health

# 2. Run deployment template
template run deploy-pipeline environment=staging

# 3. Watch dashboard for progress
# (opens automatically)

# 4. Verify completion
pinky inbox --type completion

# 5. If successful, deploy to prod
template run deploy-pipeline environment=production
```

### Workflow 3: Code Review Process

```bash
# 1. Request review from pinky
template run code-review files="src/components/*.tsx"

# 2. Make changes based on feedback
vim src/components/Button.tsx

# 3. Commit with auto-test
git commit -m "Fix TypeScript errors in Button"
# → Auto-triggers tests

# 4. Check results in dashboard
# → See test completion in real-time
```

### Workflow 4: Continuous Monitoring

```bash
# 1. Open dashboard
open ~/Documents/projects/pinkyandbrain/dashboard.html

# 2. Keep it open on second monitor

# 3. Work normally - commit, push, etc.

# 4. Watch tasks flow through system in real-time
# - Commits trigger tests
# - Tests complete
# - Build starts
# - Deploy executes

# All visible in dashboard!
```

---

## 🔥 Power User Tips

### 1. Combine Tools

```bash
# Send task via CLI + watch in dashboard
pinky send "Analyze performance" --to pinky-claude --priority high &
open ~/Documents/projects/pinkyandbrain/dashboard.html
```

### 2. Custom Templates

Create `templates/my-workflow.json`:
```json
{
  "name": "my-workflow",
  "description": "My custom workflow",
  "template": {
    "from": "{{from}}",
    "to": "{{to}}",
    "body": "Do my thing: {{custom_param}}"
  },
  "variables": {
    "custom_param": {
      "description": "My parameter",
      "required": true
    }
  }
}
```

Run it:
```bash
template run my-workflow custom_param="test data"
```

### 3. Chained Workflows

```bash
# In one terminal: Watch logs
pinky logs --follow

# In another: Execute chain
template run test-runner && \
template run build-frontend && \
template run deploy-pipeline environment=staging

# Watch it all flow through the logs
```

### 4. Dashboard + CLI Combo

```bash
# Terminal 1: Dashboard (visual)
open ~/Documents/projects/pinkyandbrain/dashboard.html

# Terminal 2: CLI monitoring (text)
watch -n 2 'pinky status'

# Terminal 3: Work
git commit -m "[test:pinky] New feature"
```

---

## 📊 What You've Built

**Before (manual)**:
```bash
# Send message
curl -X POST http://192.168.5.80:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "maxyolo-claude",
    "to": "pinky-claude",
    "type": "task",
    "subject": "Run Tests",
    "body": "Run npm test and report results",
    "priority": "high",
    "metadata": {
      "task_id": "test-12345",
      "auto_execute": false
    }
  }'

# Check inbox
curl http://localhost:3100/inbox | jq '.messages[] | select(.type == "task")'
```

**After (with utilities)**:
```bash
# Send message
pinky send "Run tests" --to pinky-claude --priority high

# Or use template
template run test-runner

# Or just commit
git commit -m "[test:pinky] My changes"

# Check results
pinky inbox
# Or just open dashboard
```

**Time saved**: ~90% less typing, ~100% more smiling 😁

---

## 🎓 Command Cheat Sheet

### Quick Reference

```bash
# CLI
pinky s "task"              # Send task
pinky i                      # Check inbox
pinky st                     # System status
pinky h                      # Health check
pinky l -f                   # Follow logs

# Templates
template list                # List templates
template run <name>          # Execute template

# Git
git commit -m "[test:agent]" # Trigger on commit
git push                     # Validate on push

# Dashboard
open ~/Documents/projects/pinkyandbrain/dashboard.html
```

### One-Liners for Common Tasks

```bash
# Full system check
pinky health && pinky status

# Send task + watch results
pinky send "Build app" --to pinky-claude & open dashboard.html

# Deploy pipeline
template run deploy-pipeline environment=staging

# Monitor everything
pinky logs -f & open dashboard.html

# Clear and restart
pinky clear && ./orchestrator.sh
```

---

## 🚀 Installation

All utilities are already installed! Just reload your shell:

```bash
source ~/.zshrc

# Verify
pinky --help
template --help
```

**Files Created**:
- `~/Documents/projects/pinkyandbrain/pinky-cli.sh` → `pinky` command
- `~/Documents/projects/pinkyandbrain/template-runner.sh` → `template` command
- `~/Documents/projects/pinkyandbrain/templates/*.json` → 5 pre-built templates
- `~/Documents/projects/pinkyandbrain/git-hooks/*` → Git automation
- `~/Documents/projects/pinkyandbrain/dashboard.html` → Live dashboard

---

## 💡 Next Level

**When you're ready to go even further**:

1. **Custom MCP Server** - Expose these utilities via MCP protocol
2. **Web API** - REST API wrapper around the CLI
3. **Mobile Dashboard** - View agents from phone
4. **Slack Integration** - Task notifications in Slack
5. **Metrics & Analytics** - Track task completion rates
6. **AI Task Router** - Claude decides which agent gets what task

---

## 🎉 Why This Is Amazing

**You built**:
- A unified CLI for distributed systems
- A template library for common workflows
- Git hooks that turn commits into CI/CD
- A real-time dashboard for visualization

**Skills you're using**:
- Bash scripting
- JSON templating
- Git hooks
- Real-time UIs
- API design
- Systems thinking

**What it replaces**:
- GitHub Actions (you have git hooks)
- Jenkins (you have task pipelines)
- Datadog (you have live dashboard)
- AWS SQS (you have message bus)
- Airflow (you have workflow templates)

**All on hardware you own. With code you wrote. Understanding you have.**

---

**Your face should hurt from smiling now.** 😁

If not, run this and watch the magic:

```bash
# Terminal 1: Open dashboard
open ~/Documents/projects/pinkyandbrain/dashboard.html

# Terminal 2: Run a workflow
template run test-runner

# Watch it appear in real-time in the dashboard!
```

**Built with**: Bash, HTML, JavaScript, JSON, and a whole lot of ambition.
