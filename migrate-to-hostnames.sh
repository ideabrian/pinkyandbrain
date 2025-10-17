#!/bin/bash

# migrate-to-hostnames.sh - Replace hardcoded IPs with hostnames
# Brain's suggestion: Use hostnames instead of IPs for resilience
# SAFE MODE: Shows diffs, asks per file, preserves directory structure

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 IP to Hostname Migration Tool${NC}"
echo ""
echo "Current network map:"
echo "  192.168.5.80  →  pinky.local  (192.168.5.4)"
echo "  192.168.5.76  →  max.local    (192.168.5.5)"
echo "  192.168.5.81  →  brain.local  (192.168.5.6)"
echo ""

# Default to dry-run mode
DRY_RUN=true
if [ "$1" = "--apply" ]; then
  DRY_RUN=false
  echo -e "${YELLOW}⚠️  APPLY MODE - Changes will be made${NC}"
else
  echo -e "${GREEN}🔍 DRY-RUN MODE - No files will be modified${NC}"
  echo "   Run with --apply to actually make changes"
fi
echo ""

# Backup directory with full timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/pinkyandbrain/.ip-migration-backup-$TIMESTAMP"

# Files to check (excluding docs and logs)
echo "Scanning for files with hardcoded IPs..."
FILES=$(grep -rl "192\.168\.5\.\(76\|80\|81\)" ~/pinkyandbrain/ \
  --exclude-dir=".git" \
  --exclude-dir="node_modules" \
  --exclude-dir="docs" \
  --exclude-dir=".ip-migration-backup*" \
  --exclude="*.log" \
  --exclude="*.md" \
  --exclude="migrate-to-hostnames.sh" \
  --exclude="CLOUDFLARE-INVENTORY.md" \
  2>/dev/null || true)

if [ -z "$FILES" ]; then
  echo -e "${GREEN}✅ No script files found with hardcoded IPs!${NC}"
  exit 0
fi

echo ""
echo -e "${YELLOW}Files that will be checked:${NC}"
FILE_COUNT=0
while IFS= read -r file; do
  FILE_COUNT=$((FILE_COUNT + 1))
  echo "  $FILE_COUNT. $file"
done <<< "$FILES"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Process each file
CHANGED_COUNT=0
SKIPPED_COUNT=0

while IFS= read -r file; do
  if [ ! -f "$file" ]; then
    continue
  fi

  # Create temp file with replacements
  TEMP_FILE=$(mktemp)
  sed \
    -e 's/192\.168\.5\.80/pinky.local/g' \
    -e 's/192\.168\.5\.76/max.local/g' \
    -e 's/192\.168\.5\.81/brain.local/g' \
    "$file" > "$TEMP_FILE"

  # Check if there are any differences
  if diff -q "$file" "$TEMP_FILE" > /dev/null 2>&1; then
    # No changes needed
    rm "$TEMP_FILE"
    continue
  fi

  # Show the file and diff
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}File: $file${NC}"
  echo ""
  echo -e "${YELLOW}Changes:${NC}"

  # Show colored diff
  diff -u "$file" "$TEMP_FILE" | tail -n +3 | while IFS= read -r line; do
    if [[ $line == -* ]]; then
      echo -e "${RED}$line${NC}"
    elif [[ $line == +* ]]; then
      echo -e "${GREEN}$line${NC}"
    else
      echo "$line"
    fi
  done

  echo ""

  if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}[DRY-RUN] Would update this file${NC}"
    CHANGED_COUNT=$((CHANGED_COUNT + 1))
    rm "$TEMP_FILE"
  else
    # Ask for confirmation
    read -p "Apply these changes? (y/n/q to quit) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Qq]$ ]]; then
      echo ""
      echo -e "${YELLOW}Migration cancelled by user${NC}"
      rm "$TEMP_FILE"
      break
    elif [[ $REPLY =~ ^[Yy]$ ]]; then
      # Create backup preserving directory structure
      mkdir -p "$BACKUP_DIR"
      RELATIVE_PATH="${file#$HOME/pinkyandbrain/}"
      BACKUP_FILE="$BACKUP_DIR/$RELATIVE_PATH"
      mkdir -p "$(dirname "$BACKUP_FILE")"
      cp "$file" "$BACKUP_FILE"

      # Apply changes
      mv "$TEMP_FILE" "$file"
      echo -e "${GREEN}✓ Updated${NC}"
      CHANGED_COUNT=$((CHANGED_COUNT + 1))
    else
      echo -e "${YELLOW}✗ Skipped${NC}"
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      rm "$TEMP_FILE"
    fi
  fi

  echo ""
done <<< "$FILES"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${GREEN}📊 Dry-run Summary:${NC}"
  echo "  Files that would be changed: $CHANGED_COUNT"
  echo ""
  echo "To actually apply changes, run:"
  echo -e "${YELLOW}  ./migrate-to-hostnames.sh --apply${NC}"
else
  echo -e "${GREEN}📊 Migration Summary:${NC}"
  echo "  Files changed: $CHANGED_COUNT"
  echo "  Files skipped: $SKIPPED_COUNT"

  if [ $CHANGED_COUNT -gt 0 ]; then
    echo ""
    echo -e "${GREEN}Backups saved to:${NC}"
    echo "  $BACKUP_DIR"
    echo ""
    echo "To rollback a specific file:"
    echo "  cp $BACKUP_DIR/path/to/file ~/pinkyandbrain/path/to/file"
  fi
fi

echo ""
