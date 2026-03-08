
# React Component Scaffolder

## Component Template

```typescript
// components/Button.tsx
import { ButtonHTMLAttributes } from 'react'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
}

export function Button({ 
  variant = 'primary', 
  size = 'md', 
  children,
  className = '',
  ...props 
}: ButtonProps) {
  const baseStyles = 'rounded font-medium transition-colors'
  const variantStyles = {
    primary: 'bg-blue-600 hover:bg-blue-700 text-white',
    secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-900',
    danger: 'bg-red-600 hover:bg-red-700 text-white',
  }
  const sizeStyles = {
    sm: 'px-3 py-1 text-sm',
    md: 'px-4 py-2',
    lg: 'px-6 py-3 text-lg',
  }
  
  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}
```

## Usage Example

```typescript
import { Button } from '@/components/Button'

export default function Page() {
  return (
    <div>
      <Button variant="primary" size="md" onClick={() => alert('Clicked!')}>
        Click Me
      </Button>
    </div>
  )
}
```
