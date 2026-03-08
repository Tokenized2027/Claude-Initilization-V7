---
name: api-design
description: Design and build production REST APIs with proper error handling, validation, and documentation. Use when creating new API endpoints, reviewing API structure, or standardizing API patterns. Triggers on "API endpoint", "REST API", "API route", "API design", "endpoint structure", "response format".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: development
  source: community-contributed
  license: MIT
---

# API Design

Production-grade REST API patterns with consistent error handling, validation, and response formats.

## Instructions

### Standard Response Envelope

Every API response uses this structure:

```typescript
// Success
{
  "success": true,
  "data": { /* payload */ },
  "meta": {
    "timestamp": "2026-02-15T12:00:00Z",
    "requestId": "req_abc123"
  }
}

// Error
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "issue": "Invalid format" }
    ]
  },
  "meta": {
    "timestamp": "2026-02-15T12:00:00Z",
    "requestId": "req_abc123"
  }
}
```

### Next.js API Route Template

```typescript
// app/api/[resource]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const QuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})

export async function GET(request: NextRequest) {
  const requestId = crypto.randomUUID()
  
  try {
    const params = QuerySchema.parse(
      Object.fromEntries(request.nextUrl.searchParams)
    )
    
    const data = await fetchData(params)
    
    return NextResponse.json({
      success: true,
      data,
      meta: {
        timestamp: new Date().toISOString(),
        requestId,
        page: params.page,
        limit: params.limit,
      },
    })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid query parameters',
          details: error.errors.map(e => ({
            field: e.path.join('.'),
            issue: e.message,
          })),
        },
        meta: { timestamp: new Date().toISOString(), requestId },
      }, { status: 400 })
    }
    
    console.error(`[${requestId}] Unhandled error:`, error)
    return NextResponse.json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
      },
      meta: { timestamp: new Date().toISOString(), requestId },
    }, { status: 500 })
  }
}
```

### Flask/FastAPI Template (Python)

```python
# For Python-based backends
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from datetime import datetime
import uuid

app = FastAPI()

class ApiResponse(BaseModel):
    success: bool
    data: dict | list | None = None
    error: dict | None = None
    meta: dict

@app.get("/api/v1/{resource}")
async def get_resource(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
):
    request_id = str(uuid.uuid4())
    try:
        data = await fetch_data(page=page, limit=limit)
        return ApiResponse(
            success=True,
            data=data,
            meta={"timestamp": datetime.utcnow().isoformat(), "requestId": request_id}
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
```

### HTTP Status Code Guide

| Code | When to Use |
|------|-------------|
| 200 | Success — data returned |
| 201 | Created — new resource made |
| 204 | Success — no content to return (DELETE) |
| 400 | Bad request — validation failed |
| 401 | Unauthorized — no/invalid auth token |
| 403 | Forbidden — valid auth but insufficient permissions |
| 404 | Not found — resource doesn't exist |
| 409 | Conflict — duplicate or state conflict |
| 429 | Rate limited — too many requests |
| 500 | Server error — unexpected failure |

### URL Naming Conventions

```
GET    /api/v1/operators           → List operators
GET    /api/v1/operators/:id       → Get single operator
POST   /api/v1/operators           → Create operator
PUT    /api/v1/operators/:id       → Update operator (full)
PATCH  /api/v1/operators/:id       → Update operator (partial)
DELETE /api/v1/operators/:id       → Delete operator

GET    /api/v1/operators/:id/stakes → Nested resource
GET    /api/v1/metrics/staking     → Action/analytics endpoint
POST   /api/v1/auth/login          → Action endpoint
```

**Rules:**
- Plural nouns for resources (`/operators` not `/operator`)
- Lowercase, kebab-case (`/stake-history` not `/stakeHistory`)
- Version in URL (`/api/v1/`) not headers
- No verbs in URLs (`/operators` not `/getOperators`)

## When to Use This Skill

✅ Use api-design when:
- Creating new API endpoints
- Standardizing API response formats
- The API architect or backend agent needs patterns
- Reviewing API structure for consistency

❌ Don't use api-design for:
- Frontend component work (use react-patterns)
- Database schema design (use backend-developer agent)
- Authentication setup (use auth-middleware-setup skill)
