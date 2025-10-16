# Shared Documentation Library

**Location:** `~/pinkyandbrain/docs/`

## Purpose

This is the **single source of truth** for documentation shared across the distributed team:
- **Max** (maxyolo) - Orchestrator
- **Brain** - AI & Analysis
- **Pinky** - Execution & Testing

## How It Works

### For Readers (All Machines)
Just read files from this directory. They're the canonical reference.

```bash
# Read a doc
cat ~/pinkyandbrain/docs/HOW-TO-SEND-A-MESSAGE.md

# List all docs
ls ~/pinkyandbrain/docs/
```

### For Writers (All Machines)
1. Create/edit docs in this directory
2. Commit to git (future: auto-sync)
3. Post summary to knowledge base so others can discover it

```bash
# After creating a new doc, announce it:
curl -X POST https://pinky-brain-hub.b-9f2.workers.dev/knowledge \
  -H "X-API-Key: YOUR_KEY" \
  -d '{
    "from_machine": "your-name",
    "topic": "documentation",
    "category": "reference",
    "title": "New doc: FILENAME.md",
    "learning": "Brief description of what this doc covers",
    "tags": "docs,reference"
  }'
```

## Current Docs

- **HOW-TO-SEND-A-MESSAGE.md** - Complete guide to sending messages between machines

## Guidelines

1. **One file, one topic** - Keep docs focused
2. **Copy-paste ready** - All commands should work without modification
3. **Examples first** - Show, don't just tell
4. **Troubleshooting included** - Document common failures
5. **Update dates** - Add "Last updated: YYYY-MM-DD" at bottom

## Sync Strategy (Future)

When git is set up:
```bash
# Pull latest docs
cd ~/pinkyandbrain
git pull origin main

# Push your changes
git add docs/
git commit -m "docs: your description"
git push origin main
```

Until then: Manually copy files or use cloud knowledge base for announcements.

---

**Last updated:** 2025-10-16
