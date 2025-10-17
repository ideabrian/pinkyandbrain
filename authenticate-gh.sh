#!/bin/bash
# Helper script to authenticate gh CLI on brain and pinky

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 GitHub CLI Authentication Helper"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Since brain and pinky are remote machines, you have 3 options:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Option 1: Interactive SSH Session (Recommended)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Open an SSH session and run gh auth login interactively:"
echo ""
echo "  # For brain:"
echo "  ssh brain"
echo "  ~/bin/gh auth login"
echo "  # Then follow the prompts"
echo ""
echo "  # For pinky:"
echo "  ssh pinky"
echo "  ~/bin/gh auth logout  # Clear bad token first"
echo "  ~/bin/gh auth login"
echo "  # Then follow the prompts"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Option 2: Use a Personal Access Token"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Create a token at: https://github.com/settings/tokens/new"
echo "   Scopes: repo, workflow, read:org, gist, delete_repo"
echo ""
echo "2. Run these commands (replace YOUR_TOKEN):"
echo ""
echo "  # For brain:"
echo "  echo 'ghp_YOUR_TOKEN' | ssh brain '~/bin/gh auth login --with-token'"
echo ""
echo "  # For pinky:"
echo "  ssh pinky '~/bin/gh auth logout'"
echo "  echo 'ghp_YOUR_TOKEN' | ssh pinky '~/bin/gh auth login --with-token'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Option 3: Copy Credentials from Maxyolo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Since maxyolo is already authenticated, we can copy the config:"
echo ""
echo "WARNING: This shares your personal GitHub token across machines."
echo "Only do this if you trust all machines equally."
echo ""
echo "Run these commands:"
echo ""
cat << 'SCRIPT'
  # Get your token from maxyolo
  gh auth token

  # Use that token on brain
  echo 'YOUR_TOKEN_FROM_ABOVE' | ssh brain '~/bin/gh auth login --with-token'

  # Use that token on pinky  
  ssh pinky '~/bin/gh auth logout'
  echo 'YOUR_TOKEN_FROM_ABOVE' | ssh pinky '~/bin/gh auth login --with-token'
SCRIPT
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "After authentication, verify with:"
echo "  ./verify-gh-setup.sh"
echo ""
