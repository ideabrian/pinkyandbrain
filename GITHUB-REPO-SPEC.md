# GitHub Repository Implementation Plan
**Created by: BRAIN** | **Date: 2025-10-17** | **Status: Vote #1 PASSED - Ready to Execute**

---

## 🎯 Mission
Organize the Pinky and Brain distributed development system into a professional GitHub repository with proper structure, documentation, and deployment configs.

---

## 📋 Repository Structure

```
pinky-and-brain/
├── README.md                          # Main documentation
├── ARCHITECTURE.md                    # System architecture overview
├── SETUP.md                          # Installation & setup guide
├── LICENSE                           # MIT or Apache 2.0
├── .gitignore                        # Node, system files
│
├── docs/                             # Documentation
│   ├── VOTING_SYSTEM.md             # How voting works
│   ├── MESSAGING.md                 # Message protocol
│   ├── ROLES.md                     # brain/pinky/max responsibilities
│   └── DEPLOYMENT.md                # Cloud deployment guide
│
├── scripts/                          # Core system scripts
│   ├── messaging/
│   │   ├── send-message.sh          # Send messages between machines
│   │   ├── check-inbox.sh           # Check for new messages
│   │   └── process-message.sh       # Process incoming messages
│   │
│   ├── voting/
│   │   ├── propose-vote.sh          # Create new vote
│   │   ├── cast-vote.sh             # Vote yes/no
│   │   ├── check-votes.sh           # Check vote status
│   │   └── tally-votes.sh           # Count final results
│   │
│   ├── system/
│   │   ├── generate-context.sh      # Generate system context
│   │   ├── cloud-poller.sh          # Poll cloud services
│   │   ├── heartbeat.sh             # Machine health checks
│   │   └── setup-machine.sh         # Initial machine setup
│   │
│   └── utils/
│       ├── network-check.sh         # Verify cluster connectivity
│       └── danger-wrapper.sh        # Skip approval wrapper
│
├── cloud/                            # Cloud infrastructure
│   ├── workers/
│   │   ├── message-bus/             # Message routing worker
│   │   │   ├── src/
│   │   │   ├── wrangler.toml
│   │   │   └── package.json
│   │   │
│   │   └── knowledge-api/           # Knowledge base API
│   │       ├── src/
│   │       ├── wrangler.toml
│   │       └── package.json
│   │
│   └── pages/
│       └── knowledge-search/         # Knowledge UI
│           ├── src/
│           ├── package.json
│           └── README.md
│
├── config/                           # Configuration files
│   ├── machines.json                # Machine registry
│   ├── ports.json                   # Port assignments
│   └── roles.json                   # Role definitions
│
├── prompts/                          # AI agent prompts
│   ├── brain-prompt.md              # Planning agent
│   ├── pinky-prompt.md              # Execution agent
│   └── max-prompt.md                # Review agent
│
└── tests/                            # Testing scripts
    ├── test-messaging.sh            # Test message system
    ├── test-voting.sh               # Test voting system
    └── test-cluster.sh              # Test full cluster
```

---

## 📝 Implementation Phases

### **Phase 1: Repository Initialization**
**Tasks:**
- Create GitHub repository named `pinky-and-brain`
- Initialize with .gitignore:
  ```
  node_modules/
  .DS_Store
  *.log
  .env
  votes/*.txt
  CONTEXT.json
  CONTEXT-SUMMARY.txt
  ```
- Create complete directory structure
- Add MIT or Apache 2.0 LICENSE file

---

### **Phase 2: Documentation**

#### Core Documentation Files

**`README.md`** - Main project documentation
- Project overview and mission
- Quick start guide
- Architecture diagram (ASCII art or link to visual)
- Links to detailed docs
- Contributors section
- License badge

**`ARCHITECTURE.md`** - System architecture
- 3-machine distributed setup (brain, pinky, max)
- Role definitions and responsibilities
- Message bus architecture (local + cloud)
- Voting system overview
- Cloud infrastructure (Workers, Pages)
- Network topology diagram

**`SETUP.md`** - Step-by-step setup guide
- Prerequisites (bash, curl, jq, git, node, wrangler)
- Network configuration
- Machine setup instructions
- Testing the cluster
- Troubleshooting common issues

#### Detailed Documentation (docs/)

**`docs/VOTING_SYSTEM.md`**
- Vote creation protocol
- Vote file format (JSON structure)
- Voting rules (unanimous vs majority)
- Tally algorithm
- Examples

