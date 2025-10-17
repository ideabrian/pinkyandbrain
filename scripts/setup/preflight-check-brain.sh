#!/bin/bash

# preflight-check-brain.sh - Verify brain is ready for deployment
# Run this BEFORE deploy-to-brain.sh

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BRAIN_IP="192.168.5.81"
BRAIN_USER="brain"

clear
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🧠 Brain Pre-Flight Checklist${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Function to show check status
check() {
    local name="$1"
    local status="$2"

    if [ "$status" = "ok" ]; then
        echo -e "${GREEN}✓${NC} $name"
    elif [ "$status" = "warn" ]; then
        echo -e "${YELLOW}⚠${NC} $name"
    else
        echo -e "${RED}✗${NC} $name"
    fi
}

echo -e "${YELLOW}Before deployment, complete these steps on Brain:${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Terminal Full Disk Access
echo -e "${BLUE}Step 1: Grant Terminal Full Disk Access${NC}"
echo ""
echo "On Brain, do this:"
echo "  1. Open System Settings"
echo "  2. Go to: Privacy & Security → Full Disk Access"
echo "  3. Click the (i) or (+) button"
echo "  4. Find and enable: Terminal"
echo "  5. Quit and reopen Terminal if it's running"
echo ""
read -p "$(echo -e "${YELLOW}Have you granted Terminal Full Disk Access? [y/N]: ${NC}")" terminal_fda

if [[ "$terminal_fda" =~ ^[Yy]$ ]]; then
    check "Terminal Full Disk Access" "ok"
else
    check "Terminal Full Disk Access" "fail"
    echo ""
    echo -e "${RED}REQUIRED:${NC} Terminal needs Full Disk Access"
    echo "This allows setup scripts to access system files."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 2: Remote Login
echo -e "${BLUE}Step 2: Enable Remote Login${NC}"
echo ""
echo "On Brain, do this:"
echo "  1. Open System Settings"
echo "  2. Go to: General → Sharing"
echo "  3. Turn on: Remote Login"
echo "  4. Click the (i) info button next to Remote Login"
echo "  5. Enable: 'Allow full disk access for remote users'"
echo "  6. Make sure your user ($BRAIN_USER) is in the allowed list"
echo ""
read -p "$(echo -e "${YELLOW}Have you enabled Remote Login with full disk access? [y/N]: ${NC}")" remote_login

if [[ "$remote_login" =~ ^[Yy]$ ]]; then
    check "Remote Login Enabled" "ok"
else
    check "Remote Login Enabled" "fail"
    echo ""
    echo -e "${RED}REQUIRED:${NC} Remote Login must be enabled"
    echo "This allows SSH access from maxyolo."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 3: Verify IP Address
echo -e "${BLUE}Step 3: Verify IP Address${NC}"
echo ""
echo "Expected IP: $BRAIN_IP"
echo ""
read -p "$(echo -e "${YELLOW}Is brain's IP address $BRAIN_IP? [y/N]: ${NC}")" ip_confirm

if [[ "$ip_confirm" =~ ^[Yy]$ ]]; then
    check "IP Address: $BRAIN_IP" "ok"
else
    echo ""
    echo -e "${YELLOW}To check brain's IP, run on brain:${NC}"
    echo "  ipconfig getifaddr en0   (Ethernet)"
    echo "  ipconfig getifaddr en1   (WiFi)"
    echo ""
    read -p "Enter brain's actual IP address: " BRAIN_IP
    check "IP Address: $BRAIN_IP" "warn"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 4: Test Network Connectivity
echo -e "${BLUE}Step 4: Test Network Connectivity${NC}"
echo ""
echo "Testing ping to $BRAIN_IP..."

if ping -c 3 "$BRAIN_IP" &>/dev/null; then
    check "Network Ping" "ok"
else
    check "Network Ping" "fail"
    echo ""
    echo -e "${RED}Cannot reach brain at $BRAIN_IP${NC}"
    echo "Verify:"
    echo "  - Brain is powered on"
    echo "  - Brain is connected to WiFi/Ethernet"
    echo "  - IP address is correct"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 5: Test SSH Connectivity
echo -e "${BLUE}Step 5: Test SSH Connection${NC}"
echo ""
echo "Testing SSH to $BRAIN_USER@$BRAIN_IP..."

if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$BRAIN_USER@$BRAIN_IP" "echo 'SSH Connected'" 2>/dev/null | grep -q "SSH Connected"; then
    check "SSH Connection" "ok"
else
    check "SSH Connection" "fail"
    echo ""
    echo -e "${YELLOW}First time connecting?${NC} Try manually first:"
    echo "  ssh $BRAIN_USER@$BRAIN_IP"
    echo ""
    echo "You'll need to:"
    echo "  1. Accept fingerprint (type 'yes')"
    echo "  2. Enter password"
    echo "  3. Type 'exit' to return"
    echo ""
    read -p "$(echo -e "${YELLOW}Try SSH connection now? [y/N]: ${NC}")" try_ssh

    if [[ "$try_ssh" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Connecting to $BRAIN_USER@$BRAIN_IP..."
        echo "Type 'exit' after successful login."
        echo ""
        ssh "$BRAIN_USER@$BRAIN_IP"

        echo ""
        read -p "$(echo -e "${YELLOW}Did SSH work? [y/N]: ${NC}")" ssh_worked

        if [[ "$ssh_worked" =~ ^[Yy]$ ]]; then
            check "SSH Connection (manual)" "ok"
        else
            echo ""
            echo -e "${RED}SSH is required for deployment${NC}"
            exit 1
        fi
    else
        exit 1
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Pre-Flight Checks Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}Brain is ready for deployment!${NC}"
echo ""
echo "Next step:"
echo ""
echo -e "${BLUE}  ./deploy-to-brain.sh $BRAIN_USER@$BRAIN_IP${NC}"
echo ""
echo "This will:"
echo "  • Install Homebrew, Node.js, Claude Code"
echo "  • Deploy message bus and CLI tools"
echo "  • Configure SSH keys"
echo "  • Integrate brain into the cluster"
echo ""
echo "Estimated time: 10-15 minutes"
echo ""

# Create deployment command file for easy copy-paste
echo "./deploy-to-brain.sh $BRAIN_USER@$BRAIN_IP" > /tmp/deploy-brain-command.sh
chmod +x /tmp/deploy-brain-command.sh

echo -e "${YELLOW}Tip:${NC} Saved deployment command to /tmp/deploy-brain-command.sh"
echo ""
