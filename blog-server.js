#!/usr/bin/env node
// Dead simple blog server - serves markdown as HTML
// Usage: node blog-server.js

const express = require('express');
const marked = require('marked');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3888;  // Unique port, avoids conflicts
const POSTS_DIR = path.join(__dirname, 'blog-drafts');

// Syntax highlighting support
marked.setOptions({
  highlight: function(code, lang) {
    return code; // Add Prism.js or highlight.js later if needed
  },
  breaks: true,
  gfm: true
});

// Serve static assets
app.use('/assets', express.static(path.join(__dirname, 'blog-assets')));

// Homepage - list all posts
app.get('/', (req, res) => {
  const files = fs.readdirSync(POSTS_DIR)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const content = fs.readFileSync(path.join(POSTS_DIR, f), 'utf8');
      const title = content.match(/^# (.+)$/m)?.[1] || f;
      const date = fs.statSync(path.join(POSTS_DIR, f)).mtime;
      return {
        slug: f.replace('.md', ''),
        title,
        date: date.toISOString().split('T')[0]
      };
    })
    .sort((a, b) => new Date(b.date) - new Date(a.date));

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Sawdust.ai - Real Lessons from Building AI Systems</title>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          line-height: 1.6;
          max-width: 800px;
          margin: 0 auto;
          padding: 40px 20px;
          background: #fafafa;
        }
        h1 { margin-bottom: 10px; }
        .tagline { color: #666; margin-bottom: 40px; }
        .post {
          background: white;
          padding: 20px;
          margin-bottom: 20px;
          border-radius: 8px;
          border-left: 4px solid #0066cc;
        }
        .post h2 { margin-bottom: 5px; }
        .post .date { color: #999; font-size: 14px; }
        .post a { text-decoration: none; color: #0066cc; }
        .post a:hover { text-decoration: underline; }
      </style>
    </head>
    <body>
      <h1>Sawdust.ai</h1>
      <p class="tagline">Real lessons from building distributed AI systems. Not tutorials - actual sawdust.</p>

      ${files.map(post => `
        <div class="post">
          <h2><a href="/post/${post.slug}">${post.title}</a></h2>
          <div class="date">${post.date}</div>
        </div>
      `).join('')}

      <footer style="margin-top: 60px; color: #999; font-size: 14px;">
        Built on our distributed Mac setup. <a href="https://github.com/ideabrian/pinkyandbrain">See the code</a>.
      </footer>
    </body>
    </html>
  `;

  res.send(html);
});

// Individual post
app.get('/post/:slug', (req, res) => {
  const filePath = path.join(POSTS_DIR, `${req.params.slug}.md`);

  if (!fs.existsSync(filePath)) {
    return res.status(404).send('Post not found');
  }

  const markdown = fs.readFileSync(filePath, 'utf8');
  const html = marked.parse(markdown);

  const page = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>${req.params.slug} - Sawdust.ai</title>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          line-height: 1.6;
          max-width: 800px;
          margin: 0 auto;
          padding: 40px 20px;
          background: #fafafa;
        }
        article {
          background: white;
          padding: 40px;
          border-radius: 8px;
        }
        h1 { margin-bottom: 30px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        h2 { margin-top: 30px; margin-bottom: 15px; }
        p { margin-bottom: 15px; }
        pre {
          background: #2d2d2d;
          color: #f8f8f2;
          padding: 20px;
          border-radius: 4px;
          overflow-x: auto;
          margin: 20px 0;
        }
        code {
          background: #f4f4f4;
          padding: 2px 6px;
          border-radius: 3px;
          font-family: 'Courier New', monospace;
        }
        pre code {
          background: transparent;
          padding: 0;
        }
        a { color: #0066cc; }
        .back { margin-bottom: 20px; }
        .back a { text-decoration: none; }
      </style>
    </head>
    <body>
      <div class="back"><a href="/">← Back to posts</a></div>
      <article>
        ${html}
      </article>
      <footer style="margin-top: 60px; color: #999; font-size: 14px; text-align: center;">
        <a href="/">More sawdust</a> |
        <a href="https://github.com/ideabrian/pinkyandbrain">GitHub</a>
      </footer>
    </body>
    </html>
  `;

  res.send(page);
});

// RSS feed
app.get('/rss.xml', (req, res) => {
  const files = fs.readdirSync(POSTS_DIR)
    .filter(f => f.endsWith('.md'))
    .map(f => {
      const content = fs.readFileSync(path.join(POSTS_DIR, f), 'utf8');
      const title = content.match(/^# (.+)$/m)?.[1] || f;
      const date = fs.statSync(path.join(POSTS_DIR, f)).mtime;
      return {
        slug: f.replace('.md', ''),
        title,
        date: date.toUTCString(),
        content: content.substring(0, 500) + '...'
      };
    })
    .sort((a, b) => new Date(b.date) - new Date(a.date));

  const rss = `<?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>Sawdust.ai</title>
        <link>http://sawdust.ai</link>
        <description>Real lessons from building distributed AI systems</description>
        ${files.map(post => `
          <item>
            <title>${post.title}</title>
            <link>http://sawdust.ai/post/${post.slug}</link>
            <pubDate>${post.date}</pubDate>
            <description>${post.content}</description>
          </item>
        `).join('')}
      </channel>
    </rss>`;

  res.type('application/xml');
  res.send(rss);
});

app.listen(PORT, () => {
  console.log(`📝 Sawdust blog running at http://localhost:${PORT}`);
  console.log(`📂 Serving posts from: ${POSTS_DIR}`);
});
