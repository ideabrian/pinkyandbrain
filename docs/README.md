# PinkyAndBrain Documentation Library

**Location:** `~/pinkyandbrain/docs/`
**Synced with:** GitHub
**Purpose:** Centralized documentation for the entire cluster

## Overview

This is the single source of truth for all documentation across the PinkyAndBrain cluster. Instead of scattered HANDOFF.md and README files in each project, all documentation lives here.

## Directory Structure

```
~/pinkyandbrain/docs/
├── README.md           # This file
├── system/             # System architecture & infrastructure
├── guides/             # How-to guides & tutorials
├── projects/           # Project-specific documentation
└── api/                # API documentation & references
```

## Current Documentation

### Guides
- **[Playwright MCP Setup](guides/playwright-mcp-setup.md)** - Complete guide to installing and using Playwright MCP with vision capability for visual testing

### System
- Coming soon: Architecture diagrams, cluster setup, message bus docs

### Projects
- Coming soon: Message Manager, Knowledge Viewer, Train The Humans AI

### API
- Coming soon: Message Bus API, Decision Queue API, Knowledge Base API

## Documentation Standards

All documentation should include frontmatter with:
- **Author:** Who created it (brain-claude, pinky-claude, etc.)
- **Category:** Type of document (Setup Guide, Architecture, Tutorial, etc.)
- **Tags:** Searchable keywords
- **Updated:** Last update date

**Example:**
```markdown
# Document Title

**Author:** brain-claude
**Category:** Setup Guide
**Tags:** playwright, mcp, testing
**Updated:** 2025-10-16

## Content starts here...
```

## Finding Documentation

### Search by Keyword
```bash
grep -r "playwright" ~/pinkyandbrain/docs/
```

### List All Docs
```bash
find ~/pinkyandbrain/docs/ -name "*.md" -type f
```

### Browse by Category
```bash
ls -la ~/pinkyandbrain/docs/guides/
ls -la ~/pinkyandbrain/docs/system/
ls -la ~/pinkyandbrain/docs/projects/
ls -la ~/pinkyandbrain/docs/api/
```

## Adding Documentation

### 1. Choose the Right Directory

- **guides/** - How-to, setup instructions, tutorials
- **system/** - Architecture, infrastructure, core systems
- **projects/** - Project-specific docs (Message Manager, etc.)
- **api/** - API specifications, endpoint documentation

### 2. Use Descriptive Filenames

```bash
# Good
playwright-mcp-setup.md
message-bus-api.md
train-the-humans-architecture.md

# Bad
setup.md
api.md
docs.md
```

### 3. Include Frontmatter

Always start with author, category, tags, and date.

### 4. Link to Related Docs

Reference other documentation when relevant:
```markdown
See also: [Message Bus API](../api/message-bus-api.md)
```

## Migration from Old Docs

The following files need to be migrated to this structure:

### From Message Manager Project
- [ ] `/Users/brain/message-manager/HANDOFF.md` → `system/handoff-pattern.md`
- [ ] `/Users/brain/message-manager/SYSTEM-CONTEXT.md` → `system/architecture.md`
- [ ] `/Users/brain/message-manager/HOW-TO-SEND-A-MESSAGE.md` → `guides/how-to-send-message.md`

### From Other Projects
- [ ] Knowledge Base documentation
- [ ] Pinky's AUTO-LAUNCH-GUIDE.md
- [ ] Pinky's TTY-LIMITATION.md
- [ ] Max's webhook specs

## CLI Tool (Future)

Planned CLI for easier documentation management:

```bash
# Add new doc
./docs.sh add guides "How to Test with Playwright" --tags testing,playwright

# Search docs
./docs.sh search "message bus"

# List all docs
./docs.sh list

# Update existing doc
./docs.sh update guides/playwright-mcp-setup.md
```

## Web UI (Future)

Planned web interface for browsing documentation:
- URL: http://brain.local:5175
- Features: Search, categories, tags, markdown rendering
- Similar to Knowledge Viewer but for docs

## GitHub Sync

All documentation is synced with GitHub for:
- Version control
- Team collaboration
- Backup
- Public sharing (if needed)

## Best Practices

1. **Document as you go** - Create docs immediately after discoveries
2. **Update dates** - Always update the "Updated" field when editing
3. **Use examples** - Show code examples, not just descriptions
4. **Link generously** - Reference related docs
5. **Keep it current** - Remove outdated information
6. **Test instructions** - Verify setup guides actually work
7. **Tag thoroughly** - Use multiple tags for discoverability

## Why This Exists

**Problem:**
- Each project had its own HANDOFF.md, SYSTEM-CONTEXT.md, README.md
- No discoverability - hard to find "how do I X?"
- No shared format or location
- Documentation fragmentation across the cluster

**Solution:**
- Single location: `~/pinkyandbrain/docs/`
- Organized structure (system, guides, projects, api)
- Consistent format with frontmatter
- Synced with GitHub
- Searchable and linkable

## Team Usage

### Brain (brain-claude)
- Documents UI/UX patterns
- Product vision documentation
- Integration guides

### Pinky (pinky-claude)
- System architecture docs
- Autonomous operation guides
- Technical deep-dives

### Max (maxyolo-claude)
- Infrastructure docs
- API specifications
- Deployment guides

## Contributing

1. Choose appropriate directory
2. Create markdown file with frontmatter
3. Write clear, concise documentation with examples
4. Link to related docs
5. Commit to GitHub with descriptive message

## Quick Start

```bash
# Navigate to docs
cd ~/pinkyandbrain/docs/

# Create new guide
cat > guides/my-new-guide.md << 'EOF'
# My New Guide

**Author:** brain-claude
**Category:** Tutorial
**Tags:** example
**Updated:** 2025-10-16

## Content here...
EOF

# View all guides
ls -la guides/

# Search for content
grep -r "search term" .
```

## Next Steps

1. Migrate existing documentation from projects
2. Build CLI tool for easier management
3. Create web UI for browsing
4. Set up GitHub sync workflow
5. Create templates for common doc types

## Contact

Questions or suggestions? Send a message via the message bus:

```bash
curl -X POST http://localhost:3100/send -H "Content-Type: application/json" -d "$(cat <<'EOF'
{
  "to": "brain-claude",
  "from": "your-name",
  "subject": "Docs Library Question",
  "body": "Your question here...",
  "priority": "normal"
}
EOF
)"
```
