# 📨 How to Send & Receive Messages

## Quick Reference

**Send a message:**
```bash
curl -s -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "your-name",
    "to": "brain-claude",
    "subject": "Your Subject",
    "body": "Your message here"
  }'
```

**Check your inbox:**
```bash
curl -s http://localhost:3100/inbox | jq .
```

**Check unread messages:**
```bash
curl -s http://localhost:3100/inbox/unread | jq .
```

## Addressing Messages

**Machine names accepted:**
- `brain-claude` or `brain` → Brain's Claude session
- `pinky-claude` or `pinky` → Pinky's Claude session  
- `maxyolo-claude` or `max` → Max's Claude session
- `any` → Broadcast to all machines

## Message Structure

```json
{
  "from": "sender-name",
  "to": "recipient-name",
  "subject": "Optional subject",
  "body": "Your message content",
  "priority": "normal"  // optional: normal, high, urgent
}
```

## Common Commands

**Send to brain:**
```bash
curl -X POST http://localhost:3100/send -H "Content-Type: application/json" \
  -d '{"from":"max","to":"brain-claude","body":"Hey Brain! Question for you..."}'
```

**Send to all machines:**
```bash
curl -X POST http://localhost:3100/send -H "Content-Type: application/json" \
  -d '{"from":"max","to":"any","body":"Team announcement!"}'
```

**Check how many unread:**
```bash
curl -s http://localhost:3100/inbox | jq '{unread: .unread, total: .total}'
```

**Read latest message:**
```bash
curl -s http://localhost:3100/inbox | jq '.messages[0]'
```

## Remote Messaging

**Send from maxyolo to brain:**
```bash
ssh brain 'curl -X POST http://localhost:3100/send -H "Content-Type: application/json" \
  -d "{\"from\":\"max\",\"to\":\"brain-claude\",\"body\":\"Hello!\"}"'
```

## Message Bus Ports

- maxyolo: `http://localhost:3100`
- brain: `http://192.168.5.81:3100`
- pinky: `http://192.168.5.80:3100`

## Pollers

Each machine runs a message poller that:
1. Checks for unread messages every 5 seconds
2. Processes messages automatically (when enabled)
3. Logs activity to `~/poller-{machine}.log`

**Check poller status:**
```bash
ps aux | grep message-poller | grep -v grep
```

**View poller log:**
```bash
tail -f ~/poller-$(hostname -s).log
```

## Tips

- Use descriptive subjects for easier filtering
- Messages persist until explicitly deleted
- Pollers automatically detect and log new messages
- Use `jq` for pretty formatting: `curl ... | jq .`

## Shortcuts (if you have aliases installed)

```bash
inboxes          # Check all inboxes
buses            # Check message bus status  
msg-brain '{}'   # Quick send to brain
msg-pinky '{}'   # Quick send to pinky
```
