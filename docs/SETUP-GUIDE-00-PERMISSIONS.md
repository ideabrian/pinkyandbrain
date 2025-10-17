# Setup Guide 00: macOS Permissions & Security

**Goal**: Grant necessary permissions for SSH, Terminal, and system configuration

## What is "Full Disk Access"?

macOS security feature that controls which apps can:
- Access all files on your Mac
- Modify system settings
- Enable/disable system services (like Remote Login)

**Why you need it**: Terminal needs permission to enable SSH server (Remote Login)

## Granting Full Disk Access to Terminal

**On pinky** (the Mac mini you're setting up):

### Step 1: Open System Settings
```
Click  menu → System Settings
```

### Step 2: Navigate to Privacy & Security
```
System Settings → Privacy & Security
```

### Step 3: Full Disk Access
```
Privacy & Security → Full Disk Access
```

**You may need to click the lock icon 🔒 at bottom and enter your password**

### Step 4: Add Terminal
```
1. Click the [+] button
2. Navigate to: Applications → Utilities → Terminal
3. Select Terminal.app
4. Click "Open"
5. Toggle Terminal ON (switch should be blue/green)
```

### Step 5: If Using iTerm2 (Instead of Terminal)
```
Same steps, but select:
Applications → iTerm.app
```

**Important**: You may need to **quit and restart Terminal/iTerm** for permissions to take effect.

## Alternative: Using GUI for Remote Login

If Terminal is still giving you trouble, enable Remote Login via GUI:

### Method 1: System Settings (macOS Ventura+)
```
1. System Settings
2. General
3. Sharing
4. Toggle "Remote Login" ON
5. Click (i) info button
6. Make sure your user is in "Allow access for:" list
```

### Method 2: System Preferences (macOS Monterey and earlier)
```
1. System Preferences
2. Sharing
3. Check "Remote Login" checkbox
4. Verify your user is allowed
```

## Verifying Remote Login is Enabled

In Terminal on pinky:
```bash
# Check if Remote Login is on
sudo systemsetup -getremotelogin

# Should output: Remote Login: On
```

**If it says "Off"**, try:
```bash
sudo systemsetup -setremotelogin on
```

## Common Issues

**"Operation not permitted" error**
- Terminal doesn't have Full Disk Access
- Follow steps above to grant it

**Can't unlock Privacy & Security settings**
- Need admin password
- Make sure you're logged in as admin user

**Changes don't take effect**
- Quit Terminal completely (Cmd+Q)
- Reopen Terminal
- Try command again

## Security Note

**Full Disk Access = Powerful Permission**
- Only grant to apps you trust
- Terminal is safe (it's made by Apple)
- iTerm2 is safe (open source, widely used)

You can revoke access anytime by toggling it OFF in Privacy & Security settings.

## Next Steps

Once Remote Login is enabled on pinky:
- Return to **SETUP-GUIDE-01-SSH.md** to continue SSH setup
- Test connection from maxyolo: `ssh maxyolo@192.168.5.80`

---
**Status**: Complete when `sudo systemsetup -getremotelogin` shows "On"
