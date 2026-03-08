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
