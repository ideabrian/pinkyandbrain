#!/bin/bash
# Sync docs folder to Brain and Pinky

DOCS_DIR="$HOME/pinkyandbrain/docs/"
BRAIN_HOST="brain.local"
PINKY_HOST="pinky.local"

echo "🔄 Syncing docs to distributed team..."

# Sync to Brain
echo "📤 Syncing to Brain..."
rsync -avz --delete "$DOCS_DIR" "$BRAIN_HOST:~/pinkyandbrain/docs/" 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Brain synced successfully"
else
    echo "❌ Failed to sync to Brain"
fi

# Sync to Pinky
echo "📤 Syncing to Pinky..."
rsync -avz --delete "$DOCS_DIR" "$PINKY_HOST:~/pinkyandbrain/docs/" 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Pinky synced successfully"
else
    echo "❌ Failed to sync to Pinky"
fi

echo "✨ Sync complete!"
