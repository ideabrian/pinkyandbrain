# SSH Cluster Setup Tutorial

## Setting Up Passwordless SSH Between Multiple Machines

This tutorial will guide you through setting up bidirectional SSH access between multiple machines using a shared SSH key. This is particularly useful for home labs, development clusters, or any scenario where you need seamless access between machines for SSH, SCP, and rsync operations.

## Prerequisites

- Multiple machines on the same network (this tutorial uses 3 machines)
- SSH server running on all machines
- Terminal access to all machines
- Basic understanding of SSH and command line

## Scenario

In this example, we'll set up three machines:
- **brain.local** (192.168.5.81) - Main machine
- **max.local** (192.168.5.76) - Secondary machine
- **pinky.local** (192.168.5.80) - Secondary machine

After setup, all three machines will be able to SSH, SCP, and rsync to each other without passwords.

## Step 1: Generate a Shared SSH Key (On Main Machine)

First, we'll create a shared SSH key pair that all machines will use.

```bash
# On brain.local
ssh-keygen -t ed25519 -C "brain-cluster" -f ~/.ssh/id_machines
```

When prompted:
- Press Enter to skip the passphrase (or add one if you prefer)
- This creates two files:
  - `~/.ssh/id_machines` (private key - keep secure!)
  - `~/.ssh/id_machines.pub` (public key - safe to share)

### Why Ed25519?

Ed25519 keys are:
- More secure than RSA
- Smaller key size
- Faster to generate and use
- The modern standard for SSH keys

## Step 2: Configure SSH on the Main Machine

Create or edit your SSH config file:

```bash
# On brain.local
nano ~/.ssh/config
```

Add entries for the other machines:

```
Host maxyolo max.local
    HostName 192.168.5.76
    User maxyolo
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes

Host pinky pinky.local
    HostName 192.168.5.80
    User pinky
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
```

### Config Explanation:

- **Host**: Aliases you can use (e.g., `ssh max` or `ssh max.local`)
- **HostName**: Actual IP address or hostname
- **User**: Username on the remote machine
- **IdentityFile**: Path to your private key
- **IdentitiesOnly**: Only use the specified key (prevents trying other keys)

## Step 3: Copy Public Key to Remote Machines

Add your public key to the `authorized_keys` file on each remote machine:

```bash
# Option 1: Using ssh-copy-id (easiest if password auth is enabled)
ssh-copy-id -i ~/.ssh/id_machines.pub maxyolo@192.168.5.76
ssh-copy-id -i ~/.ssh/id_machines.pub pinky@192.168.5.80

# Option 2: Manual copy (if you have initial access)
cat ~/.ssh/id_machines.pub | ssh maxyolo@192.168.5.76 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
cat ~/.ssh/id_machines.pub | ssh pinky@192.168.5.80 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

## Step 4: Test Initial Connectivity

Verify you can SSH from the main machine to others:

```bash
# On brain.local
ssh max.local "hostname && whoami"
# Should output: max.local / maxyolo

ssh pinky.local "hostname && whoami"
# Should output: pinky.local / pinky
```

## Step 5: Set Up Bidirectional Access

Now we need to configure the other machines so they can also SSH back. We'll copy the shared key to each machine.

### Copy the Shared Key to Each Machine

```bash
# On brain.local
# Copy to max.local
scp ~/.ssh/id_machines ~/.ssh/id_machines.pub max.local:~/.ssh/

# Copy to pinky.local
scp ~/.ssh/id_machines ~/.ssh/id_machines.pub pinky.local:~/.ssh/
```

### Set Correct Permissions

```bash
# On max.local
ssh max.local "chmod 600 ~/.ssh/id_machines && chmod 644 ~/.ssh/id_machines.pub"

# On pinky.local
ssh pinky.local "chmod 600 ~/.ssh/id_machines && chmod 644 ~/.ssh/id_machines.pub"
```

### Why These Permissions?

- **600** (private key): Only you can read/write - SSH requires this
- **644** (public key): You can read/write, others can read

## Step 6: Configure SSH on Remote Machines

Create SSH configs on each remote machine:

### On max.local:

```bash
ssh max.local "cat > ~/.ssh/config << 'EOF'
Host pinky
    HostName 192.168.5.80
    User pinky
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes

Host brain
    HostName 192.168.5.81
    User brain
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
EOF"
```

### On pinky.local:

```bash
ssh pinky.local "cat > ~/.ssh/config << 'EOF'
Host brain
    HostName 192.168.5.81
    User brain
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes

Host maxyolo
    HostName 192.168.5.76
    User maxyolo
    IdentityFile ~/.ssh/id_machines
    IdentitiesOnly yes
EOF"
```

## Step 7: Add Public Key to All authorized_keys Files

Each machine needs the shared public key in its `authorized_keys`:

```bash
# On brain.local - add to your own authorized_keys
cat ~/.ssh/id_machines.pub >> ~/.ssh/authorized_keys

# On max.local
cat ~/.ssh/id_machines.pub | ssh max.local "cat >> ~/.ssh/authorized_keys"

# On pinky.local
cat ~/.ssh/id_machines.pub | ssh pinky.local "cat >> ~/.ssh/authorized_keys"
```

## Step 8: Verify Full Connectivity

Test SSH in all directions:

```bash
# From brain to max and pinky
ssh max.local "echo 'Brain to Max works'"
ssh pinky.local "echo 'Brain to Pinky works'"

