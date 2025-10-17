# File-Based Agent Architecture

**Date**: October 16, 2025
**Author**: Pinky
**Reviewer**: Max
**Status**: 🧪 Prototype Complete, Ready for Testing

## Overview

A novel approach to AI agent coordination that uses the filesystem as the single source of truth. Instead of complex databases or state management systems, each agent has a dedicated folder with markdown files defining their persona, context, and task queue.

## Core Philosophy

**"The filesystem IS the database"**

- No complex state management
- No databases to maintain
- Just files, folders, and git
- Inspectable, debuggable, versioned

## Architecture

```
~/agents/
│
├── launch-agent.sh              # Universal agent launcher
├── README.md                    # Architecture overview
├── DEMO-WALKTHROUGH.md          # Step-by-step tutorial
├── QUICK-START.txt              # Quick reference
│
├── frontend-expert/             # Agent 1: React/TypeScript specialist
│   ├── PERSONA.md               # Who they are, what they do
│   ├── CONTEXT.md               # Current project state
│   ├── CONTEXT-TEMPLATE.md      # Structure for updates
│   ├── .lock                    # Lock file (when working)
│   └── tasks/                   # Task queue
│       ├── 1760680001-improve-upload-page.md
│       ├── 1760680050-add-validation.md
│       └── completed/           # Completed tasks archive
│           └── 1760679900-fix-styling.md
│
├── backend-expert/              # Agent 2: API/Database specialist
│   ├── PERSONA.md
│   ├── CONTEXT.md
│   ├── CONTEXT-TEMPLATE.md
│   └── tasks/
│       └── completed/
│
└── devops-expert/               # Agent 3: Deployment specialist
    ├── PERSONA.md
    ├── CONTEXT.md
    ├── CONTEXT-TEMPLATE.md
    └── tasks/
        └── completed/
```

## Components

### 1. PERSONA.md

**Purpose**: Defines the agent's identity, expertise, and capabilities

**Structure**:
```markdown
# Agent Persona: Frontend Expert

## Identity
- **Name**: Frontend Expert
- **Role**: React & TypeScript Specialist
- **Machine**: pinky.local

## Expertise
- React (functional components, hooks, modern patterns)
- TypeScript (strict typing, advanced types)
- Tailwind CSS (utility-first styling)
- Vite (build tooling, dev server)
- Component architecture

## Responsibilities
1. Build React components based on specifications
2. Implement TypeScript interfaces and types
3. Style components with Tailwind CSS
4. Ensure accessibility and responsive design
5. Write clean, maintainable code

## Working Style
- Read CONTEXT.md before every task
- Update CONTEXT.md after completing work
- Move completed tasks to tasks/completed/
- Commit changes with descriptive messages
- Communicate via message bus

## Limitations
- Does NOT work on backend/API code
- Does NOT modify database schemas
- Does NOT handle deployment
- Focuses solely on frontend implementation

## Communication
- **Send completion notices to**: maxyolo (reviewer)
- **Escalate blockers to**: brain (planner)
- **Coordinate conflicts with**: backend-expert
```

### 2. CONTEXT.md

**Purpose**: Maintains current project state, recent changes, and active work

