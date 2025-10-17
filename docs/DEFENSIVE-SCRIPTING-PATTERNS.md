# Defensive Scripting Patterns

**Last Updated:** 2025-10-17
**Knowledge ID:** knowledge-1760714638289
**Lesson Learned From:** .aliases file incident (smashed existing file instead of merging)

---

## The Problem

When writing scripts that modify files, it's easy to accidentally:
- ✗ Overwrite important files with no backup
- ✗ Use `basename()` and lose directory structure in backups
- ✗ Do bulk operations without showing what will change
- ✗ Make irreversible changes without user review
- ✗ Create backup filename collisions

**Real Incident:**
> Created a `.aliases` file and copied it to another machine, **smashing the existing `.aliases`** instead of creating a diff and updating it smartly. User's fault for yolo'ing, but painful lesson.

---

## The Solution: 7 Defensive Patterns

### 1. ✅ Default to Dry-Run Mode

```bash
#!/bin/bash

# Default to dry-run, require explicit --apply
DRY_RUN=true
if [ "$1" = "--apply" ]; then
  DRY_RUN=false
  echo "⚠️  APPLY MODE - Changes will be made"
else
  echo "🔍 DRY-RUN MODE - No files will be modified"
  echo "   Run with --apply to actually make changes"
fi
```

**Why:** User can safely see what would happen first. Nothing breaks by default.

**Usage:**
```bash
./script.sh           # Shows what would change (safe)
./script.sh --apply   # Actually makes changes (explicit)
```

---

### 2. ✅ Show Full Colored Diffs

```bash
# Create temp file with proposed changes
TEMP_FILE=$(mktemp)
sed 's/old/new/g' "$file" > "$TEMP_FILE"

# Check if there are differences
if diff -q "$file" "$TEMP_FILE" > /dev/null 2>&1; then
  # No changes needed
  rm "$TEMP_FILE"
  continue
fi

# Show colored diff
echo "File: $file"
echo "Changes:"
diff -u "$file" "$TEMP_FILE" | tail -n +3 | while IFS= read -r line; do
  if [[ $line == -* ]]; then
    echo -e "\033[0;31m$line\033[0m"  # Red for removed lines
  elif [[ $line == +* ]]; then
    echo -e "\033[0;32m$line\033[0m"  # Green for added lines
  else
    echo "$line"  # Context lines (unchanged)
  fi
done
```

**Why:** User sees **exactly** what will change, line by line. No surprises.

**Example Output:**
```diff
File: /Users/pinky/pinkyandbrain/audio-bridge.js
Changes:
  const MESSAGE_BUSES = [
-     { name: 'maxyolo', url: 'http://192.168.5.76:3100' },
+     { name: 'maxyolo', url: 'http://max.local:3100' },
-     { name: 'pinky', url: 'http://192.168.5.80:3100' }
+     { name: 'pinky', url: 'http://pinky.local:3100' }
  ];
```

---

### 3. ✅ Per-File Confirmation (Not Bulk)

```bash
while IFS= read -r file; do
  # Show diff for THIS file
  diff -u "$file" "$TEMP_FILE"

  # Ask for confirmation PER FILE
  read -p "Apply these changes? (y/n/q to quit) " -n 1 -r
  echo ""

  if [[ $REPLY =~ ^[Qq]$ ]]; then
    echo "Migration cancelled by user"
    rm "$TEMP_FILE"
    break  # Exit immediately
  elif [[ $REPLY =~ ^[Yy]$ ]]; then
    # Backup and apply change
    create_backup "$file"
    mv "$TEMP_FILE" "$file"
    echo "✓ Updated"
  else
    echo "✗ Skipped"
    rm "$TEMP_FILE"
  fi
done <<< "$FILES"
```

**Why:**
- Can approve some files, skip others
- Can quit mid-process if something looks wrong
- User stays in control

**NOT this:**
```bash
# ❌ BAD: One prompt for all files
read -p "Update all 44 files? (y/n) "
if yes; then
  # Bulk update everything (scary!)
fi
```

---

### 4. ✅ Preserve Directory Structure in Backups

```bash
# ❌ BAD: Uses basename, loses directory info
BACKUP_DIR="$HOME/.backup"
cp "$file" "$BACKUP_DIR/$(basename $file).bak"

# Problem: Both of these backup to "config.sh.bak"
#   /path/to/config.sh
#   /other/path/config.sh
# Second one overwrites the first!
```

