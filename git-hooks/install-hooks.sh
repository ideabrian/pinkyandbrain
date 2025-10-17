#!/bin/bash

# install-hooks.sh - Install git hooks for any project

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Git Hooks Installer                                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository"
    echo "   Run this from the root of your git project"
    exit 1
fi

HOOKS_DIR="$(dirname "$0")"
GIT_HOOKS_DIR=".git/hooks"

echo "Installing hooks from: $HOOKS_DIR"
echo "Target: $GIT_HOOKS_DIR"
echo ""

# Install post-commit
if [ -f "$HOOKS_DIR/post-commit" ]; then
    cp "$HOOKS_DIR/post-commit" "$GIT_HOOKS_DIR/"
    chmod +x "$GIT_HOOKS_DIR/post-commit"
    echo "✅ post-commit installed"
else
    echo "⚠️  post-commit not found"
fi

# Install pre-push
if [ -f "$HOOKS_DIR/pre-push" ]; then
    cp "$HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo "✅ pre-push installed"
else
    echo "⚠️  pre-push not found"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Hooks installed successfully!                             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "USAGE:"
echo ""
echo "1. Trigger tasks with commit message:"
echo "   git commit -m '[test:pinky] Add new feature'"
echo "   git commit -m '[build:maxyolo] Update dependencies'"
echo ""
echo "2. Auto-trigger on code changes:"
echo "   git commit -m 'Normal commit' (auto-detects .ts/.js changes)"
echo ""
echo "3. Pre-push validation:"
echo "   git push (automatically validates before push to main/master)"
echo ""
echo "TRIGGERS:"
echo "  [test:agent]   - Run tests"
echo "  [build:agent]  - Build project"
echo "  [deploy:agent] - Deploy to staging"
echo "  [review:agent] - Code review"
echo ""
