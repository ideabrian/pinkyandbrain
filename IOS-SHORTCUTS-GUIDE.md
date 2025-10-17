# iOS Shortcuts - Autonomous Workflow Trigger

**Trigger your 3-machine autonomous development team from your iPhone!**

---

## Quick Start

**URL to hit from iPhone**:
```
http://192.168.5.76:3100/build
```

**Method**: POST
**Body**: JSON

---

## iOS Shortcut Setup

### Step 1: Create New Shortcut

1. Open **Shortcuts** app on iPhone
2. Tap **+** to create new shortcut
3. Name it: **"Build with Pinky & Brain"**

### Step 2: Add Actions

**Action 1: Ask for Input**
- Search for "Ask for Input"
- Prompt: "What do you want to build?"
- Input Type: Text
- Default Answer: (leave blank)

**Action 2: Get Contents of URL**
- Search for "Get Contents of URL"
- URL: `http://192.168.5.76:3100/build`
- Method: POST
- Headers:
  - `Content-Type`: `application/json`
- Request Body: JSON
  ```json
  {
    "idea": "Provided Input",
    "description": "",
    "priority": "normal"
  }
  ```

  **Note**: Replace "Provided Input" with the variable from Step 1

**Action 3: Show Result**
- Search for "Show Result"
- Text: Contents of URL

### Step 3: Test It

1. Run the shortcut
2. Type: "Build me a button component"
3. Tap Done
4. You should see JSON response with workflowId

---

## Detailed Configuration

### Request Body Fields

```json
{
  "idea": "Required - Your feature request",
  "description": "Optional - Extra details",
  "priority": "Optional - normal, high, or low"
}
```

**Examples**:

```json
{
  "idea": "Build me a todo list component"
}
```

```json
{
  "idea": "Create a user authentication form",
  "description": "Include email, password, and remember me checkbox",
  "priority": "high"
}
```

```json
{
  "idea": "Make a responsive navigation bar",
  "description": "Mobile menu, logo, and 5 nav links"
}
```

### Response Format

```json
{
  "success": true,
  "workflowId": "workflow-1760576344782",
  "message": "Workflow started! Your autonomous team is building it now.",
  "status": "sent_to_brain",
  "idea": "Build me a user profile card component",
  "trackingUrl": "http://max.local:3100/workflow/workflow-1760576344782",
  "tip": "Pollers will pick this up and start working automatically"
}
```

### Track Workflow Status

**Endpoint**: `GET /workflow/:workflowId`

**Example**:
```
http://192.168.5.76:3100/workflow/workflow-1760576344782
```

**Response**:
```json
{
  "workflowId": "workflow-1760576344782",
  "status": "planning",
  "messages": 1,
  "timeline": [
    {
      "from": "ios-shortcut",
      "to": "brain",
      "subject": "New Build Request from iPhone",
      "timestamp": "2025-10-16T00:59:04.782Z",
      "read": false
    }
  ],
  "lastUpdate": "2025-10-16T00:59:04.782Z"
}
```

**Status Values**:
- `planning` - Brain is creating the spec
- `implementing` - Pinky is writing the code
- `reviewing` - Maxyolo is testing and integrating
- `unknown` - Can't determine status

---

## Advanced Shortcuts

### Shortcut 1: Build & Track

**Flow**:
1. Ask for idea
2. POST to /build
3. Extract workflowId from response
4. Wait 30 seconds
5. GET /workflow/:workflowId
6. Show status

### Shortcut 2: Quick Build (No Input)

**Preset ideas**:
- "Build me a button component"
- "Create a card component"
- "Make a modal dialog"

Use **Choose from Menu** action to select predefined ideas.

### Shortcut 3: Build with Voice

1. Dictate text
2. POST to /build with dictated text
3. Show confirmation

---

## Network Requirements

### On Same WiFi

**Your iPhone must be on the same WiFi network as your MacBook (maxyolo)**.

**Network**: Home WiFi
**maxyolo IP**: 192.168.5.76
**Port**: 3100

### Check Connection

Test from Safari on iPhone:
```
http://192.168.5.76:3100/health
```

You should see:
```json
{
  "status": "ok",
  "machine": "max.local",
  "messages": 2,
  "timestamp": "2025-10-16T00:59:04.782Z"
}
```

### Troubleshooting

**Problem**: "Could not connect to the server"

**Solutions**:
1. Verify iPhone on same WiFi network
2. Check message bus is running:
   ```bash
   ps aux | grep claude-messenger
   ```
3. Restart message bus:
   ```bash
   pkill -f claude-messenger
   cd ~/pinkyandbrain
   node claude-messenger.js &
   ```
4. Check firewall settings (macOS System Settings → Network → Firewall)

---

## Example Workflows

### Example 1: Morning Build Session

**iPhone at 8am**:
```
"Build me a dashboard component with charts"
```

**Result**: When you get to your desk, the component is ready to review.

### Example 2: Idea While Commuting

**iPhone on train**:
```
"Create an email subscription form with validation"
```

**Result**: By the time you're home, it's built and tested.

### Example 3: Weekend Project Kickoff

**iPhone on Saturday morning**:
```
"Build a complete blog post editor with markdown support"
```

**Result**: Autonomous team builds it while you enjoy your weekend.

---

## API Reference

### POST /build

