---
name: next-api-scaffold
description: Creates Next.js API routes with TypeScript, error handling, and validation. Use when user says "create API route", "add endpoint", "new API", mentions /api/ paths, or wants to add a Next.js route handler.
metadata:
  author: Mastering Claude Code
  version: 1.0.0
  category: scaffolding
---

# Next.js API Route Scaffolder

## GET Endpoint Template

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams
    const limit = searchParams.get('limit') || '10'
    
    // TODO: Fetch from database
    const users = []
    
    return NextResponse.json({ success: true, data: users })
  } catch (error) {
    console.error('GET /api/users error:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

## POST Endpoint Template

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const validation = schema.safeParse(body)
    
    if (!validation.success) {
      return NextResponse.json(
        { success: false, errors: validation.error.errors },
        { status: 400 }
      )
    }
    
    // TODO: Save to database
    return NextResponse.json({ success: true, data: validation.data }, { status: 201 })
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Internal server error' }, { status: 500 })
  }
}
```

## Dynamic Route Template

```typescript
// app/api/users/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { id } = params
  // TODO: Fetch user by id
  return NextResponse.json({ success: true, data: { id } })
}
```
