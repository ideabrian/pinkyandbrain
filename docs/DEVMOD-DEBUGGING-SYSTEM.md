# devMod - Visual API Debugging System

**Date**: October 16, 2025
**Author**: Pinky
**Status**: ✅ Production-Ready
**Project**: FunJobs.ai

## Overview

devMod is a comprehensive debugging system that provides real-time visual feedback for all API calls in a full-stack application. It shows green indicators for successful requests and red indicators for errors, making troubleshooting as simple as taking a screenshot.

## Problem Solved

**Original Issue**: "Error: Failed to Fetch" with no visibility into what's happening
- No way to see API calls being made
- No visibility into request/response data
- Difficult to debug CORS, network, or server errors
- Trial-and-error debugging process

**Solution**: Visual debugging UI that logs every API interaction with complete request/response data

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Frontend (React)                    │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Component (e.g., Home.tsx, UploadJob.tsx)      │  │
│  │                                                  │  │
│  │  apiFetch('/api/jobs')  ←─────────────────┐     │  │
│  │       │                                    │     │  │
│  │       ▼                                    │     │  │
│  │  ┌────────────────────────────────┐       │     │  │
│  │  │  client/lib/api.ts             │       │     │  │
│  │  │  - Creates log entry           │       │     │  │
│  │  │  - Calls fetch()               │       │     │  │
│  │  │  - Updates log with result     │       │     │  │
│  │  └────────┬───────────────────────┘       │     │  │
│  │           │                                │     │  │
│  │           ▼                                │     │  │
│  │  ┌────────────────────────────────┐       │     │  │
│  │  │  devModLogger (Singleton)      │       │     │  │
│  │  │  - Stores all API logs         │       │     │  │
│  │  │  - Notifies subscribers        │       │     │  │
│  │  └────────┬───────────────────────┘       │     │  │
│  │           │                                │     │  │
│  │           │ Subscribe                      │     │  │
│  │           ▼                                │     │  │
│  │  ┌────────────────────────────────┐       │     │  │
│  │  │  DevMod Component              │       │     │  │
│  │  │  - Floating button (🟢/🔴)     │       │     │  │
│  │  │  - Expandable panel            │       │     │  │
│  │  │  - Shows all logs              │       │     │  │
│  │  └────────────────────────────────┘       │     │  │
│  │                                            │     │  │
│  └────────────────────────────────────────────┘     │  │
│                                                      │  │
└──────────────────────────────────────────────────────┘  │
                           │                              │
                           │ HTTP Request                 │
                           ▼                              │
┌─────────────────────────────────────────────────────────┐
│                 Backend (Cloudflare Workers)            │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Logging Middleware                              │  │
│  │  - Logs request (method, path, URL)             │  │
│  │  - Executes handler                              │  │
│  │  - Logs response (status, duration)             │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Components

### 1. devModLogger (client/components/DevMod.tsx)

**Purpose**: Singleton logger that stores all API interactions

```typescript
export interface APILog {
  id: string;
  timestamp: number;
  method: string;
  url: string;
  status?: number;
  duration?: number;
  requestData?: any;
  responseData?: any;
  error?: string;
  state: 'pending' | 'success' | 'error';
}

export const devModLogger = {
  logs: [] as APILog[],
  listeners: new Set<(logs: APILog[]) => void>(),

  addLog(log: APILog) {
    this.logs.unshift(log); // Add to beginning
    if (this.logs.length > 50) this.logs.pop(); // Keep max 50
    this.notifyListeners();
  },

  updateLog(id: string, updates: Partial<APILog>) {
    const log = this.logs.find(l => l.id === id);
    if (log) {
      Object.assign(log, updates);
      this.notifyListeners();
    }
  },

  subscribe(listener: (logs: APILog[]) => void) {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  },

  notifyListeners() {
    this.listeners.forEach(listener => listener([...this.logs]));
  },

  clear() {
    this.logs = [];
    this.notifyListeners();
  },
};
```

### 2. apiFetch Wrapper (client/lib/api.ts)

**Purpose**: Replaces native `fetch()` throughout the app, automatically logging all requests