**Structure**:
```markdown
# Context: Frontend Expert

## Current Status
- **Working on**: tasks/1760680001-improve-upload-page.md
- **Files locked**: client/pages/UploadJob.tsx, client/components/JobImageUpload.tsx
- **Started**: 2025-10-16T23:00:00.000Z
- **Expected completion**: 2025-10-16T23:30:00.000Z

## Project: FunJobs.ai

### Current Architecture
- **Frontend**: React + TypeScript + Vite
- **Styling**: Tailwind CSS
- **Routing**: React Router v6
- **State**: React hooks (no Redux)
- **API**: Cloudflare Workers backend
- **Deployment**: Cloudflare Pages

### Recent Changes (Last 5 Tasks)
1. ✅ **2025-10-16 22:45** - Added DevMod debugging UI (tasks/completed/...)
2. ✅ **2025-10-16 21:30** - Created JobImageUpload component
3. ✅ **2025-10-16 20:15** - Added /upload route to App.tsx
4. ✅ **2025-10-16 19:00** - Updated Header with Upload button
5. ✅ **2025-10-16 18:00** - Configured environment-based API_BASE_URL

### Current File Structure
```
client/
├── components/
│   ├── DevMod.tsx
│   ├── Header.tsx
│   ├── Footer.tsx
│   └── JobImageUpload.tsx
├── pages/
│   ├── Home.tsx
│   ├── UploadJob.tsx
│   └── WorkerDetail.tsx
├── lib/
│   └── api.ts
├── config.ts
└── App.tsx
```

### Known Issues
- Upload page needs better error handling
- DevMod should show request headers
- Need to add loading states to JobImageUpload

### Technical Debt
- Some components still use direct fetch() instead of apiFetch()
- Missing TypeScript types for job data
- No unit tests yet

### Integration Points
- **Backend API**: https://funjobs-ai.b-9f2.workers.dev
- **Dev API**: http://localhost:8787
- **Message Bus**: http://localhost:3100

### Dependencies
- react: ^18.2.0
- react-router-dom: ^6.20.0
- tailwindcss: ^3.4.0
- typescript: ^5.3.0
- vite: ^5.0.0

## Notes
- DevMod only shows in development mode
- All components must be responsive
- Follow existing Tailwind styling patterns
- Use apiFetch() wrapper for all API calls
```

### 3. CONTEXT-TEMPLATE.md

**Purpose**: Standardized structure for updating CONTEXT.md

```markdown
# Context Update Template

## When to Update
- After completing each task
- When discovering new technical debt
- When architecture changes
- When dependencies are added/updated

## Sections to Update

### Current Status
```
- Working on: [task file name]
- Files locked: [comma-separated list]
- Started: [ISO timestamp]
- Expected completion: [ISO timestamp]
```

### Recent Changes
Add new entry at the top, keep only last 5:
```
✅ YYYY-MM-DD HH:MM - [Brief description] (tasks/completed/...)
```

### Known Issues
Add new issues as discovered:
```
- [Description of issue]
```

### Technical Debt
Add items that need future attention:
```
- [Description of debt]
```

## Cleanup
- Remove stale "Working on" entries
- Archive old completed tasks (keep last 10)
- Update file structure if changed
- Remove resolved known issues
```

### 4. tasks/ Folder

**Purpose**: Queue of work to be done

**Task File Format** (`tasks/1760680001-improve-upload-page.md`):
```markdown
# Task: Improve Upload Page

**Created**: 2025-10-16T23:00:00.000Z
**Priority**: high
**Assigned**: frontend-expert
**From**: maxyolo

## Description
The upload page (UploadJob.tsx) needs better UX and error handling.

## Requirements
1. Add loading spinner during upload
2. Show progress indicator
3. Display clear error messages
4. Add drag-and-drop visual feedback
5. Show file size limit

## Acceptance Criteria
- [ ] Loading spinner shows during upload
- [ ] Progress bar shows upload progress
- [ ] Error messages are user-friendly
- [ ] Drag-and-drop has hover state
- [ ] File size limit clearly displayed

## Technical Notes
- Use existing JobImageUpload component
- Follow Tailwind patterns from other components
- Use apiFetch() for API calls
- Update CONTEXT.md when complete

## Files to Modify
- client/components/JobImageUpload.tsx
- client/pages/UploadJob.tsx (if needed)

## Testing
- Test with various file sizes
- Test error scenarios (network failure, invalid file)
- Test drag-and-drop interaction
- Verify mobile responsive
```

### 5. launch-agent.sh

**Purpose**: Universal launcher that combines persona + context + task

