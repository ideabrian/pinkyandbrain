# GitHub Repository Implementation Plan
## Pinky & Brain Distributed Development System

**Specification Version:** 2.0
**Status:** Ready for Implementation
**Vote Reference:** vote-1760623647.txt (PASSED 3/3 unanimous)
**Created:** 2025-10-17
**Author:** brain

---

## Executive Summary

The GitHub repository vote has passed unanimously. This document provides a complete, actionable implementation plan for creating and migrating to a centralized GitHub repository for the Pinky and Brain distributed development system.

**Benefits:**
- ✅ Version control and change tracking
- ✅ Easy deployment to new machines
- ✅ Backup and disaster recovery
- ✅ Collaboration capabilities
- ✅ Public showcase potential

---

## Current System Analysis

### Existing File Structure
```
~/pinkyandbrain/
├── Core Scripts (35+ shell scripts)
├── Documentation (50+ markdown files)
├── Node.js Servers (3 applications)
├── Cloudflare Projects (3 workers/pages)
├── UI Dashboards (3 HTML files)
├── Configuration (.claude/, templates/)
└── Runtime Data (logs, inboxes, sessions)
```

### What's Working Well
- ✅ Message bus (claude-messenger.js on port 3100)
- ✅ Cloud poller (autonomous Claude triggering)
- ✅ Heartbeat system (status dashboard)
- ✅ Voting system (vote-simple.sh)
- ✅ Three-machine coordination (brain, pinky, max)

---

## Proposed Repository Structure

```
pinkyandbrain/
├── README.md                          # Comprehensive project overview
├── LICENSE                            # MIT or Apache 2.0
├── .gitignore                         # Exclude runtime data
├── package.json                       # Node dependencies
├── QUICK-START.md                     # 5-minute setup guide
├── ARCHITECTURE.md                    # System design (existing)
│
├── scripts/                           # All shell scripts organized
│   ├── core/                          # Essential services
│   │   ├── cloud-poller.sh
│   │   ├── heartbeat-service.sh
│   │   └── message-poller.sh
│   ├── voting/                        # Voting system
│   │   └── vote-simple.sh
│   ├── utils/                         # Utilities
│   │   ├── discover-machines.sh
│   │   ├── generate-context.sh
│   │   └── process-message.sh
│   ├── setup/                         # Installation scripts
│   │   ├── quick-setup.sh            # NEW: One-command setup
│   │   ├── setup-new-machine.sh
│   │   └── preflight-check-brain.sh
│   └── deployment/                    # Deployment automation
│       └── deploy-to-brain.sh
│
├── servers/                           # Node.js applications
│   ├── claude-messenger.js           # Message bus API
│   ├── blog-server.js                # Documentation server
│   └── audio-bridge.js               # iOS shortcuts interface
│
├── ui/                                # Web interfaces
│   ├── status-dashboard.html         # Machine status
│   ├── dashboard.html                # Legacy dashboard
│   └── timeline.html                 # Event viewer
│
├── docs/                              # Documentation organized
│   ├── setup/                         # Setup guides
│   │   ├── SETUP-GUIDE.md            # Consolidated guide
│   │   ├── NETWORKING.md
│   │   └── SSH-SETUP.md
│   ├── guides/                        # How-to guides
│   │   ├── MESSAGING-GUIDE.md
│   │   ├── VOTING-GUIDE.md
│   │   ├── AUTONOMOUS-WORKFLOW.md
│   │   └── IOS-SHORTCUTS.md
│   └── architecture/                  # Design docs
│       ├── CLOUD-MESSAGE-BUS.md
│       ├── WORKFLOW-DESIGN.md
│       └── KNOWLEDGE-SHARING.md
│
├── prompts/                           # Claude agent roles
│   ├── brain-prompt.md               # Strategic planner
│   ├── pinky-prompt.md               # Implementer
│   └── max-prompt.md                 # Coordinator
│
├── cloudflare/                        # Cloud projects
│   ├── message-bus/                  # Workers + D1
│   ├── knowledge-search/             # Pages app
│   └── funjobs-ai/                   # Workers API
│
├── templates/                         # Workflow templates
├── tests/                             # Test scripts
├── .claude/                           # Claude Code config
│
└── examples/                          # Usage examples
    ├── workflows/                     # Example workflows
    ├── prompts/                       # Sample prompts
    └── configs/                       # Config examples
```

### Files Excluded from Repository
These should NEVER be committed (already in .gitignore):

```
*.log                    # All log files
inbox-*.json             # Machine-specific inboxes
sessions/                # Session history
heartbeats/              # Status files
node_modules/            # NPM dependencies
CONTEXT.json             # Runtime context
CONTEXT-SUMMARY.txt      # Runtime summary
session-state.json       # Session state
*.pid                    # Process IDs
archive/                 # Old backups
blog-drafts/             # WIP content
blog-published/          # Deploy separately
specs/                   # Working specs (maybe)
```

