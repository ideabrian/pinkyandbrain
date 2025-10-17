# How to Resume Claude Code Sessions

## Quick Start

### Starting a New Session
```bash
cd ~/pinkyandbrain
claude
```

### Resuming with Context
Claude Code maintains conversation history automatically, but here are helpful ways to provide context:

## Option 1: Quick Context Prompt
```bash
cd ~/pinkyandbrain
claude
```
Then say:
> "I'm back! Can you check the knowledge base for what we were working on? Search for recent entries from pinky."

## Option 2: Check Recent Work First
```bash
# Check recent knowledge entries
knowledge recent 10

# Check morning standup
standup

# Check inbox for messages
curl -s http://localhost:3100/inbox/unread | jq '.'
```

Then start Claude with that context in mind.

## Option 3: Start with Specific Context File
```bash
# Create a context file
cat > /tmp/resume-context.md <<EOF
# Resume Session

## What I was working on:
- [Brief description]

## What needs to be done:
- [Next steps]

## Questions:
- [Any questions]
EOF

claude
# Then reference the context file in your first message
```

## Option 4: Use HANDOFF.md (Recommended for Long Tasks)

Before ending a session, update HANDOFF.md with current state:
```bash
cat > ~/pinkyandbrain/HANDOFF.md <<EOF
# Session Handoff - $(date)

## Just Completed
- [What you finished this session]
- [Files modified]
- [Deployed where]

## In Progress
- [What's partially done]

## Next Steps
1. [Next priority task]
2. [Future work]

## Notes
- [Important context]
- [Gotchas to remember]
EOF
```

Then resume with:
```bash
cd ~/pinkyandbrain
claude
# First message: "Please read HANDOFF.md and tell me where we left off"
```

**Philosophy:** "Documentation as you go > trying to remember later"

## Before Ending Session: Verification Checklist

✅ Did I test what I built?
✅ Did I document in HANDOFF.md?
✅ Did I add non-trivial learnings to knowledge base?
✅ Did I mark all todos as complete/pending appropriately?
✅ Are next steps clear for next session?

**Philosophy:** "Don't declare success without verification"

## Session State Tracking

For complex multi-step work, check session-state.json:
```bash
cat ~/pinkyandbrain/session-state.json
# Shows: current task, progress %, artifacts created, notes
```

This is automatically maintained during sessions with TodoWrite tracking.

## Automated Polling (For Autonomous Operation)

### Start Message Poller
```bash
cd ~/pinkyandbrain
./message-poller.sh &
# This runs in background and will create context files when messages arrive
```

### Check Poller Status
```bash
ps aux | grep poller | grep -v grep
tail -f ~/poller-$(hostname -s).log
```

## Important Files & Locations

### Scripts & Tools
- `~/pinkyandbrain/` - All team scripts
- `~/pinkyandbrain/morning-standup.sh` - Daily standup digest
- `~/pinkyandbrain/knowledge-cli.sh` - Knowledge base access
- `~/pinkyandbrain/gm.sh` - Team broadcasts
- `~/pinkyandbrain/vote-cli.sh` - Voting system
- `~/pinkyandbrain/cloud-poller.sh` - Message poller
- `~/pinkyandbrain/HANDOFF.md` - Session handoff notes
- `~/pinkyandbrain/session-state.json` - Current task state

### Aliases (from ~/.aliases)
- `standup` - View yesterday's work
- `knowledge` or `share` - Knowledge base
- `gm` - Send good morning
- `vote` - Team voting
- `pb` - cd ~/pinkyandbrain
- `buses` - Check message bus status
- `ssa` - Reload shell config

### Configuration
- `~/.zshrc` - Shell configuration
- `~/.aliases` - All aliases
- Environment variables:
  - `CLOUD_BUS_URL` - https://pinky-brain-hub.b-9f2.workers.dev
  - `CLOUD_API_KEY` - [set in ~/.zshrc]

## Typical Resume Workflow

1. **Start fresh session**
   ```bash
   cd ~/pinkyandbrain
   claude
   ```

2. **Get oriented**
   ```
   "Hey! I'm resuming our session. Can you:
   1. Check the knowledge base for recent entries from pinky
   2. Show me HANDOFF.md if it exists
   3. Check for unread messages
   4. Tell me what we should work on next"
   ```

3. **Verify systems are running**
   ```
   "Can you verify the message bus and pollers are running?"
   ```

## Quick Recovery: Something Broke?

### Message pollers not working?
```bash
ps aux | grep poller | grep -v grep
# If none running:
cd ~/pinkyandbrain
./message-poller.sh &
```

