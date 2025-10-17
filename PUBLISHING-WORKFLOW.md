# Sawdust.ai Publishing Workflow

## Philosophy
**Sawdust** = The messy, real-world lessons from building distributed AI systems. Not polished tutorials - actual problems, fixes, and learnings.

## Content Sources
Every session with brain/pinky/max generates sawdust:
- Bug fixes and debugging stories
- Architecture decisions
- Integration challenges
- "Oh shit" moments and recoveries
- Lessons learned

## Publishing Pipeline

### 1. Capture (During Session)
- Session summaries auto-saved to `~/pinkyandbrain/sessions/`
- HANDOFF.md updated with key decisions
- Code committed to GitHub with descriptive messages

### 2. Extract (Post-Session)
```bash
# Review session for blog-worthy content
cat ~/pinkyandbrain/sessions/session-*.txt | grep -A 5 "Problem\|Solution\|Lesson"

# Key questions:
# - What broke?
# - How did we fix it?
# - What did we learn?
# - Would this help others?
```

### 3. Draft (Writing)
Create post in `~/pinkyandbrain/blog-drafts/`:

**Template:**
```markdown
---
title: "Post Title"
date: YYYY-MM-DD
tags: [distributed-systems, claude-ai, automation]
status: draft
---

## The Problem
[What went wrong or what we needed to solve]

## The Context
[Background - our setup, what we were trying to do]

## The Journey
[The debugging/building process - include missteps!]

## The Solution
[What worked, with code examples]

## The Sawdust (Lessons Learned)
[Key takeaways, what we'd do differently]

## Try It Yourself
[Link to GitHub repo, simplified steps]
```

### 4. Review (Quality Check)
- [ ] Technical accuracy verified
- [ ] Code examples tested
- [ ] Links work (GitHub, other posts)
- [ ] Images/screenshots added
- [ ] SEO: Title, description, tags
- [ ] Readability: Not too technical, not too simple

### 5. Publish (Multi-Platform)

#### Primary: sawdust.ai
```bash
# Push to sawdust.ai
scp blog-drafts/post-title.md sawdust.ai:/var/www/html/posts/
# Or use your CMS/static site generator
```

#### Syndication (Same Day)
1. **Dev.to** - Full crosspost with canonical URL back to sawdust.ai
2. **Hashnode** - Same content, different audience

#### Social (Within 24h)
1. **Twitter/X Thread**
   - Hook: The problem in 1 tweet
   - 3-5 tweets: Journey highlights
   - Final: Link to full post

2. **Hacker News** (if significant)
   - Title format: "Show HN: [Brief description]"
   - Best time: Weekday 8-10am PT

3. **Reddit**
   - r/selfhosted - Hardware/setup posts
   - r/ClaudeAI - AI agent coordination
   - r/homelab - Distributed systems
   - Rule: Participate in community, don't just promote

#### Code (Always)
- Update GitHub README with link to blog post
- Add blog post to repo's `docs/` folder as reference

### 6. Engage (Community)
- Respond to comments within 24h
- Update post if good questions reveal gaps
- Note follow-up topics requested by readers

## Content Calendar

### Immediate Queue (Ready to Write)
1. **"3,266 Files Later: Fixing an Infinite Claude Loop"**
   - Status: Session captured ✅
   - Estimated: 2-3 hours to draft
   - Target: This week

2. **"Status Dashboard for Distributed AI Teams"**
   - Status: Code complete ✅
   - Estimated: 2 hours to draft
   - Target: This week

3. **"Git Strategies for Machine-Specific Repos"**
   - Status: Solution implemented ✅
   - Estimated: 1.5 hours to draft
   - Target: Next week

### Future Topics (From Backlog)
- Password-less SSH setup (from setup guides)
- The DHCP problem and .local solution
- Building a distributed voting system
- Message bus architecture for AI agents
- Why 3 cheap machines > 1 expensive one

## Metrics to Track

### Quantitative
- Page views per post
- Time on page
- GitHub stars/forks
- Social shares/engagement
- Comments/questions

### Qualitative
- What resonates with readers?
- What questions do they ask?
- What do they want to see next?
- Are they building similar systems?

## Success Criteria

**Short-term (3 months):**
- 10 quality posts published
- 1,000+ monthly visitors to sawdust.ai
- Active GitHub community (issues, PRs)
- Email list started (optional)

**Long-term (1 year):**
- Authority on distributed AI development
- Conference talk opportunities
- Consulting/collaboration requests
- Course/book potential

## Tools & Setup

### Writing
- Markdown editor (VS Code, iA Writer, etc.)
- Code screenshots (Carbon.now.sh, ray.so)
- Architecture diagrams (Excalidraw, tldraw)

### Publishing
- Static site generator (Hugo, Astro, Next.js)
- GitHub Pages / Netlify / Vercel
- RSS feed for subscribers

### Social
- Buffer/Hypefury for scheduling
- Canva for og:image cards
- Analytics (Plausible, Fathom, or Google)

## Writing Tips

### Voice
- ✅ First person: "We hit this problem..."
- ✅ Conversational: Like explaining to a friend
- ✅ Honest: Include failures and wrong turns
- ❌ Corporate: No buzzwords or overselling
- ❌ Tutorial-only: Show the mess, not just the solution

### Structure
1. **Hook** - Problem in first 2 sentences
2. **Context** - Enough background, not too much
3. **Journey** - The actual work (most important!)
4. **Solution** - What worked, with code
5. **Lessons** - The sawdust - what we learned
6. **CTA** - GitHub link, follow for more

### Code Examples
- Include enough context to understand
- Link to full code in GitHub
- Show before/after for fixes
- Comment the interesting parts

## Automation Opportunities

```bash
# Session-to-blog helper
./extract-blog-content.sh session-1760715809.txt

# Generates:
# - Key problems mentioned
# - Solutions implemented
# - Code changes made
# - Suggested blog title/outline
```

## Repository Structure
```
~/pinkyandbrain/
├── blog-drafts/          # Posts in progress
├── blog-published/       # Archive of published posts
├── blog-assets/          # Images, diagrams, code samples
├── sessions/             # Raw material from sessions
└── PUBLISHING-WORKFLOW.md
```

## Next Steps

1. **This Week:**
   - [ ] Create blog-drafts folder
   - [ ] Draft "Infinite Loop" post
   - [ ] Set up sawdust.ai (if not already)
   - [ ] Write Twitter bio linking to sawdust.ai

2. **This Month:**
   - [ ] Publish 2-3 posts
   - [ ] Share on HN/Reddit
   - [ ] Start email list (optional)
   - [ ] Create content calendar

3. **This Quarter:**
   - [ ] Establish weekly publishing rhythm
   - [ ] Build email subscriber base
   - [ ] Engage with homelab/AI communities
   - [ ] Consider conference talk submissions

---

**Remember:** The goal is to share the sawdust - the messy, valuable lessons that don't make it into polished tutorials. That's what makes this content unique and valuable.