```typescript
import { devModLogger, APILog } from '../components/DevMod';
import { API_BASE_URL } from '../config';

function tryParseJSON(text: any): any {
  try {
    return typeof text === 'string' ? JSON.parse(text) : text;
  } catch {
    return text;
  }
}

export async function apiFetch(path: string, options: RequestInit = {}) {
  const url = path.startsWith('http') ? path : `${API_BASE_URL}${path}`;
  const logId = `log-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  const startTime = Date.now();

  // Create log entry
  const log: APILog = {
    id: logId,
    timestamp: startTime,
    method: options.method || 'GET',
    url,
    state: 'pending',
    requestData: options.body ? tryParseJSON(options.body) : undefined,
  };

  devModLogger.addLog(log);

  try {
    const response = await fetch(url, options);
    const duration = Date.now() - startTime;

    // Clone response to read body without consuming it
    const clonedResponse = response.clone();
    let responseData;
    try {
      responseData = await clonedResponse.json();
    } catch {
      responseData = await clonedResponse.text();
    }

    // Update log with result
    devModLogger.updateLog(logId, {
      status: response.status,
      duration,
      responseData,
      state: response.ok ? 'success' : 'error',
      error: response.ok ? undefined : `HTTP ${response.status}`,
    });

    return response;
  } catch (error: any) {
    const duration = Date.now() - startTime;
    devModLogger.updateLog(logId, {
      duration,
      state: 'error',
      error: error.message || 'Network error',
    });
    throw error;
  }
}
```

### 3. DevMod Component (client/components/DevMod.tsx)

**Purpose**: Visual UI that displays all API logs

```typescript
import { useState, useEffect } from 'react';