### Message bus not responding?
```bash
curl -s http://localhost:3100/health | jq .
# If fails:
cd ~/pinkyandbrain
nohup node claude-messenger.js > messenger.log 2>&1 &
```

### Can't remember what I built?
```bash
knowledge search <topic>
git log --oneline -10
ls -lt ~/pinkyandbrain/ | head -20
cat HANDOFF.md
```

## Check What's Running in Background

```bash
# See all pinkyandbrain processes
ps aux | grep pinkyandbrain | grep -v grep

# See all Claude Code bash shells (from within Claude session)
/bashes

# Check specific background bash output
bash-output <bash-id>
```

## Knowledge Base Quick Reference

```bash
# Search for past solutions
knowledge search "timeline" "react" "bug"

# See what I learned recently
knowledge recent 5

# Add new learning
cat > /tmp/knowledge-new.json <<EOF
{
  "from_machine": "pinky",
  "topic": "React",
  "category": "bug-fix",
  "title": "useRef vs useState for intervals",
  "learning": "When using setInterval with state, use useRef to avoid stale closures",
  "code_example": "const bufferRef = useRef([]); setInterval(() => setEvents(bufferRef.current), 30000);",
  "tags": "react,hooks,closure,useref"
}
EOF
knowledge add /tmp/knowledge-new.json
```

## Pro Tips

- Claude Code remembers the conversation history within a session
- Always `cd ~/pinkyandbrain` before starting - sets working directory context
- Use `standup` to see what happened yesterday
- Use `knowledge search <topic>` to find past work
- Check message inbox for team communications
- The poller can auto-launch Claude, but that integration is still being built
- Update HANDOFF.md at natural stopping points, not just at end of session
- Use TodoWrite tool to track multi-step tasks - creates session-state.json automatically

## Current Work In Progress

As of Oct 16, 2025:
- ✅ Morning standup feature (runs at 9am daily)
- ✅ Good morning broadcast script
- ✅ Voting CLI (waiting for API endpoints from Brain)
- ✅ **Live Timeline** - https://pinky-brain-timeline.pages.dev
- ✅ Message pollers (running on all machines)
- ✅ Cloud message bus (Cloudflare Workers + D1)
- ✅ Knowledge base (searchable, shareable)
- 🚧 Auto-launch Claude on message arrival (team discussion ongoing)
- 🚧 Shared GitHub repo (pending team vote)

## Team Contact

Send messages to team:
```bash
# Via local message bus
curl -X POST http://192.168.5.81:3100/send \
  -H "Content-Type: application/json" \
  -d '{"to":"brain","from":"pinky","subject":"Subject","body":"Message","priority":"normal"}'

# Or via gm.sh for broadcasts
gm

# Check messages
curl -s http://localhost:3100/inbox/unread | jq .
```

## Getting Help

```bash
knowledge search <topic>    # Search knowledge base
standup                      # See recent activity
intro                        # Show cluster info
train                        # Human training system
cat HANDOFF.md               # Check session notes
cat session-state.json       # Check current task state
```

## Examples of Good Handoff Notes

### Example 1: Mid-Task Handoff
```markdown
# Session Handoff - 2025-10-16 14:30

## Just Completed
- Fixed timeline display bug (React closure issue in useEffect)
- Changed buffer from useState to useRef in index.html:186
- Deployed to https://pinky-brain-timeline.pages.dev
- Verified all 6 events display with scrolling animation

## In Progress
- None

## Next Steps
1. Consider adding real-time updates (WebSocket?) instead of 5s polling
2. Add voting UI to knowledge viewer (brain is building HN-style viewer)
3. Implement GitHub strategy discussion

## Notes
- Timeline uses useRef to avoid stale closures in setInterval
- Events fetch every 5s, display updates every 30s for smooth UX
- React production build would eliminate Babel warning
```

### Example 2: Blocked/Waiting Handoff
```markdown
# Session Handoff - 2025-10-16 12:00

## Just Completed
- Built vote-cli.sh with full CRUD operations
- Tested locally, all commands work

## In Progress
- Waiting for Brain to deploy voting endpoints to Cloudflare Worker

## Next Steps
1. Wait for Brain to message when endpoints are ready
2. Test vote-cli.sh against live API
3. Add voting to knowledge viewer UI
4. Create /vote slash command for quick access

## Notes
- Vote CLI expects: POST /votes, GET /votes/:id, GET /votes/results/:id
- Need to coordinate with Brain on API schema
```
