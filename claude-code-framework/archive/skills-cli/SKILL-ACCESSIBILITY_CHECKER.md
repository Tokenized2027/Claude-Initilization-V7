
# Accessibility Checker

## Quick Checks

### Semantic HTML

```tsx
// ❌ Bad - non-semantic
<div onClick={handleClick}>Click me</div>

// ✅ Good - semantic
<button onClick={handleClick}>Click me</button>
```

### Alt Text

```tsx
// ❌ Bad - missing alt
<img src="logo.png" />

// ✅ Good - descriptive alt
<img src="logo.png" alt="Company logo" />
```

### ARIA Labels

```tsx
// ❌ Bad - no label
<button><SearchIcon /></button>

// ✅ Good - aria-label
<button aria-label="Search"><SearchIcon /></button>
```

### Keyboard Navigation

```tsx
// ✅ Good - keyboard accessible
<button onKeyDown={(e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    handleClick()
  }
}}>
  Submit
</button>
```

## Automated Checks

```bash
# Install axe-core
npm install --save-dev @axe-core/react

# Add to tests
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

test('should have no a11y violations', async () => {
  const { container } = render(<App />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```
