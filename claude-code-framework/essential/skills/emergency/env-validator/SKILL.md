---
name: env-validator
description: Validates .env files for missing variables, incorrect formats, exposed secrets, and configuration errors. Use when user says "check my .env", "environment variables missing", "config error", or mentions problems with environment setup.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: emergency
---

# Environment Variable Validator

Checks .env files for common issues and security problems.

## Validation Checks

### Check 1: Required Variables Present

**Common required variables for Next.js:**
```
NEXT_PUBLIC_API_URL=
DATABASE_URL=
API_KEY=
```

**Common required variables for Flask:**
```
FLASK_APP=
DATABASE_URL=
SECRET_KEY=
```

**How to check:**
```bash
# List all env vars
cat .env.local

# Check for specific var
grep "DATABASE_URL" .env.local
```

---

### Check 2: No Exposed Secrets

**Security scan:**
```bash
# Check for common secret patterns
grep -E "(password|secret|key|token)" .env.local

# Verify .env.local is in .gitignore
cat .gitignore | grep .env.local
```

**If exposed:**
```bash
# Remove from git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env.local" \
  --prune-empty --tag-name-filter cat -- --all

# Rotate all secrets immediately
```

---

### Check 3: Correct Formats

**URL format:**
```bash
# Database URL
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# API URL (must start with http:// or https://)
NEXT_PUBLIC_API_URL=http://localhost:3000
```

**Boolean format:**
```bash
# Use lowercase true/false
DEBUG=true
# Not: DEBUG=True or DEBUG=1
```

---

### Check 4: No Trailing Spaces

**Common issue:**
```bash
# Bad - has trailing space
API_KEY=abc123 

# Good
API_KEY=abc123
```

**Fix:**
```bash
# Remove trailing spaces
sed -i 's/[[:space:]]*$//' .env.local
```

---

### Check 5: Port Numbers Valid

**Check ports:**
```bash
# Ports should be 1-65535
PORT=3000  # Valid
PORT=70000  # Invalid (too high)
```

---

## Common Issues

### Issue 1: .env.local Not Loaded

**Check:**
```bash
# Verify file exists
ls -la .env.local

# Check file is readable
cat .env.local

# Restart dev server
npm run dev
```

---

### Issue 2: Variable Not Accessible

**Next.js:**
```bash
# Browser-accessible vars need NEXT_PUBLIC_ prefix
NEXT_PUBLIC_API_URL=http://localhost:3000  # ✅ Works in browser
API_SECRET=abc123                           # ✅ Server-side only
```

---

### Issue 3: Wrong .env File

**Next.js uses:**
- `.env.local` (local development, ignored by git)
- `.env.development` (development defaults)
- `.env.production` (production defaults)
- `.env` (all environments)

**Check you're editing the right one:**
```bash
ls -la .env*
```

---

## Quick Validation Script

```bash
#!/bin/bash
# Save as: scripts/validate-env.sh

echo "🔍 Validating .env.local..."

# Check file exists
if [ ! -f .env.local ]; then
  echo "❌ .env.local not found"
  exit 1
fi

# Check for exposed secrets
if grep -q "SECRET_KEY=" .env.local; then
  echo "✅ SECRET_KEY present"
else
  echo "⚠️  SECRET_KEY missing"
fi

# Check for trailing spaces
if grep -q "[[:space:]]$" .env.local; then
  echo "⚠️  Trailing spaces detected"
fi

# Check .gitignore
if grep -q ".env.local" .gitignore; then
  echo "✅ .env.local in .gitignore"
else
  echo "❌ .env.local NOT in .gitignore - ADD IT NOW"
fi

echo "✅ Validation complete"
```

---

## When to Use

✅ Use for: Checking .env files, finding missing vars, security scans
❌ Don't use for: Production secrets management, complex config architecture
