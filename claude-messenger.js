#!/usr/bin/env node

/**
 * Claude Messenger - Simple HTTP message bus for multi-agent coordination
 *
 * Each Claude session can:
 * - POST /send - Send message to another agent
 * - GET /inbox - Check for new messages
 * - POST /reply - Reply to a message
 */

const express = require('express');
const fs = require('fs').promises;
const path = require('path');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3100;
const MACHINE_NAME = os.hostname();
const INBOX_FILE = path.join(__dirname, `inbox-${MACHINE_NAME}.json`);

app.use(express.json());

// In-memory message store (persisted to file)
let messages = [];

// Load messages from disk
async function loadMessages() {
  try {
    const data = await fs.readFile(INBOX_FILE, 'utf8');
    messages = JSON.parse(data);
    console.log(`📬 Loaded ${messages.length} messages from disk`);
  } catch (err) {
    console.log('📭 No existing inbox, starting fresh');
    messages = [];
  }
}

// Save messages to disk
async function saveMessages() {
  await fs.writeFile(INBOX_FILE, JSON.stringify(messages, null, 2));
}

// Initialize
loadMessages();

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    machine: MACHINE_NAME,
    messages: messages.length,
    timestamp: new Date().toISOString()
  });
});

// Send a message
app.post('/send', async (req, res) => {
  const { to, from, subject, body, priority = 'normal' } = req.body;

  if (!to || !body) {
    return res.status(400).json({ error: 'Missing required fields: to, body' });
  }

  const message = {
    id: Date.now() + '-' + Math.random().toString(36).substr(2, 9),
    to,
    from: from || MACHINE_NAME,
    subject: subject || 'No subject',
    body,
    priority,
    timestamp: new Date().toISOString(),
    read: false,
    replies: []
  };

  messages.unshift(message); // Add to front
  await saveMessages();

  console.log(`📤 Message sent: ${from || MACHINE_NAME} → ${to}`);

  res.json({
    success: true,
    messageId: message.id,
    message: 'Message sent'
  });
});

// Get inbox (all messages for this machine)
app.get('/inbox', (req, res) => {
  const unreadCount = messages.filter(m => !m.read && m.to === MACHINE_NAME).length;

  res.json({
    machine: MACHINE_NAME,
    total: messages.length,
    unread: unreadCount,
    messages: messages.map(m => ({
      id: m.id,
      from: m.from,
      to: m.to,
      subject: m.subject,
      body: m.body,
      priority: m.priority,
      timestamp: m.timestamp,
      read: m.read,
      replyCount: m.replies.length
    }))
  });
});

// Get unread messages only
app.get('/inbox/unread', (req, res) => {
  const unread = messages.filter(m => !m.read && m.to === MACHINE_NAME);

  res.json({
    machine: MACHINE_NAME,
    unread: unread.length,
    messages: unread
  });
});

// Mark message as read
app.post('/inbox/:id/read', async (req, res) => {
  const msg = messages.find(m => m.id === req.params.id);

  if (!msg) {
    return res.status(404).json({ error: 'Message not found' });
  }

  msg.read = true;
  await saveMessages();

  res.json({ success: true, message: 'Message marked as read' });
});

// Reply to a message
app.post('/reply/:id', async (req, res) => {
  const msg = messages.find(m => m.id === req.params.id);

  if (!msg) {
    return res.status(404).json({ error: 'Message not found' });
  }

  const { body } = req.body;
  if (!body) {
    return res.status(400).json({ error: 'Reply body required' });
  }

  const reply = {
    from: MACHINE_NAME,
    body,
    timestamp: new Date().toISOString()
  };

  msg.replies.push(reply);
  await saveMessages();

  // Send reply as new message to original sender
  const replyMessage = {
    id: Date.now() + '-' + Math.random().toString(36).substr(2, 9),
    to: msg.from,
    from: MACHINE_NAME,
    subject: `Re: ${msg.subject}`,
    body,
    priority: msg.priority,
    timestamp: new Date().toISOString(),
    read: false,
    replies: []
  };

  messages.unshift(replyMessage);
  await saveMessages();

  res.json({ success: true, message: 'Reply sent' });
});

