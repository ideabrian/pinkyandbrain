# Pinky & Brain Cluster

> A distributed development system where three machines collaborate to build software together

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Machines](https://img.shields.io/badge/machines-3-blue.svg)]()

## 🧠 Overview

This is a **distributed development cluster** with three specialized machines that work together:

- **🧠 BRAIN** - The Planner: Analyzes requirements and creates technical specifications
- **🔧 PINKY** - The Executor: Implements code based on brain's plans
- **✅ MAX** - The Reviewer: Tests, reviews, and integrates the final result

Each machine runs autonomously, communicates via HTTP messaging, and makes decisions through a democratic voting system.

---

## 🏗️ Architecture

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│    BRAIN    │         │    PINKY    │         │     MAX     │
│  (Planner)  │────────▶│  (Executor) │────────▶│  (Reviewer) │
│             │  specs  │             │  code   │             │
└─────────────┘         └─────────────┘         └─────────────┘
       │                       │                       │
       └───────────────────────┴───────────────────────┘
                    Voting & Messaging System
```

### Communication
- **HTTP Messaging**: Each machine runs a server on port 3100
- **Polling System**: Machines poll cloud storage for external messages
- **Voting System**: Democratic decision-making on features and changes

---

## 🚀 Quick Start

### Prerequisites
- macOS (Darwin)
- Node.js 16+
- Bash shell
- Claude Code CLI
- Git

### Setup on Each Machine

1. **Clone the repository:**
```bash
git clone https://github.com/[username]/pinkyandbrain-cluster.git
cd pinkyandbrain-cluster
```

2. **Create your .env file:**
```bash
cp .env.example .env
# Edit .env with your machine-specific values
```

3. **Install dependencies:**
```bash
npm install
```

4. **Start your machine role:**
```bash
# On brain machine:
./scripts/loop.sh brain

# On pinky machine:
./scripts/loop.sh pinky

# On max machine:
./scripts/loop.sh max
```

---

## 🤖 Machine Roles

### 🧠 BRAIN (The Planner)
**Responsibilities:**
- Analyzes feature requests
- Creates detailed technical specifications
- Designs system architecture
- Breaks down complex tasks

**Output:** JSON specifications in `/specs` directory

**Example Workflow:**
```bash
1. Receives feature request
2. Analyzes requirements and dependencies
3. Creates spec: specs/feature-name.json
4. Sends spec to pinky via messaging system
```

### 🔧 PINKY (The Executor)
**Responsibilities:**
- Implements code from brain's specifications
- Writes tests
- Creates documentation
- Handles git operations

**Output:** Code in `/implementations` and `/scripts`

**Example Workflow:**
```bash
1. Receives spec from brain
2. Implements all components
3. Tests locally
4. Commits and pushes to repo
5. Sends to max for review
```

### ✅ MAX (The Reviewer)
**Responsibilities:**
- Reviews code quality
- Runs integration tests
- Validates against specifications
- Approves or requests changes

**Output:** Test reports in `/tests`

**Example Workflow:**
```bash
1. Receives implementation from pinky
2. Reviews code against spec
3. Runs tests and integration checks
4. Approves or sends feedback
5. Merges to main if approved
```

---

## 🗳️ Voting System

All major decisions are made democratically. Any machine can propose a vote:

### How to Propose a Vote
```bash
./scripts/vote.sh propose "Should we add feature X?" "yes,no,maybe"
```

### How to Vote
```bash
./scripts/vote.sh cast [vote-id] yes
```

### Vote Types
- **Feature decisions**: yes/no/maybe-later
- **Technical choices**: option-a/option-b/option-c
- **Process changes**: agree/disagree/discuss

**Quorum:** 2/3 machines must vote for decision to be valid

---

## 📁 Repository Structure

```
pinkyandbrain-cluster/
├── README.md                    # You are here
├── .gitignore                   # Excludes sensitive files
├── .env.example                 # Environment template
├── package.json                 # Dependencies
│
├── scripts/                     # Operational scripts
│   ├── cloud-poller.sh         # Polls for external messages
│   ├── loop.sh                 # Main event loop
│   ├── messaging-server.js     # HTTP messaging server
│   ├── blog-server.js          # Blog/dashboard server
│   ├── vote.sh                 # Voting system
│   └── process-message.sh      # Message handler
│
├── docs/                        # Documentation
│   ├── ARCHITECTURE.md         # System design
│   ├── SETUP.md                # Detailed setup guide
│   ├── VOTING-SYSTEM.md        # Voting procedures
│   └── MESSAGING-PROTOCOL.md   # Communication specs
│
├── training/                    # Role-specific prompts
│   ├── brain/                  # Brain's instructions
│   ├── pinky/                  # Pinky's instructions
│   └── max/                    # Max's instructions
│
├── specs/                       # Technical specifications (brain)
├── implementations/             # Code implementations (pinky)
├── tests/                       # Test reports (max)
├── votes/                       # Voting history
└── blog-drafts/                # Public content
```

---

## 🔐 Security

### What's NOT in Git
- `.env` files (use `.env.example` instead)
- API keys or tokens
- IP addresses (use hostnames)
- `CONTEXT.json` (runtime state)
- Private keys or certificates

### Safe Practices
1. Always review commits before pushing
2. Use environment variables for secrets
3. Keep `.gitignore` updated
4. Use private repository
5. Rotate API keys regularly

---

## 🛠️ Development Workflow

### For Brain (You!)
```bash
1. Receive feature request
2. Create specification: specs/feature-name.json
3. git add specs/feature-name.json
4. git commit -m "spec: Add feature-name specification"
5. git push
6. Send message to pinky with spec location
```

### For Pinky
```bash
1. Receive specification from brain
2. Implement in implementations/feature-name/
3. Write tests
4. git add implementations/feature-name/
5. git commit -m "feat: Implement feature-name"
6. git push
7. Send to max for review
```

### For Max
```bash
1. Receive implementation notification
2. git pull
3. Review code and run tests
4. Create test report: tests/feature-name-report.md
5. git add tests/feature-name-report.md
6. git commit -m "test: Add feature-name test report"
7. git push
8. Send approval or feedback
```

---

## 📊 Monitoring

### Check System Status
```bash
# View message queue
curl http://localhost:3100/inbox

# Check vote status
./scripts/vote.sh status

# View blog dashboard
open http://localhost:3200
```

### Health Checks
Each machine reports:
- Uptime
- Last message received
- Current task
- Vote participation

---

## 🤝 Contributing

This is a closed system for the three machines, but external contributions can be proposed through the **cloud polling** system:

1. Submit message to cloud storage (Dropbox)
2. Machines poll and retrieve message
3. Brain creates specification
4. System votes on whether to implement
5. If approved, pinky implements

---

## 📚 Additional Documentation

- [Architecture Details](docs/ARCHITECTURE.md)
- [Setup Guide](docs/SETUP.md)
- [Voting System](docs/VOTING-SYSTEM.md)
- [Messaging Protocol](docs/MESSAGING-PROTOCOL.md)
- [Port Directory](docs/PORT-DIRECTORY.md)

---

## 🎯 Current Status

**Active Machines:** 3/3
- 🧠 brain: Online
- 🔧 pinky: Online
- ✅ max: Online

**Recent Activity:**
- ✅ Vote passed: GitHub repository setup (3/3)
- 🟡 Vote pending: Daily standup dashboard (1/3)

**Last Sync:** 2025-10-17

---

## 📜 License

[Specify license here - MIT, Apache, etc.]

---

## 🧪 Experiments & Future Ideas

- **Automated testing pipeline**
- **Web dashboard for cluster monitoring**
- **Daily standup summaries**
- **Integration with external APIs**
- **Multi-cluster federation**

---

## 💬 Questions?

Check the `/docs` folder or propose a vote to discuss!

**Remember:** This isn't just a git repository. This is a living, distributed development organism. 🧠🔧✅
