# Product Requirements Document — link-vault

> **This is an EXAMPLE of a completed PRD.md file for the "link-vault" tutorial project.**
> Use this as a reference when filling in your own project's PRD.md.

**Product:** link-vault  
**Version:** 1.0 (MVP)  
**Last Updated:** 2025-02-10  
**Status:** In Development

---

## 1. Background & Context

I have hundreds of bookmarks scattered across browsers, devices, and notes apps. Browser bookmark managers are clunky, don't work across devices well, and have terrible search. Commercial bookmark services (Raindrop, Pocket) are overkill for my needs and require subscriptions.

**Core problem:** I can't quickly save and find links I care about.

---

## 2. Problem Statement

**Who has this problem?** Me (and anyone who saves lots of links).

**What's the problem?**
- Bookmarks get lost across browsers and devices
- Browser bookmark folders are rigid and hard to search
- No easy way to tag or categorize bookmarks
- Search is terrible (only searches titles, not content)
- No way to see link metadata (title, favicon, description) at a glance

**Current workarounds:**
- Browser bookmarks (terrible search, rigid folders)
- Notes apps (no link metadata, hard to organize)
- Reading list apps (too heavyweight, subscription)
- "Save for later" in various apps (scattered, inconsistent)

---

## 3. Product Vision

**In 2-3 sentences:**
link-vault is a fast, personal bookmark manager that runs locally. Save links with tags in 2 clicks, find anything with instant search, see all your links in a beautiful grid with favicons and titles.

**Not trying to be:**
- A team collaboration tool
- A read-it-later service with article extraction
- A web clipper with full-page saves
- A social bookmarking network

**Just trying to be:**
- Fast to save bookmarks
- Fast to find bookmarks
- Nice to look at
- Easy to organize with tags

---

## 4. Target Users

| User Type | Description | Primary Need |
|-----------|-------------|-------------|
| Me (Primary) | Developer who saves 5-10 links per day (docs, articles, tools, reference) | Fast save, instant search, organize by tags |
| Future: Power Users | People who save 20+ links per day and need advanced organization | Collections, bulk actions, keyboard shortcuts |

**For MVP:** Just me. Single-user, local deployment.

---

## 5. User Stories

### Core (MVP)

**As a user, I want to save a link with tags**
- **Acceptance Criteria:**
  - [ ] Can paste URL and hit save
  - [ ] Title and favicon are fetched automatically
  - [ ] Can add multiple tags (comma-separated or autocomplete)
  - [ ] Save completes in <1 second
  - [ ] Bookmark appears immediately in the main view

**As a user, I want to search my bookmarks**
- **Acceptance Criteria:**
  - [ ] Search bar at top of page
  - [ ] Searches title, URL, tags, and description
  - [ ] Results appear as I type (live filtering)
  - [ ] Case-insensitive search
  - [ ] Results are sorted by relevance

**As a user, I want to browse all my bookmarks**
- **Acceptance Criteria:**
  - [ ] Grid layout with card for each bookmark
  - [ ] Each card shows favicon, title, URL, tags
  - [ ] Cards are responsive (mobile, tablet, desktop)
  - [ ] Clicking a bookmark opens it in a new tab

**As a user, I want to edit bookmarks**
- **Acceptance Criteria:**
  - [ ] Can edit title, URL, tags, description
  - [ ] Changes save immediately
  - [ ] Can cancel edits

**As a user, I want to delete bookmarks**
- **Acceptance Criteria:**
  - [ ] Delete button on each card
  - [ ] Confirmation dialog before deletion
  - [ ] Bookmark is removed immediately from view

**As a user, I want to tag bookmarks for organization**
- **Acceptance Criteria:**
  - [ ] Tags are case-insensitive
  - [ ] Tag autocomplete from existing tags
  - [ ] Clicking a tag shows all bookmarks with that tag
  - [ ] Can add multiple tags to one bookmark

### Phase 2 (Post-MVP)

**As a user, I want to organize bookmarks into collections**
- Like folders, but a bookmark can be in multiple collections
- Useful for project-specific or topic-based grouping

**As a user, I want to import existing browser bookmarks**
- Upload HTML bookmarks file from Chrome/Firefox
- Converts folders to tags

**As a user, I want to export my bookmarks**
- Download as JSON (backup)
- Download as HTML (compatible with browsers)

**As a user, I want keyboard shortcuts**
- Cmd+K: Quick search
- Cmd+N: New bookmark
- Esc: Close modals

**As a user, I want to bulk-edit bookmarks**
- Select multiple bookmarks
- Add tags to all selected
- Delete all selected

---

## 6. Feature Roadmap

### Phase 1 — MVP (Current)

| Feature | Priority | Complexity | Notes |
|---------|----------|-----------|-------|
| Save bookmark | P0 | Low | Core feature |
| Display bookmarks grid | P0 | Low | Core feature |
| Search bookmarks | P0 | Medium | Needs good UX |
| Edit bookmark | P0 | Low | Inline editing |
| Delete bookmark | P0 | Low | With confirmation |
| Tag management | P0 | Medium | Autocomplete, filtering |
| Dark mode | P1 | Low | Aesthetic |
| Responsive design | P0 | Medium | Must work on mobile |

### Phase 2 (Future)

| Feature | Priority | Complexity | Notes |
|---------|----------|-----------|-------|
| Collections | P1 | Medium | Like folders but flexible |
| Import bookmarks | P1 | Medium | HTML import from browsers |
| Export bookmarks | P1 | Low | JSON and HTML |
| Keyboard shortcuts | P2 | Low | Power user feature |
| Bulk actions | P2 | Medium | Select multiple bookmarks |
| Link preview | P2 | High | Show page screenshot |

