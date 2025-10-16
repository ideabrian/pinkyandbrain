# Setup Guide 04: Claude Code on Multiple Machines

**Goal**: Run Claude Code sessions on any machine in your network

## Why Claude Code Everywhere?

**Use Cases:**
1. **Parallel development** - Different projects on different machines
2. **Resource distribution** - Heavy builds on pinky while you code on maxyolo
3. **Testing** - Run same prompts on different machines to compare
4. **Learning** - See how Claude handles the same task in different environments

## Step 1: Install Homebrew on Pinky

**On pinky** (SSH into it or use iTerm directly):
```bash
ssh pinky

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (for Apple Silicon Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify it works
brew --version
```

**What's happening:**
- Downloads Homebrew installer
- Installs to `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
- Adds to your PATH so you can run `brew` commands
- You'll be prompted for your password during install

## Step 2: Install Node.js on Pinky

Claude Code requires Node.js:

```bash
# Still on pinky
brew install node

# Verify
node --version
npm --version
```

**Alternative: Use nvm for version management**
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install latest LTS Node
nvm install --lts
nvm use --lts
```

## Step 3: Install Claude Code on Pinky

```bash
# Still on pinky
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

## Step 4: Login to Claude Code on Pinky

**Important**: Each machine needs its own login!

```bash
# On pinky
claude

# You'll see: "To use Claude Code, please visit: https://console.anthropic.com/..."
# Open that URL in a browser
# Login/authorize
# Copy the code and paste it back in terminal
```

**Pro tip**: You can use the same Anthropic account on all machines.

## Step 5: Test Claude Code on Pinky

```bash
# On pinky, run a simple test
claude "what is my hostname"

# Should respond with: Pinkys-Mac-mini.local
```

## Parallel Claude Sessions

Now you can run Claude Code on multiple machines simultaneously!

### Example: Parallel Development

**On maxyolo:**
```bash
# Frontend development
claude "help me build a React component"
```

**On pinky (in another terminal):**
```bash
ssh pinky
claude "help me build the API for this component"
```

Both sessions run independently, at the same time!

### Example: Distributed Testing

**Test script** (`test-on-all.sh`):
```bash
#!/bin/bash
echo "Testing Node version across all machines:"
./run-on-all.sh "node --version"

echo -e "\nTesting npm version:"
./run-on-all.sh "npm --version"

echo -e "\nTesting Claude Code:"
./run-on-all.sh "claude --version"
```

## Install Everything Everywhere

Once you've done pinky, create a checklist for brain:

```bash
# Copy your setup script to each machine
scp setup-dev-tools.sh pinky:~/
scp setup-dev-tools.sh brain:~/

# Run it everywhere
./run-on-all.sh "bash ~/setup-dev-tools.sh"
```

## What to Install on All Machines

**Essential Dev Tools:**
```bash
brew install git          # Version control
brew install jq           # JSON parsing
brew install htop         # Process monitoring
brew install node         # JavaScript runtime
npm install -g @anthropic-ai/claude-code
```

**Useful Additions:**
```bash
brew install gh           # GitHub CLI
brew install docker       # Containerization
brew install postgresql   # Database
brew install redis        # Cache
```

**Machine-Specific Only:**
- VS Code / Cursor (if you prefer different editors per machine)
- Desktop apps (browsers, Slack, etc.)
- Personal configs

## Managing Multiple Sessions

**iTerm2 setup:**
1. Create profiles for each machine
2. Set up split panes
3. Run Claude on different machines simultaneously

**Terminal tabs:**
```bash
# Tab 1: maxyolo
claude

# Tab 2: pinky
ssh pinky
claude

# Tab 3: brain (when ready)
ssh brain
claude
```

## Troubleshooting

**"claude: command not found" after install:**
```bash
# Reload your shell
source ~/.zprofile
# or
source ~/.bashrc

# Check npm global packages
npm list -g --depth=0
```

**Can't login to Claude Code:**
- Check internet connection
- Visit console.anthropic.com manually
- Try clearing cache: `rm -rf ~/.claude`
- Reinstall: `npm uninstall -g @anthropic-ai/claude-code && npm install -g @anthropic-ai/claude-code`

**Different versions on different machines:**
```bash
# Check versions everywhere
./run-on-all.sh "claude --version"

# Update everywhere
./run-on-all.sh "npm update -g @anthropic-ai/claude-code"
```

## Advanced: Orchestrating Claude Sessions

**Idea**: Run the same prompt on all machines, compare outputs

```bash
# test-distributed-claude.sh
PROMPT="Explain what machine I'm running on"

echo "Running on maxyolo:"
claude "$PROMPT" -p

echo -e "\n\nRunning on pinky:"
ssh pinky "claude '$PROMPT' -p"

echo -e "\n\nRunning on brain:"
ssh brain "claude '$PROMPT' -p"
```

## The Power of Distributed Claude

**What you can do:**
1. **Compare responses** - Same prompt, different environments
2. **Parallel workflows** - Frontend + Backend simultaneously
3. **Resource optimization** - Heavy tasks on specific machines
4. **Learning** - How does context affect Claude's responses?

**Real example:**
```bash
# On maxyolo: Design the UI
claude "Create a dashboard layout with React"

# On pinky: Build the backend
claude "Create Express API for this dashboard"

# On brain: Database schema
claude "Design PostgreSQL schema for this data"
```

All working at the same time, all sharing the same goal! 🚀

---
**Status**: Complete when you can run `claude` on any machine
**Next**: Build something amazing with your distributed AI command center!
