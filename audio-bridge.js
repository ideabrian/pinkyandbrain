#!/usr/bin/env node

// audio-bridge.js - Bridge message bus to audio inbox
// Polls message buses and sends new messages to audio server

const http = require('http');

// Configuration
const AUDIO_SERVER = 'http://localhost:3200';
const SECRET_KEY = '2SQG7DVohylO06huwjAUKcYaS6d9XyPr';

const MESSAGE_BUSES = [
    { name: 'maxyolo', url: 'http://192.168.5.76:3100' },
    { name: 'pinky', url: 'http://192.168.5.80:3100' }
    // Add brain when ready: { name: 'brain', url: 'http://192.168.5.XX:3100' }
];

const POLL_INTERVAL = 3000; // 3 seconds
const SEEN_MESSAGES = new Set(); // Track already-announced messages

console.log('🔊 Audio Bridge Started');
console.log(`   Polling: ${MESSAGE_BUSES.map(b => b.name).join(', ')}`);
console.log(`   Audio Server: ${AUDIO_SERVER}`);
console.log(`   Interval: ${POLL_INTERVAL}ms\n`);

// Helper: Fetch JSON
async function fetchJSON(url) {
    return new Promise((resolve, reject) => {
        http.get(url, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(data));
                } catch (error) {
                    reject(error);
                }
            });
        }).on('error', reject);
    });
}

// Voice mapping for each agent
const AGENT_VOICES = {
    'maxyolo': 'Evan',              // Orchestrator - calm male
    'max': 'Evan',
    'orchestrator': 'Evan',         // Orchestrator alias
    'pinky': 'Allison (Enhanced)',  // Executor - enhanced female
    'brain': 'Daniel'               // Planner - British accent
};

// Helper: POST to audio server
async function announceMessage(text, metadata = {}) {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify({
            message: text,
            voice: metadata.voice || null,
            secret: SECRET_KEY,
            _metadata: metadata
        });

        const options = {
            hostname: 'localhost',
            port: 3200,
            path: '/announce',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };

        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve(data));
        });

        req.on('error', reject);
        req.write(postData);
        req.end();
    });
}

// Poll a single message bus
async function pollBus(bus) {
    try {
        const inbox = await fetchJSON(`${bus.url}/inbox`);

        // Filter for unread messages on client side
        const unreadMessages = (inbox.messages || []).filter(m => m.read === false);

        if (unreadMessages.length > 0) {
            console.log(`\n📬 ${bus.name}: ${unreadMessages.length} unread messages`);

            for (const msg of unreadMessages) {
                // Skip if already seen
                if (SEEN_MESSAGES.has(msg.id)) {
                    continue;
                }

                // Mark as seen
                SEEN_MESSAGES.add(msg.id);

                // Shorten agent names for natural speech
                const from = msg.from.replace('-claude', '');

                // Build announcement text - simple format
                const announcement = `${from} says: ${msg.body}`;

                // Get voice for this agent
                const voice = AGENT_VOICES[from] || AGENT_VOICES[msg.from] || null;

                console.log(`   🔊 Announcing: "${announcement.substring(0, 80)}..." (voice: ${voice})`);

                // Send to audio server
                try {
                    await announceMessage(announcement, {
                        source: 'message-bus',
                        bus: bus.name,
                        message_id: msg.id,
                        from: msg.from,
                        to: msg.to,
                        type: msg.type,
                        priority: msg.priority,
                        voice: voice
                    });
                } catch (error) {
                    console.error(`   ❌ Failed to announce: ${error.message}`);
                }
            }
        }
    } catch (error) {
        // Silently fail if bus is unreachable
        // (don't spam console when agents are offline)
    }
}

// Main polling loop
async function poll() {
    for (const bus of MESSAGE_BUSES) {
        await pollBus(bus);
    }

    // Clean up old seen messages (keep last 1000)
    if (SEEN_MESSAGES.size > 1000) {
        const arr = Array.from(SEEN_MESSAGES);
        SEEN_MESSAGES.clear();
        arr.slice(-500).forEach(id => SEEN_MESSAGES.add(id));
    }
}

// Start polling
setInterval(poll, POLL_INTERVAL);

// Initial poll
poll();

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n\n🛑 Audio Bridge stopped');
    process.exit(0);
});
