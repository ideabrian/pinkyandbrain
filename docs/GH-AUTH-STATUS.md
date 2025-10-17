# GitHub CLI Authentication Status

## Current Status (Oct 15, 2025 - 8:25 PM)

### ✅ maxyolo (localhost)
- **Status**: ✓ Authenticated
- **Account**: ideabrian
- **Token**: Valid (keyring)
- **gh operations**: Working

### ⚠️ brain
- **Status**: ✗ Not authenticated
- **Config**: No ~/.config/gh directory
- **Next step**: Run authentication

### ⚠️ pinky
- **Status**: ✗ Invalid token
- **Config**: Has ~/.config/gh directory with invalid token
- **Next step**: Re-authenticate

---

## How to Authenticate

### Option 1: Interactive Login (Easiest)

**On brain:**
```bash
ssh brain
~/bin/gh auth login
# Choose: GitHub.com → HTTPS → Login with web browser
# Follow the browser prompts
```

**On pinky:**
```bash
ssh pinky
~/bin/gh auth logout  # Clear invalid token first
~/bin/gh auth login
# Choose: GitHub.com → HTTPS → Login with web browser
# Follow the browser prompts
```

### Option 2: Token Authentication

1. **Create a token**: https://github.com/settings/tokens/new
   - Scopes: `repo`, `workflow`, `read:org`, `gist`, `delete_repo`

2. **Authenticate with token:**

```bash
# On brain
ssh brain
echo 'ghp_YOUR_TOKEN_HERE' | ~/bin/gh auth login --with-token

# On pinky
ssh pinky  
~/bin/gh auth logout  # Clear invalid token first
echo 'ghp_YOUR_TOKEN_HERE' | ~/bin/gh auth login --with-token
```

---

## Verification

After authenticating, verify with:

```bash
cd ~/Documents/projects/pinkyandbrain
./verify-gh-setup.sh
```

You should see:
- ✓ Authenticated for all machines
- ✓ gh operations working for all machines

---

## Why Pinky Has Invalid Token

Pinky shows "invalid token" because:
1. Authentication was attempted but incomplete
2. The token in `~/.config/gh/hosts.yml` is malformed or expired
3. Need to logout first, then re-authenticate

**Fix:**
```bash
ssh pinky
~/bin/gh auth logout
~/bin/gh auth login
```

---

## Testing After Authentication

Once all machines are authenticated, test with:

```bash
# Test repo listing on all machines
./run-on-all.sh "bash -l -c '~/bin/gh repo list --limit 3 2>/dev/null || gh repo list --limit 3'"

# Test creating an issue
ssh brain "cd ~/some-repo && ~/bin/gh issue list"

# Test creating a PR
ssh pinky "cd ~/some-repo && ~/bin/gh pr list"
```

---

## Summary

**To complete setup:**

1. **brain**: Run `ssh brain '~/bin/gh auth login'`
2. **pinky**: Run `ssh pinky '~/bin/gh auth logout && ~/bin/gh auth login'`
3. **Verify**: Run `./verify-gh-setup.sh`

All three machines will then be able to collaborate on GitHub repos, PRs, and issues!
