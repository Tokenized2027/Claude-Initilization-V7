# CLAUDE.md — Solo Vibe Coder Edition (Vue/Nuxt)

> This is the consolidated system prompt for solo developers building with Vue 3 / Nuxt 3.
> Copy this file into the root of every new Vue/Nuxt project as `CLAUDE.md`.

---

## Project Info

- **Repo:** [GIT_REPO_URL]
- **Stack:** Nuxt 3 + Vue 3 + TypeScript + Tailwind CSS + Pinia
- **Owner:** [Your name/handle]
- **Purpose:** [One sentence describing what this project does]

## Linked Project Files

- PRD: `./docs/PRD.md`
- Tech Spec: `./docs/TECH_SPEC.md`
- Status: `./STATUS.md`
- Changelog: `./CHANGELOG.md`

---

## Who You're Working With

You are working with a solo developer who builds through AI-assisted "vibe coding." They:
- Have strong conceptual understanding of systems and products
- Rely on you (Claude) to write and debug all code
- Work alone on full-stack projects from idea to deployment
- Need direct, action-oriented guidance with exact commands and complete files

**Communication style:** Brief, conversational, action-first. No preambles. Show results.

---

## CRITICAL RULES — NO EXCEPTIONS

### 1. COMPLETE FILES ONLY
- Never say "the rest stays the same" or give partial code
- Every file you produce must be complete and copy-pasteable
- No truncation, no shortcuts, no "..." placeholders

### 2. NEVER ASSUME FILE STATE
- If you need to modify an existing file, ask to see it first
- Always verify current state before making changes

### 3. COMMANDS FIRST, EXPLANATION LATER
- Lead with exact terminal commands
- Then provide complete code files
- Brief explanation only if needed

### 4. HANDLE ALL EDGE CASES
- Every component handles: loading, error, empty data, edge cases
- Every API endpoint validates input and returns meaningful errors
- Every form has proper validation and error messages

### 5. VERIFY BEFORE WRITING
- Confirm: new file or modifying existing?
- If modifying, ask for current contents first

---

## Code Quality Standards

### Vue/Nuxt Standards
1. **Composition API only.** Use `<script setup lang="ts">` — never Options API.
2. **TypeScript strict.** Type all props, emits, composables, and API responses.
3. **No dead code.** No commented-out blocks, no unused imports.
4. **DRY principle.** Extract shared logic to composables under `composables/`.
5. **Single responsibility.** One component, one purpose. If >200 lines, split.

### Project Structure

```
project-root/
├── app.vue                  # Root layout
├── pages/                   # File-based routing
│   ├── index.vue
│   ├── login.vue
│   └── dashboard/
│       └── index.vue
├── components/              # Reusable UI components
│   ├── ui/                  # Design system (Button, Input, Card)
│   └── features/            # Feature-specific components
├── composables/             # Shared reactive logic
│   ├── useAuth.ts
│   └── useApi.ts
├── server/                  # Nuxt server routes (API)
│   ├── api/
│   │   ├── auth/
│   │   │   └── login.post.ts
│   │   └── users/
│   │       ├── index.get.ts
│   │       └── [id].get.ts
│   └── middleware/
│       └── auth.ts
├── stores/                  # Pinia stores
│   └── auth.ts
├── types/                   # TypeScript interfaces
│   └── index.ts
├── assets/                  # CSS, images
│   └── css/
│       └── main.css
├── public/                  # Static files
├── .env.example
├── .gitignore
├── CLAUDE.md
├── STATUS.md
├── nuxt.config.ts
├── tailwind.config.ts
└── package.json
```

### Component Patterns

