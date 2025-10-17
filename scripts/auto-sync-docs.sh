#!/bin/bash
# Auto-sync docs from GitHub
# Run this in cron or manually to keep docs in sync

cd ~/pinkyandbrain || exit 1

# Pull latest changes
echo "🔄 Pulling latest docs from GitHub..."
git pull origin main

# Show what changed
if [ $? -eq 0 ]; then
    echo "✅ Docs synced successfully"
    echo "📁 Docs available at: ~/pinkyandbrain/docs/"
    ls -1 docs/
else
    echo "❌ Sync failed"
    exit 1
fi
