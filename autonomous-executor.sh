#!/bin/bash
# autonomous-executor.sh - True autonomous Claude Code execution
# Uses claude -p for non-interactive, headless operation
#
# This is THE solution - no TTY, no expect, no screen needed!

set -e

# Configuration
ROLE=${1}
MESSAGE_ID=${2}
CONTEXT_FILE=${3}

if [ -z "$MESSAGE_ID" ] || [ -z "$CONTEXT_FILE" ]; then
    echo "Usage: $0 <role> <message_id> <context_file>"
    exit 1
fi

WORK_DIR="$HOME/pinkyandbrain"
SESSION_LOG="$WORK_DIR/autonomous-sessions.log"
OUTPUT_LOG="$WORK_DIR/autonomous-output-$MESSAGE_ID.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SESSION_LOG"
}

log "${GREEN}═══ Starting autonomous session $MESSAGE_ID ═══${NC}"
log "Role: $ROLE"
log "Context: $CONTEXT_FILE"

cd "$WORK_DIR"

# Read the task context
TASK_CONTEXT=$(cat "$CONTEXT_FILE")

# Build the complete prompt with instructions
PROMPT="You are working AUTONOMOUSLY as $ROLE.

═══ TASK CONTEXT ═══
$TASK_CONTEXT

═══ AUTONOMOUS WORKFLOW ═══
Complete this task following these steps:

1. **Understand**: Read and analyze the task requirements
2. **Plan**: Think through the implementation approach
3. **Execute**: Write the code/scripts/documentation
4. **Test**: Thoroughly test your work
5. **Document**: Add comments and update relevant docs
6. **Commit**: If you created/modified files, commit to git with a clear message
7. **Share**: Share significant learnings to knowledge base using ./knowledge-cli.sh
8. **Handoff**: Update HANDOFF.md with what you completed

═══ IMPORTANT NOTES ═══
- You are running in NON-INTERACTIVE mode (-p flag)
- All file operations should work normally
- Git commits should have clear, descriptive messages
- Test your work before committing
- When complete, your output will be logged and the session will end

Work methodically and document everything. Begin now.
"

log "Executing Claude with -p flag (non-interactive)..."
log "Output will be saved to: $OUTPUT_LOG"

# Execute Claude in non-interactive mode
# The -p flag allows headless operation without TTY
# --dangerously-skip-permissions allows autonomous file operations
# --continue maintains context from previous sessions
claude -p "$PROMPT" \
    --dangerously-skip-permissions \
    --continue \
    > "$OUTPUT_LOG" 2>&1

EXIT_CODE=$?

log "Claude execution completed with exit code: $EXIT_CODE"

if [ $EXIT_CODE -eq 0 ]; then
    log "${GREEN}✓ Task completed successfully${NC}"
else
    log "${RED}✗ Task failed with exit code $EXIT_CODE${NC}"
fi

# Show summary of output
log "Output summary (first 10 and last 10 lines):"
echo "─── First 10 lines ───" >> "$SESSION_LOG"
head -10 "$OUTPUT_LOG" >> "$SESSION_LOG"
echo "─── Last 10 lines ───" >> "$SESSION_LOG"
tail -10 "$OUTPUT_LOG" >> "$SESSION_LOG"

log "Full output at: $OUTPUT_LOG"
log "${GREEN}═══ Session $MESSAGE_ID complete ═══${NC}"

exit $EXIT_CODE
