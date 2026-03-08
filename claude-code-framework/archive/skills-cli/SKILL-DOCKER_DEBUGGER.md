
# Docker Debugger

Quickly diagnoses and fixes common Docker container issues.

## Instructions

### Step 1: Identify the Error Type

When you see a Docker error, first categorize it:

**Port Conflict Errors:**
- `EADDRINUSE: address already in use`
- `Bind for 0.0.0.0:3000 failed: port is already allocated`
- `Error starting userland proxy: listen tcp4 0.0.0.0:5432: bind: address already in use`

**Image Errors:**
- `Error response from daemon: manifest for [image] not found`
- `docker: Error response from daemon: pull access denied`
- `failed to solve with frontend dockerfile.v0`

**Network Errors:**
- `driver failed programming external connectivity`
- `network [name] not found`
- `endpoint with name [name] already exists in network`

**Volume Errors:**
- `Error response from daemon: error while mounting volume`
- `invalid volume specification`
- `permission denied` (volume mount)

**Build Errors:**
- `failed to compute cache key`
- `COPY failed: file not found`
- `RUN returned a non-zero code`

### Step 2: Apply the Appropriate Fix

#### Port Conflict Fix

**Diagnostic command:**
```bash
# Find what's using the port
lsof -i :[PORT_NUMBER]
# Example: lsof -i :3000
```

**Quick fix:**
```bash
# Kill the process using the port
lsof -ti:[PORT_NUMBER] | xargs kill -9
# Example: lsof -ti:3000 | xargs kill -9
```

**Alternative fixes:**
```bash
# Option 1: Change the port in docker-compose.yml
# Change "3000:3000" to "3001:3000"

# Option 2: Stop all containers and restart
docker-compose down
docker-compose up -d

# Option 3: Find and stop the specific container
docker ps
docker stop [CONTAINER_ID]
```

**Verify:**
```bash
# Check if port is now free
lsof -i :[PORT_NUMBER]
# Should return nothing

# Restart your container
docker-compose up -d
```

---

#### Image Not Found Fix

**Diagnostic:**
```bash
# Check if image exists locally
docker images | grep [IMAGE_NAME]

# Check Docker Hub for the image
# Visit: https://hub.docker.com/search?q=[IMAGE_NAME]
```

**Fix:**
```bash
# Pull the image manually
docker pull [IMAGE_NAME]:[TAG]
# Example: docker pull postgres:15

# Or rebuild if it's a custom image
docker-compose build [SERVICE_NAME]
docker-compose up -d
```

**Common issues:**
- Typo in image name (check Dockerfile or docker-compose.yml)
- Missing tag (add `:latest` or specific version)
- Private registry requires login: `docker login`

---

#### Network Error Fix

**Diagnostic:**
```bash
# List Docker networks
docker network ls

# Inspect a specific network
docker network inspect [NETWORK_NAME]
```

**Fix:**
```bash
# Remove the problematic network
docker network rm [NETWORK_NAME]

# Recreate with docker-compose
docker-compose down
docker-compose up -d

# Or create manually
docker network create [NETWORK_NAME]
```

**For "endpoint already exists":**
```bash
# Force remove the container
docker rm -f [CONTAINER_NAME]

# Clean up networks
docker network prune -f

# Restart
docker-compose up -d
```

---

#### Volume Error Fix

**Diagnostic:**
```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect [VOLUME_NAME]
```

**Fix for permission errors:**
```bash
# Check ownership of volume mount path
ls -la /path/to/volume

# Fix permissions (if local mount)
sudo chown -R $USER:$USER /path/to/volume

# Or run container with user flag in docker-compose.yml:
# user: "${UID}:${GID}"
```

**Fix for "volume not found":**
```bash
# Create the volume
docker volume create [VOLUME_NAME]

# Or let docker-compose create it
docker-compose up -d
```

**Clean up unused volumes:**
```bash
docker volume prune -f
```

---

#### Build Error Fix

**For "file not found" in COPY:**
```dockerfile
# Check Dockerfile COPY paths
COPY ./src /app/src  # Must match actual directory structure

# Verify files exist relative to Dockerfile
ls -la ./src
```

**For "RUN returned non-zero code":**
```bash
# Build with verbose output
docker-compose build --no-cache --progress=plain

# Run the failing command manually to debug
docker run -it [IMAGE_NAME] /bin/bash
[RUN YOUR COMMAND]
```

**For cache issues:**
```bash
# Build without cache
docker-compose build --no-cache

# Remove all build cache
docker builder prune -af
```

---

### Step 3: Nuclear Options (When Nothing Else Works)

**Warning:** These delete containers, images, and volumes. Use only if you have backups.

