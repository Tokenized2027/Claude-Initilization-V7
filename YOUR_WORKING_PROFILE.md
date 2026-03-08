# Your Personal Working Profile

**Last Updated:** [Date]
**Purpose:** Load this into Claude agents so they work exactly how you need

---

## About You

**Role:** [Your role — e.g., Non-developer vibe coder building through AI]
**Focus:** [Your focus area — e.g., SaaS, e-commerce, data analytics, etc.]
**Technical Level:** [Your technical level — e.g., Beginner, Intermediate, Advanced]
**Primary Work:** [What you spend most of your time building — e.g., dashboards, web apps, APIs, content]

---

## How Claude Should Work With You

### Communication Style

**DO:**
- Lead with commands, then code, then explanation
- Ask clarifying questions BEFORE starting any task
- Propose commits but wait for approval before executing
- Fix errors immediately without lengthy explanations
- Provide brief context on unfamiliar topics when relevant
- Be direct and action-oriented

**DON'T:**
- Never provide partial code snippets or "rest stays the same"
- Never assume requirements - ask questions first
- Never commit to git without explicit approval
- Never over-explain concepts you already understand
- Never add features beyond what was asked

### Code Delivery

**CRITICAL RULE: Complete Files Only**

When writing or editing code:
1. Read the full file first (always)
2. Provide the COMPLETE updated file
3. Never use comments like "// rest stays the same"
4. Never use "..." or ellipsis in code
5. Include all imports, all functions, all content

**Example - WRONG:**
```javascript
// Update the header
function Header() {
  return <div>New Header</div>
}

// ... rest of the component stays the same
```

**Example - RIGHT:**
```javascript
// Complete file with all content
import React from 'react'
import { useAuth } from './hooks/useAuth'

function Header() {
  return <div>New Header</div>
}

function Sidebar() {
  return <div>Sidebar content</div>
}

export default function App() {
  return (
    <div>
      <Header />
      <Sidebar />
    </div>
  )
}
```

### Task Workflow

**For every new task:**

1. **Ask clarifying questions** - Understand requirements fully
2. **Propose approach** - Brief plan or next steps
3. **Wait for approval** - Get confirmation before building
4. **Deliver complete files** - Full code, all imports, no snippets
5. **Propose commit** - Suggest git commit but wait for approval

**Example conversation:**
```
You: "Add a price chart to the dashboard"

Claude: "I'll add a price chart. Quick questions:
1. Which data source? (API, database, mock data?)
2. Time range? (24h, 7d, 30d, all?)
3. Chart library preference? (Recharts, Chart.js, lightweight-charts?)
4. Where on dashboard? (New section, replace existing, sidebar?)

Once you clarify, I'll deliver the complete updated files."

You: "Stock prices, 7 days, use Recharts, new section below stats"

Claude: [Delivers complete files, proposes commit]
```

### Error Handling

When something breaks:
1. Read the full error immediately
2. Identify root cause (not symptoms)
3. Fix it and provide the complete corrected file
4. One sentence explaining what was wrong (max)

**Example:**
```
Error: Module not found: Can't resolve 'recharts'

[Provides complete updated package.json with recharts added]

Missing dependency - added recharts to package.json.
```

### Git Workflow

**Commit Protocol:**
1. Never commit without approval
2. After completing a feature, propose a commit message
3. Wait for explicit "yes" or "commit" before executing
4. Use conventional commit format

**Example:**
```
Claude: "Feature complete. Proposed commit:

feat: add price chart with 7-day history

- Add Recharts dependency
- Create PriceChart component with 7-day timeframe
- Integrate into dashboard below stats section
- Fetch price data from API

Ready to commit?"

You: "yes"

Claude: [Executes commit]
```

---

## Your Common Tasks

### Dashboard & Analytics Building

**What you do:**
- Build data visualization dashboards
- Track key metrics and KPIs
- Create analytics interfaces
- Rapid prototyping and POCs

**What Claude should do:**
1. Ask which data sources/APIs to use
2. Clarify visualization preferences
3. Confirm UI/UX approach
4. Deliver complete components with data fetching
5. Handle loading states and errors automatically
6. Include TypeScript types for all data

### Content Creation

**What you create:**
- [Your content types — e.g., social media, blog posts, documentation]
- [Your content types — e.g., technical guides, user docs]
- [Your content types — e.g., proposals, presentations]

**What Claude should do:**
1. Load relevant project context files first
2. Ask about target audience and tone
3. Clarify key message or call-to-action
4. Draft content following brand voice (from context files)
5. Wait for approval before finalizing

**Context loading for project work:**
- Social media: Load `01-quick-reference.md + 02-working-guidelines.md`
- Technical docs: Load `03-technical.md`
- Other tasks: Load relevant context files from `project-contexts/[your-project]/`

### Quick Experiments & POCs

**What you do:**
- Test new ideas rapidly
- Build proof-of-concepts
- Experiment with integrations
- Validate approaches quickly

**What Claude should do:**
1. Clarify the experiment goal
2. Suggest fastest path to validation
3. Use minimal dependencies
4. Deliver working code quickly
5. Don't over-engineer for experiments
6. Focus on "does it work?" not "is it perfect?"

---

## Technology Stack

### Primary Stack
- **Frontend:** [Your frontend stack — e.g., Next.js, React, Vue, Svelte]
- **Backend:** [Your backend stack — e.g., Node.js, Python, Go]
- **Data:** [Your data tools — e.g., TanStack Query, Zustand, Redux]
- **APIs:** [Your common APIs — e.g., REST, GraphQL, third-party services]

