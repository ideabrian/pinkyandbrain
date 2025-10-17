/**
 * Pinky & Brain Cloud Message Bus
 * Cloudflare Workers + D1 Database
 *
 * Enables autonomous workflows from anywhere in the world!
 */

interface Env {
  DB: D1Database;
  API_KEY: string;
}

interface BuildRequest {
  idea: string;
  description?: string;
  priority?: 'low' | 'normal' | 'high';
}

interface Message {
  id: string;
  workflow_id: string;
  from_machine: string;
  to_machine: string;
  subject: string;
  body: string;
  priority: string;
  status: string;
  created_at: number;
  read_at?: number;
  metadata?: string;
}

// CORS headers for iPhone/browser access
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
};

// Simple auth middleware
function checkAuth(request: Request, env: Env): boolean {
  const apiKey = request.headers.get('X-API-Key');
  return apiKey === env.API_KEY;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Public endpoints (no auth needed)
    if (path === '/health' && request.method === 'GET') {
      return new Response(JSON.stringify({
        status: 'ok',
        service: 'pinky-brain-hub',
        timestamp: Date.now(),
        edge: request.cf?.colo || 'unknown'
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // GET /timeline - Public timeline (no auth)
    if (path === '/timeline' && request.method === 'GET') {
      const limit = parseInt(url.searchParams.get('limit') || '50');
      const machine = url.searchParams.get('machine') || null;
      return await handleGetTimeline(limit, machine, env);
    }

    // All other endpoints require auth
    if (!checkAuth(request, env)) {
      return new Response(JSON.stringify({
        error: 'Unauthorized',
        message: 'Missing or invalid X-API-Key header'
      }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // Route handlers
    try {
      // POST /build - Trigger workflow from iPhone
      if (path === '/build' && request.method === 'POST') {
        return await handleBuild(request, env);
      }

      // GET /poll/:machine - Poll for new messages
      if (path.startsWith('/poll/') && request.method === 'GET') {
        const machine = path.split('/')[2];
        return await handlePoll(machine, env);
      }

      // POST /complete/:messageId - Mark message as complete
      if (path.startsWith('/complete/') && request.method === 'POST') {
        const messageId = path.split('/')[2];
        return await handleComplete(messageId, env);
      }

      // GET /workflow/:id - Get workflow status
      if (path.startsWith('/workflow/') && request.method === 'GET') {
        const workflowId = path.split('/')[2];
        return await handleWorkflowStatus(workflowId, env);
      }

      // POST /update/:workflowId - Update workflow status
      if (path.startsWith('/update/') && request.method === 'POST') {
        const workflowId = path.split('/')[2];
        return await handleWorkflowUpdate(workflowId, request, env);
      }

      // GET /messages - List all messages (admin)
      if (path === '/messages' && request.method === 'GET') {
        return await handleListMessages(env);
      }

      // ━━━ Knowledge Sharing Endpoints ━━━

      // POST /knowledge - Share a learning
      if (path === '/knowledge' && request.method === 'POST') {
        return await handleShareKnowledge(request, env);
      }

      // GET /knowledge/search - Search knowledge base
      if (path === '/knowledge/search' && request.method === 'GET') {
        const query = url.searchParams.get('q') || '';
        const topic = url.searchParams.get('topic');
        const category = url.searchParams.get('category');
        return await handleSearchKnowledge(query, topic, category, env);
      }

      // GET /knowledge/recent - Get recent learnings
      if (path === '/knowledge/recent' && request.method === 'GET') {
        const limit = parseInt(url.searchParams.get('limit') || '10');
        return await handleRecentKnowledge(limit, env);
      }

      // GET /knowledge/:id - Get specific learning
      if (path.startsWith('/knowledge/') && request.method === 'GET' && !path.includes('search') && !path.includes('recent')) {
        const knowledgeId = path.split('/')[2];
        return await handleGetKnowledge(knowledgeId, env);
      }

      // POST /knowledge/:id/helpful - Mark as helpful
      if (path.match(/\/knowledge\/[^\/]+\/helpful$/) && request.method === 'POST') {
        const knowledgeId = path.split('/')[2];
        return await handleMarkHelpful(knowledgeId, env);
      }

      // ━━━ Timeline Endpoints ━━━

      // POST /timeline - Add timeline event
      if (path === '/timeline' && request.method === 'POST') {
        return await handleAddTimelineEvent(request, env);
      }

      return new Response(JSON.stringify({
        error: 'Not found',
        endpoints: {
          'POST /build': 'Trigger workflow from iPhone',
          'GET /poll/:machine': 'Poll for messages (brain/pinky/maxyolo)',
          'POST /complete/:messageId': 'Mark message as read',
          'GET /workflow/:id': 'Get workflow status',
          'POST /update/:workflowId': 'Update workflow status',
          'GET /messages': 'List all messages',
          'POST /knowledge': 'Share a learning',
          'GET /knowledge/search?q=X': 'Search knowledge base',
          'GET /knowledge/recent': 'Get recent learnings',
          'GET /knowledge/:id': 'Get specific learning',
          'POST /knowledge/:id/helpful': 'Mark as helpful'
        }
      }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    } catch (error: any) {
      return new Response(JSON.stringify({
        error: 'Internal server error',
        message: error.message
      }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }
  }
};

// POST /build - Trigger workflow from iPhone
async function handleBuild(request: Request, env: Env): Promise<Response> {
  const body: BuildRequest = await request.json();

  if (!body.idea) {
    return new Response(JSON.stringify({
      error: 'Missing required field: idea',
      example: { idea: 'Build me a todo list component' }
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  const workflowId = `workflow-${Date.now()}`;
  const messageId = `${workflowId}-init`;
  const now = Date.now();

  // Create workflow
  await env.DB.prepare(`
    INSERT INTO workflows (workflow_id, idea, description, priority, status, created_at, updated_at)
    VALUES (?, ?, ?, ?, 'planning', ?, ?)
  `).bind(
    workflowId,
    body.idea,
    body.description || '',
    body.priority || 'normal',
    now,
    now
  ).run();

  // Create message to brain
  await env.DB.prepare(`
    INSERT INTO messages (id, workflow_id, from_machine, to_machine, subject, body, priority, status, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?)
  `).bind(
    messageId,
    workflowId,
    'ios-shortcut',
    'brain',
    'New Build Request from iPhone',
    body.description ? `${body.idea}\n\nDetails: ${body.description}` : body.idea,
    body.priority || 'normal',
    now
  ).run();

  return new Response(JSON.stringify({
    success: true,
    workflowId,
    messageId,
    message: 'Workflow started! Your autonomous team will pick this up.',
    status: 'sent_to_brain',
    idea: body.idea,
    trackingUrl: `/workflow/${workflowId}`,
    tip: 'Pollers will check cloud every 10 seconds'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// GET /poll/:machine - Poll for new messages
async function handlePoll(machine: string, env: Env): Promise<Response> {
  const result = await env.DB.prepare(`
    SELECT * FROM messages
    WHERE to_machine = ? AND status = 'pending'
    ORDER BY created_at ASC
    LIMIT 10
  `).bind(machine).all();

  return new Response(JSON.stringify({
    machine,
    unread: result.results?.length || 0,
    messages: result.results || []
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// POST /complete/:messageId - Mark message as complete
async function handleComplete(messageId: string, env: Env): Promise<Response> {
  await env.DB.prepare(`
    UPDATE messages
    SET status = 'completed', read_at = ?
    WHERE id = ?
  `).bind(Date.now(), messageId).run();

  return new Response(JSON.stringify({
    success: true,
    message: 'Message marked as completed'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// GET /workflow/:id - Get workflow status
async function handleWorkflowStatus(workflowId: string, env: Env): Promise<Response> {
  const workflow = await env.DB.prepare(`
    SELECT * FROM workflows WHERE workflow_id = ?
  `).bind(workflowId).first();

  if (!workflow) {
    return new Response(JSON.stringify({
      error: 'Workflow not found',
      workflowId
    }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  const messages = await env.DB.prepare(`
    SELECT * FROM messages WHERE workflow_id = ? ORDER BY created_at ASC
  `).bind(workflowId).all();

  return new Response(JSON.stringify({
    workflow,
    messages: messages.results || [],
    messageCount: messages.results?.length || 0
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// POST /update/:workflowId - Update workflow status
async function handleWorkflowUpdate(workflowId: string, request: Request, env: Env): Promise<Response> {
  const body: any = await request.json();

  await env.DB.prepare(`
    UPDATE workflows
    SET status = ?, updated_at = ?, completed_at = ?, result_url = ?
    WHERE workflow_id = ?
  `).bind(
    body.status || 'planning',
    Date.now(),
    body.completed ? Date.now() : null,
    body.resultUrl || null,
    workflowId
  ).run();

  return new Response(JSON.stringify({
    success: true,
    message: 'Workflow updated'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// GET /messages - List all messages
async function handleListMessages(env: Env): Promise<Response> {
  const result = await env.DB.prepare(`
    SELECT * FROM messages ORDER BY created_at DESC LIMIT 50
  `).all();

  return new Response(JSON.stringify({
    total: result.results?.length || 0,
    messages: result.results || []
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// ━━━ Knowledge Sharing Handlers ━━━

// POST /knowledge - Share a learning
async function handleShareKnowledge(request: Request, env: Env): Promise<Response> {
  const body: any = await request.json();

  if (!body.from_machine || !body.topic || !body.title || !body.learning) {
    return new Response(JSON.stringify({
      error: 'Missing required fields',
      required: ['from_machine', 'topic', 'category', 'title', 'learning'],
      example: {
        from_machine: 'brain',
        topic: 'React',
        category: 'best-practice',
        title: 'useState vs useReducer',
        learning: 'Use useState for simple state, useReducer for complex state with multiple sub-values',
        code_example: 'const [state, dispatch] = useReducer(reducer, initialState);',
        tags: 'react,hooks,state'
      }
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  const knowledgeId = `knowledge-${Date.now()}`;
  const now = Date.now();

  await env.DB.prepare(`
    INSERT INTO knowledge (id, from_machine, topic, category, title, learning, code_example, tags, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).bind(
    knowledgeId,
    body.from_machine,
    body.topic,
    body.category || 'general',
    body.title,
    body.learning,
    body.code_example || null,
    body.tags || null,
    now,
    now
  ).run();

  return new Response(JSON.stringify({
    success: true,
    knowledgeId,
    message: 'Knowledge shared! Your team can now learn from this.',
    from: body.from_machine,
    topic: body.topic
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// GET /knowledge/search - Search knowledge base
async function handleSearchKnowledge(query: string, topic: string | null, category: string | null, env: Env): Promise<Response> {
  let sql = 'SELECT * FROM knowledge WHERE 1=1';
  const params: any[] = [];

  if (query) {
    sql += ' AND (title LIKE ? OR learning LIKE ? OR tags LIKE ?)';
    params.push(`%${query}%`, `%${query}%`, `%${query}%`);
  }

  if (topic) {
    sql += ' AND topic = ?';
    params.push(topic);
  }

  if (category) {
    sql += ' AND category = ?';
    params.push(category);
  }

  sql += ' ORDER BY helpful_count DESC, created_at DESC LIMIT 20';

  const result = await env.DB.prepare(sql).bind(...params).all();

  return new Response(JSON.stringify({
    query,
    topic,
    category,
    results: result.results?.length || 0,
    knowledge: result.results || []
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// GET /knowledge/recent - Get recent learnings
async function handleRecentKnowledge(limit: number, env: Env): Promise<Response> {
  const result = await env.DB.prepare(`
    SELECT * FROM knowledge ORDER BY created_at DESC LIMIT ?
  `).bind(Math.min(limit, 50)).all();

  return new Response(JSON.stringify({
    limit,
    total: result.results?.length || 0,
    knowledge: result.results || []
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// GET /knowledge/:id - Get specific learning
async function handleGetKnowledge(knowledgeId: string, env: Env): Promise<Response> {
  const result = await env.DB.prepare(`
    SELECT * FROM knowledge WHERE id = ?
  `).bind(knowledgeId).first();

  if (!result) {
    return new Response(JSON.stringify({
      error: 'Knowledge not found',
      knowledgeId
    }), {
      status: 404,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  return new Response(JSON.stringify(result), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// POST /knowledge/:id/helpful - Mark as helpful
async function handleMarkHelpful(knowledgeId: string, env: Env): Promise<Response> {
  await env.DB.prepare(`
    UPDATE knowledge SET helpful_count = helpful_count + 1 WHERE id = ?
  `).bind(knowledgeId).run();

  return new Response(JSON.stringify({
    success: true,
    message: 'Marked as helpful!'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// ━━━ Timeline Handlers ━━━

// POST /timeline - Add timeline event
async function handleAddTimelineEvent(request: Request, env: Env): Promise<Response> {
  const body: any = await request.json();

  if (!body.machine || !body.event_type || !body.title) {
    return new Response(JSON.stringify({
      error: 'Missing required fields',
      required: ['machine', 'event_type', 'title'],
      example: {
        machine: 'brain',
        event_type: 'workflow_start',
        title: 'New workflow received',
        description: 'Build me a counter component',
        icon: '🚀',
        metadata: JSON.stringify({ workflow_id: 'workflow-123' })
      }
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  const eventId = `event-${Date.now()}`;
  const now = Date.now();

  await env.DB.prepare(`
    INSERT INTO timeline_events (id, timestamp, machine, event_type, title, description, icon, metadata)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).bind(
    eventId,
    now,
    body.machine,
    body.event_type,
    body.title,
    body.description || null,
    body.icon || null,
    body.metadata || null
  ).run();

  return new Response(JSON.stringify({
    success: true,
    eventId,
    message: 'Timeline event added'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}

// GET /timeline - Get recent timeline events (PUBLIC)
async function handleGetTimeline(limit: number, machine: string | null, env: Env): Promise<Response> {
  let sql = 'SELECT * FROM timeline_events WHERE 1=1';
  const params: any[] = [];

  if (machine) {
    sql += ' AND machine = ?';
    params.push(machine);
  }

  sql += ' ORDER BY timestamp DESC LIMIT ?';
  params.push(Math.min(limit, 100));

  const result = await env.DB.prepare(sql).bind(...params).all();

  return new Response(JSON.stringify({
    total: result.results?.length || 0,
    events: result.results || []
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
}