**Purpose**: Trigger autonomous workflow

**URL**: `http://192.168.5.76:3100/build`

**Method**: POST

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "idea": "string (required)",
  "description": "string (optional)",
  "priority": "normal|high|low (optional)"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "workflowId": "string",
  "message": "string",
  "status": "sent_to_brain",
  "idea": "string",
  "trackingUrl": "string",
  "tip": "string"
}
```

**Response (400 Bad Request)**:
```json
{
  "error": "Missing required field: idea",
  "example": {
    "idea": "Build me a todo list component",
    "description": "Optional extra details",
    "priority": "normal"
  }
}
```

### GET /workflow/:workflowId

**Purpose**: Check workflow status

**URL**: `http://192.168.5.76:3100/workflow/:workflowId`

**Method**: GET

**Response (200 OK)**:
```json
{
  "workflowId": "string",
  "status": "planning|implementing|reviewing|unknown",
  "messages": number,
  "timeline": [
    {
      "from": "string",
      "to": "string",
      "subject": "string",
      "timestamp": "ISO 8601 string",
      "read": boolean
    }
  ],
  "lastUpdate": "ISO 8601 string"
}
```

**Response (404 Not Found)**:
```json
{
  "error": "Workflow not found",
  "workflowId": "string"
}
```

---

## Tips & Best Practices

### 1. Be Specific
**Good**: "Build a user profile card with avatar, name, bio, and social links"
**Bad**: "Make a card"

### 2. Include Context
**Good**: "Create a login form with email validation and password strength indicator"
**Bad**: "Login form"

### 3. Use Description Field
```json
{
  "idea": "Build a todo list",
  "description": "Include add, delete, mark complete, and filter by status. Use TypeScript and React hooks."
}
```

### 4. Set Priority
- `high` - Brain prioritizes this
- `normal` - Standard workflow
- `low` - Background task

### 5. Track Your Workflows
Save workflowId from response to check status later.

---

## Advanced: Siri Integration

**Enable Siri for shortcut**:
1. Tap (•••) on shortcut
2. Scroll down to "Siri"
3. Add to Siri
4. Record phrase: "Build with Pinky and Brain"

**Usage**:
```
"Hey Siri, Build with Pinky and Brain"
[Siri asks what to build]
"Build me a button component"
[Workflow triggered]
```

---

## What Happens After You Trigger

**Timeline** (approximately):

```
0s    - POST /build → Message sent to brain
5s    - brain's poller detects message
10s   - brain (Claude Code) starts planning
2min  - brain sends spec to pinky
2min  - pinky's poller detects message
5s    - pinky (Claude Code) starts implementing
5min  - pinky sends code to maxyolo
5min  - maxyolo's poller detects message
10s   - maxyolo (Claude Code) reviews and integrates
2min  - maxyolo completes review

Total: ~15 minutes for simple component
```

**You get**:
- Fully implemented component
- TypeScript with proper types
- React best practices
- Tested and ready to use

---

## Monitoring from iPhone

### Option 1: Safari Bookmark

Bookmark: `http://192.168.5.76:3100/inbox`

**Shows**: All messages in the cluster

### Option 2: Create Status Shortcut

1. GET `http://192.168.5.76:3100/inbox/unread`
2. Parse JSON
3. Show unread count

### Option 3: Use Tracking URL

The /build response includes `trackingUrl`. Copy and paste into Safari to watch progress.

---

## Security Notes

**This setup is for local network only**:
- ✅ Works on home WiFi
- ❌ Does NOT work from cellular/LTE
- ❌ Does NOT work from outside network

**To enable remote access** (advanced):
1. Set up VPN to home network
2. Or use ngrok/Tailscale for secure tunnel
3. Or set up port forwarding (not recommended)

---

## Next Steps

1. **Create your first shortcut** (5 minutes)
2. **Test with a simple idea** (1 minute)
3. **Check workflow status** (30 seconds)
4. **Wait for pollers to process** (~15 minutes)
5. **Review the output** on your Mac

---

## Troubleshooting Guide

### "Could not connect to server"
- Check WiFi connection (same network as Mac)
- Verify message bus running: `ps aux | grep claude-messenger`
- Test URL in Safari: `http://192.168.5.76:3100/health`

### "Missing required field: idea"
- Make sure Request Body format is correct
- Verify Content-Type header is `application/json`
- Check "idea" field is included in JSON

### "Workflow not found"
- Double-check workflowId is correct
- Message may have been cleared from bus
- Check `/inbox` endpoint to see all messages

### Pollers not processing
- Verify pollers are running:
  ```bash
  ./run-on-all.sh "pgrep -fl message-poller"
  ```
- Restart pollers:
  ```bash
  ./run-on-all.sh "pkill -f message-poller"
  workflow "test request"
  ```

---

## File Reference

**Message Bus**: `~/pinkyandbrain/claude-messenger.js`
**Endpoints**: Lines 189-289 (iOS Shortcuts integration)

**Key Functions**:
- `POST /build` → Triggers workflow
- `GET /workflow/:id` → Tracks status

---

**Status**: ✅ Ready to use
**Network**: Local WiFi only
**Response Time**: ~15 minutes for simple components

**Go build something!** 📱→🧠⚡→✨

---

**Created**: 2025-10-16
**Last Updated**: 2025-10-16
