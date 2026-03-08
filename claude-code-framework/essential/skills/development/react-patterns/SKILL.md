---
name: react-patterns
description: Production-grade React/Next.js patterns for dashboards, data visualization, and component architecture. Use when building UI components, dashboards, or refactoring React code. Triggers on "React component", "dashboard", "Next.js page", "component pattern", "state management", "data fetching".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: development
  source: community-contributed
  license: MIT
---

# React Patterns

Battle-tested React/Next.js patterns for building production dashboards, analytics UIs, and reusable component libraries.

## Instructions

### Pattern 1: Data Dashboard Component

The standard pattern for analytics dashboards:

```typescript
// components/dashboard/MetricCard.tsx
'use client'

import { useQuery } from '@tanstack/react-query'

interface MetricCardProps {
  title: string
  endpoint: string
  formatter?: (value: number) => string
  refreshInterval?: number
}

export function MetricCard({ 
  title, 
  endpoint, 
  formatter = (v) => v.toLocaleString(),
  refreshInterval = 30000 
}: MetricCardProps) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['metric', endpoint],
    queryFn: async () => {
      const res = await fetch(endpoint)
      if (!res.ok) throw new Error(`${res.status}: ${res.statusText}`)
      return res.json()
    },
    refetchInterval: refreshInterval,
  })

  if (isLoading) return <MetricCardSkeleton title={title} />
  if (error) return <MetricCardError title={title} error={error} />
  if (!data) return <MetricCardEmpty title={title} />

  return (
    <div className="rounded-lg border bg-card p-6">
      <p className="text-sm text-muted-foreground">{title}</p>
      <p className="text-2xl font-bold">{formatter(data.value)}</p>
      {data.change !== undefined && (
        <p className={data.change >= 0 ? 'text-green-600' : 'text-red-600'}>
          {data.change >= 0 ? '↑' : '↓'} {Math.abs(data.change)}%
        </p>
      )}
    </div>
  )
}
```

**Rules:**
- Always handle loading, error, and empty states — no exceptions
- Use TanStack Query for all server state (never raw useEffect + fetch)
- Skeletons match the shape of the loaded content
- Error states show what failed and offer retry

### Pattern 2: Server Component with Client Island

```typescript
// app/dashboard/page.tsx (Server Component — no 'use client')
import { MetricCard } from '@/components/dashboard/MetricCard'
import { ChartSection } from '@/components/dashboard/ChartSection'

export default async function DashboardPage() {
  // Server-side data fetch (no client bundle cost)
  const stats = await fetch('https://api.example.com/stats', {
    next: { revalidate: 60 }
  }).then(r => r.json())

  return (
    <main className="container mx-auto p-6 space-y-8">
      <h1 className="text-3xl font-bold">Protocol Dashboard</h1>
      
      {/* Static data rendered on server */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <MetricCard title="Total Staked" endpoint="/api/metrics/staked" />
        <MetricCard title="APY" endpoint="/api/metrics/apy" formatter={(v) => `${v.toFixed(2)}%`} />
        <MetricCard title="Operators" endpoint="/api/metrics/operators" />
      </div>
      
      {/* Interactive chart is a Client Component */}
      <ChartSection initialData={stats.history} />
    </main>
  )
}
```

**Rules:**
- Default to Server Components — add 'use client' only when needed
- Pass server-fetched data as props to client components
- Use `revalidate` for ISR instead of client-side polling for stable data

### Pattern 3: Recharts Data Visualization

```typescript
// components/dashboard/ChartSection.tsx
'use client'

import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts'

interface ChartData {
  date: string
  value: number
}

export function ChartSection({ initialData }: { initialData: ChartData[] }) {
  return (
    <div className="rounded-lg border bg-card p-6">
      <h2 className="text-lg font-semibold mb-4">Historical Performance</h2>
      <div className="h-[300px]">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={initialData}>
            <XAxis 
              dataKey="date" 
              tick={{ fontSize: 12 }}
              tickFormatter={(d) => new Date(d).toLocaleDateString('en', { month: 'short', day: 'numeric' })}
            />
            <YAxis tick={{ fontSize: 12 }} />
            <Tooltip 
              contentStyle={{ backgroundColor: 'hsl(var(--card))', border: '1px solid hsl(var(--border))' }}
            />
            <Line 
              type="monotone" 
              dataKey="value" 
              stroke="hsl(var(--primary))" 
              strokeWidth={2}
              dot={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}
```

### Pattern 4: Form with Validation (Zod + React Hook Form)

```typescript
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  address: z.string().regex(/^0x[a-fA-F0-9]{40}$/, 'Invalid Ethereum address'),
  amount: z.number().positive('Must be positive').max(1000000),
})

type FormData = z.infer<typeof schema>

export function StakeForm({ onSubmit }: { onSubmit: (data: FormData) => Promise<void> }) {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label className="text-sm font-medium">Wallet Address</label>
        <input {...register('address')} className="w-full rounded border p-2" />
        {errors.address && <p className="text-sm text-red-600">{errors.address.message}</p>}
      </div>
      <div>
        <label className="text-sm font-medium">Amount</label>
        <input {...register('amount', { valueAsNumber: true })} type="number" className="w-full rounded border p-2" />
        {errors.amount && <p className="text-sm text-red-600">{errors.amount.message}</p>}
      </div>
      <button type="submit" disabled={isSubmitting} className="rounded bg-primary px-4 py-2 text-white disabled:opacity-50">
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  )
}
```

## File Naming Convention

```
components/
├── ui/                    # Reusable primitives (Button, Input, Card)
├── dashboard/             # Dashboard-specific components
├── charts/                # Data visualization components
└── forms/                 # Form components with validation
```

- One component per file
- File name matches export name: `MetricCard.tsx` → `export function MetricCard`
- Colocate types with components (no separate types/ directory for component props)

## Anti-Patterns to Avoid

| Anti-Pattern | Do This Instead |
|-------------|-----------------|
| `useEffect` + `fetch` for data | TanStack Query |
| `any` type | Define interface for every prop/response |
| Inline styles | Tailwind utility classes |
| `'use client'` on every file | Server Components by default |
| Prop drilling 3+ levels | Context or composition pattern |
| Giant component (>200 lines) | Extract sub-components |

## When to Use This Skill

✅ Use react-patterns when:
- Building dashboard components
- Creating data visualization UIs
- Refactoring existing React code
- Setting up a new Next.js page
- The frontend-developer agent needs reference patterns

❌ Don't use react-patterns for:
- API design (use api-design)
- Backend logic (use backend-developer agent)
- Initial project architecture (use brainstorming first)
