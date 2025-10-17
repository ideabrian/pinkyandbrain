# 🐙 GitHub CLI Setup Across All Machines

## ✅ Current Status

### Installation
- ✅ **maxyolo**: `gh` v2.79.0 (Homebrew)
- ✅ **brain**: `gh` v2.79.0 (~/bin)
- ✅ **pinky**: `gh` v2.79.0 (~/bin)

### Authentication
- ✅ **maxyolo**: Authenticated as `ideabrian` (keyring)
- ⚠️ **brain**: Not authenticated (needs login)
- ⚠️ **pinky**: Not authenticated (needs login)

### Git Configuration
- ✅ **maxyolo**: Brian Ball <ideabrian@gmail.com>
- ✅ **brain**: Brian Ball (brain) <ideabrian@gmail.com>
- ✅ **pinky**: Brian Ball (pinky) <ideabrian@gmail.com>

---

## 🔐 Authenticating Brain and Pinky

### Option 1: Interactive Login (Recommended)

```bash
# On brain
ssh brain
~/bin/gh auth login
# Choose: GitHub.com → HTTPS → Login with web browser

# On pinky
ssh pinky
~/bin/gh auth login
# Choose: GitHub.com → HTTPS → Login with web browser
```

### Option 2: Token Authentication

1. Create a Personal Access Token:
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Scopes needed: `repo`, `workflow`, `read:org`, `gist`, `delete_repo`

2. Authenticate with token:
```bash
# On brain
ssh brain
echo "YOUR_TOKEN" | ~/bin/gh auth login --with-token

# On pinky
ssh pinky
echo "YOUR_TOKEN" | ~/bin/gh auth login --with-token
```

### Verify Authentication

```bash
./run-on-all.sh "~/bin/gh auth status 2>/dev/null || gh auth status"
```

---

## 🚀 Common gh CLI Operations

### Working with Repositories

```bash
# List your repos
gh repo list

# Clone a repo
gh repo clone owner/repo

# Create a new repo
gh repo create my-new-repo --public

# View repo info
gh repo view owner/repo
```

### Pull Requests

```bash
# Create a PR
gh pr create --title "Feature" --body "Description"

# List PRs
gh pr list

# View a PR
gh pr view 123

# Check out a PR
gh pr checkout 123

# Merge a PR
gh pr merge 123 --merge
```

### Issues

```bash
# Create an issue
gh issue create --title "Bug" --body "Description"

# List issues
gh issue list

# View an issue
gh issue view 123

# Close an issue
gh issue close 123
```

### Releases

```bash
# Create a release
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes"

# List releases
gh release list

# View a release
gh release view v1.0.0
```

### Workflows

```bash
# List workflows
gh workflow list

# View workflow runs
gh run list

# View specific run
gh run view 123456

# Re-run a workflow
gh run rerun 123456
```

---

## 🤝 Cross-Machine Collaboration Patterns

### Pattern 1: Brain Creates Plan → Pinky Implements

```bash
# On brain (create branch and plan)
ssh brain
cd ~/project
git checkout -b feature/new-component
# Brain creates plan.md
git add plan.md
git commit -m "Add implementation plan"
git push -u origin feature/new-component

# On pinky (implement the plan)
ssh pinky
cd ~/project
git fetch
git checkout feature/new-component
# Pinky implements
git add .
git commit -m "Implement feature per brain's plan"
git push

# On pinky (create PR)
~/bin/gh pr create \
  --title "Implement new component" \
  --body "Implementation follows brain's plan in plan.md"
```

### Pattern 2: Maxyolo Reviews PR

```bash
# On maxyolo (review PR)
gh pr list
gh pr view 123
gh pr diff 123
gh pr review 123 --approve
gh pr merge 123
```

### Pattern 3: Distributed Issue Handling

```bash
# Brain triages issues
ssh brain "cd ~/project && ~/bin/gh issue list --label needs-triage"

# Pinky picks up implementation
ssh pinky "cd ~/project && ~/bin/gh issue list --assignee @me"

# Maxyolo reviews completed work
gh pr list --label ready-for-review
```

---

## 📋 Quick Reference Commands

### On All Machines

```bash
# Check gh version
./run-on-all.sh "~/bin/gh --version 2>/dev/null || gh --version"

# Check auth status
./run-on-all.sh "~/bin/gh auth status 2>/dev/null || gh auth status"

# Check git config
./run-on-all.sh "git config --global user.name"
```

### Auth Setup Script

```bash
# Run the auth setup helper
./setup-gh-auth.sh
```

---

## 🛠️ Installation Details

### Installation Paths

- **maxyolo**: `/opt/homebrew/bin/gh` (Homebrew)
- **brain**: `~/bin/gh` (manual install)
- **pinky**: `~/bin/gh` (manual install)

All machines have `~/bin` in their PATH via `~/.zshrc`.

### Manual Installation (if needed)

```bash
# Run this on any machine to install gh
bash /tmp/install-gh-user.sh
```

---

## 🎯 Next Steps

1. **Authenticate brain and pinky**:
   ```bash
   ssh brain "~/bin/gh auth login"
   ssh pinky "~/bin/gh auth login"
   ```

2. **Test gh operations**:
   ```bash
   ./run-on-all.sh "~/bin/gh repo list 2>/dev/null || gh repo list"
   ```

3. **Set up shared workflows**:
   - Brain creates feature branches and plans
   - Pinky implements features
   - Maxyolo reviews and merges PRs

---

## 📚 Resources

- GitHub CLI Manual: https://cli.github.com/manual/
- GitHub CLI Repo: https://github.com/cli/cli
- Token Settings: https://github.com/settings/tokens

---

**Setup Date:** October 15, 2025
**Status:** gh CLI installed on all machines, auth pending for brain/pinky
**Next:** Authenticate brain and pinky for full collaboration