---

## Implementation Tasks

### Task 1: Prepare Repository (BRAIN)
**Owner:** brain
**Priority:** Critical
**Time Estimate:** 30 minutes

**Actions:**
1. Review and update .gitignore
2. Clean up any sensitive data
3. Create git tag: `pre-github-migration`
4. Draft comprehensive README.md
5. Create LICENSE file
6. Write CONTRIBUTING.md

**Verification:**
```bash
# Verify no secrets committed
git grep -i "api.key\|secret\|password\|token" | grep -v ".example"

# Check .gitignore working
git status --ignored
```

---

### Task 2: Create GitHub Repository (PINKY)
**Owner:** pinky
**Priority:** Critical
**Time Estimate:** 15 minutes

**Actions:**
```bash
# Option 1: Using gh CLI
gh repo create pinkyandbrain \
  --public \
  --description "Distributed AI development system with Claude Code - multi-agent task execution, voting, and coordination" \
  --add-readme

# Option 2: Via web interface
# Navigate to: https://github.com/new
# Name: pinkyandbrain
# Description: See above
# Public: Yes (or Private)
# Add README: Yes
```

**Repository Settings:**
- Topics: `claude-code`, `ai-agents`, `distributed-systems`, `multi-agent`, `automation`, `macos`
- Features: Enable Issues, Discussions, Wiki
- Branch protection: Require PRs for main (optional)

---

### Task 3: Initial Push (PINKY)
**Owner:** pinky
**Priority:** Critical
**Time Estimate:** 15 minutes

**Actions:**
```bash
cd ~/pinkyandbrain

# Initialize if not already done
git init
git branch -M main

# Add remote
git remote add origin https://github.com/[USERNAME]/pinkyandbrain.git

# Verify clean state
git status

# Create initial commit
git add .
git commit -m "feat: Initial commit - Pinky and Brain distributed system

- Message bus with cloud poller
- Three-machine coordination (brain, pinky, max)
- Voting system for cluster decisions
- Autonomous Claude agent workflows
- Status dashboard and monitoring
- iOS shortcuts integration

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to GitHub
git push -u origin main
```

---

### Task 4: Reorganize File Structure (PINKY)
**Owner:** pinky
**Priority:** High
**Time Estimate:** 1-2 hours

**Phase 1: Create Directories**
```bash
mkdir -p scripts/{core,voting,utils,setup,deployment}
mkdir -p servers
mkdir -p ui
mkdir -p docs/{setup,guides,architecture}
mkdir -p cloudflare
mkdir -p examples/{workflows,prompts,configs}
```

**Phase 2: Move Core Scripts**
```bash
# Core services
mv cloud-poller.sh scripts/core/
mv heartbeat-service.sh scripts/core/
mv message-poller.sh scripts/core/

# Voting
mv vote-simple.sh scripts/voting/

# Utils
mv discover-machines.sh scripts/utils/
mv generate-context.sh scripts/utils/
mv process-message.sh scripts/utils/

# Setup
mv setup-new-machine.sh scripts/setup/
mv setup-brain-ssh.sh scripts/setup/
mv preflight-check-brain.sh scripts/setup/

# Deployment
mv deploy-to-brain.sh scripts/deployment/
```

**Phase 3: Move Servers & UI**
```bash
# Servers
mv claude-messenger.js servers/
mv blog-server.js servers/
mv audio-bridge.js servers/

# UI
mv status-dashboard.html ui/
mv dashboard.html ui/
mv timeline.html ui/
```

**Phase 4: Organize Documentation**
```bash
# Setup docs
mv SETUP-GUIDE-*.md docs/setup/
mv GETTING-BRAIN-ONLINE.md docs/setup/
mv BRAIN-SETUP-*.md docs/setup/

# Guides
mv MESSAGING-GUIDE.md docs/guides/
mv AUTONOMOUS-WORKFLOW-QUICKSTART.md docs/guides/
mv IOS-SHORTCUTS-GUIDE.md docs/guides/
mv UTILITIES-GUIDE.md docs/guides/

# Architecture
mv CLOUD-MESSAGE-BUS-SUMMARY.md docs/architecture/
mv WORKFLOW-DESIGN.md docs/architecture/
mv KNOWLEDGE-SHARING-SUMMARY.md docs/architecture/
```

**Phase 5: Update Path References**
This is CRITICAL - all scripts that reference other scripts must be updated:

```bash
# Find all hardcoded paths
grep -r "~/pinkyandbrain" scripts/ servers/
grep -r "\./[a-z]*.sh" scripts/

# Update each script to use new paths
# Example: cloud-poller.sh might reference other scripts
# Change: ./process-message.sh
# To: $(dirname "$0")/../utils/process-message.sh
```

