---
name: seo-audit
description: Run technical SEO audits on web applications. Checks meta tags, performance, crawlability, structured data, and Core Web Vitals. Use for client sites or your own projects. Triggers on "SEO audit", "meta tags", "search ranking", "Core Web Vitals", "page speed", "search optimization".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: business
  source: community-contributed
  license: MIT
---

# SEO Audit

Systematic technical SEO audit that checks everything search engines care about.

## Instructions

### Step 1: Meta Tag Audit

Check every page for required meta tags:

```typescript
// Required meta tags for every page
interface SEORequirements {
  title: string          // 50-60 chars, unique per page
  description: string    // 150-160 chars, unique per page
  canonical: string      // Full URL, self-referencing
  ogTitle: string        // Can match title
  ogDescription: string  // Can match description
  ogImage: string        // 1200x630px recommended
  ogType: string         // 'website' | 'article'
  twitterCard: string    // 'summary_large_image'
  viewport: string       // 'width=device-width, initial-scale=1'
  robots: string         // 'index, follow' (or 'noindex' for private pages)
}
```

**Next.js implementation:**
```typescript
// app/layout.tsx or per-page metadata
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: {
    template: '%s | Brand Name',
    default: 'Brand Name — Tagline Under 60 Chars',
  },
  description: 'Compelling description under 160 characters that includes primary keyword.',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    siteName: 'Brand Name',
    images: [{ url: '/og-image.png', width: 1200, height: 630 }],
  },
  twitter: { card: 'summary_large_image' },
  robots: { index: true, follow: true },
}
```

### Step 2: Technical Crawlability

```bash
# Check robots.txt
curl -s https://[SITE]/robots.txt

# Check sitemap
curl -s https://[SITE]/sitemap.xml | head -20

# Check for broken links (if lighthouse/CLI available)
# Or manually check key pages return 200
for url in "/" "/about" "/pricing" "/blog"; do
  status=$(curl -s -o /dev/null -w "%{http_code}" "https://[SITE]${url}")
  echo "${url}: ${status}"
done
```

**Checklist:**
- [ ] `robots.txt` exists and doesn't block important pages
- [ ] `sitemap.xml` exists and lists all public pages
- [ ] No broken links (all pages return 200)
- [ ] Canonical URLs are correct and self-referencing
- [ ] No duplicate content (each page has unique title + description)
- [ ] HTTPS everywhere (no mixed content)

### Step 3: Performance (Core Web Vitals)

| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| LCP (Largest Contentful Paint) | ≤2.5s | 2.5-4s | >4s |
| FID (First Input Delay) | ≤100ms | 100-300ms | >300ms |
| CLS (Cumulative Layout Shift) | ≤0.1 | 0.1-0.25 | >0.25 |
| INP (Interaction to Next Paint) | ≤200ms | 200-500ms | >500ms |

**Quick fixes for common issues:**
```typescript
// Optimize images (Next.js)
import Image from 'next/image'
<Image src="/hero.jpg" alt="Description" width={1200} height={600} priority />

// Lazy load below-fold content
import dynamic from 'next/dynamic'
const HeavyChart = dynamic(() => import('./Chart'), { 
  loading: () => <Skeleton />,
  ssr: false
})

// Preload critical fonts
// In layout.tsx <head>
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />
```

### Step 4: Structured Data

```typescript
// JSON-LD for organization/website
const structuredData = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'Company Name',
  url: 'https://example.com',
  logo: 'https://example.com/logo.png',
  sameAs: [
    'https://twitter.com/handle',
    'https://linkedin.com/company/name',
  ],
}

// Add to page <head>
<script type="application/ld+json">
  {JSON.stringify(structuredData)}
</script>
```

### Step 5: Generate Audit Report

```markdown
## SEO Audit Report — [Site Name]
**Date:** [Date]
**Audited by:** [Agent/Person]

### Score: [X/100]

### Critical Issues (Fix Immediately)
- [ ] [Issue]: [Description + Fix]

### Warnings (Fix This Sprint)
- [ ] [Issue]: [Description + Fix]

### Passed Checks
- [x] HTTPS active
- [x] Sitemap exists
- [x] Robots.txt configured
- [x] [etc.]

### Recommendations
1. [Top priority action]
2. [Second priority]
3. [Third priority]
```

## When to Use This Skill

✅ Use seo-audit when:
- Launching a new site
- Client requests SEO review
- Search rankings dropped
- Before/after site redesign

❌ Don't use for:
- Content strategy (that's editorial, not technical SEO)
- Paid advertising (different domain)
- Social media optimization (different rules)
