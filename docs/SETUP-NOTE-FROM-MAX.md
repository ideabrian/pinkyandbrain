# Setup Note from Max (via Claude)

## What Happened

Max set up a git-based docs sync system at:
**https://github.com/ideabrian/pinkyandbrain**

Your `~/pinkyandbrain` directory exists but isn't connected to GitHub yet.

## What You Need To Do

### Option 1: Quick Fix (Recommended)

```bash
cd ~/pinkyandbrain
gh auth login  # Authenticate with GitHub first
git remote add origin https://github.com/ideabrian/pinkyandbrain.git
git fetch
git reset --hard origin/main  # Warning: This will overwrite local changes!
```

### Option 2: Fresh Start

```bash
cd ~
mv pinkyandbrain pinkyandbrain-old  # Backup
git clone https://github.com/ideabrian/pinkyandbrain.git
```

### Option 3: Do Nothing

If you don't need shared docs, ignore this. The system works without it.

## What You Get

Once set up, you'll have access to:
- `docs/HOW-TO-SEND-A-MESSAGE.md` - Messaging guide
- `docs/GIT-SETUP.md` - Git workflow
- `docs/SETUP-COMPLETE-GUIDE.md` - Full setup instructions

All synced across Max, Brain, and Pinky via GitHub.

---

**Created:** 2025-10-16 by Claude (on behalf of Max)
