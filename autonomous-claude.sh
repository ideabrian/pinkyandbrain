#!/bin/bash
# autonomous-claude.sh - True autonomous Claude Code execution
#
# This script launches Claude Code in a detached screen session with:
# - Full TTY support (via screen)
# - Session continuation (via --continue or --resume)
# - Context injection (via initial prompt)
# - Automated completion detection
# - Git commit automation
# - Full memory/context preservation

set -e

# Configuration
ROLE=${1:-$(hostname | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')}
MESSAGE_ID=$2
CONTEXT_FILE=$3
SESSION_NAME="autonomous-claude-$MESSAGE_ID"
SESSION_LOG="$HOME/pinkyandbrain/autonomous-sessions.log"
WRAPPER_SCRIPT="/tmp/autonomous-wrapper-$MESSAGE_ID.sh"

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SESSION_LOG"
}

if [ -z "$MESSAGE_ID" ] || [ -z "$CONTEXT_FILE" ]; then
    echo "Usage: $0 <role> <message_id> <context_file>"
    exit 1
fi

if [ ! -f "$CONTEXT_FILE" ]; then
    log "${RED}✗ Context file not found: $CONTEXT_FILE${NC}"
    exit 1
fi

log "${GREEN}Starting autonomous Claude session${NC}"
log "Role: $ROLE"
log "Message ID: $MESSAGE_ID"
log "Context: $CONTEXT_FILE"

# Create wrapper script that will run inside screen
cat > "$WRAPPER_SCRIPT" << 'WRAPPER_END'
#!/bin/bash
# Wrapper script running inside screen session

REPLACE_MESSAGE_ID
REPLACE_CONTEXT_FILE
REPLACE_SESSION_LOG
REPLACE_ROLE

cd ~/pinkyandbrain

# Log session start
echo "[$(date)] ═══ Starting autonomous session $MESSAGE_ID ═══" >> "$SESSION_LOG"
echo "[$(date)] Role: $ROLE" >> "$SESSION_LOG"
echo "[$(date)] Context: $CONTEXT_FILE" >> "$SESSION_LOG"

# Read the task from context
TASK=$(cat "$CONTEXT_FILE")
echo "[$(date)] Task: ${TASK:0:200}..." >> "$SESSION_LOG"

# Create the prompt that will be sent to Claude
PROMPT_FILE="/tmp/claude-prompt-$MESSAGE_ID.txt"
cat > "$PROMPT_FILE" << 'PROMPT'
You are working autonomously. Read the context and complete the task.

CONTEXT:
$(cat "$CONTEXT_FILE")

INSTRUCTIONS:
1. Complete the task described above
2. Test your work thoroughly
3. If you created/modified files, commit them to git with a descriptive message
4. Share significant learnings to knowledge base using: ./knowledge-cli.sh share
5. Update HANDOFF.md with what you completed
6. When completely done, type "autonomous-complete" to signal completion

Work autonomously. Be thorough. Document your work.
PROMPT

# Use expect to interact with Claude
/usr/bin/expect << 'EXPECT_END'
set timeout 1800
set prompt_file "/tmp/claude-prompt-REPLACE_MESSAGE_ID.txt"
set session_log "REPLACE_SESSION_LOG"

# Read the prompt
set fp [open $prompt_file r]
set prompt_text [read $fp]
close $fp

# Spawn Claude with bypass permissions
# Use --continue to maintain context from previous sessions
spawn claude --dangerously-skip-permissions --continue

# Wait for Claude to be ready
expect {
    "Try \"how does" {
        # Claude is ready - send our prompt
        send "$prompt_text\r"

        # Now wait for completion signal or timeout
        expect {
            "autonomous-complete" {
                # Task completed successfully
                set logfp [open $session_log a]
                puts $logfp "\[[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]\] ✓ Task completed (autonomous-complete signal received)"
                close $logfp
                send "exit\r"
            }
            timeout {
                # Timeout after 30 minutes
                set logfp [open $session_log a]
                puts $logfp "\[[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]\] ⚠ Session timeout after 30 minutes"
                close $logfp
                send "exit\r"
            }
            eof {
                # Claude exited
                set logfp [open $session_log a]
                puts $logfp "\[[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]\] ✓ Claude session ended"
                close $logfp
            }
        }
    }
    timeout {
        set logfp [open $session_log a]
        puts $logfp "\[[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]\] ✗ Timeout waiting for Claude to start"
        close $logfp
        exit 1
    }
}

wait
EXPECT_END

# Log completion
echo "[$(date)] ═══ Session $MESSAGE_ID completed ═══" >> "$SESSION_LOG"

# Cleanup
rm -f "/tmp/claude-prompt-$MESSAGE_ID.txt"
rm -f "/tmp/autonomous-wrapper-$MESSAGE_ID.sh"
WRAPPER_END

# Replace placeholders in wrapper script
sed -i '' "s|REPLACE_MESSAGE_ID|MESSAGE_ID=\"$MESSAGE_ID\"|g" "$WRAPPER_SCRIPT"
sed -i '' "s|REPLACE_CONTEXT_FILE|CONTEXT_FILE=\"$CONTEXT_FILE\"|g" "$WRAPPER_SCRIPT"
sed -i '' "s|REPLACE_SESSION_LOG|SESSION_LOG=\"$SESSION_LOG\"|g" "$WRAPPER_SCRIPT"
sed -i '' "s|REPLACE_ROLE|ROLE=\"$ROLE\"|g" "$WRAPPER_SCRIPT"
chmod +x "$WRAPPER_SCRIPT"

# Launch wrapper in detached screen session
log "${YELLOW}Launching screen session: $SESSION_NAME${NC}"
screen -dmS "$SESSION_NAME" bash "$WRAPPER_SCRIPT"

log "${GREEN}✓ Autonomous session launched${NC}"
log "Monitor with: screen -r $SESSION_NAME"
log "View log: tail -f $SESSION_LOG"
log "List sessions: screen -ls"

exit 0