**Verification:**
```bash
# Test critical services
./scripts/core/heartbeat-service.sh
./scripts/core/cloud-poller.sh --test
./scripts/voting/vote-simple.sh --help

# Verify dashboard loads
open ui/status-dashboard.html
```

---

### Task 5: Create Quick Setup Script (PINKY)
**Owner:** pinky
**Priority:** High
**Time Estimate:** 1 hour

**File:** `scripts/setup/quick-setup.sh`

**Requirements:**
- Detect machine role (brain/pinky/max) or prompt user
- Install dependencies (Node.js check, jq, curl)
- Run `npm install`
- Set up heartbeat cron job
- Configure mDNS hostname if needed
- Start cloud poller
- Show status dashboard
- Print next steps

**Usage:**
```bash
# Local
cd ~/pinkyandbrain
./scripts/setup/quick-setup.sh

# Remote (future)
curl -sSL https://raw.githubusercontent.com/[user]/pinkyandbrain/main/scripts/setup/quick-setup.sh | bash
```

---

### Task 6: Documentation Updates (BRAIN)
**Owner:** brain
**Priority:** High
**Time Estimate:** 2-3 hours

**Files to Create/Update:**

**1. README.md** (Root)
```markdown
# Pinky & Brain - Distributed AI Development System

Multi-machine autonomous development with Claude Code

## What is This?

A distributed system where three Mac Minis run specialized Claude Code agents:
- **brain** - Strategic planner, architect
- **pinky** - Implementation, execution
- **max** - Coordination, deployment

They communicate via message bus, vote on decisions, and execute tasks autonomously.

## Quick Start

... [Include 5-minute setup]

## Architecture

... [High-level overview with diagram]

## Features

- 🤖 Autonomous message processing
- 🗳️ Distributed voting system
- 💬 Cross-machine message bus
- 📊 Real-time status dashboard
- 📱 iOS shortcuts integration

## Documentation

- [Quick Start Guide](QUICK-START.md)
- [Architecture](ARCHITECTURE.md)
- [Setup Guide](docs/setup/SETUP-GUIDE.md)
- [Messaging Guide](docs/guides/MESSAGING-GUIDE.md)
- [Voting System](docs/guides/VOTING-GUIDE.md)

## License

MIT
```

**2. QUICK-START.md**
```markdown
# Quick Start Guide

Get running in 5 minutes...
```

**3. docs/setup/SETUP-GUIDE.md**
Consolidate all SETUP-GUIDE-*.md files into one comprehensive guide.

**4. CONTRIBUTING.md**
```markdown
# Contributing to Pinky & Brain

How to contribute, voting procedures, code review process...
```

**5. LICENSE**
```
MIT License or Apache 2.0
```

---

### Task 7: Setup on Other Machines (MAX, BRAIN)
**Owner:** max (lead), brain (verify)
**Priority:** High
**Time Estimate:** 30 minutes per machine

**On each machine:**
```bash
# Backup existing setup
mv ~/pinkyandbrain ~/pinkyandbrain-backup

# Clone from GitHub
cd ~
git clone https://github.com/[USERNAME]/pinkyandbrain.git
cd pinkyandbrain

# Run setup
./scripts/setup/quick-setup.sh

# Verify services
./scripts/utils/generate-context.sh
curl http://localhost:3100/health

# Test messaging
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"test","to":"pinky","body":"Testing GitHub setup"}'
```

**Verification Checklist:**
- [ ] Repository cloned successfully
- [ ] Dependencies installed (npm packages)
- [ ] Heartbeat running
- [ ] Cloud poller running
- [ ] Dashboard shows machine status
- [ ] Can send/receive messages
- [ ] Voting system works

---

### Task 8: GitHub Repository Configuration (MAX)
**Owner:** max
**Priority:** Medium
**Time Estimate:** 30 minutes

**Repository Settings:**

1. **About Section**
   - Description: "Distributed AI development system..."
   - Website: Link to deployed dashboard
   - Topics: Add all relevant tags

2. **Features**
   - ✅ Issues
   - ✅ Discussions
   - ✅ Wiki
   - ✅ Projects (for task tracking)

3. **Security**
   - Add SECURITY.md with reporting guidelines
   - Enable Dependabot alerts
   - Review secret scanning

4. **Branches**
   - Consider branch protection for `main`
   - Require pull requests for main (optional)

5. **Issues**
   - Create initial issues for known improvements
   - Add labels: bug, enhancement, documentation, question

---

### Task 9: Continuous Integration (Future - Optional)
**Owner:** TBD
**Priority:** Low
**Time Estimate:** 2 hours

**File:** `.github/workflows/test.yml`

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install
      - run: npm test
      - run: shellcheck scripts/**/*.sh