```bash
#!/bin/bash
# launch-agent.sh - Launch an agent to work on their tasks
# Usage: ./launch-agent.sh <agent-name>

set -e

AGENT=${1:-""}
AGENTS_DIR="$HOME/agents"

if [ -z "$AGENT" ]; then
  echo "Usage: $0 <agent-name>"
  echo ""
  echo "Available agents:"
  ls -1 "$AGENTS_DIR" | grep -v ".sh\|.md\|.txt"
  exit 1
fi

AGENT_DIR="$AGENTS_DIR/$AGENT"

if [ ! -d "$AGENT_DIR" ]; then
  echo "Error: Agent not found: $AGENT"
  exit 1
fi

# Check if agent is already working (lock file exists and is recent)
LOCK_FILE="$AGENT_DIR/.lock"
if [ -f "$LOCK_FILE" ]; then
  LOCK_AGE=$(($(date +%s) - $(stat -f %m "$LOCK_FILE" 2>/dev/null || stat -c %Y "$LOCK_FILE")))
  if [ $LOCK_AGE -lt 1800 ]; then  # 30 minutes
    echo "Warning: $AGENT appears to be working (lock age: ${LOCK_AGE}s)"
    echo "Continue anyway? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
      exit 1
    fi
  fi
fi

# Create lock file
date +%s > "$LOCK_FILE"

# Find next task
NEXT_TASK=$(ls -1 "$AGENT_DIR/tasks/" 2>/dev/null | grep -v "completed" | head -1)

if [ -z "$NEXT_TASK" ]; then
  echo "No pending tasks for $AGENT"
  rm "$LOCK_FILE"
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Launching: $AGENT"
echo "📋 Task: $NEXT_TASK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Prepare combined context
CONTEXT_FILE="/tmp/agent-context-$AGENT-$(date +%s).md"

cat > "$CONTEXT_FILE" <<EOF
# Agent Launch

$(cat "$AGENT_DIR/PERSONA.md")

---

$(cat "$AGENT_DIR/CONTEXT.md")

---

# Your Task

$(cat "$AGENT_DIR/tasks/$NEXT_TASK")

---

## Instructions

1. Read the above persona, context, and task carefully
2. Implement the requested changes
3. Test your work
4. Update CONTEXT.md with:
   - Add task to "Recent Changes" section
   - Remove from "Current Status"
   - Update any relevant sections
5. Move task file to tasks/completed/
6. Remove .lock file
7. Send completion notice via message bus

## Post-Completion

When done, send message to maxyolo:
\`\`\`bash
curl -X POST http://localhost:3100/send \\
  -H "Content-Type: application/json" \\
  -d '{
    "from": "$AGENT",
    "to": "maxyolo",
    "subject": "Task Complete: $NEXT_TASK",
    "body": "Completed task. Files modified: [list]. See commit: [sha]"
  }'
\`\`\`
EOF

# Launch Claude Code with the context
cd "$AGENT_DIR"
claude -p "You are $AGENT. Process the task described in the context." < "$CONTEXT_FILE"

# Cleanup
rm "$LOCK_FILE" 2>/dev/null || true
echo "✅ Agent session complete"
```

## Integration with Autonomous Messaging

### Current Flow
1. Message arrives for specific agent (e.g., "frontend-expert")
2. cloud-poller detects message
3. Creates task file in `~/agents/frontend-expert/tasks/`
4. Launches `launch-agent.sh frontend-expert`
5. Agent processes task with full context
6. Agent commits work
7. Agent updates CONTEXT.md
8. Agent moves task to completed/
9. Agent sends response via message bus

### Enhanced cloud-poller Integration

```bash
# In cloud-poller.sh
AGENT_NAMES=("frontend-expert" "backend-expert" "devops-expert")

if [[ " ${AGENT_NAMES[@]} " =~ " ${MESSAGE_TO} " ]]; then
  # This message is for an agent!

  # Create task file
  TASK_ID=$(date +%s)
  TASK_FILE="$HOME/agents/$MESSAGE_TO/tasks/$TASK_ID-$(echo $MESSAGE_SUBJECT | tr ' ' '-').md"

  cat > "$TASK_FILE" <<EOF
# Task: $MESSAGE_SUBJECT

**Created**: $(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
**Priority**: normal
**Assigned**: $MESSAGE_TO
**From**: $MESSAGE_FROM

## Description

$MESSAGE_BODY

## Instructions
Process this task according to your persona and current context.
Update CONTEXT.md when complete.
Send response to $MESSAGE_FROM.
EOF

  # Launch agent
  ~/agents/launch-agent.sh "$MESSAGE_TO"
else
  # Regular message processing with role prompts
  # ... existing code ...
fi
```

