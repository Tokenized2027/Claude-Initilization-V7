
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
