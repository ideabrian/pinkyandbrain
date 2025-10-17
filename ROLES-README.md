# 🎭 Pinky & Brain Roles on Maxyolo

You can now run as **brain** or **pinky** on your maxyolo machine!

## Quick Start

### Run as Brain (Planner)
```bash
cd ~/pinkyandbrain
./run-as-brain.sh
```

This starts you in **brain mode**:
- 🧠 You are the strategic planner
- 📋 You analyze requests and create plans
- 📨 You delegate to Pinky for implementation
- 💡 You share knowledge and insights

### Run as Pinky (Executor)
```bash
cd ~/pinkyandbrain
./run-as-pinky.sh
```

This starts you in **pinky mode**:
- 💖 You are the executor
- 🔨 You implement Brain's plans
- ✅ You test and deliver quality code
- 📊 You report completion to Maxyolo

### Run as Maxyolo (Reviewer)
```bash
cd ~/pinkyandbrain
./cloud-poller.sh maxyolo
```

This is your default role:
- 🎮 You review and approve work
- 🚀 You orchestrate the workflow
- 📚 You curate team knowledge
- ✨ You make final decisions

## How It Works

1. **Messages arrive** from cloud or local bus
2. **Role-specific prompt** is loaded
3. **Context is created** with the message + your role
4. **Cloud poller watches** for new messages to your role
5. **You respond** according to your role's responsibilities

## File Structure

```
~/pinkyandbrain/
├── roles/
│   ├── brain/     # Brain's workspace
│   └── pinky/     # Pinky's workspace
├── prompts/
│   ├── brain-prompt.md    # Brain's role definition
│   ├── pinky-prompt.md    # Pinky's role definition
│   └── maxyolo-prompt.md  # Your role definition
├── run-as-brain.sh   # Start as Brain
├── run-as-pinky.sh   # Start as Pinky
└── cloud-poller.sh   # Core polling script
```

## Example Workflow

### As Brain:
```bash
./run-as-brain.sh
# Wait for incoming request...
# Analyze it, create a plan
# Send plan to Pinky via cloud bus
```

### As Pinky:
```bash
./run-as-pinky.sh
# Wait for Brain's plan...
# Implement the code
# Test thoroughly
# Report completion to Maxyolo
```

### As Maxyolo:
```bash
./cloud-poller.sh maxyolo
# Wait for Pinky's completion...
# Review the work
# Approve or request changes
# Deploy if approved
```

## Logs

- Brain: `~/pinkyandbrain/cloud-poller-brain-local.log`
- Pinky: `~/pinkyandbrain/cloud-poller-pinky-local.log`
- Maxyolo: `~/pinkyandbrain/cloud-poller-maxyolo.log`

View logs:
```bash
tail -f ~/pinkyandbrain/cloud-poller-brain-local.log
```

## Stop a Role

```bash
# Stop brain
pkill -f 'cloud-poller.sh brain'

# Stop pinky
pkill -f 'cloud-poller.sh pinky'

# Stop maxyolo
pkill -f 'cloud-poller.sh maxyolo'
```

## Send Messages Between Roles

```bash
# Brain sends to Pinky
curl -X POST https://pinky-brain-hub.b-9f2.workers.dev/timeline \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $CLOUD_API_KEY" \
  -d '{
    "machine": "brain",
    "event_type": "planning",
    "title": "Created implementation plan",
    "description": "Plan for counter component"
  }'
```

## Tips

1. **One role at a time** - Only run one role poller at a time
2. **Check logs** - Use `tail -f` to monitor activity
3. **Know your role** - Read your prompt file to understand responsibilities
4. **Communicate** - Post timeline events to show progress
5. **Share knowledge** - Use knowledge-cli.sh to share learnings

---

**Now you can be Brain, Pinky, or Maxyolo - all on one machine!** 🎭
