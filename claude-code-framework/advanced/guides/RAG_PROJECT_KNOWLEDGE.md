# RAG & Project Knowledge — Give Your Agents Full Context

> **TL;DR:** Claude Projects support uploading files (docs, code, PDFs) as "Project Knowledge" that gets automatically retrieved and included in every conversation. This is RAG (Retrieval-Augmented Generation) built-in. Use it to give your agents persistent access to codebases, documentation, specifications, and reference materials without pasting them every time.
>
> **Last Updated:** February 12, 2026

---

## What Is Project Knowledge (RAG)?

**RAG (Retrieval-Augmented Generation)** is a technique where relevant context is automatically retrieved from a knowledge base and included in the AI's prompt. Claude Projects implements this as **Project Knowledge** — you upload files once, and Claude automatically searches and includes relevant content in every conversation.

### How It Works

```
1. Upload files to Project → Stored in project knowledge base
2. User asks question → Claude searches uploaded files
3. Relevant content retrieved → Added to context window
4. Claude responds → Using both its training and your docs
```

### Why This Matters for Your Workflow

Without RAG:
```
User: "How does our authentication flow work?"
You: [paste auth docs, paste code files, paste API spec]
Agent: [responds based on pasted content]

Next conversation:
You: "How do we handle password resets?"
You: [paste auth docs again, paste code files again...]
```

With RAG:
```
User: "How does our authentication flow work?"
Agent: [searches uploaded docs automatically] → responds

Next conversation:
User: "How do we handle password resets?"
Agent: [searches uploaded docs automatically] → responds
```

---

## What Can Be Uploaded

### Supported File Types

| Type | Extensions | Use Cases |
|------|-----------|-----------|
| **Text** | `.txt`, `.md`, `.csv` | Documentation, specs, data |
| **Code** | `.py`, `.js`, `.tsx`, `.java`, `.go`, etc. | Source code, configurations |
| **Documents** | `.pdf`, `.docx` | Specifications, manuals, reports |
| **Spreadsheets** | `.xlsx`, `.csv` | Data files, configurations |
| **Images** | `.png`, `.jpg`, `.webp` | Diagrams, screenshots, mockups |

### Size Limits

- **Per file:** Up to 32 MB
- **Total project knowledge:** Up to 200 files or 30 MB total (whichever comes first)
- **Context window:** Claude can access ~200K tokens from uploaded files per conversation

---

## Setting Up Project Knowledge

### 1. Create a Claude Project

