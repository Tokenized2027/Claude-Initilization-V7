---
name: docker-compose-generator
description: Creates docker-compose.yml files for multi-container applications including Next.js, PostgreSQL, Redis, and more. Use when user says "create docker-compose", "containerize app", "Docker setup", or mentions multi-container deployment.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: deployment
---

# Docker Compose Generator

## Next.js + PostgreSQL + Redis

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - .:/app
      - /app/node_modules
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=myapp
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

## Usage

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all
docker-compose down

# Rebuild
docker-compose build --no-cache
```
