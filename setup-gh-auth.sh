#!/bin/bash
# Setup GitHub CLI authentication on brain and pinky

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 GitHub CLI Authentication Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will set up gh CLI auth on brain and pinky"
echo ""
echo "You'll need to:"
echo "  1. Get a personal access token from GitHub"
echo "  2. Run 'gh auth login' on each machine"
echo ""
echo "Or you can share auth from maxyolo:"
echo ""
echo "  On maxyolo:"
echo "    gh auth status  # Shows your token"
echo ""
echo "  On brain/pinky:"
echo "    gh auth login"
echo "    # Choose: GitHub.com → HTTPS → Paste token"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Checking current auth status:"
echo ""

echo "✓ maxyolo:"
gh auth status 2>&1 | head -3

echo ""
echo "━ brain:"
ssh brain "~/bin/gh auth status" 2>&1 | head -1

echo ""
echo "━ pinky:"
ssh pinky "~/bin/gh auth status" 2>&1 | head -1

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To authenticate brain and pinky, run:"
echo ""
echo "  ssh brain '~/bin/gh auth login'"
echo "  ssh pinky '~/bin/gh auth login'"
echo ""
echo "Or create a token at: https://github.com/settings/tokens"
echo "Scopes needed: repo, workflow, read:org, gist"
echo ""