```bash
# ✅ GOOD: Preserves full directory structure
BACKUP_DIR="$HOME/.backup-20251017-150730"
RELATIVE_PATH="${file#$HOME/pinkyandbrain/}"
BACKUP_FILE="$BACKUP_DIR/$RELATIVE_PATH"

# Create parent directories
mkdir -p "$(dirname "$BACKUP_FILE")"

# Backup with full path
cp "$file" "$BACKUP_FILE"

# Result:
#   Original: ~/pinkyandbrain/prompts/pinky-prompt.md
#   Backup:   ~/.backup-20251017-150730/prompts/pinky-prompt.md
```

**Why:**
- No filename collisions
- Can restore to exact original location
- Easy to see what was backed up where

**Rollback is simple:**
```bash
# Restore specific file
cp ~/.backup-20251017-150730/prompts/pinky-prompt.md \
   ~/pinkyandbrain/prompts/pinky-prompt.md

# Or restore everything
cp -r ~/.backup-20251017-150730/* ~/pinkyandbrain/
```

---

### 5. ✅ Use Temp Files, Not In-Place sed

```bash
# ❌ BAD: Modifies file directly, no going back
sed -i '' 's/old/new/g' "$file"
```

```bash
# ✅ GOOD: Create temp, show diff, then apply if confirmed
TEMP_FILE=$(mktemp)
sed 's/old/new/g' "$file" > "$TEMP_FILE"

# Show what would change
diff -u "$file" "$TEMP_FILE"

# User confirms
if user_confirms; then
  # Backup first
  create_backup "$file"

  # Apply change
  mv "$TEMP_FILE" "$file"
else
  # Abort
  rm "$TEMP_FILE"
fi
```

**Why:**
- Can review changes before applying
- Easy to abort without consequences
- Temp file is automatically cleaned up

---

### 6. ✅ Add Quit Option to Loops

```bash
# Always include 'q' option
read -p "Apply changes? (y/n/q to quit) " -n 1 -r

if [[ $REPLY =~ ^[Qq]$ ]]; then
  echo ""
  echo "Migration cancelled by user"
  rm "$TEMP_FILE"
  break  # Exit the loop immediately
fi
```

**Why:** User can stop mid-process if they see something wrong in one of the diffs.

**User Experience:**
```
File: script1.sh
- old content
+ new content
Apply? (y/n/q) y
✓ Updated

File: script2.sh
- old content
+ new content
Apply? (y/n/q) n
✗ Skipped

File: script3.sh
- old content
+ WAIT THIS LOOKS WRONG
Apply? (y/n/q) q

Migration cancelled by user
```

---

### 7. ✅ Timestamp Backup Directories

```bash
# ❌ BAD: Gets overwritten on each run
BACKUP_DIR="$HOME/.backup"
# Second run overwrites first run's backups!
```

```bash
# ✅ GOOD: Unique per run
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.migration-backup-$TIMESTAMP"

# Results in:
#   ~/.migration-backup-20251017-150730/
#   ~/.migration-backup-20251017-151445/
#   ~/.migration-backup-20251017-152301/
```

**Why:**
- Can compare multiple backup runs
- Never lose old backups
- Can track when changes were made
- Easy to identify which backup to restore from

---

## Complete Safe Migration Script Template

```bash
#!/bin/bash
# Safe file modification script template
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Default to dry-run
DRY_RUN=true
if [ "$1" = "--apply" ]; then
  DRY_RUN=false
  echo -e "${YELLOW}⚠️  APPLY MODE${NC}"
else
  echo -e "${GREEN}🔍 DRY-RUN MODE${NC}"
  echo "Run with --apply to make changes"
fi

# 2. Timestamped backup directory
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.backup-$TIMESTAMP"

# 3. Find files to process
echo "Scanning for files..."
FILES=$(grep -rl "pattern" ~/path/ \
  --exclude-dir=".git" \
  --exclude="*.md" \
  --exclude="*.log" \
  2>/dev/null || true)

if [ -z "$FILES" ]; then
  echo "No files found"
  exit 0
fi

# Show file list
echo ""
echo "Files to check:"
FILE_COUNT=0
while IFS= read -r file; do
  FILE_COUNT=$((FILE_COUNT + 1))
  echo "  $FILE_COUNT. $file"
done <<< "$FILES"
echo ""

CHANGED_COUNT=0
SKIPPED_COUNT=0

# Process each file
while IFS= read -r file; do
  [ ! -f "$file" ] && continue

  # 4. Create temp with changes
  TEMP_FILE=$(mktemp)
  sed 's/old/new/g' "$file" > "$TEMP_FILE"

  # 5. Check for differences
  if diff -q "$file" "$TEMP_FILE" > /dev/null 2>&1; then
    # No changes needed
    rm "$TEMP_FILE"
    continue
  fi

  # 6. Show colored diff
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}File: $file${NC}"
  echo ""

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
    # 7. Ask per file with quit option
    read -p "Apply these changes? (y/n/q to quit) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Qq]$ ]]; then
      echo -e "${YELLOW}Migration cancelled${NC}"
      rm "$TEMP_FILE"
      break
    elif [[ $REPLY =~ ^[Yy]$ ]]; then
      # 8. Preserve directory structure in backup
      RELATIVE_PATH="${file#$HOME/path/}"
      BACKUP_FILE="$BACKUP_DIR/$RELATIVE_PATH"
      mkdir -p "$(dirname "$BACKUP_FILE")"
      cp "$file" "$BACKUP_FILE"

      # 9. Apply change
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

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$DRY_RUN" = true ]; then
  echo "Dry-run complete: $CHANGED_COUNT files would be changed"
  echo "To apply: $0 --apply"
else
  echo "Complete: $CHANGED_COUNT changed, $SKIPPED_COUNT skipped"
  if [ $CHANGED_COUNT -gt 0 ]; then
    echo "Backups: $BACKUP_DIR"
  fi
fi
```