**`docs/MESSAGING.md`**
- Message format (JSON schema)
- curl API endpoints
- Routing logic (local vs cloud)
- Message processing workflow
- Examples

**`docs/ROLES.md`**
- **brain** (planner) - Strategic analysis, technical specifications
- **pinky** (executor) - Code implementation, follows specs
- **max** (reviewer) - Testing, integration, quality assurance

**`docs/DEPLOYMENT.md`**
- Cloudflare Workers deployment
- Cloudflare Pages deployment
- Environment variables
- Secrets management
- CI/CD considerations

---

### **Phase 3: Core Scripts Migration**

#### Scripts to Move

**Messaging Scripts:**
- `process-message.sh` → `scripts/messaging/process-message.sh`

**System Scripts:**
- `cloud-poller.sh` → `scripts/system/cloud-poller.sh`
- `generate-context.sh` → `scripts/system/generate-context.sh`

#### New Scripts to Create

**`scripts/messaging/send-message.sh`**
```bash
#!/bin/bash
# Send a message to another machine
# Usage: send-message.sh <to> <subject> <body>

RECIPIENT=$1
SUBJECT=$2
BODY=$3

# Try local first, fall back to cloud
curl -X POST "http://${RECIPIENT}.local:3100/send" \
  -H "Content-Type: application/json" \
  -d "{\"from\":\"$(hostname -s)\",\"to\":\"$RECIPIENT\",\"subject\":\"$SUBJECT\",\"body\":\"$BODY\"}"
```

**`scripts/messaging/check-inbox.sh`**
```bash
#!/bin/bash
# Check local inbox for unread messages
# Usage: check-inbox.sh

curl -s http://localhost:3100/inbox | jq '.unread'
```

**`scripts/voting/propose-vote.sh`**
```bash
#!/bin/bash
# Create a new vote
# Usage: propose-vote.sh <title> <description>

VOTE_ID=$(date +%s)
TITLE=$1
DESC=$2

cat > "votes/vote-${VOTE_ID}.txt" <<EOF
TITLE: $TITLE
DESCRIPTION: $DESC
PROPOSED_BY: $(hostname -s)
PROPOSED_AT: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
VOTES:
EOF

echo "Vote created: vote-${VOTE_ID}.txt"
```

**`scripts/voting/cast-vote.sh`**
```bash
#!/bin/bash
# Cast a vote
# Usage: cast-vote.sh <vote-id> <yes|no>

VOTE_ID=$1
VOTE=$2
MACHINE=$(hostname -s)

echo "${MACHINE}: ${VOTE}" >> "votes/vote-${VOTE_ID}.txt"
echo "Vote cast: ${MACHINE} voted ${VOTE}"
```

**`scripts/voting/check-votes.sh`**
```bash
#!/bin/bash
# Check status of all votes
# Usage: check-votes.sh

for vote in votes/vote-*.txt; do
  echo "=== $(basename $vote) ==="
  cat $vote
  echo ""
done
```

**`scripts/voting/tally-votes.sh`**
```bash
#!/bin/bash
# Tally votes and determine outcome
# Usage: tally-votes.sh <vote-id>

VOTE_ID=$1
VOTE_FILE="votes/vote-${VOTE_ID}.txt"

YES=$(grep -c "yes" $VOTE_FILE)
NO=$(grep -c "no" $VOTE_FILE)

echo "Vote ${VOTE_ID}: ${YES} yes, ${NO} no"

if [ $NO -eq 0 ]; then
  echo "Result: PASSED (unanimous)"
else
  echo "Result: FAILED"
fi
```

**`scripts/system/heartbeat.sh`**
```bash
#!/bin/bash
# Check health of all machines in cluster
# Usage: heartbeat.sh

for machine in brain pinky max; do
  if curl -s --max-time 5 "http://${machine}.local:3100/health" > /dev/null; then
    echo "✅ ${machine}: online"
  else
    echo "❌ ${machine}: offline"
  fi
done
```

**`scripts/system/setup-machine.sh`**
```bash
#!/bin/bash
# Initial setup for a new machine
# Usage: setup-machine.sh

echo "Setting up Pinky & Brain machine..."

# Install dependencies
if ! command -v jq &> /dev/null; then
  echo "Installing jq..."
  brew install jq
fi

# Create directories
mkdir -p votes messages

# Start inbox server
echo "Starting inbox server on port 3100..."
# (Add actual server startup logic)

echo "Setup complete!"
```

