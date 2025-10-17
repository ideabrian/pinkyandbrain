# Pinky & Brain Cluster

> "Are you thinking what I'm thinking, Brain?" 
> "I think so, Pinky, but this time with autonomous AI agents and distributed orchestration!"

A multi-agent development system where three machines collaborate autonomously to plan, build, and deploy software.

## The System

**brain** (Planner) - Creates technical specifications and architectural plans
**pinky** (Executor) - Implements code based on brain's specifications  
**max** (Reviewer) - Tests, reviews, and integrates pinky's work

## Features

- **Autonomous Messaging**: Machines communicate via local and cloud message buses
- **Distributed Development**: Each machine has a specialized role in the workflow
- **Knowledge Sharing**: Centralized knowledge base accessible across the cluster
- **Cloud Deployment**: Automated deployment to Cloudflare Workers and Pages
- **Workflow Orchestration**: Coordinated task execution across machines
- **Vote-Based Decisions**: Democratic decision-making via voting system

## Quick Start

### Prerequisites

- Node.js 18+ installed on all machines
- Claude Code CLI configured
- GitHub CLI (`gh`) authenticated
- SSH keys configured for machine-to-machine communication
- Cloudflare account (optional, for cloud deployment)

### Setup

1. Clone this repository on each machine:
```bash
git clone https://github.com/ideabrian/pinkyandbrain-cluster.git ~/pinkyandbrain
cd ~/pinkyandbrain
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment:
```bash
cp .env.example .env
# Edit .env with your actual values
```

4. Set up hostnames (add to /etc/hosts):
```
192.168.5.4   pinky.local
192.168.5.x   brain.local
192.168.5.x   max.local
```

5. Start the message bus on each machine:
```bash
node claude-messenger.js
```

6. Start the cloud poller (optional, for autonomous operation):
```bash
./cloud-poller.sh
```

## Architecture

### Directory Structure

```
pinkyandbrain/
├── scripts/              # Utility scripts
│   ├── setup/           # Initial setup scripts
│   ├── deployment/      # Deployment automation
│   └── utilities/       # Helper utilities
├── cloudflare/          # Cloud deployment
│   ├── workers/         # Cloudflare Workers
│   └── pages/           # Cloudflare Pages
├── docs/                # Documentation
├── workflows/           # Workflow definitions
│   └── templates/       # Workflow templates
├── git-hooks/           # Git hooks for automation
└── workflow-output/     # Generated code output
```

### Message Bus

The system uses two message buses:
- **Local**: HTTP server on port 3100 (each machine)
- **Cloud**: Cloudflare Worker for cross-network communication

Send a message:
```bash
curl -X POST http://RECIPIENT.local:3100/send \
  -H "Content-Type: application/json" \
  -d '{"from":"sender","to":"recipient","body":"message"}'
```

View inbox:
```bash
curl http://localhost:3100/inbox
```

### Workflow Example

1. **Planning**: Send feature request to brain
2. **Specification**: Brain creates technical spec and sends to pinky
3. **Implementation**: Pinky writes code based on spec
4. **Review**: Pinky notifies max when complete
5. **Integration**: Max tests and merges to main

## Key Scripts

### Setup
- `setup-new-machine.sh` - Initial machine setup
- `setup-gh-auth.sh` - GitHub CLI authentication
- `setup-brain-ssh.sh` - SSH key distribution

### Orchestration
- `orchestrator.sh` - Main workflow orchestrator
- `cloud-poller.sh` - Autonomous message polling
- `process-message.sh` - Message processing handler

### Utilities
- `generate-context.sh` - Update system context
- `gm.sh` - Quick message sending
- `pinky-cli.sh` - Pinky command-line interface
- `knowledge-cli.sh` - Knowledge base interface

### Deployment
- `deploy-to-brain.sh` - Deploy updates to brain machine
- `run-on-all.sh` - Execute command on all machines

## Voting System

Make cluster-wide decisions via voting:

```bash
./vote-simple.sh "Should we implement feature X?" "yes,no,later"
```

Votes are recorded in `votes/` and can be queried by any machine.

## Knowledge Base

Share knowledge across the cluster:

```bash
# Add knowledge
./knowledge-cli.sh add "Topic" "Content here"

# Search knowledge
./knowledge-cli.sh search "keyword"

# View all knowledge
curl https://knowledge-search.pages.dev
```

## Autonomous Operation

The system can run fully autonomously:

1. Cloud poller monitors for incoming messages
2. Messages trigger Claude Code with appropriate prompts
3. Claude processes task and generates response
4. Response is automatically sent back via message bus

Enable autonomous mode:
```bash
./cloud-poller.sh &
```

## Development

### Adding a New Workflow

1. Create workflow definition in `workflows/`
2. Add template to `workflows/templates/`
3. Update orchestrator to recognize new workflow
4. Test on a single machine first
5. Deploy to cluster

### Creating a Custom Message Handler

1. Add handler logic to `process-message.sh`
2. Test with sample messages
3. Deploy via `deploy-to-brain.sh`

## Cloud Infrastructure

### Deployed Services

- **Message Bus**: https://pinky-brain-hub.b-9f2.workers.dev
- **Knowledge Search**: https://knowledge-search.pages.dev
- **FunJobs.ai**: https://funjobs-ai.b-9f2.workers.dev

### Deployment

Deploy to Cloudflare:
```bash
cd cloudflare/workers/message-bus
wrangler deploy
```

## Troubleshooting

### Messages Not Delivering

1. Check message bus is running: `curl http://localhost:3100/inbox`
2. Verify hostname resolution: `ping brain.local`
3. Check firewall settings on port 3100

### Cloud Poller Not Responding

1. Check if running: `ps aux | grep cloud-poller`
2. View logs: `tail -f cloud-poller.log`
3. Restart: `pkill -f cloud-poller && ./cloud-poller.sh &`

### SSH Connection Issues

1. Test SSH: `ssh brain.local "echo success"`
2. Check SSH keys: `ls -la ~/.ssh/`
3. Re-run setup: `./setup-brain-ssh.sh`

## Security Notes

- Never commit `.env` files
- Never commit `CONTEXT.json` (contains runtime secrets)
- Use SSH keys for machine-to-machine auth
- Rotate API keys regularly
- Keep Cloudflare tokens secure

## Documentation

See `docs/` directory for detailed documentation:
- System architecture
- Setup guides
- Workflow design
- Training materials
- API references

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

Private repository - All rights reserved.

## Team

- **brain** - The planner and architect
- **pinky** - The executor and builder  
- **max** - The reviewer and integrator

"Same thing we do every night, Pinky - try to build better software!"
