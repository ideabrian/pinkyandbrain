#!/bin/bash

# setup-new-machine.sh - Automated setup for Pinky & Brain distributed system
# Run this on a fresh Mac to integrate it into the cluster
#
# Usage:
#   On the NEW machine (brain):
#     bash <(curl -s https://raw.githubusercontent.com/.../setup-new-machine.sh)
#   OR copy this script and run:
#     ./setup-new-machine.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration (will be detected or prompted)
MACHINE_NAME=""
MACHINE_ROLE=""  # "orchestrator", "executor", or "planner"
ORCHESTRATOR_IP="192.168.5.76"
ORCHESTRATOR_USER="maxyolo"

# Script state
SETUP_LOG="$HOME/setup-brain-$(date +%Y%m%d-%H%M%S).log"

# Logging functions
log() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$SETUP_LOG"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$SETUP_LOG"
}

error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$SETUP_LOG"
}

info() {
    echo -e "${BLUE}ℹ${NC} $1" | tee -a "$SETUP_LOG"
}

header() {
    echo "" | tee -a "$SETUP_LOG"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}" | tee -a "$SETUP_LOG"
    echo -e "${BLUE}  $1${NC}" | tee -a "$SETUP_LOG"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}" | tee -a "$SETUP_LOG"
    echo "" | tee -a "$SETUP_LOG"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Prompt with default
prompt() {
    local var_name=$1
    local prompt_text=$2
    local default_value=$3

    read -p "$prompt_text [$default_value]: " input
    eval "$var_name=\"${input:-$default_value}\""
}

# Main setup flow
main() {
    clear
    header "🧠 Pinky & Brain - New Machine Setup"

    info "This script will configure this Mac to join your distributed system"
    info "Setup log: $SETUP_LOG"
    echo ""

    # Step 0: Gather information
    gather_info

    # Step 1: System checks
    step_system_checks

    # Step 2: Install Homebrew
    step_install_homebrew

    # Step 3: Install development tools
    step_install_dev_tools

    # Step 4: Install Node.js
    step_install_nodejs

    # Step 5: Setup SSH
    step_setup_ssh

    # Step 6: Install Claude Code
    step_install_claude

    # Step 7: Deploy services
    step_deploy_services

    # Step 8: Verify setup
    step_verify

    # Final summary
    print_summary
}

# Gather machine information
gather_info() {
    header "Step 0: Configuration"

    # Detect hostname
    local current_hostname=$(hostname -s)
    prompt MACHINE_NAME "Machine hostname (for SSH)" "$current_hostname"

    # Role selection
    echo ""
    info "Select machine role:"
    echo "  1) Orchestrator (coordinates tasks)"
    echo "  2) Executor (performs tasks)"
    echo "  3) Planner (analyzes and strategizes)"
    read -p "Choice [2]: " role_choice

    case "${role_choice:-2}" in
        1) MACHINE_ROLE="orchestrator" ;;
        2) MACHINE_ROLE="executor" ;;
        3) MACHINE_ROLE="planner" ;;
        *) MACHINE_ROLE="executor" ;;
    esac

    log "Configuration: $MACHINE_NAME ($MACHINE_ROLE)"
}

# System checks
step_system_checks() {
    header "Step 1: System Checks"

    # Check macOS version
    local os_version=$(sw_vers -productVersion)
    log "macOS version: $os_version"

    # Check architecture
    local arch=$(uname -m)
    log "Architecture: $arch"

    # Get IP address
    local ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "unknown")
    log "IP address: $ip"

    # Check if Terminal has Full Disk Access
    warn "Please ensure Terminal has Full Disk Access:"
    warn "  System Settings → Privacy & Security → Full Disk Access → Terminal"
    read -p "Press Enter when ready..."

    # Check if Remote Login is enabled
    warn "Please ensure Remote Login is enabled:"
    warn "  System Settings → General → Sharing → Remote Login"
    read -p "Press Enter when ready..."

    log "System checks complete"
}

# Install Homebrew
step_install_homebrew() {
    header "Step 2: Install Homebrew"

    if command_exists brew; then
        log "Homebrew already installed"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    log "Homebrew installed successfully"
}

# Install development tools
step_install_dev_tools() {
    header "Step 3: Install Development Tools"

    info "Installing: git, jq, curl, wget..."
    brew install git jq curl wget 2>&1 | tee -a "$SETUP_LOG"

    log "Development tools installed"
}

# Install Node.js via nvm
step_install_nodejs() {
    header "Step 4: Install Node.js"

    if command_exists node; then
        log "Node.js already installed: $(node --version)"
        return 0
    fi

    info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
    nvm alias default node

    log "Node.js installed: $(node --version)"
    log "npm installed: $(npm --version)"
}

