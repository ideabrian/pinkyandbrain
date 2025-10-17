# Sawdust.ai - Quick Setup with Astro

## Why Astro?
- Native Markdown support
- Blazing fast
- SEO optimized
- Code syntax highlighting
- Free hosting
- Easy to maintain

## Setup (30 minutes)

### 1. Create Astro Site
```bash
npm create astro@latest sawdust-blog
# Choose:
# - Template: Blog
# - TypeScript: Yes (or No, your choice)
# - Install dependencies: Yes
# - Git: Yes
```

### 2. Project Structure
```
sawdust-blog/
├── src/
│   ├── content/
│   │   └── blog/           # Drop .md files here!
│   │       ├── infinite-loop.md
│   │       ├── status-dashboard.md
│   │       └── git-strategies.md
│   ├── layouts/
│   └── pages/
├── public/                 # Images, assets
└── astro.config.mjs       # Config
```

### 3. Write Your First Post
```markdown
---
title: "3,266 Files Later: Fixing an Infinite Claude Loop"
description: "How an auto-message loop taught us to filter system messages"
pubDate: 2025-10-17
tags: ["claude-ai", "debugging", "distributed-systems"]
---

## The Problem
Max said I was in an auto-message loop...

[Rest of your content]
```

### 4. Local Development
```bash
cd sawdust-blog
npm run dev
# Open http://localhost:4321
```

### 5. Deploy (Free)

#### Option A: Netlify (Recommended)
```bash
# Push to GitHub
git remote add origin git@github.com:ideabrian/sawdust-blog.git
git push -u origin main

# On Netlify:
# 1. New site from Git
# 2. Connect to GitHub repo
# 3. Build: npm run build
# 4. Publish directory: dist
# 5. Deploy!

# Add custom domain:
# Settings → Domain management → sawdust.ai
```

#### Option B: Vercel
```bash
npm i -g vercel
vercel
# Follow prompts, done!
```

#### Option C: Cloudflare Pages
```bash
# Push to GitHub
# Go to Cloudflare Pages dashboard
# Connect repo
# Build: npm run build
# Output: dist
# Deploy!
```

### 6. Custom Domain
```
# In your domain registrar (Namecheap, Cloudflare, etc):
# Add CNAME record:
# @ → your-site.netlify.app
# www → your-site.netlify.app

# Or use Cloudflare nameservers for faster DNS
```

## Blog Post Template

Create `src/content/blog/template.md`:

```markdown
---
title: "Post Title"
description: "Brief description for SEO"
pubDate: 2025-10-17
heroImage: "/blog-images/post-hero.jpg"  # optional
tags: ["tag1", "tag2", "tag3"]
---

## The Problem
What went wrong or what you needed to solve.

## The Context
Your setup, what you were trying to do.

## The Journey
The debugging/building process - include missteps!

\`\`\`bash
# Code examples with syntax highlighting
curl http://localhost:3100/status
\`\`\`

## The Solution
What worked.

\`\`\`javascript
// More code
const solution = "works great";
\`\`\`

## The Sawdust (Lessons Learned)
Key takeaways.

## Try It Yourself
Link to [GitHub repo](https://github.com/ideabrian/pinkyandbrain).
```

## Content Workflow

### Write Locally
```bash
cd sawdust-blog/src/content/blog
code my-new-post.md  # or vim, whatever
```

### Preview
```bash
npm run dev
# Check http://localhost:4321/blog/my-new-post
```

### Publish
```bash
git add .
git commit -m "New post: My New Post"
git push
# Netlify auto-deploys in ~30 seconds
```

## Customization

### Add Analytics (Optional)
```bash
npm install @astrojs/partytown
```

In `astro.config.mjs`:
```javascript
import { defineConfig } from 'astro/config';
import partytown from '@astrojs/partytown';

export default defineConfig({
  integrations: [partytown()],
});
```

Add to `src/layouts/BaseLayout.astro`:
```html
<!-- Plausible Analytics (privacy-friendly) -->
<script defer data-domain="sawdust.ai"
  src="https://plausible.io/js/script.js"></script>
```

### Syntax Highlighting Themes
Edit `astro.config.mjs`:
```javascript
export default defineConfig({
  markdown: {
    shikiConfig: {
      theme: 'github-dark', // or dracula, nord, etc.
    },
  },
});
```

### Custom Styling
Astro uses standard CSS. Edit files in `src/styles/`.

## RSS Feed (Auto-Generated!)
Astro blog template includes RSS at `/rss.xml`

Readers can subscribe in their feed reader.

## SEO Checklist
- [x] Descriptive titles (60 chars max)
- [x] Meta descriptions (155 chars max)
- [x] Hero images (og:image for social)
- [x] Canonical URLs
- [x] Sitemap (auto-generated)
- [x] Fast loading (Astro is fast)

## Alternative: Simple Static HTML

If you want even simpler:

```bash
# Just serve markdown as HTML with pandoc
for file in *.md; do
  pandoc "$file" -s --css style.css -o "${file%.md}.html"
done
```

Host on GitHub Pages or any static host.

**Pros:** Maximum control, zero dependencies
**Cons:** No blog features (tags, archive, RSS)

## My Recommendation

**Start with Astro:**
1. Modern, fast, great DX
2. Markdown-native
3. Easy to deploy
4. Scales with you (can add React/Vue later)
5. Active community

**Time investment:**
- Initial setup: 30-60 minutes
- Per post: Write markdown, push, done
- Maintenance: Essentially zero

You can literally start writing in markdown today and have a beautiful blog live by tonight.

## Next Steps

1. [ ] Run `npm create astro@latest sawdust-blog`
2. [ ] Copy your first blog draft to `src/content/blog/`
3. [ ] Test locally with `npm run dev`
4. [ ] Push to GitHub
5. [ ] Deploy to Netlify (3 clicks)
6. [ ] Point sawdust.ai to Netlify
7. [ ] Ship! 🚀

Want me to help draft the first post while you set up Astro?
