# Audio URL Reader - Distributed AI Workflow

**Drop a URL, hear it summarized and read aloud**

Uses both Mac machines in a distributed workflow:
- **Max (orchestrator)**: Receives URL, coordinates workflow
- **Pinky (executor)**: Fetches, analyzes, summarizes
- **Audio system**: Reads summary aloud with distinct voices

---

## Quick Start

```bash
# On Max (maxyolo)
./read-url.sh https://learn.omacom.io/3/omacom/76/omakase-computing
```

That's it! Within 10-15 seconds, you'll hear the summary.

---

## How It Works

### Architecture

```
Max (Orchestrator)
    ↓ (sends URL task)
Pinky (Executor)
    ├─ Fetches URL content
    ├─ Analyzes with AI (or extracts key text)
    └─ Sends 2-3 sentence summary back
    ↓
Audio Bridge (polls message bus)
    ↓
Audio Inbox (port 3200)
    └─ Reads aloud with Pinky's voice (Allison Enhanced)
```

### Workflow Steps

1. **Max receives URL** (from you)
   ```bash
   ./read-url.sh <url>
   ```

2. **Max sends task to Pinky**
   - Via message bus (port 3100)
   - Priority: high
   - Task: "Fetch and summarize this URL for audio"

3. **Pinky processes**
   - Fetches URL content (HTTP/HTTPS)
   - Extracts main text
   - Summarizes to 2-3 sentences
   - Optimizes for audio playback

4. **Pinky sends result back**
   - Via message bus to Max
   - Contains clean summary

5. **Audio bridge picks up**
   - Polls every 3 seconds
   - Finds Pinky's message
   - Queues to audio inbox

6. **Audio system plays**
   - Pinky's voice (Allison Enhanced)
   - Sequential playback (no overlap)
   - Clear, natural speech

---

## Manual Workflow (Step by Step)

### On Max:

```bash
# Send task to Pinky
cd ~/Documents/projects/pinkyandbrain
./pinky-cli.sh send "Fetch and summarize https://example.com" --to pinky-claude
```

### On Pinky (or Pinky's Claude session):

```bash
# 1. Check inbox
pinky inbox

# 2. Fetch URL (example using curl + AI)
curl -s https://example.com | head -1000 > /tmp/content.txt

# 3. Summarize (manually or with AI)
# Extract 2-3 key sentences

# 4. Send back
pinky send "Summary: <your summary here>" --to maxyolo-claude
```

### Back on Max:

```bash
# Audio bridge automatically picks up Pinky's message
# Wait ~3-5 seconds, then:
curl -X POST http://localhost:3200/api/inbox/play-all
```

---

## Automated Workflow (with URL Handler)

### Setup on Pinky:

```bash
# Copy handler to Pinky
scp ~/Documents/projects/pinkyandbrain/workflows/pinky-url-handler.js pinky:~/

# On Pinky, start the handler
ssh pinky "node ~/pinky-url-handler.js > ~/url-handler.log 2>&1 &"
```

### Now on Max:

```bash
# Just drop URLs!
./read-url.sh https://example.com

# Handler automatically:
# - Detects URL task
# - Fetches content
# - Summarizes
# - Sends back
# - Audio system plays
```

---

## Voice Assignments

Each agent has a distinct voice:

- **Max/Maxyolo** → Evan (male, orchestrator)
- **Pinky** → Allison (Enhanced) (female, executor)
- **Brain** → Daniel (British, planner)

When Pinky sends the summary back, you'll hear it in Allison's voice!

---

## Customization

### Change Summary Length

Edit `pinky-url-handler.js` line 85:

```javascript
// Get first 500 characters
if (text.length > 500) {  // Change this number
```

### Change Voice

Edit `audio-bridge.js` line 48:

```javascript
'pinky': 'Allison (Enhanced)',  // Try: 'Samantha', 'Victoria', 'Karen'
```

### Change Polling Interval

Edit `pinky-url-handler.js` line 9:

```javascript
const POLL_INTERVAL = 5000; // Change from 5 seconds
```

---

## Advanced Usage

### With AI Summarization

For better summaries, use Claude API or WebFetch:

```javascript
// In pinky-url-handler.js, replace summarizeText() with:
async function summarizeWithAI(text) {
    // Call Claude API or use WebFetch tool
    // Return 2-3 sentence summary
}
```

### Audio File Generation

Instead of real-time TTS, generate audio files:

```bash
# On Pinky, after summarizing:
say -v "Allison (Enhanced)" -o /tmp/summary.aiff "Your summary here"

# Transfer to Max
scp /tmp/summary.aiff maxyolo:/tmp/

# Play on Max
afplay /tmp/summary.aiff
```

---

## Examples

### Example 1: Blog Post

```bash
./read-url.sh https://blog.example.com/my-article
```

**You hear:** "pinky says: This article discusses the benefits of distributed computing. It explains how multiple machines can work together to solve problems faster than a single machine. The key advantage is parallel processing and fault tolerance."

### Example 2: Documentation

```bash
./read-url.sh https://docs.example.com/getting-started
```

**You hear:** "pinky says: The getting started guide walks through installation and basic usage. You need Node.js version 18 or higher and a GitHub account. The setup process takes about 5 minutes."

### Example 3: News Article

```bash
./read-url.sh https://news.example.com/tech-update
```

**You hear:** "pinky says: New developments in artificial intelligence show promising results. Researchers achieved a 40 percent improvement in accuracy. The technology will be available commercially next year."

---

## Troubleshooting

### URL not processing?

Check Pinky's handler is running:

```bash
ssh pinky "ps aux | grep url-handler"
```

If not, start it:

```bash
ssh pinky "cd ~ && node pinky-url-handler.js > ~/url-handler.log 2>&1 &"
```

### No audio playback?

1. Check audio server:
   ```bash
   curl http://localhost:3200/health
   ```

2. Check audio bridge:
   ```bash
   ps aux | grep audio-bridge
   ```

3. Manual trigger:
   ```bash
   curl -X POST http://localhost:3200/api/inbox/play-all
   ```

### Summary too short/long?

Edit `pinky-url-handler.js` line 85 to change character limit.

---

## Files

- **read-url.sh** - Main command (Max)
- **workflows/fetch-and-read.sh** - Full workflow orchestrator
- **workflows/pinky-url-handler.js** - Automated processor (Pinky)
- **audio-bridge.js** - Message bus to audio bridge
- **hook-announce/index.js** - Audio inbox server

---

## Future Enhancements

- [ ] AI-powered summarization (Claude API)
- [ ] Multi-language support
- [ ] Podcast mode (save summaries as audio files)
- [ ] PDF support
- [ ] YouTube transcript extraction
- [ ] Batch processing (multiple URLs)
- [ ] Summary caching (don't re-fetch same URL)
- [ ] Voice selection per URL type (news = one voice, docs = another)

---

**Built with:** Mac minis, Node.js, macOS TTS, distributed message passing

**Philosophy:** "Three machines are better than one" - learning distributed systems hands-on