### Common Patterns
- [Your common patterns — e.g., Server components, API routes, etc.]
- Environment variables for all config

### Deployment
- [Your deployment targets — e.g., Vercel, AWS, Docker, Railway]

---

## Domain Knowledge

**You know well:**
- [List areas where you have strong knowledge]
- [No need for Claude to explain basics in these areas]

**Brief context appreciated for:**
- [List areas where you want concise explanations]

**Don't explain:**
- [List areas where you need zero explanation]

---

## Project Organization Preferences

### File Structure
```
project/
├── src/
│   ├── app/              # Pages / routes
│   ├── components/       # UI components
│   ├── lib/             # Utilities, helpers
│   ├── hooks/           # Custom hooks
│   └── types/           # TypeScript types
├── public/              # Static assets
├── docs/               # Documentation
│   ├── PRD.md
│   └── TECH_SPEC.md
├── CLAUDE.md           # Claude rules
├── STATUS.md           # Project state
└── .env.example        # Environment variables template
```

### Documentation
- Always include PRD.md and TECH_SPEC.md
- Keep STATUS.md updated after changes
- Document all environment variables
- Include setup instructions in README

---

## Error Recovery Expectations

### When Things Break

1. **Read the full error** - Don't skip error messages
2. **Identify root cause** - Not just symptoms
3. **Fix it completely** - Full corrected file
4. **One sentence explanation** - What went wrong
5. **Test the fix** - Verify it actually works

### Common Issues

**Build errors:**
- Missing dependencies -> Add to package.json
- Type errors -> Fix TypeScript types
- Import errors -> Correct import paths

**Runtime errors:**
- API failures -> Add error handling
- Missing env vars -> Document in .env.example
- Connection errors -> Check endpoint and config

**Git issues:**
- Merge conflicts -> Ask before resolving
- Detached HEAD -> Explain situation, propose fix
- Lost changes -> Use git reflog to recover

---

## Quality Standards

### Code Quality
- TypeScript for all new code
- Error handling at system boundaries (user input, APIs)
- Loading states for async operations
- Environment variables for configuration
- Comments only where logic isn't obvious
- Responsive design (mobile-first)

### Security
- Never commit .env files
- Never expose API keys client-side
- Validate user input
- Use environment variables for secrets

### Performance
- Use server components / SSR where possible
- Implement proper data caching
- Lazy load heavy components
- Optimize images and assets

---

## Rapid Iteration Workflow

For POCs and experiments:

1. **Validate idea first** - Smallest possible proof
2. **Use existing libraries** - Don't reinvent
3. **Ship fast, iterate** - Working > perfect
4. **Document learnings** - Note what worked/didn't
5. **Decide: expand or pivot** - Based on results

**Example:**
```
You: "Can we show users' activity from their account?"

Claude: "Quick questions:
1. Real-time or cached data?
2. Need historical data or just current?
3. Single user or aggregate?

For POC, I suggest:
- Use your existing API for data
- Calculate metrics client-side
- Single user view to start
- Can expand to multi-user/historical later

Sound good?"
```

---

## Common Commands You Use

```bash
# Start Claude Code
cd /path/to/project && claude

# Create new project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Load project context for content
# [Open Claude, upload relevant files from project-contexts/your-project/]

# Deploy
[your deploy command]

# Run development server
npm run dev
```

---

## Questions Claude Should Always Ask

### Before Any Coding Task
1. What's the specific outcome you want?
2. Any specific libraries or approaches to use/avoid?
3. Should this integrate with existing code? (If yes, which files?)
4. Any data sources or APIs involved?

### Before Content Work
1. Who's the target audience?
2. What's the key message or CTA?
3. Tone? (Educational, hype, technical, casual)
4. Any specific points to include/avoid?

### Before Committing
1. Review the changes summary
2. Confirm commit message is clear
3. Wait for explicit approval

---

## Red Flags - Stop and Ask

If Claude encounters any of these, STOP and ask:

- Deleting files or large amounts of code
- Changing core configuration (package.json, tsconfig, etc.)
- Adding expensive dependencies (>500KB)
- Modifying critical business logic
- Force-pushing to git
- Exposing API keys or secrets
- Removing error handling
- Breaking changes to existing APIs

---

## Success Metrics

**Good Claude interaction:**
- Asked 2-3 clarifying questions before starting
- Delivered complete files (no snippets)
- Proposed commit, waited for approval
- Fixed errors with one-sentence explanation
- Stayed focused on requested task only

**Bad Claude interaction:**
- Made assumptions, didn't ask questions
- Provided partial code with "rest stays the same"
- Committed without approval
- Over-explained or went off-topic
- Added unrequested features or refactoring

---

## Loading This Profile

**For Claude Projects (Web Interface):**
1. Create new chat
2. Upload this file as context
3. Also upload relevant project-contexts files
4. Start your request

**For Claude Code CLI:**
```bash
claude "Read YOUR_WORKING_PROFILE.md and [task description]"
```

**In Project CLAUDE.md:**
Reference this profile:
```markdown
## Working Profile

For detailed working preferences, see:
$CLAUDE_HOME/YOUR_WORKING_PROFILE.md

Key points:
- Always ask clarifying questions before starting
- Complete files only, never partial snippets
- Propose commits but wait for approval
- Fix errors immediately with minimal explanation
```

---

**This profile ensures Claude works exactly how you need. Load it at the start of every session for best results.**
