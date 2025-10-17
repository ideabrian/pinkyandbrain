#!/bin/bash

# setup-brain-ssh.sh - Full bidirectional SSH setup for brain
# Sets up SSH between all three machines: maxyolo, pinky, brain
#
# Usage:
#   ./setup-brain-ssh.sh brain@192.168.5.81

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# Configuration
BRAIN_TARGET=${1:-"brain@192.168.5.81"}
BRAIN_IP=$(echo "$BRAIN_TARGET" | cut -d'@' -f2)
BRAIN_USER=$(echo "$BRAIN_TARGET" | cut -d'@' -f1)

PINKY_IP="192.168.5.80"
PINKY_USER="pinky"

MAXYOLO_IP="192.168.5.76"
MAXYOLO_USER="maxyolo"

SSH_KEY="~/.ssh/id_machines"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  🔑 Full SSH Setup: Pinky & Brain Network"
echo "═══════════════════════════════════════════════════"
echo ""
info "Setting up bidirectional SSH between:"
echo "  • maxyolo (${MAXYOLO_IP})"
echo "  • pinky   (${PINKY_IP})"
echo "  • brain   (${BRAIN_IP})"
echo ""

# ============================================================================
# STEP 1: Verify SSH key exists on maxyolo
# ============================================================================
echo ""
info "Step 1: Verify SSH key on maxyolo"
echo ""

if [ ! -f ~/.ssh/id_machines ]; then
    warn "No SSH key found. Creating one..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_machines -N "" -C "pinky-and-brain-cluster"
    log "SSH key created at ~/.ssh/id_machines"
else
    log "SSH key exists at ~/.ssh/id_machines"
fi

# ============================================================================
# STEP 2: Set up maxyolo → brain
# ============================================================================
echo ""
info "Step 2: Setting up maxyolo → brain"
echo ""

info "Testing connection to brain..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "echo 'Connected'" &>/dev/null; then
    log "Can connect to brain"

    # Copy SSH key to brain
    info "Copying SSH key to brain..."
    ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    cat ~/.ssh/id_machines.pub | ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "cat >> ~/.ssh/authorized_keys && sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    log "maxyolo → brain: SSH key deployed"

    # Add to SSH config
    if ! grep -q "Host brain" ~/.ssh/config 2>/dev/null; then
        cat >> ~/.ssh/config <<EOF

Host brain
    HostName ${BRAIN_IP}
    User ${BRAIN_USER}
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
EOF
        log "Added 'brain' to SSH config"
    fi

    # Test password-less connection
    if ssh brain "echo 'SSH test successful'" &>/dev/null; then
        log "maxyolo → brain: Password-less SSH working ✓"
    else
        warn "maxyolo → brain: SSH key might not be working"
    fi
else
    error "Cannot connect to brain at ${BRAIN_TARGET}"
    error "Make sure:"
    error "  1. Brain is powered on and connected to network"
    error "  2. Remote Login is enabled on brain"
    error "  3. You can manually SSH: ssh ${BRAIN_TARGET}"
    exit 1
fi

# ============================================================================
# STEP 3: Set up pinky → brain
# ============================================================================
echo ""
info "Step 3: Setting up pinky → brain"
echo ""

info "Generating SSH key on pinky (if needed)..."
ssh pinky "if [ ! -f ~/.ssh/id_machines ]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_machines -N '' -C 'pinky-to-brain';
    echo 'Key generated on pinky';
else
    echo 'Key already exists on pinky';
fi"

info "Copying pinky's public key to brain..."
PINKY_PUB_KEY=$(ssh pinky "cat ~/.ssh/id_machines.pub")
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "echo '$PINKY_PUB_KEY' >> ~/.ssh/authorized_keys && sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
log "pinky → brain: SSH key deployed"

# Add brain to pinky's SSH config
info "Configuring pinky's SSH config..."
ssh pinky "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/config <<'SSHCONFIG'

Host brain
    HostName ${BRAIN_IP}
    User ${BRAIN_USER}
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
SSHCONFIG"

# Test pinky → brain
if ssh pinky "ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no brain 'echo Success' 2>/dev/null" | grep -q "Success"; then
    log "pinky → brain: Password-less SSH working ✓"
else
    warn "pinky → brain: SSH might need manual first connection"
    warn "Run on pinky: ssh brain  (to accept fingerprint)"
fi

# ============================================================================
# STEP 4: Set up brain → maxyolo
# ============================================================================
echo ""
info "Step 4: Setting up brain → maxyolo"
echo ""