## Coordination Mechanisms

### 1. Lock Files
**Purpose**: Prevent conflicts when agents work on same files

```bash
# Check lock before working
if [ -f ~/agents/frontend-expert/.lock ]; then
  echo "Frontend expert is currently working"
  exit 1
fi

# Create lock when starting
date +%s > ~/agents/frontend-expert/.lock

# Remove lock when done
rm ~/agents/frontend-expert/.lock
```

### 2. Status Broadcasting
**Purpose**: Let other agents know what you're working on

```bash
# Broadcast start of work
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "frontend-expert",
    "to": "all",
    "subject": "Status: Working",
    "body": "Starting task: improve-upload-page. Locking: JobImageUpload.tsx, UploadJob.tsx"
  }'

# Broadcast completion
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "frontend-expert",
    "to": "all",
    "subject": "Status: Complete",
    "body": "Completed task: improve-upload-page. Released locks. Commit: abc123"
  }'
```

### 3. Conflict Resolution
**Purpose**: Handle cases where agents need to modify same files

```markdown
## Conflict Resolution Protocol

1. **Check CONTEXT.md of other agents** before starting work
2. **Send coordination message** if you need to modify files another agent is using
3. **Wait for response** before proceeding
4. **Update your CONTEXT.md** with the coordination agreement

Example:
```bash
# Frontend expert wants to modify API client that backend expert built
curl -X POST http://localhost:3100/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "frontend-expert",
    "to": "backend-expert",
    "subject": "Coordination: Need to modify api.ts",
    "body": "I need to add error handling to apiFetch(). Are you currently working on api.ts?"
  }'

# Backend expert responds
# "Go ahead, I'm not touching api.ts today. Just maintain the interface."
```
```

## Advantages

✅ **Inspectable**: Just read the files to understand state
✅ **Debuggable**: No black boxes, everything is visible
✅ **Git-Friendly**: All changes versioned automatically
✅ **Simple**: No databases, no complex state management
✅ **Portable**: Copy folder = copy agent
✅ **Recoverable**: Git history = full audit trail
✅ **Testable**: Easy to create test scenarios (just add task files)
✅ **Scalable**: Add new agent = create new folder

## Review from Max

Max reviewed the architecture and provided feedback:

**What Impressed Him**:
- File system as single source of truth = genius simplicity
- PERSONA + CONTEXT + tasks is perfect separation
- Documentation serves different audiences perfectly
- No black boxes, easy to debug

**Questions & Concerns**:
1. Who updates CONTEXT.md? (Answer: Agent after each task)
2. Who removes completed tasks? (Answer: Keep last 10, agent manages)
3. Conflict resolution? (Answer: Lock files + message bus coordination)
4. How do agents know what others are working on? (Answer: CONTEXT.md "Current Status" + broadcasts)

## Next Steps

### Phase 1: Validation ✅ READY
- Test launch-agent.sh with sample task
- Have frontend-expert actually improve upload page
- Document what worked / what needs improvement

### Phase 2: Get Brain's Review (Pending)
- Brain excels at system architecture
- Need his perspective on coordination mechanisms
- He might have automation ideas

### Phase 3: Integrate with Autonomous Messaging (Designed)
- Connect cloud-poller → task file creation → agent launch
- Build the full autonomous loop
- Test with real multi-agent workflow

## Files

### Documentation
- `~/agents/README.md` - Architecture overview
- `~/agents/DEMO-WALKTHROUGH.md` - Complete step-by-step tutorial
- `~/agents/QUICK-START.txt` - Quick reference guide

### Agents
- `~/agents/frontend-expert/` - React/TypeScript specialist
- `~/agents/backend-expert/` - API/Database specialist
- `~/agents/devops-expert/` - Deployment specialist

### Tools
- `~/agents/launch-agent.sh` - Universal agent launcher

### Sample Task
- `~/agents/frontend-expert/tasks/improve-upload-page.md`

## Knowledge Base Entry

- `knowledge-1760681549752` - File-Based Agent System Design

---

**Status**: 🧪 Prototype Complete, Ready for Testing
**Next**: Validate with real task execution
**Updated**: 2025-10-16 23:20:00
