# Playwright MCP with Vision Capabilities Setup Guide

**Updated:** 2025-10-16
**Purpose:** Configure Playwright MCP server with vision capabilities for Claude Desktop, VS Code, Cursor, and other MCP clients

---

## Overview

Playwright MCP provides two operating modes:

1. **Snapshot Mode (Default)** - Uses accessibility tree for fast, structured interactions
2. **Vision Mode** - Uses screenshots and coordinate-based interactions for visual elements

Vision mode is useful when:
- Elements don't have proper accessibility attributes
- Visual verification is required
- Coordinate-based interactions are needed
- The accessibility tree is insufficient

---

## Installation

### Option 1: Global Installation

```bash
npm install -g @playwright/mcp
```

### Option 2: Using npx (Recommended)

No installation required - use `npx @playwright/mcp@latest` which always runs the latest version.

---

## Configuration

### For Claude Desktop

**Location:** `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--caps",
        "vision"
      ]
    }
  }
}
```

### For VS Code / Cursor

**Location:** `.vscode/mcp-settings.json` or workspace settings

```json
{
  "mcp.servers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--caps",
        "vision"
      ]
    }
  }
}
```

### Command Line Usage

```bash
# Run with vision enabled
npx @playwright/mcp@latest --caps vision

# Multiple capabilities
npx @playwright/mcp@latest --caps vision,pdf

# Alternative: Use --vision flag directly
npx @playwright/mcp@latest --vision
```

---

## Available Capabilities

The `--caps` flag accepts a comma-separated list of capabilities:

- **vision** - Enable coordinate-based interactions with screenshots
- **pdf** - Enable PDF generation capabilities
- **tabs** - Enable multi-tab management
- **history** - Enable browser history navigation
- **wait** - Enable advanced wait conditions
- **files** - Enable file upload/download
- **install** - Enable extension/plugin installation

**Examples:**

```bash
# Vision only
npx @playwright/mcp@latest --caps vision

# Vision + PDF
npx @playwright/mcp@latest --caps vision,pdf

# All capabilities
npx @playwright/mcp@latest --caps vision,pdf,tabs,history,wait,files,install
```

---

## How Vision Mode Works

### Snapshot Mode (Default)
- Requests browser's accessibility tree (structured representation)
- Faster - no screenshot processing overhead
- Works with text-based LLMs
- Uses semantic element selectors

### Vision Mode
- Captures screenshots of the page
- Requires LLM with visual capabilities (like Claude Sonnet)
- Uses coordinate-based interactions
- Fallback for complex visual elements

### Tools Available in Vision Mode

When vision is enabled, additional tools become available:

```typescript
// Screenshot tools
browser_screenshot()  // Capture viewport screenshot
browser_element_screenshot(selector)  // Screenshot specific element

// Coordinate-based interaction
browser_click_at_coordinates(x, y)  // Click at specific position
browser_move_mouse(x, y)  // Move mouse to coordinates
```

---

## Testing the Setup

### 1. Verify MCP Server is Running

In Claude Desktop or your MCP client, check that the Playwright server appears in available tools.

### 2. Test Vision Capabilities

Ask Claude to:
```
Take a screenshot of https://example.com and identify the main heading
```

If vision mode is working, Claude will:
1. Navigate to the page
2. Capture a screenshot
3. Analyze the visual content
4. Provide coordinate-based interactions if needed

### 3. Command Line Test

```bash
# Start the server manually
npx @playwright/mcp@latest --caps vision

# Server should start and display:
# ✓ Playwright MCP Server running
# ✓ Vision mode: enabled
```

---

## Troubleshooting

### Issue: Vision mode not working

**Check:**
- Ensure you're using a vision-capable LLM (Claude Sonnet, GPT-4V, etc.)
- Verify `--caps vision` is in the args array
- Restart your MCP client after config changes

### Issue: MCP server not connecting

**Solutions:**
1. Check Node.js version: `node --version` (requires Node 18+)
2. Update to latest Playwright MCP: `npx @playwright/mcp@latest`
3. Check config file syntax (valid JSON)
4. Look for errors in MCP client logs

### Issue: Screenshots not appearing

**Verify:**
- Vision capability is enabled in config
- LLM has vision capabilities
- Browser has permission to capture screens
- No headless mode restrictions

---

## Performance Considerations

### Snapshot Mode
- **Speed:** ~100-500ms per interaction
- **Accuracy:** High for well-structured pages
- **LLM Requirements:** Text-only models work fine

### Vision Mode
- **Speed:** ~1-3s per screenshot + processing
- **Accuracy:** Better for visual-heavy pages
- **LLM Requirements:** Requires vision-capable models
- **Bandwidth:** Higher due to image transfer

**Recommendation:** Use snapshot mode by default, enable vision only when needed for specific use cases.

---

## Advanced Configuration

### Custom Browser Options

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--caps",
        "vision",
        "--browser",
        "chromium",
        "--headless",
        "false"
      ]
    }
  }
}
```

### Environment Variables

```bash
# Set browser type
export PLAYWRIGHT_BROWSER=chromium

# Set headless mode
export PLAYWRIGHT_HEADLESS=false

# Then run
npx @playwright/mcp@latest --caps vision
```

### Multiple Playwright Instances

You can run multiple MCP servers with different configurations:

```json
{
  "mcpServers": {
    "playwright-vision": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--caps", "vision"]
    },
    "playwright-pdf": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--caps", "pdf"]
    },
    "playwright-all": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--caps", "vision,pdf,tabs"]
    }
  }
}
```

---

## Example Use Cases

### 1. Visual Regression Testing

```
Take a screenshot of https://funjobs-ai.b-9f2.workers.dev
Compare it with the screenshot at ~/baseline.png
Identify any visual differences
```

### 2. Coordinate-Based Interaction

```
Navigate to https://example.com
Find the "Sign Up" button visually
Click it using coordinates
```

### 3. PDF Generation with Vision

```
Navigate to https://example.com
Take a screenshot
Generate a PDF of the page
Save both outputs
```

---

## Resources

- **GitHub:** https://github.com/microsoft/playwright-mcp
- **NPM:** https://www.npmjs.com/package/@playwright/mcp
- **MCP Docs:** https://modelcontextprotocol.io
- **Playwright Docs:** https://playwright.dev

---

## Quick Reference

**Enable vision in Claude Desktop:**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--caps", "vision"]
    }
  }
}
```

**Command line:**
```bash
npx @playwright/mcp@latest --caps vision
```

**Test vision:**
```
Ask Claude: "Take a screenshot of https://example.com"
```

**Multiple capabilities:**
```bash
npx @playwright/mcp@latest --caps vision,pdf,tabs
```

---

**Status:** Production-ready as of March 2025
**Compatibility:** Works with Claude Desktop, VS Code, Cursor, and all MCP-compatible clients
**Requirements:** Node.js 18+, Vision-capable LLM for visual features