---

## 7. Technical Requirements (High-Level)

**Performance:**
- Search results in <100ms
- Page load in <500ms
- Bookmark save in <1 second

**Scalability:**
- Must handle 10,000+ bookmarks smoothly
- Search must stay fast (database indexes, caching)

**Security:**
- Single-user, local only (no auth needed for MVP)
- No exposure of bookmarks to internet (runs on localhost)
- Sanitize URLs to prevent XSS

**Integrations:**
- None for MVP
- Phase 2: Browser extension for quick saves

**Deployment:**
- Docker Compose (Frontend + Backend + DB)
- Runs on local network (mini PC)
- No cloud deployment needed

---

## 8. Success Metrics

| Metric | Target | How Measured |
|--------|--------|-------------|
| Daily active use | Save 5+ bookmarks per day | Log bookmark creation timestamps |
| Search usage | 10+ searches per day | Log search queries |
| Bookmark retention | 0 bookmarks deleted per week | I only delete mistakes, not useful bookmarks |
| Performance | Search <100ms, save <1s | Measure and log |

**Key success indicator:** I stop using browser bookmarks and notes apps for saving links. 100% of my link-saving happens in link-vault.

---

## 9. Out of Scope

**For MVP, we are NOT building:**
- Multi-user support
- User authentication
- Cloud sync
- Browser extension (save for Phase 2)
- Article extraction (like Pocket)
- Web clipper / full-page save
- Social features (sharing bookmarks)
- Comments or annotations on bookmarks
- Read/unread tracking
- Analytics or link click tracking
- Mobile app (web-only, but responsive)

---

## 10. User Flows

### Flow 1: Save a Bookmark

1. User clicks "Add Bookmark" button
2. Modal opens with URL field focused
3. User pastes URL
4. System fetches title and favicon (auto)
5. User adds tags (optional)
6. User adds description (optional)
7. User clicks "Save"
8. Bookmark appears in grid immediately
9. Modal closes

**Edge cases:**
- Invalid URL → show error, don't close modal
- Favicon fetch fails → use default icon
- No title found → use URL as title
- Duplicate URL → warn user, allow saving anyway

---

### Flow 2: Search for a Bookmark

1. User types in search bar
2. Results filter live (debounced 300ms)
3. Matching bookmarks appear in grid
4. Non-matching bookmarks fade out
5. User clicks a bookmark → opens in new tab
6. User clears search → all bookmarks return

**Edge cases:**
- No results found → show "No matches" empty state
- Search during loading → queue search until loaded

---

### Flow 3: Edit a Bookmark

1. User clicks edit icon on bookmark card
2. Inline form appears (title, URL, tags, description)
3. User makes changes
4. User clicks "Save" → changes persist
5. Or user clicks "Cancel" → reverts changes

**Edge cases:**
- Invalid URL → show error, don't save
- No changes made → treat as cancel

---

### Flow 4: Delete a Bookmark

1. User clicks delete icon on bookmark card
2. Confirmation dialog appears
3. User clicks "Delete" → bookmark removed immediately
4. Or user clicks "Cancel" → bookmark remains

**Edge cases:**
- None (deletion is permanent, can't undo)

---

## 11. Design Notes

**Visual Style:**
- Dark theme (easier on eyes for evening use)
- Clean, minimal interface
- Focus on content (bookmarks), not chrome
- Inspiration: Linear app (clean, fast, dark)

**Layout:**
- Grid layout for bookmark cards (3-4 columns on desktop, 1 column on mobile)
- Card design: Favicon + title + URL snippet + tags
- Search bar always visible at top
- "Add Bookmark" button prominent in top-right

**Interactions:**
- Hover states on cards
- Smooth animations (fade in/out, scale)
- No page refreshes (all actions via API)

---

## 12. Acceptance Criteria for MVP

MVP is "done" when:
- [ ] Can save a bookmark with tags in <3 clicks
- [ ] Can search and find any bookmark in <5 seconds
- [ ] UI works on mobile, tablet, desktop
- [ ] Dark mode looks good
- [ ] Docker setup works (`docker compose up -d` and it just works)
- [ ] No critical bugs (app doesn't crash, data doesn't get lost)
- [ ] I actually use it daily for 1 week straight

---

## 13. Launch Checklist

Before considering MVP "launched":
- [ ] All user stories in Phase 1 completed
- [ ] Tested on Chrome, Firefox, Safari
- [ ] Tested on actual mobile device (not just DevTools)
- [ ] README written with setup instructions
- [ ] Seed data script for demo
- [ ] Backup strategy (Docker volumes, database exports)
- [ ] No known high-priority bugs

---

## 14. Future Considerations

**If I want to expand later:**
- Multi-user support would require major refactoring:
  - Add user accounts and authentication
  - Add `user_id` to bookmarks table
  - Add sharing permissions
  - Add cloud deployment
  
  This is explicitly out of scope for MVP but keeping architecture flexible enough that it's possible.

**Browser extension:**
- Would be a separate codebase
- Communicates with link-vault API
- Quick-save current tab with Cmd+D
  
  Phase 2 feature, don't build yet.

**Mobile app:**
- Could be a React Native app reusing frontend components
- Or just a PWA (Progressive Web App) of the web version
  
  Nice to have, not MVP.
