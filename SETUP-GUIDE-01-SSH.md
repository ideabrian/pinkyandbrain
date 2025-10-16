# Setup Guide 01: SSH Communication Between Machines

**Goal**: Enable password-less SSH between maxyolo (laptop), pinky (Mac mini), and brain (Mac mini)

## Prerequisites
- All machines on same network
- macOS on all machines
- Admin access to all machines

## Step 1: Find Pinky's IP Address

On **pinky**, open Terminal and run:
```bash
# Get pinky's local IP address
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Look for something like `192.168.1.X` or `10.0.0.X`

**Write down pinky's IP**: ______________

## Step 2: Set Up Computer Names (Optional but Recommended)

On **pinky**, set the computer name:
```bash
# Set all three naming schemes for consistency
sudo scutil --set ComputerName pinky
sudo scutil --set LocalHostName pinky
sudo scutil --set HostName pinky

# Restart mDNSResponder to activate
sudo killall -HUP mDNSResponder
```

This makes pinky accessible via `pinky.local`

## Step 3: Enable Remote Login on Pinky

On **pinky**:
```bash
# Enable SSH server (Remote Login)
sudo systemsetup -setremotelogin on

# Verify it's running
sudo systemsetup -getremotelogin
# Should say: Remote Login: On
```

## Step 4: Copy SSH Key from Maxyolo to Pinky

On **maxyolo**, run:
```bash
# Replace PINKY_IP with the IP address you found in Step 1
ssh-copy-id -i ~/.ssh/id_ed25519.pub maxyolo@PINKY_IP

# You'll be prompted for pinky's password (one time only)
```

**Alternative if ssh-copy-id isn't available**:
```bash
cat ~/.ssh/id_ed25519.pub | ssh maxyolo@PINKY_IP "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

## Step 5: Test Password-less Connection

On **maxyolo**:
```bash
# Test connection with hostname (if Step 2 worked)
ssh maxyolo@pinky.local "echo 'Connection successful from pinky!'"

# OR test with IP address
ssh maxyolo@PINKY_IP "echo 'Connection successful from pinky!'"
```

If you see "Connection successful from pinky!" without entering a password, you're done! ✅

## Step 6: Add to SSH Config for Easy Access

On **maxyolo**, create/edit `~/.ssh/config`:
```bash
cat >> ~/.ssh/config << 'EOF'

Host pinky
    HostName pinky.local  # or use IP address
    User maxyolo
    IdentityFile ~/.ssh/id_ed25519

Host brain
    HostName brain.local
    User maxyolo
    IdentityFile ~/.ssh/id_ed25519
EOF
```

Now you can simply type: `ssh pinky` 🎉

## Troubleshooting

**Can't connect to pinky.local?**
- Use IP address instead
- Check firewall settings on pinky
- Verify pinky and maxyolo are on same network

**Permission denied?**
- Check SSH key was copied correctly: `ssh maxyolo@pinky.local "cat ~/.ssh/authorized_keys"`
- Verify permissions: `ssh maxyolo@pinky.local "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"`

**Connection times out?**
- Verify Remote Login is enabled on pinky
- Check if firewall is blocking SSH (port 22)

## Next Steps
Once SSH is working, proceed to **SETUP-GUIDE-02-ORCHESTRATION.md**

---
**Status**: Complete when you can run `ssh pinky "hostname"` without password
