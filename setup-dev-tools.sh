#!/bin/bash

# setup-dev-tools.sh - Install common development tools on all machines
# Run locally: ./setup-dev-tools.sh
# Run everywhere: ./run-on-all.sh "bash -c '\$(curl -fsSL https://raw.githubusercontent.com/...setup-dev-tools.sh)'"

set -e

echo "🚀 Setting up development tools..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH (for M1/M2 Macs)
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✓ Homebrew already installed"
fi

# Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# Install common tools
echo "📥 Installing common development tools..."
brew install git          # Version control
brew install jq           # JSON parsing
brew install htop         # Process monitoring
brew install curl         # HTTP client
brew install wget         # Download files

# Install Node.js (via nvm for version management)
if ! command -v nvm &> /dev/null; then
    echo "📦 Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install latest LTS Node
    nvm install --lts
    nvm use --lts
else
    echo "✓ nvm already installed"
fi

echo "✅ Development tools setup complete!"
echo ""
echo "Installed:"
echo "  - Homebrew package manager"
echo "  - git, jq, htop, curl, wget"
echo "  - nvm + Node.js LTS"
echo ""
echo "Next: Install Claude Code with 'npm install -g @anthropic-ai/claude-code'"
