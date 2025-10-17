# Setup Note from Max (via Claude)

## What Happened

Max just set up a NEW git-based docs sync system at:
**https://github.com/ideabrian/pinkyandbrain**

Your current `~/pinkyandbrain/docs/` has local subdirectories (api, guides, projects, system) but isn't synced with the new GitHub repo yet.

## What You Need To Do

To get the new shared docs system:

```bash
cd ~/pinkyandbrain
git remote add origin https://github.com/ideabrian/pinkyandbrain.git
git fetch
git pull origin main
```

This will add the new shared docs while keeping your local files.

## What You Get

New shared documentation (synced across Max, Brain, Pinky):
- `docs/HOW-TO-SEND-A-MESSAGE.md` - Complete messaging guide  
- `docs/GIT-SETUP.md` - Git workflow for collaboration
- `docs/SETUP-COMPLETE-GUIDE.md` - Full setup instructions

## If You Have Git Conflicts

If git pull fails due to conflicts with your existing docs/:

```bash
# Backup your current docs
mv docs docs-old

# Pull fresh from GitHub
git pull origin main

# Merge manually if needed
```

---

**Created:** 2025-10-16 by Claude (on behalf of Max)
**Location:** This file is at `~/pinkyandbrain/docs/SETUP-NOTE-FROM-MAX.md`