// Get all messages (for debugging)
app.get('/messages/all', (req, res) => {
  res.json({ messages });
});

// Clear all messages
app.delete('/messages/all', async (req, res) => {
  messages = [];
  await saveMessages();
  res.json({ success: true, message: 'All messages cleared' });
});

// ━━━ iOS Shortcuts Integration ━━━

// POST /build - Trigger autonomous workflow from iPhone
app.post('/build', async (req, res) => {
  const { idea, description, priority = 'normal' } = req.body;

  if (!idea) {
    return res.status(400).json({
      error: 'Missing required field: idea',
      example: {
        idea: 'Build me a todo list component',
        description: 'Optional extra details',
        priority: 'normal'
      }
    });
  }

  // Create workflow ID
  const workflowId = `workflow-${Date.now()}`;

  // Send to brain to start planning
  const message = {
    id: `${workflowId}-init`,
    to: 'brain',
    from: 'ios-shortcut',
    subject: 'New Build Request from iPhone',
    body: description ? `${idea}\n\nDetails: ${description}` : idea,
    priority,
    timestamp: new Date().toISOString(),
    read: false,
    replies: [],
    metadata: {
      workflowId,
      source: 'ios-shortcut',
      device: req.headers['user-agent'] || 'iPhone'
    }
  };

  messages.unshift(message);
  await saveMessages();

  console.log(`📱 iPhone workflow triggered: ${workflowId}`);
  console.log(`   Idea: ${idea}`);

  res.json({
    success: true,
    workflowId,
    message: 'Workflow started! Your autonomous team is building it now.',
    status: 'sent_to_brain',
    idea,
    trackingUrl: `http://${MACHINE_NAME}:${PORT}/workflow/${workflowId}`,
    tip: 'Pollers will pick this up and start working automatically'
  });
});

// GET /workflow/:id - Check workflow status
app.get('/workflow/:id', (req, res) => {
  const workflowId = req.params.id;

  // Find all messages related to this workflow
  const workflowMessages = messages.filter(m =>
    m.id.includes(workflowId) ||
    (m.metadata && m.metadata.workflowId === workflowId) ||
    m.body.includes(workflowId)
  );

  if (workflowMessages.length === 0) {
    return res.status(404).json({
      error: 'Workflow not found',
      workflowId
    });
  }

  // Determine status based on message flow
  let status = 'unknown';
  const hasInitMessage = workflowMessages.some(m => m.to === 'brain');
  const hasPinkyMessage = workflowMessages.some(m => m.to === 'pinky');
  const hasMaxyoloMessage = workflowMessages.some(m => m.to === 'maxyolo');

  if (hasMaxyoloMessage) {
    status = 'reviewing';
  } else if (hasPinkyMessage) {
    status = 'implementing';
  } else if (hasInitMessage) {
    status = 'planning';
  }

  res.json({
    workflowId,
    status,
    messages: workflowMessages.length,
    timeline: workflowMessages.map(m => ({
      from: m.from,
      to: m.to,
      subject: m.subject,
      timestamp: m.timestamp,
      read: m.read
    })).reverse(),
    lastUpdate: workflowMessages[0]?.timestamp
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════╗
║   Claude Messenger                     ║
║   Machine: ${MACHINE_NAME.padEnd(27)}║
║   Port: ${PORT.toString().padEnd(30)}║
╚═══════════════════════════════════════╝

📡 Message bus online
📬 Inbox: ${INBOX_FILE}

API Endpoints:
  POST   /send              - Send message
  GET    /inbox             - View all messages
  GET    /inbox/unread      - View unread messages
  POST   /inbox/:id/read    - Mark as read
  POST   /reply/:id         - Reply to message
  GET    /health            - Health check

  📱 iOS Shortcuts:
  POST   /build             - Trigger autonomous workflow from iPhone
  GET    /workflow/:id      - Check workflow status

Ready for multi-agent communication! 🤖💬🤖
📱 iOS Shortcuts enabled!
  `);
});