# Setup SSH
step_setup_ssh() {
    header "Step 5: Setup SSH"

    local ssh_key="$HOME/.ssh/id_machines"

    # Check if key exists
    if [ ! -f "$ssh_key" ]; then
        info "Generating SSH key..."
        ssh-keygen -t ed25519 -f "$ssh_key" -N "" -C "$MACHINE_NAME-distributed-system"
        log "SSH key generated"
    else
        log "SSH key already exists"
    fi

    # Display public key
    echo ""
    info "SSH Public Key (share this with orchestrator):"
    echo "─────────────────────────────────────────────────────"
    cat "${ssh_key}.pub"
    echo "─────────────────────────────────────────────────────"
    echo ""

    warn "Next steps for SSH integration:"
    warn "1. On orchestrator machine, run:"
    warn "   echo '<paste public key>' >> ~/.ssh/authorized_keys"
    warn "2. Add this machine to orchestrator's ~/.ssh/config"
    warn ""
    read -p "Press Enter when SSH is configured..."

    log "SSH setup complete"
}

# Install Claude Code
step_install_claude() {
    header "Step 6: Install Claude Code"

    if command_exists claude; then
        log "Claude Code already installed"
        return 0
    fi

    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code

    log "Claude Code installed: $(claude --version)"

    warn "You'll need to authorize Claude Code later:"
    warn "  Run: claude"
    warn "  Visit the authorization URL"
    warn "  Complete device authorization"
}

# Deploy distributed services
step_deploy_services() {
    header "Step 7: Deploy Distributed Services"

    local project_dir="$HOME/pinkyandbrain"

    info "Creating project directory: $project_dir"
    mkdir -p "$project_dir"

    # Create message bus
    info "Creating message bus (port 3100)..."
    cat > "$project_dir/claude-messenger.js" <<'EOF'
#!/usr/bin/env node

// Simple HTTP message bus for agent communication
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3100;

app.use(express.json());

let messages = [];
let messageId = 1;

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        machine: require('os').hostname(),
        messages: messages.length
    });
});

// Send message
app.post('/send', (req, res) => {
    const msg = {
        id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        ...req.body,
        timestamp: new Date().toISOString(),
        read: false,
        replyCount: 0
    };
    messages.unshift(msg);
    res.json({ success: true, messageId: msg.id, message: 'Message sent' });
});

// Get inbox
app.get('/inbox', (req, res) => {
    res.json({ messages, total: messages.length });
});

// Mark as read
app.post('/inbox/:id/read', (req, res) => {
    const msg = messages.find(m => m.id === req.params.id);
    if (msg) {
        msg.read = true;
        res.json({ success: true });
    } else {
        res.status(404).json({ error: 'Message not found' });
    }
});

app.listen(PORT, () => {
    console.log(`📬 Message bus listening on port ${PORT}`);
    console.log(`   Machine: ${require('os').hostname()}`);
});
EOF
    chmod +x "$project_dir/claude-messenger.js"

    # Install express
    info "Installing npm dependencies..."
    cd "$project_dir"
    npm init -y
    npm install express

    log "Message bus created"

    # Create CLI tool
    info "Creating CLI tool..."
    # (Abbreviated - would copy pinky-cli.sh)

    log "Services deployed to $project_dir"
}

# Verify setup
step_verify() {
    header "Step 8: Verification"

    # Check commands
    local checks=(
        "brew:Homebrew"
        "node:Node.js"
        "npm:npm"
        "git:Git"
        "jq:jq"
    )

    info "Checking installed commands..."
    for check in "${checks[@]}"; do
        IFS=':' read -r cmd name <<< "$check"
        if command_exists "$cmd"; then
            log "$name: ✓"
        else
            error "$name: ✗ (not found)"
        fi
    done

    # Test message bus
    info "Testing message bus..."
    cd "$HOME/pinkyandbrain"
    node claude-messenger.js > /tmp/messenger-test.log 2>&1 &
    local bus_pid=$!
    sleep 2

    if curl -s http://localhost:3100/health | grep -q "ok"; then
        log "Message bus: ✓"
    else
        error "Message bus: ✗ (not responding)"
    fi

    kill $bus_pid 2>/dev/null || true

    log "Verification complete!"
}

# Print final summary
print_summary() {
    header "🎉 Setup Complete!"

    echo ""
    log "Machine Name: $MACHINE_NAME"
    log "Role: $MACHINE_ROLE"
    log "Project Directory: $HOME/pinkyandbrain"
    echo ""

    info "Next Steps:"
    echo "  1. Start message bus:"
    echo "     cd ~/pinkyandbrain && node claude-messenger.js &"
    echo ""
    echo "  2. Authorize Claude Code:"
    echo "     claude"
    echo ""
    echo "  3. Test connectivity from orchestrator:"
    echo "     ssh $MACHINE_NAME"
    echo "     curl http://<ip>:3100/health"
    echo ""
    echo "  4. Send test message:"
    echo "     cd ~/pinkyandbrain"
    echo "     ./pinky-cli.sh send 'Hello from $MACHINE_NAME' --to <agent>"
    echo ""

    log "Setup log saved to: $SETUP_LOG"
    echo ""
}

# Run main setup
main "$@"
