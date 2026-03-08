# Project Contexts

Context files for specific projects you work on. Load these into Claude when working on project-specific tasks.

---

## Available Contexts

### [Your Project Name]
**Location:** `your-project/`
**Last Updated:** [Date]
**Version:** [Version]

**What's included:**
- Project technical specifications
- Working guidelines and brand voice
- Quick reference (key info, contacts, rules)

**When to use:**
- Creating content (social posts, blog posts)
- Technical work and development
- Documentation and guides

**How to load:**
See `your-project/README.md` for task-specific file combinations.

---

## Adding New Project Contexts

### Structure Template

When adding a new project context:

```
project-contexts/
└── your-project-name/
    ├── README.md                  # Context loading guide
    ├── 00-overview.md            # Project overview
    ├── 01-technical-specs.md     # Technical details
    ├── 02-business-context.md    # Business/product context
    └── 03-reference.md           # Quick lookups
```

### What to Include

**Essential:**
1. **README.md** - When to load which files
2. **Overview** - What the project is, your role
3. **Technical specs** - Architecture, APIs, integrations
4. **Reference** - Key links, glossary

**Optional:**
- Brand voice and tone guidelines
- Content approval workflows
- Frequently asked questions
- Common code patterns
- Integration documentation

### Best Practices

1. **Split large docs** - Keep files under 20K tokens each
2. **Task-based loading** - Document which files for which tasks
3. **Update frequency** - Note how often each file changes
4. **Version tracking** - Include version numbers and dates
5. **Navigation guide** - Always include a README

---

## Usage with Claude

### In Claude Projects

1. Create a new chat
2. Click the paperclip icon
3. Upload relevant context files
4. Ask your question

**Example:**
```
Upload: your-project/01-quick-reference.md
        your-project/02-working-guidelines.md

Prompt: "Draft a tweet announcing the new feature launch"
```

### With Claude Code

```bash
# Method 1: Load in conversation
claude
# Then: "Read project-contexts/your-project/01-quick-reference.md and help me..."

# Method 2: One-shot with context
claude "Using project-contexts/your-project/03-technical.md, explain how the API works"
```

### In CLAUDE.md Files

Reference project contexts in project-specific CLAUDE.md:

```markdown
## Project Context

For project-specific tasks:
- Project docs: $CLAUDE_HOME/project-contexts/your-project/
- Load combinations: See project-contexts/your-project/README.md
```

---

## Context Loading Strategy

### Minimize Context Bloat

**Don't load everything:**
- Only load files needed for current task
- Split large docs by topic
- Create task-specific loading guides

**Why this matters:**
- Faster responses (less to process)
- Lower costs (fewer tokens)
- Better focus (less irrelevant info)
- Clearer outputs (less confusion)

### Example: Bad vs Good

**Bad - Load everything:**
```
Load: All 7 project files (48K tokens)
Task: Write a tweet about a feature
Result: Slow, expensive, unfocused
```

**Good - Load specific files:**
```
Load: 01-quick-reference.md + 02-working-guidelines.md (8K tokens)
Task: Write a tweet about a feature
Result: Fast, cheap, focused
```

---

## Maintenance

### Regular Updates

**Monthly:**
- Review technical specs for accuracy
- Update metrics and statistics
- Add new FAQ entries
- Check all links

**Quarterly:**
- Update working guidelines
- Refresh competitive analysis
- Audit reference materials
- Archive outdated information

**As Needed:**
- Product launches
- Major updates
- Team/contact changes

### Version Control

Track versions in each README.md:
```markdown
**Version:** 1.0
**Last Updated:** YYYY-MM-DD
**Last Reviewed:** YYYY-MM-DD
**Next Review:** YYYY-MM-DD
```

---

## Context File Guidelines

### Writing Style

- **Concise:** No fluff, get to the point
- **Structured:** Use clear headings and lists
- **Scannable:** Easy to find specific info
- **Accurate:** Verify all facts and figures
- **Actionable:** Include what to do, not just what is

### Formatting

- Use markdown for all files
- Include table of contents for >200 lines
- Code blocks for addresses/commands
- Tables for comparisons
- Bullet lists for steps/features

### Token Budget

Target file sizes:
- Quick reference: 2-5K tokens
- Technical specs: 10-20K tokens
- User guides: 10-15K tokens
- Reference/appendix: 3-7K tokens

**Check token count:**
```bash
# Rough estimate: ~750 tokens per 1000 chars
wc -c your-file.md
```

---

## Examples

### Good Context File Structure

```markdown
# Project Technical Specifications

**Version:** 1.0
**Last Updated:** YYYY-MM-DD

## Quick Reference
[Most-accessed info]

## Architecture
[Technical details]

## API Reference
[Endpoints, params, examples]

## Common Patterns
[Code snippets, workflows]

## Troubleshooting
[Known issues, solutions]
```

### Loading Guide Template

```markdown
# Context Loading Guide

## By Task Type

**Task A:** Load files X + Y
**Task B:** Load files Y + Z
**Task C:** Load file X only

## File Descriptions

**File X:** Contains...
**File Y:** Contains...
**File Z:** Contains...
```

---

## Integration with Claude Code Framework

### In Your Workflow

1. **Daily work:** Reference global `~/.claude/CLAUDE.md`
2. **Project-specific:** Load from `project-contexts/[project]/`
3. **Common patterns:** Use `templates/`

### In Agent Prompts

When setting up agents, reference project contexts:

```markdown
## Available Contexts

For [Project Name] work, load contexts from:
$CLAUDE_HOME/project-contexts/[project]/

See context README for loading guide.
```

---

## Future Project Contexts

**Planned additions:**
- [Your planned project contexts]
- Common patterns and templates

**To add a new context:**
1. Create folder: `project-contexts/new-project/`
2. Add split documentation files
3. Create README.md with loading guide
4. Update this file's "Available Contexts" section

---

**Remember:** Context files are tools, not textbooks. Load what you need, when you need it.
