# CLI-Compatible Skills

These skills are formatted for use with Claude Code CLI. Unlike the web-based skills (which use the upload system), these are designed to be read directly from markdown files in your project.

## How to Use

### Option 1: Add to Project Knowledge (Recommended)

Copy the relevant skill files into your project's `docs/skills/` directory:

```bash
mkdir -p docs/skills
cp ~/mastering-claude-code-v4.1/skills-cli/SKILL-*.md docs/skills/
```

Then reference them in your CLAUDE.md:

```markdown
## Skills Reference

Available skills in `docs/skills/`:
- SKILL-GIT-RECOVERY.md - Git recovery commands
- SKILL-DOCKER-DEBUG.md - Docker troubleshooting
- SKILL-VERCEL-DEPLOY.md - Vercel deployment
- SKILL-NEXT-API.md - Next.js API scaffolding
- SKILL-REACT-COMPONENT.md - React component templates
```

### Option 2: Single Emergency Playbook

Create a combined `docs/EMERGENCY_PLAYBOOK.md` with all skills:

```bash
cat skills-cli/SKILL-*.md > docs/EMERGENCY_PLAYBOOK.md
```

Then in CLAUDE.md:

```markdown
## Emergency Reference

See `docs/EMERGENCY_PLAYBOOK.md` for:
- Git recovery procedures
- Docker debugging
- Deployment guides
- Component scaffolding
```

### Option 3: MCP Server (Advanced)

If you're using MCP, create a skill server that exposes these as tools:

```json
{
  "mcpServers": {
    "skills": {
      "command": "node",
      "args": ["skills-mcp-server.js"],
      "env": {
        "SKILLS_DIR": "./docs/skills"
      }
    }
  }
}
```

## Skill Catalog

### Emergency Skills

- **SKILL-GIT-RECOVERY.md** - Undo commits, recover files, fix git mistakes
- **SKILL-DOCKER-DEBUG.md** - Container issues, port conflicts, volume problems
- **SKILL-ENV-VALIDATOR.md** - Validate environment variables
- **SKILL-BUILD-ERROR-FIXER.md** - Fix common build errors
- **SKILL-DEPENDENCY-RESOLVER.md** - Fix npm/package issues

### Scaffolding Skills

- **SKILL-NEXT-API.md** - Create Next.js API routes
- **SKILL-REACT-COMPONENT.md** - Generate React components
- **SKILL-AUTH-MIDDLEWARE.md** - Set up auth middleware
- **SKILL-DATABASE-MIGRATION.md** - Create database migrations
- **SKILL-TEST-SCAFFOLD.md** - Generate test files

### Deployment Skills

- **SKILL-VERCEL-DEPLOY.md** - Deploy to Vercel
- **SKILL-DOCKER-COMPOSE.md** - Generate docker-compose files
- **SKILL-GITHUB-ACTIONS.md** - Set up CI/CD

### Quality Skills

- **SKILL-SECURITY-SCAN.md** - Security audit checklist
- **SKILL-ACCESSIBILITY.md** - A11y validation

## Key Differences from Web Skills

1. **No frontmatter metadata** - Just markdown content
2. **Standalone format** - Each skill is self-contained
3. **CLI-friendly** - Optimized for terminal reading
4. **Direct copy-paste** - Code blocks ready to execute
5. **Single-file reference** - No multi-file coordination needed

## Converting Web Skills to CLI

If you want to convert a web skill to CLI format:

```bash
# Extract just the content (remove metadata)
tail -n +9 skills/emergency/git-recovery/SKILL.md > skills-cli/SKILL-GIT-RECOVERY.md
```

Or use the conversion script:

```bash
./scripts/convert-skills-to-cli.sh
```

## Usage in Claude Code

When working with Claude Code, reference skills like this:

```
Claude: I need to undo my last commit

You: See docs/skills/SKILL-GIT-RECOVERY.md, section "Undo Last Commit"
```

Or if you have them in your CLAUDE.md:

```
Claude: Check the Git Recovery section in CLAUDE.md
```

## Best Practices

1. **Keep in project root** - Store skills where Claude Code can find them
2. **Reference in CLAUDE.md** - Link to skills in your project prompt
3. **Update regularly** - As you learn, add to the skills
4. **Project-specific** - Create custom skills for your stack
5. **Version control** - Commit skills with your project

## Creating Custom Skills

Template for a new CLI skill:

```markdown
# SKILL: [Name]

## When to Use

Use this skill when [description of use case].

## Quick Commands

```bash
# Command 1
command --option

# Command 2
command --option
```

## Step-by-Step Guide

### Step 1: [Action]

[Instructions]

```bash
# Commands
```

### Step 2: [Action]

[Instructions]

## Common Issues

### Issue: [Description]

**Fix:**
```bash
# Solution
```

## Examples

### Example 1: [Scenario]

```bash
# Full example
```

## Related Skills

- SKILL-[RELATED].md
```

Save as `docs/skills/SKILL-CUSTOM-NAME.md`
