# Templates - Reusable Boilerplate

Quick-start templates for common patterns and setups. Copy, customize, ship.

---

## Available Templates

### 🐳 Docker
**Location:** `docker/`
**Use for:** Containerized deployments, isolated environments

**Templates:**
- Python web apps (Flask/FastAPI)
- Next.js applications (coming soon)
- Full-stack setups (coming soon)

**Quick start:**
```bash
cp -r templates/docker/python-web/* /path/to/your/project/
# Customize docker-compose.yml and Dockerfile
./setup-docker.sh
```

**Documentation:** `docker/README.md`

---

### ⛓️ Web3 Patterns (Planned)
**Use for:** Common DeFi/Web3 code patterns

These will be added as you build real projects. Candidates:
- ERC20 token interactions
- Staking contract interfaces
- Price feed integrations
- Wallet connection patterns

### 📦 Project Setup
**Use for:** Initializing new projects with best practices

Use `create-project.sh` in the toolkit instead — it generates full scaffolded projects
interactively. See `claude-code-framework/essential/toolkit/`.

---

## How to Use Templates

### Quick Copy Method

```bash
# Copy entire template
cp -r $CLAUDE_HOME/templates/[template-type]/[template-name]/* /path/to/your/project/

# Or copy specific files
cp $CLAUDE_HOME/templates/docker/python-web/Dockerfile.production /path/to/your/project/
```

### Customization Checklist

After copying a template:

1. **Read the template's README** - Understand what it does
2. **Search for placeholders** - Usually marked with `[CHANGE-ME]` or `your-app-name`
3. **Update configurations** - Ports, service names, versions
4. **Add your environment variables** - Copy .env.example to .env
5. **Test the setup** - Run once to verify it works
6. **Commit to git** - Save your customized version

### Example Workflow

```bash
# 1. Copy template
cp -r $CLAUDE_HOME/templates/docker/python-web/* ~/projects/my-new-app/

# 2. Navigate to project
cd ~/projects/my-new-app/

# 3. Customize
# - Edit docker-compose.yml (change service name, ports)
# - Edit Dockerfile if needed
# - Create .env from .env.example

# 4. Test
./setup-docker.sh

# 5. Verify
curl http://localhost:5000/health

# 6. Commit
git add .
git commit -m "Add Docker setup from template"
```

---

## Template Guidelines

### What Makes a Good Template

**Universal:**
- Works for multiple projects
- No project-specific hardcoded values
- Clear placeholder markers

**Well-Documented:**
- README explaining what it does
- Comments in config files
- Quick start guide included

**Secure by Default:**
- No hardcoded secrets
- Environment variables for config
- Security best practices built in

**Easy to Customize:**
- Clear separation of generic vs specific
- Documented customization points
- Sane defaults that work out of box

---

## Creating Your Own Templates

### When to Create a Template

Create a template when you:
- Use the same setup 3+ times
- Have a proven working pattern
- Want to standardize across projects
- Share setup with team/community

### Template Structure

```
templates/your-template-name/
├── README.md                 # What it is, how to use
├── QUICKSTART.md            # 5-minute setup guide
├── [config files]           # Docker, package.json, etc.
├── .env.example             # Environment variables
└── examples/                # Sample usage
```

### Template README Template

```markdown
# [Template Name]

One-line description of what this template provides.

## What's Included

- Feature 1
- Feature 2
- Feature 3

## Quick Start

1. Copy template
2. Customize X, Y, Z
3. Run setup

## Customization Points

- [File]: Change [what]
- [File]: Update [what]

## Requirements

- Dependency 1
- Dependency 2

## Support

See main templates README or [relevant docs]
```

---

## Integration with Claude Code

### In Project CLAUDE.md

Reference templates you've used:

```markdown
## Project Setup

This project uses templates from:
- Docker: $CLAUDE_HOME/templates/docker/python-web/

For updates, check template source and merge changes.
```

### Ask Claude to Use Templates

```bash
claude "Set up Docker using the template from $CLAUDE_HOME/templates/docker/python-web/"
```

---

## Template Catalog

### By Use Case

**Deployment:**
- `docker/python-web/` - Python Flask/FastAPI

**Web3 Development:** (planned, add as you build real projects)

**Project Initialization:** Use `create-project.sh` in the toolkit

---

## Best Practices

### Using Templates

1. **Always customize** - Don't use templates blindly
2. **Read the README** - Understand what you're copying
3. **Test before committing** - Verify it works
4. **Document changes** - Note what you customized
5. **Keep templates updated** - Periodically sync improvements

### Maintaining Templates

1. **Version templates** - Track changes over time
2. **Test regularly** - Ensure they still work
3. **Update dependencies** - Keep packages current
4. **Document breaking changes** - Note what's incompatible
5. **Archive old versions** - Keep working versions available

---

## Common Customization Points

### Docker Templates
- Service names in docker-compose.yml
- Port mappings
- Resource limits (CPU/memory)
- Health check endpoints
- Volume mount paths

### Application Templates
- Application name
- Port numbers
- Database connections
- API keys (via environment variables)
- Feature flags

### Configuration Templates
- File paths
- URLs and endpoints
- Timeout values
- Retry logic
- Logging levels

---

## Troubleshooting Templates

### Template Won't Work

1. **Check requirements** - Do you have prerequisites?
2. **Read the README** - Missing a setup step?
3. **Verify customizations** - Did you update all placeholders?
4. **Check versions** - Are dependencies compatible?
5. **Review recent changes** - Did template break?

### Finding the Right Template

1. **Start here** - Read this README
2. **Check template READMEs** - Read specific docs
3. **Look at examples** - See template in action
4. **Ask Claude** - "Which template should I use for [use case]?"

---

## Contributing Templates

### Have a Useful Pattern?

If you've created something reusable:

1. **Generalize it** - Remove project-specific details
2. **Document it** - Add README and comments
3. **Test it** - Verify it works fresh
4. **Add it** - Create folder under appropriate category
5. **Update this README** - List new template

### Quality Checklist

Before adding a template:
- [ ] No hardcoded secrets or API keys
- [ ] Clear placeholder markers for customization
- [ ] Comprehensive README with quick start
- [ ] Working .env.example
- [ ] Tested on fresh install
- [ ] Comments explaining non-obvious parts
- [ ] Listed in this README

---

## Future Templates

**Planned additions:**

**Docker:**
- Next.js optimized builds
- Multi-service orchestration
- Database + app combos

**Web3:**
- Common contract interactions
- Wallet connection patterns
- Transaction workflows
- Event listening setups

**Project Setup:**
- Full-stack starter templates
- API-first architecture
- Monorepo structures

**Want something specific?** Create an issue or ask Claude to help build it.

---

**Remember:** Templates are starting points, not final solutions. Customize for your needs.