# From max to brain and pinky
ssh max.local "ssh brain 'echo Max to Brain works'"
ssh max.local "ssh pinky 'echo Max to Pinky works'"

# From pinky to brain and max
ssh pinky.local "ssh brain 'echo Pinky to Brain works'"
ssh pinky.local "ssh maxyolo 'echo Pinky to Max works'"
```

All commands should execute without password prompts!

## Step 9: Test SCP and Rsync

### Test SCP (Secure Copy)

```bash
# Create a test file
echo "test file" > /tmp/test.txt

# Copy from brain to max
scp /tmp/test.txt max.local:/tmp/

# Copy from max to pinky
ssh max.local "scp /tmp/test.txt pinky:/tmp/"

# Copy from pinky to brain
ssh pinky.local "scp /tmp/test.txt brain:/tmp/"
```

### Test Rsync

```bash
# Create a test directory
mkdir -p /tmp/rsync_test
echo "content" > /tmp/rsync_test/file.txt

# Sync from brain to max
rsync -av /tmp/rsync_test/ max.local:/tmp/rsync_test_from_brain/

# Sync from max to pinky
ssh max.local "rsync -av /tmp/rsync_test/ pinky:/tmp/rsync_test_from_max/"

# Sync from pinky to brain
ssh pinky.local "rsync -av /tmp/rsync_test/ brain:/tmp/rsync_test_from_pinky/"
```

## Verification Checklist

- [ ] SSH works from any machine to any other machine
- [ ] No password prompts when connecting
- [ ] SCP can copy files between all machines
- [ ] Rsync can sync directories between all machines
- [ ] All machines have the same private key (`~/.ssh/id_machines`)
- [ ] All machines have the public key in their `authorized_keys`
- [ ] All machines have proper SSH config entries

## Security Considerations

### Private Key Security

The private key (`id_machines`) is now on all three machines. This means:

- **Compromising any machine compromises the cluster**
- Only use this setup on trusted networks (home lab, private network)
- For production environments, consider:
  - Individual keys per machine
  - Certificate-based authentication
  - Bastion hosts for external access

### Network Security

- Keep all machines on a private network
- Use a firewall to block SSH from outside your network
- Consider using a VPN for remote access
- Monitor SSH logs for unauthorized access attempts

### Best Practices

1. **Use strong passphrases** on the shared key if possible
2. **Regular key rotation** - regenerate keys periodically
3. **Limit key usage** - use `IdentitiesOnly yes` in SSH config
4. **Monitor access** - check `/var/log/auth.log` or equivalent
5. **Backup keys securely** - encrypted backup of the private key

## Troubleshooting

### "Permission denied (publickey)"

Check:
```bash
# Verify private key permissions (must be 600)
ls -l ~/.ssh/id_machines

# Verify public key is in authorized_keys
grep "brain-cluster" ~/.ssh/authorized_keys

# Check SSH config syntax
ssh -G hostname
```

### "Connection refused"

Check:
```bash
# Verify SSH server is running
sudo systemctl status sshd  # Linux
sudo systemctl status ssh   # Ubuntu/Debian

# Check if SSH port is open
nc -zv hostname 22
```

### "Host key verification failed"

```bash
# Remove old host key
ssh-keygen -R hostname

# Or clear all known hosts
rm ~/.ssh/known_hosts
```

### Connection works but asks for password

```bash
# Check authorized_keys permissions (should be 600 or 644)
ssh hostname "ls -l ~/.ssh/authorized_keys"

# Verify the public key matches
diff <(ssh-keygen -lf ~/.ssh/id_machines.pub) \
     <(ssh hostname "ssh-keygen -lf ~/.ssh/id_machines.pub")
```

## Advanced: Adding More Machines

To add a fourth machine (e.g., world.local):

1. Copy the shared key to the new machine:
   ```bash
   scp ~/.ssh/id_machines* world.local:~/.ssh/
   ```

2. Add the public key to its authorized_keys:
   ```bash
   cat ~/.ssh/id_machines.pub | ssh world.local "cat >> ~/.ssh/authorized_keys"
   ```

3. Create SSH config on the new machine for all other machines

4. Update SSH configs on all existing machines to include the new machine

5. Test connectivity in all directions

## Useful Commands Reference

### View your public key
```bash
cat ~/.ssh/id_machines.pub
```

### View key fingerprint
```bash
ssh-keygen -lf ~/.ssh/id_machines
```

### Test SSH connection with verbose output
```bash
ssh -v hostname
```

### Copy files with progress
```bash
rsync -av --progress source/ destination/
```

### Copy files excluding patterns
```bash
rsync -av --exclude='*.log' source/ destination/
```

### SSH with specific key
```bash
ssh -i ~/.ssh/id_machines user@hostname
```

## Conclusion

You now have a fully configured SSH cluster where all machines can seamlessly communicate with each other. This setup is ideal for:

- Development environments
- Home labs
- Distributed computing projects
- File synchronization between machines
- Remote script execution across multiple hosts

Remember to keep your private keys secure and only use this setup on trusted networks!

## Additional Resources

- [OpenSSH Manual](https://www.openssh.com/manual.html)
- [SSH Config File Documentation](https://man.openbsd.org/ssh_config)
- [SSH Security Best Practices](https://infosec.mozilla.org/guidelines/openssh)
- [Rsync Manual](https://linux.die.net/man/1/rsync)
