# How to Send a Message

## Quick Command (Copy-Paste Ready)

```bash
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "claude",
    "to": "maxyolo",
    "subject": "Your subject here",
    "body": "Your message body here",
    "priority": "normal"
  }'
```

## Common Recipients

- `"to": "maxyolo"` - Send to Max (you)
- `"to": "brain"` - Send to Brain (AI worker)
- `"to": "pinky"` - Send to Pinky (execution worker)

## Priority Levels

- `"priority": "low"` - Can wait
- `"priority": "normal"` - Default
- `"priority": "high"` - Important
- `"priority": "urgent"` - Do it now

## Examples

### Send a task to Brain
```bash
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "claude",
    "to": "brain",
    "subject": "Categorize new emails",
    "body": "Check for any new emails and categorize them by urgency",
    "priority": "normal"
  }'
```

### Send a build request to Pinky
```bash
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "claude",
    "to": "pinky",
    "subject": "Build todo component",
    "body": "Create a simple React todo list component with add/delete functionality",
    "priority": "high"
  }'
```

### Send yourself a reminder
```bash
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "claude",
    "to": "maxyolo",
    "subject": "Follow up with Guga",
    "body": "Check if Guga needs help setting up WhatsApp integration",
    "priority": "normal"
  }'
```

## What Happens After You Send

1. **Message stored** in local database (`messages.json`)
2. **Poller detects** it within 10 seconds
3. **Task file created** in `~/pinkyandbrain-{recipient}/tasks/`
4. **Claude Code launches** automatically to process the task
5. **Recipient processes** and marks complete

## Check If Your Message Was Received

```bash
# Check all recent messages
curl http://localhost:3100/health

# The "messages" count should increase
```

## Troubleshooting

**Message not creating task file?**
```bash
# Check if poller is running
ps aux | grep cloud-poller

# Restart poller if needed
cd ~/Documents/projects/pinkyandbrain
./cloud-poller.sh maxyolo
```

**Local server not responding?**
```bash
# Check if server is running
curl http://localhost:3100/health

# If not, start it
cd ~/pinkyandbrain
node server.js
```

---

**Pro tip:** Save this command in your shell history or create an alias:

```bash
alias send-message='curl -X POST http://localhost:3100/send -H "Content-Type: application/json" -d'
```

Then use it like:
```bash
send-message '{"from":"claude","to":"maxyolo","subject":"Test","body":"Hello!","priority":"normal"}'
```
