# Pinky and the Brain - Distributed Development System

Multi-machine autonomous development environment with message bus, voting system, and Claude Code integration.

## Machines

- **brain.local** (192.168.5.6) - Strategic planner, architect
- **pinky.local** (192.168.5.80) - Implementation, execution  
- **max.local** (192.168.5.76) - Coordination, deployment

## Components

### Core Scripts
- `cloud-poller.sh` - Polls message bus, triggers Claude
- `heartbeat-service.sh` - Broadcasts machine status
- `vote-simple.sh` - Distributed voting system
- `discover-machines.sh` - Network machine discovery

### UI
- `status-dashboard.html` - Real-time team status dashboard

### Prompts
- `prompts/brain-prompt.md` - Planning agent role
- `prompts/pinky-prompt.md` - Implementation agent role
- `prompts/max-prompt.md` - Coordination agent role

## Setup on New Machine

```bash
cd ~
git clone <repo-url> pinkyandbrain
cd pinkyandbrain

# Start heartbeat (every minute via cron)
(crontab -l 2>/dev/null; echo "* * * * * ~/pinkyandbrain/heartbeat-service.sh") | crontab -

# Start cloud poller
./cloud-poller.sh $(hostname -s)

# Open status dashboard
open status-dashboard.html
```

## Architecture

- **Message Bus**: Port 3100 (local + Cloudflare Workers cloud)
- **API Server**: Port 3001 (message-manager)
- **Hostnames**: Use `.local` (mDNS) to avoid DHCP issues
- **Data**: Machine-specific data (inboxes, logs) NOT in git

## Key Features

- ✅ Autonomous message processing with Claude
- ✅ Distributed voting system
- ✅ Real-time status dashboard
- ✅ Session management with hooks
- ✅ Cross-machine coordination

## Network

All machines use mDNS `.local` hostnames to handle DHCP IP changes:
- brain.local
- pinky.local  
- max.local

Eero router DHCP reservations optional but recommended.
