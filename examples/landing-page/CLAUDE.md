# Landing Page — Claude Instructions

> Claude reads this file automatically at the start of every session.

## What this project is

A one page marketing site for `[Your Product Name]`. Static HTML, Tailwind via CDN, no build step, no backend. Goal is to load fast, look clean, and convert visitors to sign up or contact.

## Stack

- Plain HTML and CSS
- Tailwind CSS via the CDN (`<script src="https://cdn.tailwindcss.com"></script>`)
- Vanilla JS only when needed (form submission, smooth scroll)
- Hosted on `[Netlify / Vercel / Cloudflare Pages / GitHub Pages]`

## File layout

```
index.html         single page
assets/
  logo.svg
  hero.jpg
styles.css         only if Tailwind utilities are not enough
```

## Rules for Claude

### Always

- Keep it a single file when you can. A 400 line `index.html` is fine.
- Use semantic HTML (`<header>`, `<main>`, `<section>`, `<footer>`).
- Mobile first. Design the narrow width first, then add `md:` and `lg:` breakpoints.
- Compress images before referencing them. Prefer SVG for logos and icons.
- Add `alt` text to every image.
- Add basic Open Graph tags and a favicon.

### Never

- Add a build step unless explicitly asked.
- Add a framework (React, Next, Vue) unless explicitly asked.
- Add analytics, cookie banners, or tracking without asking first.
- Embed long video autoplay blocks.

## Voice and copy

- Short sentences.
- One idea per section.
- Value first, mechanism second. Lead with what the visitor gets, not how it works.
- The call to action appears above the fold and repeats at the bottom.

## Checklist before shipping

- [ ] Loads in under 2 seconds on a slow phone.
- [ ] Works with JavaScript disabled (nav + read main content).
- [ ] No broken links.
- [ ] Lighthouse score 90+ on Performance and Accessibility.
- [ ] Tested at 360px, 768px, 1280px widths.
