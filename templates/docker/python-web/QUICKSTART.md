# 🚀 Docker Quick Start - 5 Minutes to Launch

Get your Python web application running in a fully isolated container in 5 minutes.

---

## ✅ Prerequisites

- Docker Desktop installed and running
- Your project's requirements.txt
- Environment variables identified
- 5 minutes of your time

---

## 🎯 Step-by-Step

### 1. Copy Template Files (1 minute)

```bash
# From your Claude templates folder
cp templates/docker/python-web/Dockerfile.production /path/to/your/project/
cp templates/docker/python-web/docker-compose.yml /path/to/your/project/
cp templates/docker/python-web/setup-docker.sh /path/to/your/project/
cp templates/docker/python-web/setup-docker.bat /path/to/your/project/
cp templates/docker/python-web/.dockerignore /path/to/your/project/
```

### 2. Configure Environment (2 minutes)

```bash
# Copy your env example
cp .env.example .env

# Edit .env and add your variables
nano .env  # or use any text editor
```

**Customize docker-compose.yml:**
- Change service name (line 3): `your-app-name`
- Adjust port if needed (line 10): `"5000:5000"`
- Update command (line 13) to match your app entry point

### 3. Run Setup Script (2 minutes)

**Windows:**
```powershell
.\setup-docker.bat
```

**macOS/Linux:**
```bash
chmod +x setup-docker.sh
./setup-docker.sh
```

**Or use Docker Compose directly:**
```bash
docker-compose build
docker-compose up -d
```

### 4. Access Your App

Open your browser: **http://localhost:5000** (or your configured port)

---

## 🎉 That's It!

You now have a fully isolated, secure environment running:
- ✅ Your Python application
- ✅ Complete data isolation
- ✅ Resource limits
- ✅ Security hardening
- ✅ Health monitoring (if configured)

---

## 📊 Common Commands

```bash
# View logs
docker-compose logs -f

# Stop container
docker-compose down

# Start container
docker-compose up -d

# Restart container
docker-compose restart

# Access container shell
docker-compose exec your-app-name /bin/bash

# Complete cleanup
docker-compose down -v
docker system prune -a
```

---

## 🔧 Troubleshooting

**Port already in use?**
```bash
# Edit docker-compose.yml
# Change: "5001:5000"  # Use different host port
```

**Container won't start?**
```bash
# View logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

**Need to access container?**
```bash
docker-compose exec your-app-name /bin/bash
```

**Permission issues?**
```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

---

## 📚 Next Steps

- Customize Dockerfile for your specific needs
- Add health check endpoint to your app
- Configure additional services (database, redis, etc.)
- Set up monitoring and logging
- Review security settings

---

## 🔒 Security Features Included

- Non-root user execution
- Read-only root filesystem
- Network isolation
- Resource limits (2 CPU cores, 2GB RAM)
- Minimal permissions
- No privilege escalation

---

**Status**: Ready to Deploy 🚀
**Environment**: Fully Isolated & Secure 🔒
