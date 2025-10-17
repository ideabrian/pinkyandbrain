# Setup Guide 02: Network Configuration & IP Addresses

**Goal**: Understand and document your three-machine network setup

## Your Network Map

```
Router (192.168.5.x network)
├── maxyolo (laptop)  → 192.168.5.76
├── pinky (Mac mini)  → 192.168.5.80
└── brain (Mac mini)  → [TBD]
```

## Understanding IP Addresses

### What is 192.168.5.80?

**192.168.x.x** = Private network addresses
- `192` = Part of private address space (not on public internet)
- `168` = Continued private space marker
- `.5` = Your subnet (like a "neighborhood" in your network)
- `.80` = pinky's specific address (like a house number)

**Other special addresses you saw:**
- `192.168.5.255` = Broadcast address (talks to ALL devices on subnet)
- `127.0.0.1` = Localhost (your own machine)

### Why Private Networks?

**Inside your home:**
- Devices use private addresses (192.168.x.x, 10.x.x.x)
- Free to assign, no registration needed
- Safe from direct internet access

**Connecting to internet:**
- Your router uses NAT (Network Address Translation)
- Translates private → public address
- All devices share one public IP
- This is why you have a router!

## Hostname Resolution

macOS includes Bonjour (mDNS) which lets you use `.local` names:

**Instead of:** `ssh pinky@192.168.5.80`
**You can use:** `ssh pinky@pinky.local` or just `ssh pinky`

### How .local Works

1. You type `pinky.local`
2. macOS broadcasts: "Who is pinky?"
3. pinky responds: "I'm at 192.168.5.80"
4. Connection established

**Note**: Only works on same local network!

## Current SSH Setup

You can now connect with just:
```bash
ssh pinky
```

This works because:
1. `~/.ssh/config` defines the `pinky` host
2. Uses IP address 192.168.5.80
3. Uses password-less key `~/.ssh/id_machines`
4. Logs in as user `pinky`

## Network Troubleshooting

### Find device on network
```bash
# Ping by .local name
ping -c 3 pinky.local

# Scan your subnet for all devices (requires nmap)
nmap -sn 192.168.5.0/24
```

### Check your own IP
```bash
# On macOS
ifconfig | grep "inet " | grep -v 127.0.0.1

# Just WiFi
ipconfig getifaddr en0
```

### Test connectivity
```bash
# Can you reach pinky?
ping -c 3 192.168.5.80

# Is SSH port open?
nc -zv 192.168.5.80 22
```

## Ports Explained

Every service uses a "port number" - like different doors into a building:

- **22** = SSH (remote terminal access)
- **80** = HTTP (websites)
- **443** = HTTPS (secure websites)
- **3000** = Common development server port
- **5432** = PostgreSQL database
- **3306** = MySQL database

When you connect to `192.168.5.80:22`, you're saying:
- Go to IP address 192.168.5.80
- Knock on door #22 (SSH service)

## Firewall & Security

**Your setup is secure because:**
1. Private network only (192.168.x.x not accessible from internet)
2. SSH key authentication (not just passwords)
3. macOS firewall can be enabled for extra protection

**To check firewall status:**
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

## Next: Adding Brain

When brain comes online:
1. Get its IP: `ifconfig | grep "inet "`
2. Add to SSH config
3. Copy `id_machines.pub` key
4. Test connection

See **SETUP-GUIDE-03-ORCHESTRATION.md** for running commands across all machines!

---
**Status**: Complete when you understand your network layout and can ssh to pinky without password
