#!/bin/bash
# autonomous-claude-v2.sh - Simplified autonomous Claude executor
# Uses simpler approach: create a script that pipes commands to Claude

set -e

ROLE=${1}
MESSAGE_ID=${2}
CONTEXT_FILE=${3}

if [ -z "$MESSAGE_ID" ] || [ -z "$CONTEXT_FILE" ]; then
    echo "Usage: $0 <role> <message_id> <context_file>"
    exit 1
fi

SESSION_LOG="$HOME/pinkyandbrain/autonomous-sessions.log"
WORK_DIR="$HOME/pinkyandbrain"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SESSION_LOG"
}

log "=== Starting autonomous session $MESSAGE_ID ==="
log "Context: $CONTEXT_FILE"

# Read the task
TASK=$(cat "$CONTEXT_FILE")
log "Task: ${TASK:0:200}..."

# Create a script that will interact with Claude using expect
EXPECT_SCRIPT="/tmp/auto-claude-$MESSAGE_ID.exp"
cat > "$EXPECT_SCRIPT" << 'EXPECT_EOF'
#!/usr/bin/expect -f

set timeout 3600
set context_file "CONTEXT_FILE_PLACEHOLDER"
set message_id "MESSAGE_ID_PLACEHOLDER"

# Build the prompt
set prompt "You are working autonomously.

Read this context and complete the task:
---
"
append prompt [exec cat $context_file]
append prompt "\n---

INSTRUCTIONS:
1. Complete the task described above
2. Test your work thoroughly
3. If you created/modified files, commit to git with a descriptive message
4. Share learnings: ./knowledge-cli.sh share <topic> <title> <content>
5. Update HANDOFF.md with what you completed
6. When done, output the exact text: AUTONOMOUS_TASK_COMPLETE

Work methodically. Document everything.
"

# Spawn Claude
spawn claude --dangerously-skip-permissions --continue

# Wait for Claude to be ready and send prompt
expect {
    -re "Try \".+\"" {
        send "$prompt\r"
        # Now wait for completion or timeout
        expect {
            "AUTONOMOUS_TASK_COMPLETE" {
                send "exit\r"
                expect eof
            }
            timeout {
                send "exit\r"
                expect eof
            }
        }
    }
    timeout {
        puts "Failed to start Claude"
        exit 1
    }
}
EXPECT_EOF

# Replace placeholders
sed -i '' "s|CONTEXT_FILE_PLACEHOLDER|$CONTEXT_FILE|g" "$EXPECT_SCRIPT"
sed -i '' "s|MESSAGE_ID_PLACEHOLDER|$MESSAGE_ID|g" "$EXPECT_SCRIPT"
chmod +x "$EXPECT_SCRIPT"

# Launch in screen
log "Launching screen session..."
screen -dmS "autonomous-$MESSAGE_ID" "$EXPECT_SCRIPT"

log "✓ Session launched: autonomous-$MESSAGE_ID"
log "Monitor: screen -r autonomous-$MESSAGE_ID"
log "Logs: tail -f $SESSION_LOG"

exit 0