1. Go to claude.ai
2. Click "Projects" → "Create Project"
3. Name it (e.g., "My App Development")
4. Set project instructions (your agent's system prompt)

### 2. Upload Your Knowledge Base

**What to upload:**

| File | Why |
|------|-----|
| `README.md` | Project overview, setup instructions |
| `CLAUDE.md` | Your project's coding rules |
| `STATUS.md` | Current state (if you want persistent memory) |
| `docs/PRD.md` | What you're building |
| `docs/TECH_SPEC.md` | How you're building it |
| `docs/API.md` | API documentation |
| `package.json` / `requirements.txt` | Dependencies |
| Key source files | Core logic, utilities, configurations |
| Architecture diagrams | Visual references |
| Integration docs | External API documentation |

**How to upload:**

1. In Project Settings → "Project Knowledge"
2. Click "Add files" or drag-and-drop
3. Files are automatically indexed for search

### 3. Test Retrieval

```
You: "What's our current tech stack?"
Agent: [searches uploaded package.json, TECH_SPEC.md]
       → "Based on package.json, we're using Next.js 15, React 19..."

You: "Show me how we handle API errors"
Agent: [searches uploaded source files]
       → "Looking at lib/api.ts, errors are handled with..."
```

---

## Best Practices for Project Knowledge

### Structure Your Uploads

```
project-knowledge/
├── 00-PROJECT-OVERVIEW.md       # Start here doc
├── CLAUDE.md                    # Coding rules
├── STATUS.md                    # Current state
├── docs/
│   ├── PRD.md                   # Requirements
│   ├── TECH_SPEC.md             # Architecture
│   ├── API.md                   # API reference
│   └── DEPLOYMENT.md            # Deployment guide
├── key-source-files/
│   ├── src/lib/api.ts           # Core utilities
│   ├── src/config/index.ts      # Configuration
│   └── src/types/index.ts       # Type definitions
└── references/
    ├── next-docs-excerpt.md     # Framework docs
    ├── web3-integration.md      # External integration guides
    └── architecture-diagram.png
```

### Keep It Focused

✅ **Do upload:**
- Core documentation (README, specs, guides)
- Key source files that define patterns
- Architecture diagrams and mockups
- Integration documentation for external APIs
- Configuration examples
- Frequently referenced utils/types

❌ **Don't upload:**
- Entire `node_modules/` or `venv/` (dependencies)
- Build artifacts (`.next/`, `dist/`, `build/`)
- Log files
- Binary files that Claude can't read
- Duplicate or redundant documentation

### Write Searchable Documentation

Make files easy for Claude to search:

**✅ GOOD:**
```markdown
# Authentication Flow

## Password Reset Process

Users can reset their password through:
1. Email link (expires in 1 hour)
2. SMS code (expires in 10 minutes)

Implementation: `src/auth/password-reset.ts`

The password reset flow uses JWT tokens signed with...
```

**❌ BAD:**
```markdown
# Auth

See code for details.
```

### Update Regularly

Project Knowledge isn't automatically synced with your codebase. When you make significant changes:

1. **Delete outdated files** from Project Knowledge
2. **Upload updated versions** of changed files
3. **Update STATUS.md** to reflect current state

Set a reminder to refresh Project Knowledge weekly or after major changes.

---

## Integration with Your Agent Workflow

### Agent System Prompt Template

When setting up agents in Projects, structure your system prompt to leverage Project Knowledge:

```markdown
=== IDENTITY ===
You are the [Role] for the [Project Name] project.

=== PROJECT CONTEXT ===
Before every response:
1. Check STATUS.md for current state
2. Review relevant files from Project Knowledge
3. Follow rules in CLAUDE.md

=== AVAILABLE KNOWLEDGE ===
The following files are available in Project Knowledge:
- README.md: Project overview and setup
- CLAUDE.md: Coding standards and rules
- STATUS.md: Current project state
- docs/PRD.md: Product requirements
- docs/TECH_SPEC.md: Technical architecture
- [List other key files]

Always search Project Knowledge before making assumptions about:
- Current implementation patterns
- Dependencies and versions
- Configuration options
- Integration specifications

=== YOUR ROLE ===
[Agent-specific instructions go here]
```

### Example: Frontend Developer Agent with RAG

```markdown
=== FRONTEND DEVELOPER AGENT ===

You have access to the full codebase in Project Knowledge.

Before writing any code:
1. Search for similar components in uploaded files
2. Check TECH_SPEC.md for architecture patterns
3. Verify dependencies in package.json
4. Review CLAUDE.md for code style rules

When the user asks to create a component:
1. Search: "component pattern" in Project Knowledge
2. Find: Existing component structure
3. Follow: Established patterns for consistency

When debugging:
1. Search: Error message or file name
2. Review: Related code in uploaded files
3. Check: Recent changes in STATUS.md
```

---

## Advanced RAG Techniques

### Technique 1: Layered Documentation

Upload files in order of importance:

**Layer 1 - Always Relevant:**
- README.md
- CLAUDE.md  
- STATUS.md

**Layer 2 - Frequently Referenced:**
- PRD.md
- TECH_SPEC.md
- Core source files

**Layer 3 - Specific References:**
- External API docs
- Integration guides
- Examples

Claude searches all layers but prioritizes earlier uploads and more relevant matches.

### Technique 2: Chunk Important Files

If you have a 100-page specification, break it into focused chunks:

```
docs/
├── spec-overview.md              # 5 pages - always retrieved
├── spec-authentication.md        # 10 pages - auth queries
├── spec-data-models.md          # 15 pages - database queries
├── spec-api-reference.md        # 20 pages - API queries
└── spec-deployment.md           # 10 pages - DevOps queries
```

Better retrieval than one giant `specification.pdf`.

### Technique 3: Use "Index" Files

Create an index that maps topics to files:

```markdown
# PROJECT INDEX

## Authentication
See: `docs/auth-spec.md`, `src/auth/`, `src/middleware/auth.ts`

## Database
See: `docs/data-models.md`, `src/db/schema.ts`, `docs/migrations/`

## API Endpoints
See: `docs/api-reference.md`, `src/app/api/`

## Deployment
See: `docs/deployment.md`, `.github/workflows/`, `Dockerfile`
```

Claude can search this index first to find relevant files.

### Technique 4: Embed Commands in Documentation

```markdown
# Deployment Guide

## To deploy to production:

**Terminal commands:**
```bash
# Build the application
npm run build

# Run tests
npm test

# Deploy to Vercel
vercel --prod
```

Claude can extract exact commands from uploaded guides.
```

---

## RAG for Different Project Types

### Next.js Dashboard Project

**Upload:**
- `package.json` - Dependencies
- `next.config.js` - Configuration
- `tailwind.config.ts` - Styling setup
- `src/app/layout.tsx` - Root layout
- `src/lib/` - All utilities
- `src/types/` - All types
- `README.md` - Setup guide
- `CLAUDE.md` - Code rules

**Agent prompt:**
```markdown
You have access to our Next.js codebase.

Before creating components:
- Search Project Knowledge for similar components
- Check src/lib/ for existing utilities
- Verify types in src/types/
- Follow patterns in layout.tsx
```

### Python Backend Project

**Upload:**
- `requirements.txt` - Dependencies
- `src/app.py` - Flask app factory
- `src/routes/` - All routes
- `src/services/` - Business logic
- `src/models/` - Data models
- `docs/API.md` - API spec
- `README.md` - Setup guide
- `.env.example` - Config template

**Agent prompt:**
```markdown
You have access to our Flask codebase.

Before writing APIs:
- Search for existing routes in src/routes/
- Check src/services/ for reusable logic
- Verify data models in src/models/
- Follow patterns in API.md
```

### Multi-Service Docker Project

**Upload:**
- `docker-compose.yml` - Service definitions
- Each service's README
- Shared configs
- Architecture diagram
- Integration specs
- Deployment guide

**Agent prompt:**
```markdown
You have access to our microservices architecture.

Before making changes:
- Review docker-compose.yml for service structure
- Check architecture diagram for data flow
- Verify integration specs for contracts
- Consider impact on dependent services
```

---

## Limitations and Workarounds

### Limitation 1: No Auto-Sync

**Problem:** Uploaded files don't automatically update when code changes.

**Workaround:**
- Set calendar reminder to refresh weekly
- Upload STATUS.md after each session
- Use git hooks to remind you to update Project Knowledge

### Limitation 2: Search Quality Varies

**Problem:** RAG search might miss relevant files or retrieve irrelevant ones.

**Workaround:**
- Use descriptive filenames
- Add topic keywords in file headers
- Create index files (see Technique 3)
- Ask specifically: "Search project knowledge for authentication"

### Limitation 3: Context Window Limits

**Problem:** Can't retrieve entire codebase in one conversation.

**Workaround:**
- Upload only key files, not entire repos
- Break large files into focused chunks
- Use file naming to make search easier
- Prompt: "Search for X in uploaded files"

### Limitation 4: Binary Files Limited

**Problem:** PDFs and images have less searchable text.

**Workaround:**
- Extract text from PDFs into .md files
- Add alt text descriptions for diagrams
- Upload both image and text description

---

## Measuring RAG Effectiveness

### Test Your Setup

1. **Upload your knowledge base**
2. **Ask test questions:**
   - "What's our current tech stack?"
   - "How do we handle authentication?"
   - "Show me the database schema"
   - "What's the deployment process?"

3. **Verify Claude:**
   - Searches uploaded files
   - Cites specific files
   - Provides accurate info

### If RAG Isn't Working Well

**Symptoms:**
- Claude doesn't find uploaded files
- Gives generic answers instead of project-specific
- Misses relevant documentation

**Fixes:**
- Add more descriptive filenames
- Break large files into topics
- Upload an index file
- Explicitly ask: "Check Project Knowledge for..."

---

## RAG vs. Pasting Context

| Approach | Pros | Cons | When to Use |
|----------|------|------|-------------|
| **RAG (Project Knowledge)** | ✅ Upload once, use forever<br>✅ Automatic retrieval<br>✅ No repetitive pasting | ❌ Setup required<br>❌ Must keep updated | Long-term projects with stable docs |
| **Manual Pasting** | ✅ Always current<br>✅ Full control<br>✅ No setup | ❌ Repetitive<br>❌ Easy to forget files | Quick one-off tasks, rapid iteration |
| **Hybrid (Both)** | ✅ Best of both<br>✅ RAG for stable docs<br>✅ Paste for active work | ❌ Must manage both | Most production projects |

**Recommended:** Use Project Knowledge for stable documentation and paste active files you're currently modifying.

---

## Integration with Other Features

### RAG + Prompt Caching

```
Upload stable docs to Project Knowledge → Auto-retrieved each conversation
+ 
Cache the retrieval in system prompt → Pay only 10% on subsequent uses
=
Persistent knowledge + cost savings
```

### RAG + Batch Processing

```python
# All batch requests can access Project Knowledge
# No need to paste docs in each request

requests = [
    {
        "custom_id": f"test-{i}",
        "params": {
            "model": "claude-opus-4-6",
            "max_tokens": 1024,
            "messages": [
                {"role": "user", "content": f"Test scenario {i}"}
            ]
        }
    }
    for i in range(1000)
]

# Claude searches Project Knowledge for each request
# (if run through Projects, not raw API)
```

### RAG + Agent Handoffs

```
System Architect Project:
- Uploads: Architecture patterns, best practices
- Retrieves: When designing new systems

↓ Handoff Brief

Frontend Developer Project:
- Uploads: Component library, UI patterns, style guide
- Retrieves: When building UI

↓ Handoff Brief

Backend Developer Project:
- Uploads: API patterns, database schema, service architecture
- Retrieves: When building endpoints
```

Each agent has specialized knowledge for their domain.

---

## Troubleshooting

### "Claude isn't finding my uploaded files"

1. **Check file format** — Some binary formats aren't searchable
2. **Verify upload completed** — Look in Project Settings → Project Knowledge
3. **Ask explicitly** — "Search Project Knowledge for [topic]"
4. **Check filename** — Make it descriptive: `auth-implementation.md` not `notes.txt`

### "Claude gives outdated information"

1. **Re-upload updated files** — RAG doesn't auto-sync
2. **Delete old versions** — Remove outdated files from Project Knowledge
3. **Update STATUS.md** — Include recent changes
4. **Tell Claude** — "Ignore old info, use latest from Project Knowledge"

### "Retrieval is slow or inconsistent"

1. **Reduce file count** — Upload <50 files for best performance
2. **Break large files** — Split 100-page PDFs into focused documents
3. **Use indexes** — Create topic → file mapping
4. **Clear cache** — Start new conversation to reset search

---

## Quick Reference: RAG Setup Checklist

- [ ] Create Claude Project for your work
- [ ] Upload core documentation (README, CLAUDE.md, STATUS.md)
- [ ] Upload specifications (PRD, TECH_SPEC)
- [ ] Upload key source files (utils, types, configs)
- [ ] Upload reference materials (API docs, guides)
- [ ] Create index file mapping topics to files
- [ ] Test retrieval with sample questions
- [ ] Add RAG instructions to agent system prompts
- [ ] Set reminder to refresh files weekly
- [ ] Document what's uploaded in Project README

---

## See Also

- `advanced/guides/ARCHITECTURE_BLUEPRINT.md` — Agent system setup
- `essential/agents/README.md` — Agent prompt structure
- `essential/guides/PITFALLS.md` — Common Claude Code issues
- Anthropic Docs: https://support.claude.com/en/articles/11473015-retrieval-augmented-generation-rag-for-projects