**Clean everything and start fresh:**
```bash
# Stop all containers
docker-compose down -v

# Remove all stopped containers
docker container prune -f

# Remove all unused images
docker image prune -af

# Remove all unused volumes
docker volume prune -f

# Remove all unused networks
docker network prune -f

# Restart Docker daemon (Linux)
sudo systemctl restart docker

# Restart Docker daemon (Mac)
# Docker Desktop → Preferences → Reset → Restart Docker
```

**Then rebuild:**
```bash
docker-compose build --no-cache
docker-compose up -d
```

---

## Common Scenarios

### Scenario 1: "Port 3000 already in use"

**User says:** "My Next.js app won't start - port 3000 is already in use"

**Response:**
```bash
# Kill whatever is using port 3000
lsof -ti:3000 | xargs kill -9

# Verify port is free
lsof -i :3000

# Start your container
docker-compose up -d
```

**Explanation:** Another process (probably a previous container or dev server) is holding port 3000. We kill it and restart.

---

### Scenario 2: "postgres image not found"

**User says:** "Docker says 'manifest for postgres:latest not found'"

**Response:**
```bash
# Pull the image explicitly
docker pull postgres:15

# Or update docker-compose.yml to specify version
# Change: image: postgres:latest
# To:     image: postgres:15

# Then start
docker-compose up -d
```

**Explanation:** Docker Hub removed support for some `:latest` tags. Always specify a version.

---

### Scenario 3: "Container starts then immediately exits"

**User says:** "My container starts but exits immediately with code 1"

**Response:**
```bash
# Check logs to see what failed
docker-compose logs [SERVICE_NAME]

# Run container interactively to debug
docker-compose run [SERVICE_NAME] /bin/bash

# Common fixes:
# 1. Missing environment variable - check .env file
# 2. Database not ready - add healthcheck or sleep
# 3. Wrong command - check docker-compose.yml command:
```

---

### Scenario 4: "Permission denied on volume mount"

**User says:** "Getting 'permission denied' when container tries to write to mounted volume"

**Response:**
```bash
# Fix ownership of mounted directory
sudo chown -R $USER:$USER ./data

# Or add user to docker-compose.yml:
# services:
#   app:
#     user: "${UID}:${GID}"

# Export UID/GID in terminal first:
export UID=$(id -u)
export GID=$(id -g)

# Then restart
docker-compose down
docker-compose up -d
```

---

### Scenario 5: "docker-compose up hangs on 'Creating network'"

**User says:** "docker-compose just hangs when trying to create network"

**Response:**
```bash
# Clean up existing networks
docker network prune -f

# Remove the compose network manually
docker network rm [PROJECT]_default

# Restart Docker daemon
sudo systemctl restart docker  # Linux
# Or restart Docker Desktop on Mac

# Try again
docker-compose up -d
```

---

## Troubleshooting Tips

**Always check logs first:**
```bash
docker-compose logs [SERVICE_NAME]
docker logs [CONTAINER_ID]
```

**Verify environment variables:**
```bash
docker-compose config
# Shows resolved configuration with env vars
```

**Check resource usage:**
```bash
docker stats
# Shows CPU, memory, network usage per container
```

**Inspect running containers:**
```bash
docker ps
docker inspect [CONTAINER_ID]
```

**Get into a running container:**
```bash
docker exec -it [CONTAINER_NAME] /bin/bash
# Or /bin/sh for Alpine-based images
```

---

## Prevention

**Use health checks in docker-compose.yml:**
```yaml
services:
  db:
    image: postgres:15
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
  
  app:
    depends_on:
      db:
        condition: service_healthy
```

**Always specify image versions:**
```yaml
# Bad
image: postgres:latest

# Good
image: postgres:15
```

**Use .dockerignore:**
```
node_modules
.git
.env
*.log
```

**Pin dependencies in Dockerfile:**
```dockerfile
# Bad
FROM node

# Good  
FROM node:20-alpine
```

---

## Quick Reference

| Error | Quick Fix |
|-------|-----------|
| Port in use | `lsof -ti:[PORT] \| xargs kill -9` |
| Image not found | `docker pull [IMAGE]:[TAG]` |
| Network exists | `docker network rm [NAME]` |
| Volume permission | `sudo chown -R $USER:$USER [PATH]` |
| Container exits | Check logs: `docker-compose logs` |
| Build cache issue | `docker-compose build --no-cache` |
| Everything broken | `docker-compose down -v && docker system prune -af` |

---

## When to Use This Skill

✅ Use docker-debugger when:
- Docker error appears
- Container won't start or exits immediately
- Port conflict error
- Image pull fails
- Volume mounting issues
- Network errors

❌ Don't use docker-debugger for:
- Writing Dockerfiles from scratch (use DevOps agent)
- Complex orchestration setup (use DevOps agent)
- Production deployment (use DevOps agent)
- Architectural decisions about containerization

**This skill fixes Docker problems. For building Docker infrastructure, use your DevOps Engineer agent.**
