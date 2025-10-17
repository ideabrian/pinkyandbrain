#!/usr/bin/env node

// pinky-url-handler.js - Automatically fetch and summarize URLs from tasks
// Runs on Pinky, monitors inbox for URL fetch tasks

const http = require('http');
const https = require('https');

const LOCAL_BUS = 'http://localhost:3100';
const MAX_BUS = 'http://192.168.5.76:3100';
const POLL_INTERVAL = 5000; // 5 seconds
const SEEN_TASKS = new Set();

console.log('🤖 Pinky URL Handler Started');
console.log('   Monitoring inbox for URL fetch tasks...\n');

// Helper: Fetch JSON from URL
async function fetchJSON(url) {
    return new Promise((resolve, reject) => {
        const client = url.startsWith('https') ? https : http;
        client.get(url, (res) => {
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

// Helper: Fetch HTML content
async function fetchHTML(url) {
    return new Promise((resolve, reject) => {
        const client = url.startsWith('https') ? https : http;
        client.get(url, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve(data));
        }).on('error', reject);
    });
}

// Helper: Send message back to Max
async function sendToMax(subject, body) {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify({
            from: 'pinky-claude',
            to: 'maxyolo-claude',
            subject: subject,
            body: body,
            priority: 'normal'
        });

        const options = {
            hostname: '192.168.5.76',
            port: 3100,
            path: '/send',
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

// Simple text summarizer (extract first paragraph and key sentences)
function summarizeText(html) {
    // Strip HTML tags
    let text = html.replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
                   .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
                   .replace(/<[^>]+>/g, ' ')
                   .replace(/\s+/g, ' ')
                   .trim();

    // Get first 500 characters as summary
    if (text.length > 500) {
        text = text.substring(0, 500);
        // Find last complete sentence
        const lastPeriod = text.lastIndexOf('.');
        if (lastPeriod > 200) {
            text = text.substring(0, lastPeriod + 1);
        }
    }

    return text;
}

// Extract URL from task body
function extractURL(text) {
    const urlMatch = text.match(/https?:\/\/[^\s]+/);
    return urlMatch ? urlMatch[0] : null;
}

// Check inbox for URL fetch tasks
async function checkInbox() {
    try {
        const inbox = await fetchJSON(`${LOCAL_BUS}/inbox`);
        const unreadMessages = (inbox.messages || []).filter(m => !m.read);

        for (const msg of unreadMessages) {
            // Skip if already processed
            if (SEEN_TASKS.has(msg.id)) {
                continue;
            }

            // Check if message is a URL fetch task
            const isURLTask = msg.body && (
                msg.body.toLowerCase().includes('fetch') ||
                msg.body.toLowerCase().includes('summarize')
            ) && msg.body.match(/https?:\/\//);

            if (!isURLTask) {
                continue;
            }

            SEEN_TASKS.add(msg.id);

            console.log(`\n📥 New URL task from ${msg.from}`);
            const url = extractURL(msg.body);

            if (!url) {
                console.log('   ❌ No URL found in task');
                continue;
            }

            console.log(`   URL: ${url}`);
            console.log('   Fetching...');

            try {
                // Fetch URL content
                const html = await fetchHTML(url);
                console.log(`   ✅ Fetched ${html.length} characters`);

                // Summarize
                const summary = summarizeText(html);
                console.log(`   📝 Summary: ${summary.substring(0, 100)}...`);

                // Send back to Max
                await sendToMax('URL Summary Complete', summary);
                console.log('   ✅ Sent summary to Max');

            } catch (error) {
                console.error(`   ❌ Error: ${error.message}`);
                await sendToMax('URL Fetch Failed', `Failed to fetch ${url}: ${error.message}`);
            }
        }

    } catch (error) {
        // Silently fail on network errors
    }
}

// Main loop
setInterval(checkInbox, POLL_INTERVAL);
checkInbox(); // Initial check

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n\n🛑 Pinky URL Handler stopped');
    process.exit(0);
});
