# Claude Code Hooks Setup Guide

## Auto-Check Messages on Stop

This hook automatically checks for unread messages every time Claude Code finishes responding.

---

## Quick Setup

### 1. Copy the hook script (if not on pinky)

```bash
# From brain or maxyolo
scp pinky:~/pinkyandbrain/check-messages-hook.sh ~/pinkyandbrain/
chmod +x ~/pinkyandbrain/check-messages-hook.sh
```

### 2. Edit Claude Code settings

Open `~/.claude/settings.json` and add this hooks configuration:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/pinkyandbrain/check-messages-hook.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/pinkyandbrain/check-messages-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**Note:** If you already have other settings, merge the `hooks` section with your existing config.

### 3. Restart Claude Code

Exit and restart Claude Code for the hooks to take effect.

---

## What It Does

Every time Claude finishes responding, you'll see:

```
📬 You have 2 unread message(s)
   Run: curl http://localhost:3100/inbox/unread | jq
   Or just say: 'check messages'
```

---

## Available Claude Code Hooks

Claude Code supports 8 lifecycle hooks:

### 1. **UserPromptSubmit**
Fires when user submits a prompt (before Claude processes it)
- Use for: Prompt validation, context injection, logging

### 2. **PreToolUse**
Fires before tool execution
- Use for: Validating dangerous operations, logging tool calls

### 3. **PostToolUse**
Fires after tool execution
- Use for: Auto-commit on file changes, logging results

### 4. **Stop** ✅ (we use this)
Fires when main Claude finishes responding
- Use for: Message checking, cleanup, session logging

### 5. **SubagentStop** ✅ (we use this)
Fires when Task/subagents finish
- Use for: Same as Stop, but for background tasks

### 6. **SessionStart**
Fires when Claude starts or resumes
- Use for: Loading context, showing git status, team updates

### 7. **PreCompact**
Fires before conversation compaction
- Use for: Backing up transcripts

### 8. **Notification**
Fires on notifications
- Use for: Custom notification handling

---

## Future Hook Ideas

### SessionStart Hook - Show context on startup
```bash
#!/bin/bash
# show-context-hook.sh
echo "🔄 Git: $(git status -s | wc -l) changes"
echo "📬 Messages: $(curl -s http://localhost:3100/inbox/unread | jq -r .unread)"
echo "📊 Knowledge: $(ls ~/pinkyandbrain/knowledge/*.md 2>/dev/null | wc -l) entries"
```

### PostToolUse Hook - Auto-commit documentation
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "auto-commit-docs.sh"
          }
        ]
      }
    ]
  }
}
```

### PreToolUse Hook - Warn on dangerous commands
```bash
#!/bin/bash
# warn-dangerous.sh
if echo "$TOOL_INPUT" | grep -E "rm -rf|sudo|dd"; then
    echo "⚠️  WARNING: Potentially dangerous command detected!"
fi
```

---

## Troubleshooting

### Hook not running?

1. Check the script is executable:
   ```bash
   ls -la ~/pinkyandbrain/check-messages-hook.sh
   chmod +x ~/pinkyandbrain/check-messages-hook.sh
   ```

2. Test the script manually:
   ```bash
   ~/pinkyandbrain/check-messages-hook.sh
   ```

3. Check Claude Code settings syntax:
   ```bash
   cat ~/.claude/settings.json | jq .
   ```

4. Restart Claude Code

### Script errors?

Check the message bus is running:
```bash
curl http://localhost:3100/health
```

---

## Hook Environment Variables

Claude Code provides these environment variables to hooks:

- `TOOL_NAME` - Name of the tool being used (PreToolUse/PostToolUse)
- `TOOL_INPUT` - Input parameters to the tool
- `TOOL_RESPONSE` - Output from the tool (PostToolUse only)
- `PROMPT` - User's prompt text (UserPromptSubmit)
- Additional context varies by hook type

---

## Resources

- **Official Docs:** https://docs.claude.com/en/docs/claude-code/hooks
- **This Script:** ~/pinkyandbrain/check-messages-hook.sh
- **Settings:** ~/.claude/settings.json

---

**Created:** 2025-10-17
**Author:** Pinky
**Status:** Production Ready ✅
