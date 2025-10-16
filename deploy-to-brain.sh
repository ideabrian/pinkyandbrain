#!/bin/bash

# deploy-to-brain.sh - Deploy Pinky & Brain system to a remote machine
# Run this FROM the orchestrator (maxyolo) TO set up brain
#
# Usage:
#   ./deploy-to-brain.sh <username>@<ip-address>
#   ./deploy-to-brain.sh brain@192.168.5.XX

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <username>@<ip-address>"
    echo ""
    echo "Example:"
    echo "  $0 brain@192.168.5.82"
    echo ""
    echo "Prerequisites:"
    echo "  - Remote Login enabled on target machine"
    echo "  - SSH access (password or key)"
    exit 1
fi

TARGET=$1
TARGET_HOST=$(echo "$TARGET" | cut -d'@' -f2)
TARGET_USER=$(echo "$TARGET" | cut -d'@' -f1)

echo ""
echo "═══════════════════════════════════════════"
echo "  Deploying to Brain"
echo "═══════════════════════════════════════════"
echo ""
info "Target: $TARGET"
echo ""

# Prerequisites check
echo -e "${YELLOW}⚠ IMPORTANT: Prerequisites Required${NC}"
echo ""
echo "Before deployment, ensure on Brain ($TARGET_HOST):"
echo "  1. Terminal has Full Disk Access"
echo "  2. Remote Login is enabled with full disk access"
echo ""
echo "Recommended: Run preflight check first:"
echo "  ${BLUE}./preflight-check-brain.sh${NC}"
echo ""
read -p "Have you completed prerequisites? [y/N]: " prereqs_done

if [[ ! "$prereqs_done" =~ ^[Yy]$ ]]; then
    warn "Please complete prerequisites first"
    warn "See: BRAIN-PREREQUISITES.md for detailed instructions"
    exit 1
fi

echo ""

# Step 1: Test connectivity
info "Step 1: Testing SSH connectivity..."
if ssh -o ConnectTimeout=5 -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$TARGET" "echo 'Connected'" &>/dev/null; then
    log "SSH connection successful"
else
    warn "Cannot connect via SSH"
    warn "Make sure:"
    warn "  - Remote Login is enabled on $TARGET_HOST"
    warn "  - You have SSH access (try: ssh $TARGET)"
    exit 1
fi

# Step 2: Copy SSH key
info "Step 2: Setting up SSH keys..."
if [ -f ~/.ssh/id_machines.pub ]; then
    ssh "$TARGET" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    cat ~/.ssh/id_machines.pub | ssh "$TARGET" "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    log "SSH key copied"
else
    warn "No SSH key found at ~/.ssh/id_machines.pub"
    warn "Run: ssh-keygen -t ed25519 -f ~/.ssh/id_machines"
fi

# Step 3: Install Homebrew
info "Step 3: Installing Homebrew..."
ssh "$TARGET" 'command -v brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

# Add brew to PATH
ssh "$TARGET" 'if [[ $(uname -m) == "arm64" ]]; then
    grep -q "opt/homebrew" ~/.zprofile || echo '\''eval "$(/opt/homebrew/bin/brew shellenv)"'\'' >> ~/.zprofile
else
    grep -q "usr/local/bin/brew" ~/.zprofile || echo '\''eval "$(/usr/local/bin/brew shellenv)"'\'' >> ~/.zprofile
fi'
log "Homebrew ready"

# Step 4: Install tools
info "Step 4: Installing development tools..."
ssh "$TARGET" 'eval "$(brew --prefix)/bin/brew shellenv" && brew install git jq curl wget'
log "Tools installed: git, jq, curl, wget"

# Step 5: Install Node.js
info "Step 5: Installing Node.js..."
ssh "$TARGET" 'bash -c '\''
if ! command -v node &>/dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    nvm alias default node
fi
'\''
log "Node.js installed"

# Step 6: Install Claude Code
info "Step 6: Installing Claude Code..."
ssh "$TARGET" 'bash -l -c "npm install -g @anthropic-ai/claude-code"'
log "Claude Code installed"

# Step 7: Deploy project files
info "Step 7: Deploying project files..."
ssh "$TARGET" "mkdir -p ~/pinkyandbrain"

# Copy message bus
scp ~/pinkyandbrain/claude-messenger.js "$TARGET:~/pinkyandbrain/"

# Copy CLI tool
if [ -f ~/pinkyandbrain/pinky-cli.sh ]; then
    scp ~/pinkyandbrain/pinky-cli.sh "$TARGET:~/pinkyandbrain/"
    ssh "$TARGET" "chmod +x ~/pinkyandbrain/pinky-cli.sh"
fi

# Install npm dependencies
ssh "$TARGET" "cd ~/pinkyandbrain && npm init -y 2>/dev/null || true && npm install express"

log "Project files deployed"

# Step 8: Start message bus
info "Step 8: Starting message bus..."
ssh "$TARGET" "cd ~/pinkyandbrain && node claude-messenger.js > ~/messenger.log 2>&1 &"
sleep 2

# Verify message bus
BRAIN_IP=$TARGET_HOST
if curl -s "http://$BRAIN_IP:3100/health" | grep -q "ok"; then
    log "Message bus running on port 3100"
else
    warn "Message bus may not be running (check ~/messenger.log on brain)"
fi

# Step 9: Add to SSH config
info "Step 9: Updating SSH config..."
if ! grep -q "Host brain" ~/.ssh/config 2>/dev/null; then
    cat >> ~/.ssh/config <<EOF

Host brain
    HostName $TARGET_HOST
    User $TARGET_USER
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
EOF
    log "Added 'brain' to SSH config"
else
    log "SSH config already has 'brain' entry"
fi

# Step 10: Update orchestrator
info "Step 10: Updating orchestrator configuration..."

# Add brain to run-on-all.sh
if [ -f ~/pinkyandbrain/run-on-all.sh ]; then
    if ! grep -q '"brain"' ~/pinkyandbrain/run-on-all.sh; then
        sed -i '' 's/MACHINES=(\([^)]*\))/MACHINES=(\1 "brain")/' ~/pinkyandbrain/run-on-all.sh
        log "Added brain to run-on-all.sh"
    fi
fi

# Add brain to audio bridge
if [ -f ~/pinkyandbrain/audio-bridge.js ]; then
    if ! grep -q "brain" ~/pinkyandbrain/audio-bridge.js; then
        warn "Don't forget to add brain to audio-bridge.js MESSAGE_BUSES array!"
        warn "  { name: 'brain', url: 'http://$BRAIN_IP:3100' }"
    fi
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  🎉 Deployment Complete!"
echo "═══════════════════════════════════════════"
echo ""

log "Brain is online at: $BRAIN_IP"
log "SSH shortcut: ssh brain"
log "Message bus: http://$BRAIN_IP:3100/health"
echo ""

info "Next Steps:"
echo ""
echo "  1. Test SSH connection:"
echo "     ssh brain"
echo ""
echo "  2. Authorize Claude Code on brain:"
echo "     ssh brain"
echo "     claude"
echo "     # Visit the authorization URL"
echo ""
echo "  3. Test message passing:"
echo "     cd ~/pinkyandbrain"
echo "     ./pinky-cli.sh send 'Hello brain!' --to brain-claude"
echo ""
echo "  4. Add brain to audio bridge:"
echo "     Edit audio-bridge.js and add:"
echo "     { name: 'brain', url: 'http://$BRAIN_IP:3100' }"
echo ""
echo "  5. Start orchestrator with 3 agents:"
echo "     ./orchestrator.sh"
echo ""

log "Setup complete! 🧠"
