---
name: typescript-hardening
description: Enforce strict TypeScript patterns that prevent runtime errors. Use when reviewing code for type safety, eliminating 'any' types, or setting up tsconfig for new projects. Triggers on "any type", "type error", "TypeScript strict", "type safety", "runtime error from types".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: development
  source: community-contributed
  license: MIT
---

# TypeScript Hardening

Eliminate runtime type errors by enforcing strict TypeScript patterns across your codebase.

## Instructions

### Step 1: Enforce Strict tsconfig

Every project must use this baseline:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "exactOptionalPropertyTypes": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### Step 2: API Response Typing with Zod

Never trust external data. Validate at the boundary:

```typescript
import { z } from 'zod'

// Define the schema
const ApiResponseSchema = z.object({
  data: z.object({
    price: z.number(),
    volume: z.number(),
    timestamp: z.string().datetime(),
  }),
  status: z.enum(['ok', 'error']),
})

type ApiResponse = z.infer<typeof ApiResponseSchema>

// Validate at the boundary
async function fetchPrice(endpoint: string): Promise<ApiResponse['data']> {
  const raw = await fetch(endpoint).then(r => r.json())
  const parsed = ApiResponseSchema.parse(raw) // Throws if invalid
  return parsed.data
}
```

### Step 3: Discriminated Unions for State

Replace boolean flags with discriminated unions:

```typescript
// ❌ Bad: Multiple booleans create impossible states
interface BadState {
  isLoading: boolean
  isError: boolean
  data: Data | null
  error: Error | null
}

// ✅ Good: Each state is explicit and complete
type QueryState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: Data }

// Usage forces handling every case
function render(state: QueryState) {
  switch (state.status) {
    case 'idle': return <Placeholder />
    case 'loading': return <Skeleton />
    case 'error': return <ErrorDisplay error={state.error} />
    case 'success': return <DataView data={state.data} />
  }
}
```

### Step 4: Utility Types for Common Patterns

```typescript
// Make specific fields required from a partial type
type RequireFields<T, K extends keyof T> = T & Required<Pick<T, K>>

// Extract the resolved type of a Promise
type Awaited<T> = T extends Promise<infer U> ? U : T

// Safe record access
function getProperty<T extends Record<string, unknown>>(obj: T, key: string): unknown {
  return obj[key] // noUncheckedIndexedAccess makes this `unknown`, not `T[string]`
}
```

### Step 5: Never Use These

| Banned Pattern | Replacement |
|---------------|-------------|
| `any` | `unknown` + type guard or Zod validation |
| `as TypeName` | Type guard function or Zod parse |
| `!` (non-null assertion) | Optional chaining + nullish coalescing |
| `@ts-ignore` | Fix the actual type error |
| `Object` | `Record<string, unknown>` |
| `Function` | Specific function signature |

### Quick Audit Command

Find all violations in a codebase:

```bash
# Count 'any' types
grep -rn ': any' --include='*.ts' --include='*.tsx' src/ | wc -l

# Find ts-ignore comments
grep -rn '@ts-ignore\|@ts-expect-error' --include='*.ts' --include='*.tsx' src/

# Find non-null assertions
grep -rn '!\.' --include='*.ts' --include='*.tsx' src/ | grep -v 'node_modules'

# Find type assertions
grep -rn ' as ' --include='*.ts' --include='*.tsx' src/ | grep -v 'import'
```

## When to Use This Skill

✅ Use typescript-hardening when:
- Setting up a new TypeScript project
- Reviewing code before merge
- Eliminating runtime type errors
- Onboarding agents to a codebase (set the standard early)

❌ Don't use for:
- Quick prototypes (use brainstorming first)
- Non-TypeScript projects
- Config files (JSON/YAML)
