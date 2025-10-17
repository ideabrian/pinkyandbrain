# Playwright MCP Setup Guide

**Author:** brain-claude
**Category:** Setup Guide
**Tags:** playwright, mcp, testing, visual-testing, claude-code
**Updated:** 2025-10-16

## Overview

This guide documents how to set up the official Playwright MCP server with vision capability for Claude Code. This enables browser automation, visual testing, and screenshot capabilities.

## Why Playwright MCP?

**Critical Use Case:** As the human said - "you can't see white text on white background - but for humans, that's definitely a bug."

Without visual testing, we miss UI bugs that are obvious to humans but invisible in code review.

**Capabilities:**
- Take screenshots of web pages
- Navigate and interact with browsers
- Test user flows
- Click, type, fill forms
- Extract console logs
- Save PDFs
- Validate HTTP responses

## Prerequisites

- Claude Code installed
- Node.js and npm available
- Access to `~/.claude.json` configuration file

## Installation Steps

### Step 1: Remove Old MCP Server (if exists)

If you previously installed the executeautomation version or any other Playwright MCP:

```bash
claude mcp remove playwright
```

**Output:**
```
Removed MCP server "playwright" from user config
File modified: /Users/brain/.claude.json
```

### Step 2: Add Official Playwright MCP with Vision

**Method 1: Manual Configuration (RECOMMENDED)**

Since the `claude mcp add` command doesn't support the `--caps` flag yet, manually edit the config:

```bash
# Backup current config
cp ~/.claude.json ~/.claude.json.backup

# Add Playwright MCP with vision capability using jq
cat ~/.claude.json | jq '.mcpServers.playwright = {
  "type": "stdio",
  "command": "npx",
  "args": ["@playwright/mcp@latest"],
  "capabilities": ["vision"]
}' > /tmp/claude-config-new.json && mv /tmp/claude-config-new.json ~/.claude.json
```

**Method 2: Basic Installation (without vision)**

If you don't need vision capability initially:

```bash
claude mcp add playwright npx '@playwright/mcp@latest'
```

Note: This may fail with "Cannot find module '/opt/homebrew/bin/claude'" - use Method 1 instead.

### Step 3: Verify Configuration

Check that the configuration was added correctly:

```bash
cat ~/.claude.json | jq '.mcpServers.playwright'
```

**Expected output:**
```json
{
  "type": "stdio",
  "command": "npx",
  "args": [
    "@playwright/mcp@latest"
  ],
  "capabilities": [
    "vision"
  ]
}
```

### Step 4: Verify MCP Server Status

**IMPORTANT:** You must restart Claude Code for the MCP server to activate.

After restarting, check the MCP server is connected:

```bash
claude mcp list
```

**Expected output:**
```
Checking MCP server health...

playwright: npx @playwright/mcp@latest - ✓ Connected
```

## Configuration Format

### Full Configuration Example

```json
{
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "capabilities": ["vision"]
    }
  }
}
```

### Configuration Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Transport type - use "stdio" |
| `command` | string | Command to run - "npx" for Node packages |
| `args` | array | Arguments - ["@playwright/mcp@latest"] |
| `capabilities` | array | Enable special features - ["vision"] for visual analysis |

## Available Tools

Once configured, the Playwright MCP provides these tools:

### Navigation
- `browser_navigate` - Navigate to URL
- `browser_navigate_back` - Go back in history
- `browser_navigate_forward` - Go forward in history

### Screenshots & Inspection
- `browser_take_screenshot` - Capture page or element screenshot
- `browser_snapshot` - Get page snapshot
- `browser_console_messages` - Get console logs

### Interaction
- `browser_click` - Click elements
- `browser_type` - Type text
- `browser_fill` - Fill form fields
- `browser_select_option` - Select from dropdowns
- `browser_hover` - Hover over elements
- `browser_press_key` - Keyboard input
- `browser_drag` - Drag and drop

### Tab Management
- `browser_tab_list` - List open tabs
- `browser_tab_new` - Open new tab
- `browser_tab_close` - Close tab

### Other
- `browser_file_upload` - Upload files
- `browser_pdf_save` - Save page as PDF

## Usage Examples

### Take Screenshot

Simply ask Claude:

```
Take a screenshot of https://funjobs-ai.pages.dev
```

Claude will automatically use the Playwright MCP to navigate and capture the screenshot.

### Test User Flow

```
Use Playwright MCP to:
1. Navigate to http://brain.local:5173
2. Click the "Inbox" tab
3. Take a screenshot
4. Check for any visual bugs
```

### Explicit MCP Usage

If Claude isn't using Playwright automatically, be explicit:

```
Use playwright mcp to open a browser to http://brain.local:5173
```

## Troubleshooting

### Issue: MCP Server Not Connected

**Symptom:**
```bash
claude mcp list
# Shows: playwright - ✗ Not Connected
```

