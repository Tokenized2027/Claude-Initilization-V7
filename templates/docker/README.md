# Docker Templates for Claude Code Projects

Reusable Docker configurations for rapid project deployment.

## Available Templates

### 1. Python Flask/FastAPI Template
- Production-ready Dockerfile
- Docker Compose with security hardening
- Setup scripts (Windows/Linux/Mac)
- Quick start guide

### 2. Next.js Template (Coming Soon)
- Optimized multi-stage builds
- Static export support
- Environment variable handling

### 3. Full-Stack Template (Coming Soon)
- Frontend + Backend + Database
- Nginx reverse proxy
- SSL/TLS ready

---

## Quick Start

### For Python Web Apps

1. **Copy template files to your project:**
```bash
cp templates/docker/python-web/* /path/to/your/project/
```

2. **Customize for your project:**
   - Edit `docker-compose.yml` - Change service name and ports
   - Edit `Dockerfile.production` - Adjust Python version if needed
   - Update `.env.example` with your required variables

3. **Run setup:**
```bash
# Windows
.\setup-docker.bat

# Linux/Mac
chmod +x setup-docker.sh
./setup-docker.sh
```

---

## Template Structure

```
python-web/
├── Dockerfile.production      # Multi-stage production build
├── docker-compose.yml         # Orchestration with security defaults
├── setup-docker.sh           # Linux/Mac automated setup
├── setup-docker.bat          # Windows automated setup
├── .dockerignore             # Standard ignores
└── QUICKSTART.md            # 5-minute setup guide
```

---

## Security Features

All templates include:
- ✅ Non-root user execution
- ✅ Read-only root filesystem
- ✅ Network isolation
- ✅ Resource limits (CPU/Memory)
- ✅ Minimal attack surface
- ✅ Health checks
- ✅ No privilege escalation

---

## Customization Guide

### Change Port
Edit `docker-compose.yml`:
```yaml
ports:
  - "3000:3000"  # Change left number for host port
```

### Adjust Resources
Edit `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'      # Increase CPU limit
      memory: 4G       # Increase memory limit
```

### Add Database
See `examples/` folder for postgres, mysql, redis templates.

---

## Common Commands

```bash
# Build image
docker-compose build

# Start container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop container
docker-compose down

# Access shell
docker-compose exec [service-name] /bin/bash

# Complete cleanup
docker-compose down -v
docker system prune -a
```

---

## When to Use Docker

**Good for:**
- Production deployments
- Isolated development environments
- Team collaboration (consistent envs)
- Testing in clean state
- Resource-constrained execution

**Skip Docker if:**
- Quick local prototyping
- You're just starting a project
- Simple scripts with no dependencies
- Maximum performance needed (native is faster)

---

## Integration with Claude Code

### In CLAUDE.md
```markdown
## Docker Setup

This project uses Docker for isolated execution.

**Quick start:**
```bash
./setup-docker.sh
```

**Access:** http://localhost:PORT

**Common commands:** See templates/docker/README.md
```

### In STATUS.md
```markdown
## Environment

- **Deployment:** Docker containerized
- **Port:** 5000
- **Health check:** http://localhost:5000/health
```

---

## Troubleshooting

### Port Already in Use
```bash
# Find what's using the port
lsof -i :5000  # Mac/Linux
netstat -ano | findstr :5000  # Windows

# Either kill that process or change port in docker-compose.yml
```

### Container Won't Start
```bash
# Check logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Permission Denied
```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
# Then log out and back in
```

### Out of Disk Space
```bash
# Clean up Docker resources
docker system prune -a --volumes
```

---

## Best Practices

1. **Always use .dockerignore** - Keep images small
2. **Multi-stage builds** - Separate build and runtime deps
3. **Non-root user** - Security requirement
4. **Health checks** - Enable auto-recovery
5. **Resource limits** - Prevent resource exhaustion
6. **Volume for data** - Persist important data
7. **Environment variables** - Never hardcode secrets

---

## Examples

See `claude-code-framework/advanced/examples/` for:
- Full-stack app with database
- Multi-service architecture
- SSL/TLS configuration
- CI/CD integration
- Production monitoring setup

---

## Related Documentation

- **Docker Docs:** https://docs.docker.com/
- **Docker Compose:** https://docs.docker.com/compose/
- **Security Best Practices:** https://docs.docker.com/develop/security-best-practices/
- **Claude Code Integration:** `claude-code-framework/essential/guides/INTEGRATIONS.md`
