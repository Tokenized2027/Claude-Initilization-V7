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
