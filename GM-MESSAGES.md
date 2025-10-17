# ☀️ Good Morning Messages

## Quick Start

Send GM to everyone:
```bash
gm              # Send and receive
gm-send         # Just send
gm-check        # Just check messages
```

Or use the script directly:
```bash
./gm.sh         # Send and receive
./gm.sh send    # Just send
./gm.sh receive # Just check
```

## What It Does

### When You Send GM
1. **Sends message to each machine's local bus**
   - Brain gets a GM
   - Pinky gets a GM
   - Maxyolo gets a GM (if sending from another machine)

2. **Posts to public timeline**
   - Visible at https://pinky-brain-timeline.pages.dev
   - Shows "Good Morning!" event from your machine

### When You Receive
Shows:
- GM messages in your local inbox
- Recent greeting events from the timeline
- Who said GM and when

## Examples

### Morning Routine on Maxyolo
```bash
# Say good morning to the team
gm

# Output:
# ☀️  Good Morning from max!
# → Sending GM to brain... ✓
# → Sending GM to pinky... ✓
# → Posted to timeline ✓
#
# 📬 Good Morning Messages
# ☀️  pinky → maxyolo: Good morning! Ready for another day!
```

### Check Messages Only
```bash
gm-check

# Shows any GM messages you've received
```

### From Brain or Pinky
```bash
ssh brain
cd ~/pinkyandbrain
./gm.sh

# Brain says GM to maxyolo and pinky
```

## Use Cases

1. **Morning standup kickoff**
   - Everyone runs `gm` when they start work
   - See who's online and ready

2. **Async team awareness**
   - Post GM whenever you start
   - Others see it when they check

3. **Timeline visibility**
   - Public timeline shows team activity
   - Greetings create a daily log

## Technical Details

### Message Format
```json
{
  "from": "machine-name",
  "to": "target-machine",
  "body": "Good morning! ☀️ Starting a new day. Ready to build something awesome together!"
}
```

### Timeline Event
```json
{
  "machine": "machine-name",
  "event_type": "greeting",
  "title": "Good Morning! ☀️",
  "description": "machine says GM to the team",
  "icon": "☀️"
}
```

### Where Messages Go
- **Local buses**: `http://localhost:3100/send` on each machine
- **Timeline**: `https://pinky-brain-hub.b-9f2.workers.dev/timeline`

## Integration with Other Tools

### With Standup
```bash
# Morning routine
gm                          # Say GM
./standup.sh                # Show yesterday's work (when pinky builds it)
```

### With Knowledge Sharing
```bash
# Share what you learned yesterday
gm                          # Start the day
./knowledge-cli.sh          # Share insights
```

### With Training
```bash
# Learning day
gm                          # Greet the team
./train.sh                  # Level up your skills
```

## Aliases Available

- `gm` - Send and receive GM
- `gm-send` - Just send GM
- `gm-check` - Just check messages
- `pb` - cd to pinkyandbrain directory

## Future Ideas

- [ ] Add custom GM message: `gm "Extra excited today!"`
- [ ] Show who's said GM today: `gm-roster`
- [ ] Auto-GM on terminal startup
- [ ] Include weather/quote of the day
- [ ] Summary of yesterday's activity with GM

---

**Start every day right - say GM to your distributed team!** ☀️