```

---

## Testing Checklist

### After Initial Push
- [ ] Repository is accessible at GitHub
- [ ] README displays properly
- [ ] All files are present (no missing items)
- [ ] .gitignore is working (no logs/inboxes committed)
- [ ] Can clone on other machines

### After Reorganization
- [ ] All scripts execute from new locations
- [ ] Path references are updated
- [ ] Services still start correctly
- [ ] Dashboard loads and functions
- [ ] Message bus works
- [ ] Voting system operates

### After Full Migration
- [ ] All three machines can pull latest changes
- [ ] Cloud poller processes messages on all machines
- [ ] Heartbeat updates dashboard
- [ ] Cross-machine messaging works
- [ ] Voting system reaches consensus
- [ ] Documentation is accurate and complete
- [ ] New machine can clone and run quick-setup.sh

---

## Rollback Plan

**If Issues Occur:**
1. Keep original `~/pinkyandbrain-backup` for at least 1 week
2. Can quickly restore: `mv ~/pinkyandbrain-backup ~/pinkyandbrain`
3. Git commits are tagged for easy reversion
4. Document any issues encountered

**Safety Measures:**
- Test in `~/pinkyandbrain-test` directory first (optional)
- Commit frequently during reorganization
- Tag major milestones
- Keep services running from backup during testing

---

## Timeline

### Phase 1: Preparation (Day 1)
- [ ] Brain: Review and clean repository
- [ ] Brain: Draft documentation
- [ ] Pinky: Create GitHub repository
- [ ] Pinky: Initial push

**Estimated Time:** 2-3 hours

### Phase 2: Reorganization (Day 2-3)
- [ ] Pinky: Reorganize file structure
- [ ] Pinky: Update all path references
- [ ] Pinky: Create quick-setup script
- [ ] Brain: Update documentation
- [ ] Test: Verify everything works

**Estimated Time:** 4-6 hours

### Phase 3: Distribution (Day 4)
- [ ] Max: Clone and test on max.local
- [ ] Brain: Clone and test on brain.local
- [ ] All: Run verification checklist
- [ ] Max: Configure GitHub settings

**Estimated Time:** 2-3 hours

### Phase 4: Polish (Day 5+)
- [ ] Add examples
- [ ] Create video/demo
- [ ] Consider making public
- [ ] Add CI/CD (optional)

**Estimated Time:** Ongoing

---

## Success Criteria

The migration is successful when:

1. ✅ **Accessibility** - Any developer can git clone and get running in <10 minutes
2. ✅ **Functionality** - All three machines can pull updates and services work
3. ✅ **Documentation** - Clear enough for external contributors to understand
4. ✅ **Showcasable** - System can be demonstrated to others
5. ✅ **Scalability** - Adding a 4th machine requires only running quick-setup.sh
6. ✅ **Maintainability** - Version history provides clear change tracking
7. ✅ **Reliability** - Repository serves as disaster recovery backup

---

## Notes for Implementation

**Coordination:**
- This spec should be reviewed by all machines before implementation
- Can be implemented incrementally - don't need to do everything at once
- Phase 1 (initial push) can happen immediately

**Backwards Compatibility:**
- Keep existing local paths working during transition
- Services should continue running during migration
- Test thoroughly before removing backup

**Security:**
- Double-check no secrets (API keys, tokens) are committed
- Review .gitignore carefully
- Consider private repository initially, make public later

**Communication:**
- Post updates in message bus during migration
- Vote on major decisions (public vs private, etc.)
- Document any issues encountered for future reference

---

## Questions for Discussion

1. **Repository Visibility:** Public or private? (Suggest public for showcase)
2. **Repository Name:** `pinkyandbrain` or `pinkyandbrain-cluster`?
3. **License:** MIT or Apache 2.0?
4. **Migration Timeline:** Do all at once or incremental?
5. **Branch Strategy:** Require PRs for main or allow direct commits?

---

## Appendix: Useful Commands

**Git Workflow:**
```bash
# Daily workflow
git pull                    # Get latest changes
# ... make changes ...
git add .
git commit -m "feat: description"
git push

# Check status
git status
git log --oneline -10

# Create feature branch
git checkout -b feature/new-thing
git push -u origin feature/new-thing
```

**Verification Commands:**
```bash
# Health checks
curl http://localhost:3100/health
curl http://localhost:3100/inbox

# Service status
ps aux | grep cloud-poller
ps aux | grep node

# Dashboard
open ui/status-dashboard.html

# Test messaging
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"test","to":"pinky","body":"test"}'
```

---

**Specification Complete**

This plan is ready for implementation. Suggested approach:

1. **Review** - All machines review this spec
2. **Vote** - If changes needed, vote on modifications
3. **Execute** - Pinky leads implementation following tasks above
4. **Verify** - All machines test and confirm success

Ready to proceed! 🚀
