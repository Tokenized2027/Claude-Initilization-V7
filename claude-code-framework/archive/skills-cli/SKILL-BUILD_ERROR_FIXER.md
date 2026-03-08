
# Build Error Fixer

Quickly diagnoses and fixes build/compilation errors.

## Common Build Errors

### Missing Dependency

**Error:**
```
Module not found: Can't resolve 'react'
Cannot find module 'express'
```

**Fix:**
```bash
# Check if it's in package.json
cat package.json | grep react

# If missing, install it
npm install react

# Or for dev dependencies
npm install --save-dev typescript
```

---

### Wrong Node Version

**Error:**
```
error Unsupported Engine
The engine "node" is incompatible with this module
```

**Fix:**
```bash
# Check required version
cat package.json | grep engines

# Check your version
node --version

# Install correct version with nvm
nvm install 20
nvm use 20
```

---

### TypeScript Errors

**Error:**
```
TS2307: Cannot find module './utils' or its corresponding type declarations
TS2322: Type 'string' is not assignable to type 'number'
```

**Fix:**
```bash
# Regenerate types
npm run build

# Or clear cache and rebuild
rm -rf node_modules .next
npm install
npm run build
```

**For type errors:**
- Fix the actual type mismatch in code
- Or add `// @ts-ignore` if you're certain it's fine

---

### Webpack/Next.js Config Issues

**Error:**
```
Module parse failed: Unexpected token
Invalid options object. Webpack has been initialized using a configuration object
```

**Fix:**
```bash
# Clear Next.js cache
rm -rf .next

# Rebuild
npm run build

# If still broken, check next.config.js for syntax errors
```

---

### Environment Variables Missing

**Error:**
```
error - Error: NEXT_PUBLIC_API_URL is not defined
```

**Fix:**
```bash
# Check .env.local exists
ls -la .env.local

# Verify variable is defined
cat .env.local | grep API_URL

# Add if missing
echo "NEXT_PUBLIC_API_URL=http://localhost:3000" >> .env.local

# Restart dev server
npm run dev
```

---

### Lock File Conflicts

**Error:**
```
npm ERR! code EINTEGRITY
npm ERR! Verification failed while extracting
```

**Fix:**
```bash
# Delete lock file and node_modules
rm package-lock.json
rm -rf node_modules

# Reinstall
npm install
```

---

## Quick Reference

| Error Type | Quick Fix |
|------------|-----------|
| Module not found | `npm install [package]` |
| Type errors | Clear `.next`, rebuild |
| Wrong Node version | `nvm install [version]` |
| Lock file conflict | Delete `package-lock.json`, reinstall |
| Env var missing | Add to `.env.local`, restart |
| Build cache issue | `rm -rf .next && npm run build` |

## When to Use

✅ Use for: Build errors, compilation errors, missing modules
❌ Don't use for: Runtime errors, logic bugs, production deployment