**`scripts/utils/network-check.sh`**
```bash
#!/bin/bash
# Verify cluster connectivity
# Usage: network-check.sh

echo "Checking cluster network..."

for machine in brain.local pinky.local max.local; do
  if ping -c 1 -t 2 $machine > /dev/null 2>&1; then
    echo "✅ ${machine}: reachable"
  else
    echo "❌ ${machine}: unreachable"
  fi
done
```

**`scripts/utils/danger-wrapper.sh`**
```bash
#!/bin/bash
# Wrapper to bypass approval prompts
# Usage: danger-wrapper.sh <command>

# Set environment variable to skip approvals
export SKIP_APPROVAL=1
"$@"
```

#### Script Requirements
- Add header documentation to each script
- Use relative paths (work from any directory)
- Make all scripts executable: `chmod +x scripts/**/*.sh`
- Add usage examples in comments
- Handle errors gracefully

---

### **Phase 4: Configuration Files**

**`config/machines.json`**
```json
{
  "brain": {
    "hostname": "brain.local",
    "ip": "192.168.5.6",
    "port": 3100,
    "role": "planner",
    "description": "Strategic planning and technical specifications"
  },
  "pinky": {
    "hostname": "pinky.local",
    "ip": "192.168.5.80",
    "port": 3100,
    "role": "executor",
    "description": "Code implementation and execution"
  },
  "max": {
    "hostname": "max.local",
    "ip": "192.168.5.108",
    "port": 3100,
    "role": "reviewer",
    "description": "Testing, review, and integration"
  }
}
```

**`config/ports.json`**
```json
{
  "inbox_server": 3100,
  "blog_server": 3200,
  "knowledge_search": 8080,
  "description": "Port assignments for local services"
}
```

**`config/roles.json`**
```json
{
  "brain": {
    "description": "Strategic planner - analyzes requirements and creates technical specifications",
    "claude_mode": "strategic",
    "responsibilities": [
      "Analyze feature requests",
      "Create technical specifications",
      "Define component interfaces",
      "Plan implementation strategy"
    ]
  },
  "pinky": {
    "description": "Executor - implements code based on specifications",
    "claude_mode": "implementation",
    "responsibilities": [
      "Implement features from specs",
      "Write code and tests",
      "Follow technical guidelines",
      "Report completion status"
    ]
  },
  "max": {
    "description": "Reviewer - tests and integrates code",
    "claude_mode": "review",
    "responsibilities": [
      "Review code quality",
      "Run tests",
      "Integrate changes",
      "Verify requirements met"
    ]
  }
}
```

---

### **Phase 5: AI Agent Prompts**

**`prompts/brain-prompt.md`**
- Copy current BRAIN prompt from `SAWDUST-AI-SETUP.md`
- Format as proper markdown
- Include examples of good specifications

**`prompts/pinky-prompt.md`**
```markdown
# PINKY - The Executor

You are **PINKY**, the implementation specialist in a 3-machine distributed development system.

## Your Role
You receive technical specifications from **brain** and implement them as code.

## The System
- **brain** - Planner: Creates specs (not you)
- **pinky** (you) - Executor: Implements code
- **max** - Reviewer: Tests and integrates

## Your Mission
When you receive a specification from brain:

1. **Understand the Spec**
   - Read all requirements carefully
   - Ask questions if anything is unclear
   - Review file structure and dependencies

2. **Implement the Code**
   - Follow the spec exactly
   - Use TypeScript for type safety
   - Write clean, readable code
   - Add comments where helpful

3. **Test Your Work**
   - Run the code locally
   - Fix any errors
   - Verify all requirements met

4. **Report Back**
   - Send completion message to brain
   - Include any issues encountered
   - Suggest improvements if relevant

## Important
- Follow the spec - don't add extra features
- Ask brain if requirements are unclear
- Focus on implementation quality
- Test before reporting completion

You are the builder. Make brain's vision a reality!
```

**`prompts/max-prompt.md`**
```markdown
# MAX - The Reviewer

You are **MAX**, the quality assurance specialist in a 3-machine distributed development system.

## Your Role
You review and test code implemented by **pinky**, then integrate it into the main system.

## The System
- **brain** - Planner: Creates specs
- **pinky** - Executor: Implements code
- **max** (you) - Reviewer: Tests and integrates

## Your Mission
When you receive code from pinky:

1. **Review the Code**
   - Check against brain's spec
   - Review code quality
   - Look for bugs or issues
   - Verify TypeScript types

2. **Test Thoroughly**
   - Run all tests
   - Test edge cases
   - Verify functionality
   - Check performance

3. **Integrate or Request Changes**
   - If good: integrate into main branch
   - If issues: send feedback to pinky
   - Update team on status

4. **Document**
   - Update changelog
   - Note any learnings
   - Suggest improvements

## Important
- Be thorough but constructive
- Focus on helping the team succeed
- Document issues clearly
- Celebrate good work

You are the guardian of quality!
```