info "Generating SSH key on brain (if needed)..."
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "if [ ! -f ~/.ssh/id_machines ]; then
    ssh-keygen -t ed25519 -f ~/.ssh/id_machines -N '' -C 'brain-cluster';
    echo 'Key generated on brain';
else
    echo 'Key already exists on brain';
fi"

info "Copying brain's public key to maxyolo..."
BRAIN_PUB_KEY=$(ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "cat ~/.ssh/id_machines.pub")
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "$BRAIN_PUB_KEY" >> ~/.ssh/authorized_keys
sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
log "brain → maxyolo: SSH key deployed"

# Add maxyolo to brain's SSH config
info "Configuring brain's SSH config..."
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "cat >> ~/.ssh/config <<'SSHCONFIG'

Host maxyolo
    HostName ${MAXYOLO_IP}
    User ${MAXYOLO_USER}
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
SSHCONFIG"

# Test brain → maxyolo
if ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no maxyolo 'echo Success' 2>/dev/null" | grep -q "Success"; then
    log "brain → maxyolo: Password-less SSH working ✓"
else
    warn "brain → maxyolo: SSH might need manual first connection"
fi

# ============================================================================
# STEP 5: Set up brain → pinky
# ============================================================================
echo ""
info "Step 5: Setting up brain → pinky"
echo ""

info "Copying brain's public key to pinky..."
ssh pinky "echo '$BRAIN_PUB_KEY' >> ~/.ssh/authorized_keys && sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
log "brain → pinky: SSH key deployed"

# Add pinky to brain's SSH config
info "Configuring brain's SSH config for pinky..."
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "cat >> ~/.ssh/config <<'SSHCONFIG'

Host pinky
    HostName ${PINKY_IP}
    User ${PINKY_USER}
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
SSHCONFIG"

# Test brain → pinky
if ssh -o IdentitiesOnly=yes -i ~/.ssh/id_machines "$BRAIN_TARGET" "ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no pinky 'echo Success' 2>/dev/null" | grep -q "Success"; then
    log "brain → pinky: Password-less SSH working ✓"
else
    warn "brain → pinky: SSH might need manual first connection"
fi

# ============================================================================
# STEP 6: Connection Matrix Test
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════"
echo "  🧪 Testing Full Connection Matrix"
echo "═══════════════════════════════════════════════════"
echo ""

test_connection() {
    local from=$1
    local to=$2
    local from_host=$3
    local to_host=$4

    if [ "$from" = "maxyolo" ]; then
        # Test from maxyolo (current machine)
        if ssh -o ConnectTimeout=3 "$to" "hostname" &>/dev/null; then
            log "✓ $from → $to"
            return 0
        else
            error "✗ $from → $to"
            return 1
        fi
    else
        # Test from remote machine
        if ssh "$from" "ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no $to 'hostname' 2>/dev/null" &>/dev/null; then
            log "✓ $from → $to"
            return 0
        else
            error "✗ $from → $to (may need fingerprint acceptance)"
            return 1
        fi
    fi
}

echo "Connection Matrix:"
echo ""

# Test all 6 directions
test_connection "maxyolo" "pinky" "" ""
test_connection "maxyolo" "brain" "" ""
test_connection "pinky" "maxyolo" "${PINKY_IP}" "${MAXYOLO_IP}"
test_connection "pinky" "brain" "${PINKY_IP}" "${BRAIN_IP}"
test_connection "brain" "maxyolo" "${BRAIN_IP}" "${MAXYOLO_IP}"
test_connection "brain" "pinky" "${BRAIN_IP}" "${PINKY_IP}"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════"
echo "  ✓ SSH Setup Complete!"
echo "═══════════════════════════════════════════════════"
echo ""

log "All three machines can now communicate:"
echo ""
echo "  From maxyolo:  ssh pinky   |  ssh brain"
echo "  From pinky:    ssh maxyolo |  ssh brain"
echo "  From brain:    ssh maxyolo |  ssh pinky"
echo ""

info "SSH shortcuts configured (use these anywhere):"
echo "  • ssh pinky"
echo "  • ssh brain"
echo "  • ssh maxyolo  (from pinky or brain)"
echo ""

warn "If any connection shows '✗', run this on that machine to accept fingerprint:"
echo "  ssh <target-machine>"
echo "  Type 'yes' when prompted, then 'exit'"
echo ""

info "Next steps:"
echo "  1. Continue with: ./deploy-to-brain.sh $BRAIN_TARGET"
echo "  2. Or run orchestrator: ./run-on-all.sh 'hostname'"
echo ""
