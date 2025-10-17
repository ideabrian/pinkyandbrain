# Daily Standup Dashboard - Phase 1 Implementation

This directory contains the Phase 1 implementation of the Daily Standup Dashboard system.

## Phase 1: Standup Collector Script

### Overview

The standup collector script automatically gathers daily activity data from each machine in the Pinky and Brain cluster and submits it to a centralized API.

### Files

- `standup-collector.sh` - Main collector script that gathers git commits, messages, and session data

### Features

The collector script gathers:

1. **Git Commits** - All commits made during the target day
2. **Messages** - Sent/received messages (from log files)
3. **Session Info** - Command counts and session duration
4. **Highlights** - Important commits (feat:, feature:, !)
5. **Blockers** - Problem indicators (blocked, issue, error, fix)
6. **Statistics** - Commit count, message count, files changed

### Usage

#### Manual Execution

Run for today:
```bash
./standup-collector.sh
```

Run for a specific date:
```bash
./standup-collector.sh 2025-10-16
```

#### Configuration

Set these environment variables:

```bash
export MACHINE_NAME="pinky"                              # Machine identifier
export REPO_PATH="$HOME/pinkyandbrain"                   # Repository path
export API_ENDPOINT="https://pinky-brain-hub.b-9f2.workers.dev/api/standup"
export STANDUP_AUTH_SECRET="your-secret-here"            # API authentication
```

#### Installation

1. Copy the script to each machine:
```bash
cp standup-collector.sh ~/pinkyandbrain/scripts/
chmod +x ~/pinkyandbrain/scripts/standup-collector.sh
```

2. Set up environment variables in `~/.zshrc` or `~/.bashrc`:
```bash
echo 'export STANDUP_AUTH_SECRET="your-secret-here"' >> ~/.zshrc
```

3. Set up cron job to run daily at 11:59 PM:
```bash
# Edit crontab
crontab -e

# Add this line (adjust path as needed):
59 23 * * * export STANDUP_AUTH_SECRET="your-secret"; ~/pinkyandbrain/scripts/standup-collector.sh >> ~/pinkyandbrain/logs/standup-collector.log 2>&1
```

### Output

The script produces JSON output with this structure:

```json
{
  "machine": "pinky",
  "date": "2025-10-17",
  "timestamp": "2025-10-17T17:24:16Z",
  "commits": [
    {
      "hash": "abc123...",
      "author": "Author Name",
      "date": "2025-10-17T10:23:57-07:00",
      "message": "Commit message"
    }
  ],
  "messages": [
    {
      "type": "sent",
      "timestamp": "2025-10-17 10:30:00",
      "content": "Message content"
    }
  ],
  "sessions": {
    "total_commands": 42,
    "session_duration_seconds": 3600
  },
  "highlights": ["Important feature added!"],
  "blockers": ["Fixed critical bug"],
  "stats": {
    "total_commits": 4,
    "total_messages": 2,
    "files_changed": 12
  }
}
```

### Backup

All standup data is saved locally to:
```
~/pinkyandbrain/standups/{machine}-{date}.json
```

This provides a backup even if API submission fails.

### Dependencies

- `jq` - JSON processor (install with `brew install jq`)
- `git` - Version control
- `curl` - HTTP client

### Testing

Test the script without API submission:
```bash
unset STANDUP_AUTH_SECRET
./standup-collector.sh
```

This will generate the JSON output and save the backup file, but skip API submission.

### Next Steps

Phase 2 will implement:
- Cloudflare Worker API to receive standup data
- KV storage for persistence
- Authentication and validation

Phase 3 will implement:
- Web dashboard to visualize the data
- Multi-machine comparison view
- Historical browsing

## Implementation Notes

**Status:** Phase 1 Complete
**Date:** 2025-10-17
**Machine:** pinky
**Implemented by:** PINKY

The collector script has been implemented and tested successfully. It correctly:
- Collects git commits from the repository
- Handles edge cases (no commits, missing logs)
- Generates valid JSON output
- Saves local backups
- Supports custom date ranges

Ready for Phase 2 (API Worker implementation).
