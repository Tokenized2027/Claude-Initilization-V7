
# Dependency Resolver

Fixes package manager dependency conflicts.

## Common Issues

### Peer Dependency Warnings

**Error:**
```
npm WARN ERESOLVE overriding peer dependency
npm WARN react@18.2.0 requires a peer of react-dom@^18.0.0
```

**Fix:**
```bash
# Install the required peer dependency
npm install react-dom@^18.0.0

# Or use --legacy-peer-deps flag
npm install --legacy-peer-deps
```

---

### Version Conflicts

**Error:**
```
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^17.0.0" from package-a@1.0.0
npm ERR! react@"18.2.0" from the root project
```

**Fix Option 1 - Upgrade conflicting package:**
```bash
npm install package-a@latest
```

**Fix Option 2 - Use compatible React version:**
```bash
npm install react@17.0.0 react-dom@17.0.0
```

**Fix Option 3 - Override (package.json):**
```json
{
  "overrides": {
    "react": "18.2.0"
  }
}
```

---

### Lock File Corruption

**Error:**
```
npm ERR! code EINTEGRITY
npm ERR! sha512-... integrity checksum failed
```

**Fix:**
```bash
# Delete lock file and node_modules
rm package-lock.json
rm -rf node_modules

# Clean npm cache
npm cache clean --force

# Reinstall
npm install
```

---

### Workspace/Monorepo Issues

**Error:**
```
npm ERR! Cannot find module '@myorg/shared'
```

**Fix:**
```bash
# Rebuild workspace
npm install --workspaces

# Or specific workspace
npm install --workspace=packages/shared
```

---

## Quick Fixes by Package Manager

### npm
```bash
# Clean slate
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# With legacy peer deps
npm install --legacy-peer-deps

# Force resolution
npm install --force
```

### yarn
```bash
# Clean slate
rm -rf node_modules yarn.lock
yarn cache clean
yarn install

# Force resolution
yarn install --force
```

### pnpm
```bash
# Clean slate
rm -rf node_modules pnpm-lock.yaml
pnpm store prune
pnpm install

# Force resolution
pnpm install --force
```

---

## When to Use

✅ Use for: Dependency conflicts, peer dependency errors, lock file issues
❌ Don't use for: Choosing between packages, architectural decisions
