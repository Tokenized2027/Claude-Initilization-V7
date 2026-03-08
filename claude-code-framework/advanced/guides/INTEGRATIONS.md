# Integration Guides

Quick-start guides for integrating common services into your projects.

---

## Table of Contents

1. [Supabase (Managed PostgreSQL + Auth)](#supabase)
2. [Vercel (Frontend Hosting)](#vercel)
3. [Railway (Backend Hosting)](#railway)

---

## Supabase

**What:** Managed PostgreSQL database with built-in auth, real-time subscriptions, and file storage.
**When:** Any project needing a database. Replaces self-hosted Postgres + custom auth.
**Cost:** Free tier covers most solo projects. Pro starts at $25/month.

### Setup

1. Create account at [supabase.com](https://supabase.com)
2. Create a new project (pick nearest region)
3. Copy your credentials from Settings > API:
   - `SUPABASE_URL` — your project URL
   - `SUPABASE_ANON_KEY` — public/anonymous key (safe for client)
   - `SUPABASE_SERVICE_ROLE_KEY` — secret key (server-only, never expose to client)

### Environment Variables

Add to `.env`:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...your-anon-key
SUPABASE_SERVICE_ROLE_KEY=eyJ...your-service-role-key
```

Add to `.env.example`:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### Next.js Integration

```bash
npm install @supabase/supabase-js @supabase/ssr
```

Create `lib/supabase.ts`:
```typescript
import { createClient } from '@supabase/supabase-js'

// Client-side (browser) — uses anon key
export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

Create `lib/supabase-server.ts`:
```typescript
import { createClient } from '@supabase/supabase-js'

// Server-side — uses service role key (full access, never expose to client)
export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
```

### Common Operations

```typescript
// Query data
const { data, error } = await supabase
  .from('users')
  .select('*')
  .order('created_at', { ascending: false })
  .limit(20)

// Insert data
const { data, error } = await supabase
  .from('users')
  .insert({ email: 'user@example.com', name: 'Jane' })
  .select()
  .single()

// Auth — sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password'
})

// Auth — sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure-password'
})

// Auth — get current user
const { data: { user } } = await supabase.auth.getUser()
```

### MCP Configuration

Add Postgres MCP to access your Supabase database directly from Claude Code:

```bash
claude mcp add supabase-db -e DATABASE_URL="postgresql://postgres:[PASSWORD]@db.[PROJECT_REF].supabase.co:5432/postgres" -- npx @modelcontextprotocol/server-postgres
```

Find your connection string in Supabase: Settings > Database > Connection string.

### Security Rules

- `SUPABASE_ANON_KEY` is safe for client-side (protected by Row Level Security)
- `SUPABASE_SERVICE_ROLE_KEY` is server-only — NEVER expose to browser
- Always enable Row Level Security (RLS) on tables
- Set up auth policies before going to production

---

## Vercel

**What:** Frontend hosting platform optimized for Next.js. Handles builds, CDN, SSL, and preview deployments automatically.
**When:** Any Next.js or React project ready to deploy.
**Cost:** Free tier covers hobby projects. Pro starts at $20/month.

### Setup

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Link project (run in project root)
vercel link
```

### Deploy

```bash
# Preview deployment (unique URL, doesn't affect production)
vercel

# Production deployment
vercel --prod
```

### Environment Variables

```bash
# Add env vars for production
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add SUPABASE_SERVICE_ROLE_KEY production

# List configured vars
vercel env ls

# Pull env vars to local .env
vercel env pull .env.local
```

### GitHub Auto-Deploy

1. Go to [vercel.com](https://vercel.com) > Import Project
2. Connect your GitHub repo
3. Vercel auto-deploys on every push:
   - Push to `main` → production deployment
   - Push to any branch → preview deployment with unique URL
   - PRs get preview comments with deployment link

### Custom Domain

```bash
vercel domains add yourdomain.com
```

Then update DNS at your registrar:
- Add CNAME record: `www` → `cname.vercel-dns.com`
- Add A record: `@` → `76.76.21.21`

### vercel.json (Optional)

```json
{
  "framework": "nextjs",
  "regions": ["iad1"],
  "crons": [{
    "path": "/api/cron/cleanup",
    "schedule": "0 0 * * *"
  }]
}
```

### CI/CD with GitHub Actions

See `essential/skills/deployment/github-actions-setup/SKILL.md` for a complete workflow template.

### Troubleshooting

| Problem | Fix |
|---------|-----|
| Build fails | Run `npm run build` locally first |
| Missing env vars | `vercel env ls` to check, `vercel env add` to fix |
| 404 on routes | Check `next.config.js` or add `vercel.json` rewrites |
| Function timeout | Increase timeout in `vercel.json` (max 60s on free) |
| CORS errors | Add headers in `next.config.js` |

---

## Railway

**What:** Backend hosting platform for databases, APIs, and background services. Deploy from GitHub or Docker.
**When:** Backend services, databases, cron jobs, or anything that isn't a static frontend.
**Cost:** Pay-as-you-go. Free trial with $5 credit. Hobby plan $5/month.

### Setup

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize project (run in project root)
railway init
```

### Deploy

```bash
# Deploy from current directory
railway up

# Or connect to GitHub for auto-deploy:
# 1. Go to railway.app
# 2. New Project > Deploy from GitHub Repo
# 3. Select your repo
# Auto-deploys on push to main
```

### Add a Database

```bash
# Add Postgres to your project
railway add --plugin postgresql

# Get connection string
railway variables
# Copy DATABASE_URL
```

Or via dashboard:
1. Go to your project on [railway.app](https://railway.app)
2. Click "New" > "Database" > "PostgreSQL"
3. Connection string auto-added to your service's env vars

### Environment Variables

```bash
# Set a variable
railway variables set SECRET_KEY=your-secret-here

# List all variables
railway variables

# Open dashboard to manage
railway open
```

### Dockerfile Deploy

Railway auto-detects Dockerfiles. Just have a `Dockerfile` in your repo:

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["gunicorn", "app:create_app()", "--bind", "0.0.0.0:8000"]
```

Railway builds and deploys automatically.

### Custom Domain

1. Dashboard > Your service > Settings > Domains
2. Add custom domain
3. Update DNS: CNAME to the provided Railway domain

### Monitoring

```bash
# View logs
railway logs

# Open dashboard
railway open
```

### Troubleshooting

| Problem | Fix |
|---------|-----|
| Deploy fails | Check `railway logs` for build errors |
| Database connection | Verify `DATABASE_URL` in `railway variables` |
| Port issues | Railway sets `PORT` env var automatically — use it |
| Cold starts slow | Upgrade from free tier, or add health check endpoint |
| Out of memory | Check `railway logs` for OOM, increase memory in settings |

### Flask on Railway

```bash
# Procfile (create in project root)
web: gunicorn app:create_app() --bind 0.0.0.0:$PORT
```

```bash
# requirements.txt must include
gunicorn
```

### Express/Node on Railway

```json
// package.json
{
  "scripts": {
    "start": "node dist/index.js"
  }
}
```

Railway runs `npm start` by default.

---

## Combining Services

### Typical Full-Stack Setup

```
Frontend (Vercel)  →  Backend API (Railway)  →  Database (Supabase or Railway Postgres)
```

**Environment Variables:**

| Service | Variable | Where |
|---------|----------|-------|
| Vercel (frontend) | `NEXT_PUBLIC_API_URL` | Points to Railway backend |
| Vercel (frontend) | `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL |
| Vercel (frontend) | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase public key |
| Railway (backend) | `DATABASE_URL` | Supabase or Railway Postgres |
| Railway (backend) | `SUPABASE_SERVICE_ROLE_KEY` | Supabase admin access |
| Railway (backend) | `JWT_SECRET` | For auth token signing |

### Alternative: All-in-One

For simpler projects, Supabase can handle everything:
- Database: Supabase Postgres
- Auth: Supabase Auth
- API: Supabase Edge Functions or Next.js API routes on Vercel
- Storage: Supabase Storage

No separate backend needed.
