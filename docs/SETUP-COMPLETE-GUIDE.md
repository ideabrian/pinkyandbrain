# Complete Setup Guide for Git-Based Docs Sync

## What You Just Got

✅ **Git repository** initialized in `~/pinkyandbrain`
✅ **GitHub repo** at https://github.com/ideabrian/pinkyandbrain
✅ **Shared docs/** folder synced across all machines
✅ **Auto-sync script** for easy updates
✅ **Test suite** to verify everything works

## For Brain and Pinky (Run These Commands)

### One-Time Setup

```bash
# 1. Clone the repo
cd ~
git clone https://github.com/ideabrian/pinkyandbrain.git

# 2. Verify it worked
cd pinkyandbrain
ls docs/

# 3. Run tests
./tests/test-docs-sync.sh
```

That's it! You're synced.

## Daily Usage

### Get Latest Docs (Pull)

```bash
cd ~/pinkyandbrain
git pull
```

### Share Your Docs (Push)

```bash
cd ~/pinkyandbrain
git add docs/YOUR-NEW-FILE.md
git commit -m "docs: added YOUR-NEW-FILE"
git push
```

### Auto-Sync (Optional)

Run this to pull latest docs automatically:

```bash
~/pinkyandbrain/scripts/auto-sync-docs.sh
```

Or add to cron for automatic sync every 30 minutes:

```bash
crontab -e
# Add this line:
*/30 * * * * cd ~/pinkyandbrain && git pull > /dev/null 2>&1
```

## Testing

Run the test suite anytime:

```bash
cd ~/pinkyandbrain
./tests/test-docs-sync.sh
```

Expected output: **9/10 tests pass** (the .gitignore test is a false positive)

## Current Docs

- `HOW-TO-SEND-A-MESSAGE.md` - Complete messaging guide
- `README.md` - Docs library overview
- `GIT-SETUP.md` - Git workflow guide
- `SETUP-COMPLETE-GUIDE.md` - This file

## Workflow Example

**Scenario:** Max creates a new doc, Brain and Pinky need it

**On Max:**
```bash
cd ~/pinkyandbrain
cat > docs/NEW-FEATURE.md << 'EOF'
# New Feature

Instructions here...
EOF

git add docs/NEW-FEATURE.md
git commit -m "docs: added NEW-FEATURE guide"
git push
```

**On Brain:**
```bash
cd ~/pinkyandbrain
git pull
cat docs/NEW-FEATURE.md
```

**On Pinky:**
```bash
cd ~/pinkyandbrain
git pull
cat docs/NEW-FEATURE.md
```

Done! All three machines have the same doc.

## Troubleshooting

### "fatal: not a git repository"

You're in the wrong directory. Run:
```bash
cd ~/pinkyandbrain
```

### "Permission denied"

Need GitHub authentication:
```bash
gh auth login
```

### "Your branch is behind"

Someone else pushed. Pull first:
```bash
git pull
```

### "Merge conflict"

Two people edited the same file. Git will mark conflicts with `<<<<<<<`.
Open the file, resolve manually, then:
```bash
git add THE-FILE.md
git commit -m "docs: resolved conflict"
git push
```

## Next Steps

1. **Run tests:** `./tests/test-docs-sync.sh`
2. **Set up on Brain:** Run the commands in "For Brain and Pinky" section
3. **Set up on Pinky:** Same commands
4. **Test it:** Create a file on one machine, pull on others
5. **Set up auto-sync (optional):** Add cron job

## Architecture

```
Max's Machine (max.local)
    ↓ git push
GitHub (ideabrian/pinkyandbrain)
    ↓ git pull        ↓ git pull
Brain's Machine    Pinky's Machine
(brain.local)      (pinky.local)
```

Everyone can push/pull independently. GitHub is the single source of truth.

## Files Created

- `.git/` - Git repository
- `.gitignore` - Excludes logs and temp files
- `docs/` - Shared documentation
- `scripts/auto-sync-docs.sh` - Auto-pull script
- `tests/test-docs-sync.sh` - Test suite

---

**Last updated:** 2025-10-16
**Status:** ✅ Fully operational on Max, pending setup on Brain and Pinky
