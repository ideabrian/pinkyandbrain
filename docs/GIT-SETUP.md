# Git Setup for Distributed Team

## Quick Setup (Run on Brain and Pinky)

```bash
# 1. Clone the repo
cd ~
git clone https://github.com/ideabrian/pinkyandbrain.git

# 2. Done! You're synced.
```

## Daily Workflow

### Pull Latest Changes

```bash
cd ~/pinkyandbrain
git pull
```

Run this:
- When you start your day
- Before making changes
- When someone tells you they pushed updates

### Push Your Changes

```bash
cd ~/pinkyandbrain

# Add your changes
git add docs/  # or git add .

# Commit with a message
git commit -m "docs: updated HOW-TO-SEND-A-MESSAGE"

# Push to GitHub
git push
```

### Check Status

```bash
cd ~/pinkyandbrain
git status

# See what changed
git diff

# See recent commits
git log --oneline -5
```

## Common Scenarios

### Scenario 1: Max updated docs, Brain needs them

**On Brain:**
```bash
cd ~/pinkyandbrain
git pull
cat docs/HOW-TO-SEND-A-MESSAGE.md
```

### Scenario 2: Pinky created new doc, everyone needs it

**On Pinky:**
```bash
cd ~/pinkyandbrain
git add docs/NEW-DOC.md
git commit -m "docs: added NEW-DOC"
git push
```

**On Max and Brain:**
```bash
cd ~/pinkyandbrain
git pull
ls docs/
```

### Scenario 3: Conflict (two people edited same file)

```bash
# Pull first
git pull

# If conflict, Git will tell you which files
# Open the file, look for <<<<<<< markers
# Edit to resolve
# Then:
git add docs/THE-FILE.md
git commit -m "docs: resolved conflict"
git push
```

## Troubleshooting

### "Permission denied (publickey)"

GitHub needs authentication. Run:
```bash
gh auth login
```

Or use HTTPS (already configured):
```bash
git remote set-url origin https://github.com/ideabrian/pinkyandbrain.git
```

### "Your branch is behind 'origin/main'"

Someone else pushed. Pull their changes:
```bash
git pull
```

### "You have unstaged changes"

You modified files. Either commit them or stash:
```bash
# Commit them
git add .
git commit -m "your message"
git push

# OR stash temporarily
git stash
git pull
git stash pop
```

## Auto-Sync (Optional)

Add this to your crontab to pull every 30 minutes:

```bash
# Edit crontab
crontab -e

# Add this line:
*/30 * * * * cd ~/pinkyandbrain && git pull > /dev/null 2>&1
```

Or run the sync script:
```bash
~/pinkyandbrain/scripts/auto-sync-docs.sh
```

## Best Practices

1. **Pull before you push** - Always `git pull` before `git push`
2. **Commit often** - Small commits are easier to understand
3. **Write good messages** - "docs: fixed typo in HOW-TO-SEND" not "stuff"
4. **Don't commit logs** - .gitignore already handles this
5. **Test before pushing** - Make sure your changes work

---

**Last updated:** 2025-10-16