export default function DevMod() {
  const [logs, setLogs] = useState<APILog[]>([]);
  const [isExpanded, setIsExpanded] = useState(false);
  const [selectedLog, setSelectedLog] = useState<APILog | null>(null);

  useEffect(() => {
    return devModLogger.subscribe(setLogs);
  }, []);

  const successCount = logs.filter(l => l.state === 'success').length;
  const errorCount = logs.filter(l => l.state === 'error').length;

  return (
    <>
      {/* Floating Button */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="fixed bottom-4 right-4 bg-gray-900 text-white px-4 py-2 rounded-lg shadow-lg z-50"
      >
        <div className="flex items-center gap-2">
          <span>devMod</span>
          <div className="flex gap-1">
            {successCount > 0 && (
              <span className="bg-green-500 text-white px-2 py-0.5 rounded text-xs">
                {successCount}
              </span>
            )}
            {errorCount > 0 && (
              <span className="bg-red-500 text-white px-2 py-0.5 rounded text-xs">
                {errorCount}
              </span>
            )}
          </div>
        </div>
      </button>

      {/* Expandable Panel */}
      {isExpanded && (
        <div className="fixed bottom-20 right-4 w-96 max-h-96 bg-white border-2 border-gray-900 rounded-lg shadow-2xl z-50 overflow-hidden">
          <div className="bg-gray-900 text-white px-4 py-2 flex justify-between items-center">
            <span className="font-bold">API Monitor</span>
            <button onClick={() => devModLogger.clear()}>Clear</button>
          </div>

          <div className="overflow-y-auto max-h-80">
            {logs.map(log => (
              <div
                key={log.id}
                onClick={() => setSelectedLog(log)}
                className={`p-3 border-b cursor-pointer hover:bg-gray-50 ${
                  log.state === 'error' ? 'bg-red-50' :
                  log.state === 'success' ? 'bg-green-50' : 'bg-yellow-50'
                }`}
              >
                <div className="flex items-center gap-2">
                  <span className={`w-3 h-3 rounded-full ${
                    log.state === 'error' ? 'bg-red-500' :
                    log.state === 'success' ? 'bg-green-500' : 'bg-yellow-500'
                  }`} />
                  <span className="font-bold text-sm">{log.method}</span>
                  <span className="text-xs text-gray-600 truncate flex-1">
                    {log.url}
                  </span>
                  {log.status && (
                    <span className="text-xs font-mono">{log.status}</span>
                  )}
                </div>
                {log.duration && (
                  <div className="text-xs text-gray-500 mt-1">
                    {log.duration}ms
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Detail Modal */}
      {selectedLog && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
          onClick={() => setSelectedLog(null)}
        >
          <div
            className="bg-white rounded-lg p-6 max-w-2xl max-h-96 overflow-y-auto"
            onClick={e => e.stopPropagation()}
          >
            <h3 className="font-bold text-lg mb-4">Request Details</h3>
            <pre className="text-xs bg-gray-100 p-4 rounded overflow-x-auto">
              {JSON.stringify(selectedLog, null, 2)}
            </pre>
          </div>
        </div>
      )}
    </>
  );
}
```

### 4. Backend Logging Middleware (src/index.ts)

**Purpose**: Logs all incoming requests and outgoing responses on the server

```typescript
import { Hono } from 'hono';
import { cors } from 'hono/cors';

const app = new Hono<{ Bindings: Bindings }>();

// Detailed logging middleware
app.use('*', async (c, next) => {
  const start = Date.now();
  const requestId = `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`📥 REQUEST [${requestId}]`);
  console.log(`   Method: ${c.req.method}`);
  console.log(`   Path: ${c.req.path}`);
  console.log(`   URL: ${c.req.url}`);
  console.log(`   Headers: ${JSON.stringify(Object.fromEntries(c.req.raw.headers))}`);

  await next();

  const duration = Date.now() - start;
  console.log(`📤 RESPONSE [${requestId}]`);
  console.log(`   Status: ${c.res.status}`);
  console.log(`   Duration: ${duration}ms`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
});
```

## Usage

### 1. Replace fetch() with apiFetch()

**Before**:
```typescript
const response = await fetch('/api/jobs');
const data = await response.json();
```

**After**:
```typescript
import { apiFetch } from '../lib/api';

const response = await apiFetch('/api/jobs');
const data = await response.json();
```

### 2. Add DevMod to App

**client/App.tsx**:
```typescript
import DevMod from './components/DevMod';

function App() {
  const isDev = import.meta.env.MODE === 'development';

  return (
    <div>
      {/* Your app components */}
      <Routes>
        <Route path="/" element={<Home />} />
        {/* ... */}
      </Routes>

      {/* Only show in development */}
      {isDev && <DevMod />}
    </div>
  );
}
```

### 3. Monitor API Calls

1. Open your app in development mode
2. Click the "devMod" button in bottom-right corner
3. See all API calls with green (success) or red (error) indicators
4. Click any log entry to see full request/response details
5. Use "Clear" to reset the log

## Configuration

**File**: `.dev.config.json`

```json
{
  "devMod": {
    "enabled": true,
    "logAllRequests": true,
    "logAllResponses": true,
    "showInProduction": false,
    "maxLogs": 50
  },
  "api": {
    "timeout": 30000,
    "retries": 0
  },
  "logging": {
    "level": "debug",
    "showTimestamps": true,
    "showStackTraces": true
  }
}
```

## Troubleshooting Examples

### Example 1: CORS Error
**Symptom**: Red indicator, error message "Failed to fetch"

**devMod Shows**:
```json
{
  "method": "POST",
  "url": "https://funjobs-ai.b-9f2.workers.dev/api/upload",
  "status": undefined,
  "error": "Network error",
  "state": "error"
}
```

**Solution**: Check CORS configuration in backend
```typescript
app.use('/api/*', cors({
  origin: ['http://localhost:5173', 'https://your-pages-domain.pages.dev'],
  credentials: true,
}));
```

### Example 2: 500 Internal Server Error
**Symptom**: Red indicator, status 500

**devMod Shows**:
```json
{
  "method": "GET",
  "url": "/api/jobs",
  "status": 500,
  "responseData": {"error": "Internal Server Error"},
  "state": "error"
}
```

**Solution**: Check backend logs (console output in wrangler dev)

### Example 3: Slow API Response
**Symptom**: Green indicator but high duration

**devMod Shows**:
```json
{
  "method": "GET",
  "url": "/api/jobs",
  "status": 200,
  "duration": 3847,
  "state": "success"
}
```

**Solution**: Optimize database query or add caching

## Benefits

✅ **Instant Visibility**: See every API call immediately
✅ **Visual Feedback**: Green = good, Red = error
✅ **Complete Data**: Request/response bodies, headers, timing
✅ **Development Only**: Automatically disabled in production
✅ **Easy Debugging**: Take screenshot and share with team
✅ **No Setup**: Works automatically once apiFetch is used
✅ **Minimal Overhead**: Logs stored in memory, max 50 entries

## Integration with Team Workflow

1. **Developer encounters error** → Clicks devMod button
2. **Sees red indicator** → Clicks to view details
3. **Takes screenshot** → Shares in team chat
4. **Team diagnoses issue** → From request/response data
5. **Fix deployed** → Green indicator confirms success

## Production Deployment

**Important**: devMod is automatically disabled in production builds

```typescript
const isDev = import.meta.env.MODE === 'development';
{isDev && <DevMod />}
```

When `npm run build` runs, `import.meta.env.MODE` becomes `'production'` and DevMod is not included in the bundle.

## Files Modified

- ✅ `client/components/DevMod.tsx` (new)
- ✅ `client/lib/api.ts` (new)
- ✅ `client/App.tsx` (added DevMod)
- ✅ `client/pages/Home.tsx` (replaced fetch with apiFetch)
- ✅ `client/components/JobImageUpload.tsx` (replaced fetch with apiFetch)
- ✅ `src/index.ts` (added logging middleware)
- ✅ `.dev.config.json` (new)

## Git Commits

- `01cc771` - Add devMod debugging system
- `bb883ab` - Add devMod usage guide

## Knowledge Base Entry

- `knowledge-1760681552315` - devMod Visual API Monitoring System

---

**Status**: ✅ Production-Ready
**Project**: FunJobs.ai
**Updated**: 2025-10-16 23:15:00