```vue
<!-- ✅ GOOD: Composition API with TypeScript, all states handled -->
<script setup lang="ts">
interface Props {
  userId: string
}

interface User {
  id: string
  name: string
  email: string
}

const props = defineProps<Props>()

const { data: user, pending, error } = await useFetch<User>(
  `/api/users/${props.userId}`
)
</script>

<template>
  <!-- Loading -->
  <div v-if="pending" class="animate-pulse h-32 bg-gray-200 rounded-lg dark:bg-gray-700" />

  <!-- Error -->
  <div v-else-if="error" class="p-4 text-red-600 bg-red-50 rounded-lg dark:bg-red-900/20">
    {{ error.message }}
  </div>

  <!-- Empty -->
  <div v-else-if="!user" class="p-4 text-gray-500 text-center">
    User not found.
  </div>

  <!-- Data -->
  <div v-else class="rounded-lg border p-6 dark:border-gray-700">
    <h3 class="text-lg font-semibold dark:text-white">{{ user.name }}</h3>
    <p class="text-sm text-gray-600 dark:text-gray-400">{{ user.email }}</p>
  </div>
</template>
```

### Server API Route

```typescript
// server/api/users/index.get.ts
// ✅ GOOD: Validated, typed, error-handled
export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const page = Number(query.page) || 1
  const limit = Number(query.limit) || 20

  try {
    // Replace with actual data fetching
    const users: User[] = []
    const total = 0

    return {
      success: true,
      data: users,
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) }
    }
  } catch (error) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to fetch users'
    })
  }
})
```

### Composable Pattern

```typescript
// composables/useApi.ts
// ✅ GOOD: Reusable API wrapper with error handling
export function useApi<T>(url: string) {
  const data = ref<T | null>(null)
  const loading = ref(true)
  const error = ref<string | null>(null)

  const fetch = async () => {
    loading.value = true
    error.value = null
    try {
      const result = await $fetch<{ success: boolean; data: T }>(url)
      if (result.success) {
        data.value = result.data
      }
    } catch (err: any) {
      error.value = err.message || 'An error occurred'
    } finally {
      loading.value = false
    }
  }

  return { data, loading, error, fetch }
}
```

### Pinia Store Pattern

```typescript
// stores/auth.ts
import { defineStore } from 'pinia'

interface AuthState {
  user: User | null
  token: string | null
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    token: null,
  }),
  getters: {
    isAuthenticated: (state) => !!state.token,
  },
  actions: {
    async login(email: string, password: string) {
      const res = await $fetch('/api/auth/login', {
        method: 'POST',
        body: { email, password },
      })
      this.token = res.data.token
      this.user = res.data.user
    },
    logout() {
      this.token = null
      this.user = null
      navigateTo('/login')
    },
  },
})
```

---

## Styling

- **Framework:** Tailwind CSS
- **Theme:** Dark mode default using `dark:` prefix
- **Responsive:** Mobile-first (`sm:`, `md:`, `lg:`, `xl:`)
- **No inline styles** — use Tailwind classes
- **No magic numbers** — use design tokens from Tailwind config

---

## Logging

- Server-side: Use `console.log` is acceptable in Nuxt server routes (it goes to server logs)
- Client-side: No `console.log` in production — use `console.warn`/`console.error` only for actual issues

---

## Git Discipline

- Commit after every completed unit of work
- Never commit directly to main — use feature branches
- Commit format: `type(scope): description`
  - `feat(pages): add dashboard page with charts`
  - `fix(auth): handle expired token in middleware`
  - `refactor(composables): extract useApi composable`

---

## Environment Variables

- Never hardcode secrets, URLs, or configuration
- Use `useRuntimeConfig()` for runtime env vars
- Prefix client-side vars with `NUXT_PUBLIC_`
- Every env var documented in `.env.example`
- Never commit `.env` files

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  runtimeConfig: {
    secretKey: process.env.SECRET_KEY,  // server-only
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE,  // client + server
    }
  }
})
```

---

## Self-Correction Protocol

When corrected on something substantive, add the correction below:

| Date | Correction |
|------|-----------|
| | |

---

## Project-Specific Rules

<!-- Add project-specific instructions below -->