**Solution:**
1. Verify configuration exists: `cat ~/.claude.json | jq '.mcpServers.playwright'`
2. Restart Claude Code completely
3. Check for errors in Claude Code startup

### Issue: Cannot Find Module Error

**Symptom:**
```
Error: Cannot find module '/opt/homebrew/bin/claude'
```

**Solution:**
This is a known issue with `claude mcp add` command. Use the manual jq method instead (Method 1 above).

### Issue: Tools Not Available

**Symptom:**
Claude doesn't have access to Playwright tools even though MCP is connected.

**Solution:**
1. Ensure you restarted Claude Code after configuration
2. Check `claude mcp list` shows "✓ Connected"
3. Try being explicit: "Use playwright mcp to..."

### Issue: Vision Not Working

**Symptom:**
Screenshots taken but visual analysis not happening.

**Solution:**
Verify `capabilities: ["vision"]` is in your config:
```bash
cat ~/.claude.json | jq '.mcpServers.playwright.capabilities'
# Should output: ["vision"]
```

## Differences: Claude Code vs Claude Desktop

**Claude Code Configuration:**
- File: `~/.claude.json`
- Format: Same as shown above
- Command: `claude mcp add`

**Claude Desktop Configuration:**
- File: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Format: Same JSON structure
- Command: Manual edit only

**Important:** This guide is for Claude Code. Don't confuse the two!

## Vision Capability

The `"capabilities": ["vision"]` flag enables visual analysis of screenshots:

**Without Vision:**
- Takes screenshot
- Returns image file path
- No analysis

**With Vision:**
- Takes screenshot
- Claude can "see" the image
- Analyze visual bugs
- Detect layout issues
- Read text in images
- Identify UI problems

**Example Use Case:**
```
Take a screenshot of the Decision Queue and check for:
- White text on white backgrounds
- Overlapping elements
- Alignment issues
- Color contrast problems
```

## Testing the Installation

After setup and restart, test with:

```bash
# 1. Verify connection
claude mcp list

# 2. Test with a simple screenshot
# In Claude Code session, say:
"Use Playwright to take a screenshot of http://example.com"

# 3. Check screenshot was saved
ls -la .playwright-mcp/
```

## Screenshots Storage

By default, screenshots are saved to:
```
.playwright-mcp/
```

In the directory where Claude Code is running.

## Best Practices

1. **Always Use Vision:** Include `"capabilities": ["vision"]` for full functionality
2. **Be Explicit:** Say "Use Playwright MCP" to ensure correct tool selection
3. **Test Locally First:** Test on local URLs before production sites
4. **Backup Config:** Always backup `~/.claude.json` before editing
5. **Restart After Changes:** MCP changes require Claude Code restart

## Integration with Team Workflow

### For Testing Pinky's Projects

When Pinky finishes a project (like FunJobs.ai):

1. Get GitHub repo URL from Pinky
2. Fork the repo
3. Clone locally or navigate to deployed URL
4. Use Playwright to test visually
5. Document bugs found
6. Create pull requests with fixes

### For Decision Queue Testing

```
Use Playwright MCP to:
1. Navigate to http://brain.local:5173
2. Click "Inbox" tab
3. Take screenshot
4. Check urgency colors are visible
5. Test APPROVE/EDIT/DECLINE buttons
6. Verify no white-on-white text issues
```

## Related Documentation

- [HOW-TO-SEND-A-MESSAGE.md](/Users/brain/message-manager/HOW-TO-SEND-A-MESSAGE.md) - Team communication
- [SYSTEM-CONTEXT.md](/Users/brain/message-manager/SYSTEM-CONTEXT.md) - Cluster architecture
- [HANDOFF.md](/Users/brain/message-manager/HANDOFF.md) - Session continuity

## Resources

- Official Playwright MCP: https://github.com/microsoft/playwright-mcp
- Simon Willison's TIL: https://til.simonwillison.net/claude-code/playwright-mcp-claude-code
- Playwright Docs: https://playwright.dev/
- MCP Servers List: https://mcpservers.org/servers/executeautomation/mcp-playwright

## Quick Reference

```bash
# Install (manual method)
cat ~/.claude.json | jq '.mcpServers.playwright = {
  "type": "stdio",
  "command": "npx",
  "args": ["@playwright/mcp@latest"],
  "capabilities": ["vision"]
}' > /tmp/claude-new.json && mv /tmp/claude-new.json ~/.claude.json

# Verify
cat ~/.claude.json | jq '.mcpServers.playwright'

# Check status (after restart)
claude mcp list

# Remove
claude mcp remove playwright
```

## Version History

- **2025-10-16:** Initial documentation by brain-claude
- Configuration verified working on macOS with Claude Code

## Notes

- This is the **official** @playwright/mcp package, not executeautomation's version
- Vision capability is critical for catching visual bugs
- Requires restart to activate
- May take a few seconds to connect on first use (npx downloads package)
