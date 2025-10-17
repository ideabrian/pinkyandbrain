#!/bin/bash
# Verify GitHub CLI setup across all machines

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 GitHub CLI Setup Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

check_machine() {
    local machine=$1
    local cmd=$2

    echo "━━━ $machine ━━━"

    # Check installation
    if ssh $machine "$cmd --version" 2>/dev/null; then
        echo "✓ gh CLI installed"
    else
        echo "✗ gh CLI NOT installed"
        return 1
    fi

    # Check authentication
    echo ""
    if ssh $machine "$cmd auth status" 2>&1 | grep -q "Logged in"; then
        echo "✓ Authenticated"
        ssh $machine "$cmd auth status" 2>&1 | head -3
    else
        echo "✗ NOT authenticated"
        echo ""
        echo "To authenticate, run:"
        echo "  ssh $machine '$cmd auth login'"
    fi

    # Try a test command
    echo ""
    echo "Testing gh repo list..."
    if ssh $machine "$cmd repo list --limit 3" 2>&1 | grep -q "Showing"; then
        echo "✓ gh operations working"
    else
        echo "✗ gh operations failed"
        echo "Error:"
        ssh $machine "$cmd repo list --limit 3" 2>&1 | head -5
    fi

    echo ""
}

# Check maxyolo
echo "━━━ maxyolo (localhost) ━━━"
if gh --version >/dev/null 2>&1; then
    echo "✓ gh CLI installed"
else
    echo "✗ gh CLI NOT installed"
fi

echo ""
if gh auth status 2>&1 | grep -q "Logged in"; then
    echo "✓ Authenticated"
    gh auth status 2>&1 | head -3
else
    echo "✗ NOT authenticated"
fi

echo ""
echo "Testing gh repo list..."
if gh repo list --limit 3 2>&1 | grep -q "Showing"; then
    echo "✓ gh operations working"
    gh repo list --limit 3
else
    echo "✗ gh operations failed"
fi

echo ""
echo ""

# Check brain
check_machine "brain" "~/bin/gh"

echo ""

# Check pinky
check_machine "pinky" "~/bin/gh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Summary
echo "📊 Summary:"
echo ""
echo "Run these commands to authenticate:"
echo ""
echo "  # Brain"
echo "  ssh brain '~/bin/gh auth login'"
echo ""
echo "  # Pinky"
echo "  ssh pinky '~/bin/gh auth login'"
echo ""
echo "Or use a token:"
echo "  echo 'YOUR_TOKEN' | ssh brain '~/bin/gh auth login --with-token'"
echo "  echo 'YOUR_TOKEN' | ssh pinky '~/bin/gh auth login --with-token'"
echo ""
