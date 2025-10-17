# Setup Guide 03: Orchestration - Running Commands Across All Machines

**Goal**: Execute commands on multiple machines simultaneously

## Quick Start

```bash
# Run command on all machines
./run-on-all.sh "hostname && date"

# Check system info
./run-on-all.sh "sw_vers && uname -m"

# Install software on all machines
./run-on-all.sh "brew install htop"

# Check disk space
./run-on-all.sh "df -h | grep -E '(Filesystem|/System/Volumes/Data)'"
```

## How It Works

The `run-on-all.sh` script:
1. Takes a command as an argument
2. Runs it on **localhost** (maxyolo)
3. Runs it on **pinky** via SSH
4. All executions happen **in parallel**
5. Shows color-coded output from each machine

**Current machines:**
- `localhost` = maxyolo (your laptop)
- `pinky` = Mac mini at 192.168.5.80

**When brain comes online:**
Just add `"brain"` to the MACHINES array in the script!

## Real-World Use Cases

### 1. Development Environment Setup
```bash
# Install Claude Code on all machines
./run-on-all.sh "brew install claude-code"

# Create project directories
./run-on-all.sh "mkdir -p ~/projects"

# Clone a repo everywhere
./run-on-all.sh "cd ~/projects && git clone https://github.com/user/repo.git"
```

### 2. System Monitoring
```bash
# Check what's running
./run-on-all.sh "top -l 1 | head -20"

# Monitor network
./run-on-all.sh "ifconfig | grep 'inet '"

# Check load
./run-on-all.sh "uptime"
```

### 3. Parallel Testing
```bash
# Run tests on all machines
./run-on-all.sh "cd ~/project && npm test"

# Build on all machines
./run-on-all.sh "cd ~/project && npm run build"

# Different tests on each machine
# (edit script to pass different commands per machine)
```

### 4. File Distribution
```bash
# Create config file on all machines
./run-on-all.sh "echo 'export MY_VAR=value' >> ~/.bashrc"

# Download file to all machines
./run-on-all.sh "curl -o ~/file.txt https://example.com/file.txt"
```

### 5. Learning & Practice
```bash
# Learn networking
./run-on-all.sh "netstat -an | wc -l"

# Practice shell commands
./run-on-all.sh "ps aux | grep node"

# Experiment safely
./run-on-all.sh "echo 'Testing' > /tmp/test.txt && cat /tmp/test.txt"
```

## Advanced: Machine-Specific Commands

Edit `run-on-all.sh` to run different commands on different machines:

```bash
case "$machine" in
  "localhost")
    cmd="npm run dev"  # Dev server on maxyolo
    ;;
  "pinky")
    cmd="npm run test"  # Tests on pinky
    ;;
  "brain")
    cmd="npm run build"  # Build on brain
    ;;
esac
```

## Understanding Parallel Execution

**Without parallel:**
```bash
ssh pinky "sleep 5"   # Waits 5 seconds
ssh brain "sleep 5"   # Then waits another 5
# Total: 10 seconds
```

**With parallel (what run-on-all.sh does):**
```bash
ssh pinky "sleep 5" &  # Starts, runs in background
ssh brain "sleep 5" &  # Starts immediately
wait  # Waits for both
# Total: 5 seconds (both run at once)
```

## Troubleshooting

**Command fails on one machine:**
- Check SSH connection: `ssh pinky "echo test"`
- Verify command works locally first
- Check if software is installed on that machine

**Permission denied:**
- May need `sudo` for system commands
- But `sudo` over SSH can be tricky
- Consider enabling passwordless sudo for specific commands

**Different outputs on machines:**
- That's expected! Different machines, different states
- Use this to understand environment differences
- Great learning opportunity

## Next Steps

**When brain comes online:**
1. Set up SSH keys (same process as pinky)
2. Add to ~/.ssh/config
3. Edit run-on-all.sh: add `"brain"` to MACHINES array
4. Test: `./run-on-all.sh "hostname"`

**Expand capabilities:**
- Create machine-specific scripts
- Add error handling & logging
- Build deployment pipelines
- Automate backups across machines

## The Power of Three Machines

**Why this is valuable:**

1. **Learning Distributed Systems**
   - See how commands execute across network
   - Understand timing & synchronization
   - Practice fault tolerance (what if one fails?)

2. **Parallel Development**
   - Frontend on maxyolo
   - Backend on pinky
   - Database on brain
   - All talking to each other

3. **Cost-Effective Testing**
   - Test in "production-like" environment
   - Multiple OS versions simultaneously
   - Load testing with real hardware

4. **Skills That Scale**
   - Today: 3 Mac minis
   - Tomorrow: 100 cloud servers
   - Same orchestration patterns apply

---
**Status**: Complete when you can run commands across all your machines with one script
**Next**: SETUP-GUIDE-04-CLAUDE-CODE.md (Run Claude Code sessions on multiple machines)
