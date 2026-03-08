#!/bin/bash

# React Component Scaffold
cat > scaffolding/react-component-scaffold/SKILL.md << 'EOF'
---
name: react-component-scaffold
description: Generates React components with TypeScript, props interface, and example usage. Use when user says "create component", "new component", "add React component", or mentions creating UI elements.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: scaffolding
---

# React Component Scaffolder

## Component Template

```typescript
// components/Button.tsx
import { ButtonHTMLAttributes } from 'react'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
}

export function Button({ 
  variant = 'primary', 
  size = 'md', 
  children,
  className = '',
  ...props 
}: ButtonProps) {
  const baseStyles = 'rounded font-medium transition-colors'
  const variantStyles = {
    primary: 'bg-blue-600 hover:bg-blue-700 text-white',
    secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-900',
    danger: 'bg-red-600 hover:bg-red-700 text-white',
  }
  const sizeStyles = {
    sm: 'px-3 py-1 text-sm',
    md: 'px-4 py-2',
    lg: 'px-6 py-3 text-lg',
  }
  
  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}
```

## Usage Example

```typescript
import { Button } from '@/components/Button'

export default function Page() {
  return (
    <div>
      <Button variant="primary" size="md" onClick={() => alert('Clicked!')}>
        Click Me
      </Button>
    </div>
  )
}
```
EOF

# Auth Middleware Setup
cat > scaffolding/auth-middleware-setup/SKILL.md << 'EOF'
---
name: auth-middleware-setup
description: Adds authentication middleware to protect routes and endpoints with JWT validation. Use when user says "add authentication", "protect route", "add auth", "secure endpoint", or mentions authentication/authorization.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: scaffolding
---

# Auth Middleware Setup

## Next.js Middleware

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { verify } from 'jsonwebtoken'

const JWT_SECRET = process.env.JWT_SECRET || ''

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')?.value
  
  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  
  try {
    verify(token, JWT_SECRET)
    return NextResponse.next()
  } catch (error) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*'],
}
```

## API Route Protection

```typescript
// lib/auth.ts
import { NextRequest, NextResponse } from 'next/server'
import { verify } from 'jsonwebtoken'

export function withAuth(handler: Function) {
  return async (request: NextRequest) => {
    const token = request.cookies.get('token')?.value
    
    if (!token) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    
    try {
      const decoded = verify(token, process.env.JWT_SECRET!)
      return handler(request, decoded)
    } catch (error) {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 })
    }
  }
}
```
EOF

# Database Migration
cat > scaffolding/database-migration/SKILL.md << 'EOF'
---
name: database-migration
description: Creates database migration files for schema changes including adding columns, creating tables, and altering structures. Use when user says "create migration", "add column", "alter table", "database change", or mentions schema modifications.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: scaffolding
---

# Database Migration Generator

## SQL Migration Template

```sql
-- migrations/001_add_email_to_users.sql

-- Up Migration
ALTER TABLE users ADD COLUMN email VARCHAR(255) UNIQUE;
CREATE INDEX idx_users_email ON users(email);

-- Down Migration (for rollback)
-- DROP INDEX idx_users_email;
-- ALTER TABLE users DROP COLUMN email;
```

## Prisma Migration

```bash
# Create migration
npx prisma migrate dev --name add_email_to_users

# Apply migration
npx prisma migrate deploy
```

## Alembic (Python) Migration

```python
# migrations/versions/001_add_email.py
from alembic import op
import sqlalchemy as sa

revision = '001'
down_revision = None

def upgrade():
    op.add_column('users', sa.Column('email', sa.String(255), unique=True))
    op.create_index('idx_users_email', 'users', ['email'])

def downgrade():
    op.drop_index('idx_users_email', table_name='users')
    op.drop_column('users', 'email')
```
EOF

# Test Scaffold
cat > scaffolding/test-scaffold/SKILL.md << 'EOF'
---
name: test-scaffold
description: Generates test files for components and functions with setup, basic tests, and mocks. Use when user says "add tests", "create test", "test this component", or mentions testing.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: scaffolding
---

# Test Scaffolder

## React Component Test

```typescript
// components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })
  
  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    fireEvent.click(screen.getByText('Click me'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
  
  it('applies variant styles', () => {
    const { container } = render(<Button variant="danger">Delete</Button>)
    expect(container.firstChild).toHaveClass('bg-red-600')
  })
})
```

## API Route Test

```typescript
// app/api/users/route.test.ts
import { GET, POST } from './route'
import { NextRequest } from 'next/server'