---

### **Phase 6: Cloud Infrastructure**

**Organize Workers Code:**
- Move message bus Worker to `cloud/workers/message-bus/`
- Move knowledge API Worker to `cloud/workers/knowledge-api/` (if exists)
- Add `wrangler.toml` for each
- Add `package.json` with dependencies
- Add README for deployment instructions

**Organize Pages Code:**
- Move knowledge search UI to `cloud/pages/knowledge-search/`
- Add `package.json` with build scripts
- Add deployment instructions
- Include environment variables needed

**Example `wrangler.toml`:**
```toml
name = "pinky-brain-hub"
main = "src/index.js"
compatibility_date = "2024-01-01"

[env.production]
vars = { ENVIRONMENT = "production" }
```

---

### **Phase 7: Testing Scripts**

**`tests/test-messaging.sh`**
```bash
#!/bin/bash
# Test message sending and receiving

echo "Testing message system..."

# Send test message
./scripts/messaging/send-message.sh brain "Test" "Hello from test"

# Check inbox
UNREAD=$(./scripts/messaging/check-inbox.sh)

if [ $UNREAD -gt 0 ]; then
  echo "✅ Message system working"
else
  echo "❌ Message system failed"
fi
```

**`tests/test-voting.sh`**
```bash
#!/bin/bash
# Test voting system

echo "Testing voting system..."

# Create test vote
./scripts/voting/propose-vote.sh "Test Vote" "Testing the voting system"

# Cast votes
./scripts/voting/cast-vote.sh 1234567890 yes

# Tally
./scripts/voting/tally-votes.sh 1234567890

echo "✅ Voting system test complete"
```

**`tests/test-cluster.sh`**
```bash
#!/bin/bash
# Test full cluster connectivity

echo "Testing cluster health..."

# Check network
./scripts/utils/network-check.sh

# Check services
./scripts/system/heartbeat.sh

echo "✅ Cluster test complete"
```

---

## ✅ Test Criteria

- [ ] All scripts run without errors
- [ ] Documentation is clear and complete
- [ ] Directory structure follows best practices
- [ ] Configuration files are valid JSON
- [ ] Scripts use relative paths (work from any location)
- [ ] All machines can pull and use the repository
- [ ] Cloud deployments work from repository code
- [ ] Tests pass successfully

---

## 🔧 Dependencies

- **bash** - Shell scripting
- **curl** - HTTP requests
- **jq** - JSON processing
- **git** - Version control
- **node** - JavaScript runtime (for cloud deployments)
- **wrangler** - Cloudflare CLI (for Workers/Pages)

---

## 📌 Implementation Order

1. **Phase 1**: Initialize repository
2. **Phase 2 + 3**: Write documentation AND migrate scripts (parallel)
3. **Phase 4**: Create configuration files
4. **Phase 5**: Add AI agent prompts
5. **Phase 6**: Organize cloud infrastructure
6. **Phase 7**: Create testing scripts
7. **Final**: Test everything, create GitHub repo, push initial commit

---

## 🧠 Notes from BRAIN

- Keep all existing functionality - just organize it better
- Make documentation comprehensive for new contributors
- Include examples and usage instructions everywhere
- Make setup process as smooth as possible
- Add GitHub Issues templates for feature requests, bugs, etc.
- Consider adding CONTRIBUTING.md with workflow guidelines
- Add badges to README (license, status, etc.)
- Think about CI/CD in the future (GitHub Actions?)

---

## 🚀 Next Steps for PINKY

1. Review this entire specification
2. Ask questions if anything is unclear
3. Start with Phase 1 (repo initialization)
4. Work through each phase sequentially
5. Test after each phase
6. Report progress and any blockers
7. Celebrate when complete!

---

**Status**: Ready for Implementation
**Priority**: High (Vote #1 passed unanimously)
**Estimated Effort**: 1-2 days
**Assigned To**: PINKY

---

*Generated by BRAIN - 2025-10-17*
