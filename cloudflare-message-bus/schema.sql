-- Pinky & Brain Message Bus Schema

CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY,
  workflow_id TEXT NOT NULL,
  from_machine TEXT NOT NULL,
  to_machine TEXT NOT NULL,
  subject TEXT NOT NULL,
  body TEXT NOT NULL,
  priority TEXT DEFAULT 'normal',
  status TEXT DEFAULT 'pending',
  created_at INTEGER NOT NULL,
  read_at INTEGER,
  metadata TEXT
);

CREATE INDEX IF NOT EXISTS idx_workflow_id ON messages(workflow_id);
CREATE INDEX IF NOT EXISTS idx_to_machine ON messages(to_machine);
CREATE INDEX IF NOT EXISTS idx_status ON messages(status);
CREATE INDEX IF NOT EXISTS idx_created_at ON messages(created_at);

CREATE TABLE IF NOT EXISTS workflows (
  workflow_id TEXT PRIMARY KEY,
  idea TEXT NOT NULL,
  description TEXT,
  priority TEXT DEFAULT 'normal',
  status TEXT DEFAULT 'planning',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  completed_at INTEGER,
  result_url TEXT,
  metadata TEXT
);

CREATE INDEX IF NOT EXISTS idx_workflow_status ON workflows(status);
CREATE INDEX IF NOT EXISTS idx_workflow_created ON workflows(created_at);

-- Knowledge Base for cross-team learning
CREATE TABLE IF NOT EXISTS knowledge (
  id TEXT PRIMARY KEY,
  from_machine TEXT NOT NULL,
  topic TEXT NOT NULL,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  learning TEXT NOT NULL,
  code_example TEXT,
  tags TEXT,
  helpful_count INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_knowledge_topic ON knowledge(topic);
CREATE INDEX IF NOT EXISTS idx_knowledge_category ON knowledge(category);
CREATE INDEX IF NOT EXISTS idx_knowledge_from ON knowledge(from_machine);
CREATE INDEX IF NOT EXISTS idx_knowledge_created ON knowledge(created_at);
CREATE INDEX IF NOT EXISTS idx_knowledge_helpful ON knowledge(helpful_count);

-- Public Timeline for monitoring activity
CREATE TABLE IF NOT EXISTS timeline_events (
  id TEXT PRIMARY KEY,
  timestamp INTEGER NOT NULL,
  machine TEXT NOT NULL,
  event_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  metadata TEXT
);

CREATE INDEX IF NOT EXISTS idx_timeline_timestamp ON timeline_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_timeline_machine ON timeline_events(machine);
CREATE INDEX IF NOT EXISTS idx_timeline_type ON timeline_events(event_type);