describe('/api/users', () => {
  describe('GET', () => {
    it('returns users list', async () => {
      const request = new NextRequest('http://localhost:3000/api/users')
      const response = await GET(request)
      const data = await response.json()
      
      expect(response.status).toBe(200)
      expect(data.success).toBe(true)
      expect(Array.isArray(data.data)).toBe(true)
    })
  })
  
  describe('POST', () => {
    it('creates user with valid data', async () => {
      const request = new NextRequest('http://localhost:3000/api/users', {
        method: 'POST',
        body: JSON.stringify({ name: 'Alice', email: 'alice@example.com' })
      })
      
      const response = await POST(request)
      const data = await response.json()
      
      expect(response.status).toBe(201)
      expect(data.success).toBe(true)
    })
  })
})
```
EOF

# Vercel Deployer
cat > deployment/vercel-deployer/SKILL.md << 'EOF'
---
name: vercel-deployer
description: Deploys Next.js and React applications to Vercel with environment variable configuration and domain setup. Use when user says "deploy to Vercel", "push to production", "Vercel deployment", or mentions deploying to Vercel.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: deployment
---

# Vercel Deployer

## Step 1: Install Vercel CLI

```bash
npm install -g vercel
```

## Step 2: Login

```bash
vercel login
```

## Step 3: Deploy

```bash
# Deploy to preview
vercel

# Deploy to production
vercel --prod
```

## Step 4: Set Environment Variables

```bash
# Set a variable
vercel env add DATABASE_URL production

# Or via Vercel dashboard:
# 1. Go to project settings
# 2. Environment Variables
# 3. Add variables
```

## Step 5: Custom Domain

```bash
# Add domain
vercel domains add yourdomain.com

# Link to project
vercel link
```

## Troubleshooting

**Build fails:**
```bash
# Check build logs in Vercel dashboard
# Common issues:
# - Missing environment variables
# - Wrong Node version (set in package.json)
# - Build command incorrect
```

**Environment variables not working:**
```bash
# Make sure they're prefixed with NEXT_PUBLIC_ for client-side
# Redeploy after adding variables:
vercel --prod
```
EOF

# Docker Compose Generator
cat > deployment/docker-compose-generator/SKILL.md << 'EOF'
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
EOF

# GitHub Actions Setup
cat > deployment/github-actions-setup/SKILL.md << 'EOF'
---
name: github-actions-setup
description: Creates GitHub Actions CI/CD workflows for testing, building, and deploying applications. Use when user says "add CI/CD", "GitHub Actions", "automate deployment", or mentions continuous integration.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: deployment
---

# GitHub Actions Setup

## CI Workflow (Test + Build)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test
      
      - name: Build
        run: npm run build
```

## Deploy to Vercel

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```
EOF

# Security Scanner
cat > quality/security-scanner/SKILL.md << 'EOF'
---
name: security-scanner
description: Scans code for common security vulnerabilities including hardcoded secrets, SQL injection, XSS, and dependency CVEs. Use when user says "check security", "scan for vulnerabilities", "security review", or mentions security concerns.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: quality
---

# Security Scanner

## Quick Checks

### Hardcoded Secrets

```bash
# Search for common secret patterns
grep -r "password\|secret\|api_key\|token" . --exclude-dir=node_modules

# Check for keys in code
grep -r "sk-\|pk-\|AIza" . --exclude-dir=node_modules
```

### SQL Injection Risk

```typescript
// ❌ Vulnerable
db.query(`SELECT * FROM users WHERE id = ${userId}`)

// ✅ Safe - Use parameterized queries
db.query('SELECT * FROM users WHERE id = ?', [userId])
```

### XSS Risk

```typescript
// ❌ Vulnerable
<div dangerouslySetInnerHTML={{__html: userInput}} />

// ✅ Safe - Sanitize first
import DOMPurify from 'dompurify'
<div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(userInput)}} />
```

## Automated Scans

```bash
# Check dependencies for CVEs
npm audit

# Fix vulnerabilities
npm audit fix

# Check for secrets
npx secretlint "**/*"
```
EOF

# Accessibility Checker
cat > quality/accessibility-checker/SKILL.md << 'EOF'
---
name: accessibility-checker
description: Validates components for WCAG compliance including semantic HTML, ARIA labels, contrast ratios, and keyboard navigation. Use when user says "check accessibility", "a11y", "WCAG compliance", or mentions accessibility concerns.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: quality
---

# Accessibility Checker

## Quick Checks

### Semantic HTML

```tsx
// ❌ Bad - non-semantic
<div onClick={handleClick}>Click me</div>

// ✅ Good - semantic
<button onClick={handleClick}>Click me</button>
```

### Alt Text

```tsx
// ❌ Bad - missing alt
<img src="logo.png" />

// ✅ Good - descriptive alt
<img src="logo.png" alt="Company logo" />
```

### ARIA Labels

```tsx
// ❌ Bad - no label
<button><SearchIcon /></button>

// ✅ Good - aria-label
<button aria-label="Search"><SearchIcon /></button>
```

### Keyboard Navigation

```tsx
// ✅ Good - keyboard accessible
<button onKeyDown={(e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    handleClick()
  }
}}>
  Submit
</button>
```

## Automated Checks

```bash
# Install axe-core
npm install --save-dev @axe-core/react

# Add to tests
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

test('should have no a11y violations', async () => {
  const { container } = render(<App />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```
EOF

