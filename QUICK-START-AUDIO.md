# Audio URL Reader - Quick Start

## 🚀 One-Line Usage

```bash
./read-url.sh https://learn.omacom.io/3/omacom/76/omakase-computing
```

Wait 10-15 seconds → Hear the summary!

---

## 🎯 What Just Happened?

1. **Max** (you) sent URL to **Pinky**
2. **Pinky** fetched and summarized it
3. **Audio system** read it aloud in Pinky's voice

---

## 🔧 Setup (One Time)

### 1. Start Audio Services (on Max)

```bash
# Audio server (port 3200)
cd ~/Documents/projects/hook-announce
node index.js > audio-server.log 2>&1 &

# Audio bridge (connects message bus to audio)
cd ~/Documents/projects/pinkyandbrain
node audio-bridge.js > audio-bridge.log 2>&1 &
```

### 2. Start URL Handler (on Pinky) - Optional

```bash
# Copy handler to Pinky
scp ~/Documents/projects/pinkyandbrain/workflows/pinky-url-handler.js pinky:~/

# Start handler on Pinky
ssh pinky "node ~/pinky-url-handler.js > ~/url-handler.log 2>&1 &"
```

**Note:** Without the handler, you can still do this manually in Pinky's Claude session!

---

## 📖 Manual Workflow (No Handler)

### Step 1: Send URL to Pinky

```bash
cd ~/Documents/projects/pinkyandbrain
./pinky-cli.sh send "Summarize this URL: https://example.com" --to pinky-claude
```

### Step 2: In Pinky's Claude Session

```
Fetch and summarize the URL, then send back:

pinky send "<your 2-3 sentence summary>" --to maxyolo-claude
```

### Step 3: Wait ~5 seconds

The audio bridge will pick it up and play it automatically!

---

## 🎤 Voices

- **Max**: Evan (male)
- **Pinky**: Allison Enhanced (female)
- **Brain**: Daniel (British)

---

## 🛠️ Commands

```bash
# Send any URL
./read-url.sh <url>

# Check audio inbox
curl http://localhost:3200/api/inbox | jq

# Manual playback trigger
curl -X POST http://localhost:3200/api/inbox/play-all

# Check what's in message bus
curl http://192.168.5.76:3100/inbox | jq '.messages[0:5]'
```

---

## 🐛 Troubleshooting

### No audio?

```bash
# Check audio server
curl http://localhost:3200/health

# Restart if needed
pkill -f "node index.js"
cd ~/Documents/projects/hook-announce && node index.js > audio-server.log 2>&1 &
```

### Pinky not responding?

Check if handler is running:

```bash
ssh pinky "ps aux | grep url-handler"
```

Or just do it manually in Pinky's Claude session!

---

## 📚 Full Documentation

See: `AUDIO-URL-READER.md`

---

**That's it!** Drop URLs, hear summaries. 🎧