---

## Safety Checklist

Before running any file modification script, verify:

- [ ] Defaults to dry-run mode (requires `--apply` flag)
- [ ] Shows full diff before any changes
- [ ] Asks for confirmation **per file** (not bulk)
- [ ] Preserves directory structure in backups (no `basename`)
- [ ] Uses temp files instead of `sed -i`
- [ ] Includes quit option (`q`) in confirmation prompts
- [ ] Uses timestamped backup directories
- [ ] Excludes docs, logs, and markdown files
- [ ] Has clear rollback instructions in output
- [ ] Validates files exist before processing
- [ ] Cleans up temp files on error or abort

---

## When to Use This Pattern

### ✅ Use for:
- Bulk file modifications
- Configuration updates
- Migration scripts
- Refactoring tools
- Any script that modifies existing files
- Search and replace operations
- IP to hostname migrations
- Dependency version updates

### ❌ Don't need for:
- Creating new files (nothing to backup)
- Read-only operations (grep, search, analysis)
- Generating reports
- Temporary file operations
- Deletions (use `rm -i` instead)

---

## Real-World Examples

### Example 1: IP to Hostname Migration
```bash
# Bad approach (original script):
sed -i '' -e 's/192\.168\.5\.80/pinky.local/g' \
          -e 's/192\.168\.5\.76/max.local/g' \
          -e 's/192\.168\.5\.81/brain.local/g' \
  ~/pinkyandbrain/**/*.sh

# Good approach:
./migrate-to-hostnames.sh           # See diffs
./migrate-to-hostnames.sh --apply   # Apply after review
```

### Example 2: .aliases File Update
```bash
# Bad approach (what happened):
cp new-aliases ~/.aliases  # BOOM! Lost all existing aliases

# Good approach:
diff -u ~/.aliases new-aliases      # See what's different
# Manually merge, OR:
# Create script that preserves existing and adds new
```

---

## Key Lessons

1. **Never trust bulk operations** - Show diffs, ask per file
2. **`basename()` is dangerous for backups** - Preserve full paths
3. **Default to safe mode** - Require explicit `--apply` flag
4. **Show before doing** - User should see changes before they happen
5. **Always allow abort** - Add quit option to confirmations
6. **Make backups recoverable** - Timestamp and preserve structure
7. **One mistake teaches forever** - The .aliases incident was painful but valuable

---

## Real-World Impact

This pattern prevents:
- ✗ Lost configuration files
- ✗ Debugging why things broke after a "simple script"
- ✗ Hours spent manually diffing and fixing files
- ✗ Loss of trust in automation tools
- ✗ The dreaded "oh no, what did I just do?"

Instead provides:
- ✓ Confidence in running scripts
- ✓ Clear visibility into what's changing
- ✓ Easy rollback when needed
- ✓ Audit trail of all changes
- ✓ No surprises

---

## References

- **Knowledge ID:** knowledge-1760714638289
- **Real Script:** `~/pinkyandbrain/migrate-to-hostnames.sh`
- **Incident Report:** .aliases file smashed on 2025-10-17
- **Related:** `docs/FILE-BASED-AGENT-ARCHITECTURE.md` (similar defensive patterns)

---

**Created by:** Pinky (after learning the hard way)
**Reviewed by:** Brain's suggestion to use hostnames prompted the safe rewrite
**Status:** ✅ Production pattern, use for all file modification scripts
