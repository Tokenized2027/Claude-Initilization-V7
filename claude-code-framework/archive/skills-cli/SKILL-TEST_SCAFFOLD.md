
# Test Scaffolder

## React Component Test

```typescript
// components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })
  
  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    fireEvent.click(screen.getByText('Click me'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
  
  it('applies variant styles', () => {
    const { container } = render(<Button variant="danger">Delete</Button>)
    expect(container.firstChild).toHaveClass('bg-red-600')
  })
})
```

## API Route Test

```typescript
// app/api/users/route.test.ts
import { GET, POST } from './route'
import { NextRequest } from 'next/server'

describe('/api/users', () => {
  describe('GET', () => {
    it('returns users list', async () => {
      const request = new NextRequest('http://localhost:3000/api/users')
      const response = await GET(request)
      const data = await response.json()
      
      expect(response.status).toBe(200)
      expect(data.success).toBe(true)
      expect(Array.isArray(data.data)).toBe(true)
    })
  })
  
  describe('POST', () => {
    it('creates user with valid data', async () => {
      const request = new NextRequest('http://localhost:3000/api/users', {
        method: 'POST',
        body: JSON.stringify({ name: 'Alice', email: 'alice@example.com' })
      })
      
      const response = await POST(request)
      const data = await response.json()
      
      expect(response.status).toBe(201)
      expect(data.success).toBe(true)
    })
  })
})
```
