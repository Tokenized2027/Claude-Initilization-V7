# Sprint 3 — Real-time Features

**Sprint Dates:** February 10 - February 21, 2026 (10 working days)
**Sprint Goal:** Enable real-time task updates and notifications for collaborative work

---

## Velocity & Capacity

**Historical Velocity:**
- Sprint 1: 18 points
- Sprint 2: 22 points
- **Average:** 20 points

**Planned Capacity:** 20 points
**Committed Points:** 20 points

---

## Stories

### 1. Real-time task updates with WebSockets ⚡ (8 points) — IN PROGRESS

**Status:** In Progress (Day 3)
**Assignee:** Me
**Priority:** High

**Description:**
Implement WebSocket connection so users see task updates in real-time without refreshing. When one user creates/updates/deletes a task, all connected users see the change immediately.

**Acceptance Criteria:**
- [x] WebSocket server set up (Socket.io)
- [x] Client connects and authenticates via WebSocket
- [ ] Task create events broadcast to all users in project
- [ ] Task update events broadcast
- [ ] Task delete events broadcast
- [ ] Optimistic updates on client
- [ ] Reconnection logic with exponential backoff
- [ ] Works with multiple browser tabs
- [ ] Tests for all event types

**Tasks:**
1. [x] Set up Socket.io server — 2 points (completed)
2. [ ] Create client WebSocket hook — 2 points (in progress)
3. [ ] Implement task event handlers — 2 points
4. [ ] Add optimistic updates — 1 point
5. [ ] Add reconnection logic — 1 point

**Bead Chain:** `docs/BEAD_CHAIN_realtime_tasks.md`

**Notes:**
- WebSocket server complete (Day 2-3)
- CORS configuration was tricky, documented pattern
- Ready to build client-side integration

---

### 2. Task commenting and mentions 💬 (5 points) — COMPLETED ✅

**Status:** Completed (Day 2)
**Assignee:** Me
**Priority:** High

**Description:**
Allow users to comment on tasks and mention other team members using @username syntax. Mentioned users receive notifications.

**Acceptance Criteria:**
- [x] Comment creation API endpoint
- [x] Comment editing/deletion API endpoints
- [x] Comment UI component with rich text
- [x] @mention autocomplete (searches users)
- [x] Mentions stored in database
- [x] Comment count badge on tasks
- [x] Tests for comment CRUD

**Tasks:**
1. [x] Create Comment model — 1 point
2. [x] Build comment API endpoints — 2 points
3. [x] Create comment UI components — 1 point
4. [x] Add mention autocomplete — 1 point

**Commits:**
- j6k2n1i to t6u2x1s (11 commits)

**Notes:**
- Completed ahead of schedule
- Mention autocomplete performance fixed with debouncing
- 95% test coverage

---

### 3. User profile customization 👤 (3 points) — COMPLETED ✅

**Status:** Completed (Day 1)
**Assignee:** Me
**Priority:** Medium

**Description:**
Let users customize their profiles with image, bio, and social links.

**Acceptance Criteria:**
- [x] Profile image upload to S3
- [x] Bio text field (max 500 chars)
- [x] Social links (GitHub, Twitter, LinkedIn)
- [x] Profile settings UI
- [x] Validation for all fields
- [x] Tests for profile updates

**Tasks:**
1. [x] Add profile fields to User model — 0.5 points
2. [x] Implement S3 upload — 1 point
3. [x] Build profile settings UI — 1 point
4. [x] Add validation and tests — 0.5 points

**Commits:**
- a3b9e8z to h0i6l5g (8 commits)

**Notes:**
- S3 CORS issue cost 1 hour, but pattern documented
- Tests passing at 92% coverage
- Feature working great in staging

---

### 4. Email notifications for task assignments 📧 (5 points) — PENDING

**Status:** Pending
**Assignee:** Me
**Priority:** Medium

**Description:**
Send email when a user is assigned to a task or mentioned in a comment.

**Acceptance Criteria:**
- [ ] Email sent on task assignment
- [ ] Email sent on @mention
- [ ] Email template (nice HTML)
- [ ] Email preferences (opt-in/opt-out)
- [ ] Rate limiting (max 10 emails/hour per user)
- [ ] Tests for email triggers

**Tasks:**
1. [ ] Set up email service (SendGrid) — 1 point
2. [ ] Create email templates — 1 point
3. [ ] Add email triggers — 1 point
4. [ ] Build email preferences UI — 1 point
5. [ ] Add rate limiting — 1 point

**Bead Chain:** Not yet decomposed

**Notes:**
- Depends on real-time updates completion
- Will start on Day 6-7

---

## Sprint Backlog (Daily Task Board)

### Day 0 (Feb 10) — Planning ✅
- [x] Sprint planning (2 hours)
- [x] Calculate velocity
- [x] Select stories
- [x] Create task breakdown
- [x] Decompose into beads

### Day 1 (Feb 11) — Profile Feature ✅
- [x] Complete user profile customization
- [x] 8 commits
- [x] Story completed: 3 points

### Day 2 (Feb 12) — Comments Feature ✅
- [x] Complete task commenting
- [x] 11 commits
- [x] Story completed: 5 points

### Day 3 (Feb 13) — WebSocket Server ✅
- [x] Set up Socket.io server
- [x] WebSocket authentication
- [x] 9 commits
- [x] Task completed: 2 points

### Day 4 (Feb 14) — WebSocket Client 🔄
- [ ] Create useWebSocket hook
- [ ] Test connection in multiple tabs
- [ ] Target: 2 points, 8 commits

### Day 5 (Feb 15) — Task Events
- [ ] Implement task event handlers
- [ ] Add event broadcasting
- [ ] Target: 2 points, 8 commits

### Day 6 (Feb 16) — Optimistic Updates
- [ ] Add optimistic UI updates
- [ ] Add reconnection logic
- [ ] Target: 2 points, 8 commits
- [ ] Complete WebSocket story

### Day 7 (Feb 17) — Email Setup
- [ ] Set up SendGrid
- [ ] Create email templates
- [ ] Target: 2 points, 8 commits

### Day 8 (Feb 18) — Email Triggers
- [ ] Add email on task assignment
- [ ] Add email on @mention
- [ ] Target: 2 points, 8 commits

### Day 9 (Feb 19) — Email Preferences
- [ ] Build preferences UI
- [ ] Add rate limiting
- [ ] Target: 1 point, 6 commits
- [ ] Complete email story

### Day 10 (Feb 20) — Sprint End
- [ ] Sprint review (1 hour)
- [ ] Retrospective (1 hour)
- [ ] Update memory
- [ ] Plan Sprint 4

---

## Burndown Chart

**Target:** 20 points → 0 points over 10 days
**Ideal burn rate:** 2 points/day

```
Points Remaining:
  Day 0:  20 points (planning day)
  Day 1:  17 points (completed profile: 3 points) ✓
  Day 2:  12 points (completed comments: 5 points) ✓
  Day 3:  12 points (server setup: 0 story points, but progress on WebSocket)
  Day 4:  10 points (expected)
  Day 5:   8 points (expected)
  Day 6:   4 points (expected, WebSocket complete)
  Day 7:   4 points (email setup)
  Day 8:   2 points (email triggers)
  Day 9:   0 points (email complete) 🎯
  Day 10:  0 points (review + retro)
```

**Status:** Ahead of schedule after Day 3 (12 points remaining vs 14 expected)

---

## Risks & Mitigation

### 1. WebSocket deployment complexity on Vercel
**Risk:** Serverless functions may not support long-lived WebSocket connections
**Impact:** High — Core feature blocked
**Mitigation:**
- Researching Socket.io + Vercel compatibility (Day 3)
- Backup plan: Deploy Socket.io server separately to Railway
- Time buffer: 0.5 days allocated

**Status:** Researching. May need separate WebSocket server deployment.

### 2. Email deliverability issues
**Risk:** Emails marked as spam, bounce rates
**Impact:** Medium — Feature works but user experience degraded
**Mitigation:**
- Use SendGrid (established reputation)
- Set up SPF, DKIM, DMARC records
- Test with multiple email providers
- Time buffer: 0.25 days allocated

**Status:** Not yet started

---

## Dependencies

### External Dependencies
- **Socket.io:** Already added (v4.6.1)
- **SendGrid SDK:** To be added (~50 KB)
- **AWS SDK (S3):** Already added for profile images

### Internal Dependencies
- Real-time updates depends on: WebSocket server complete ✅
- Email notifications depends on: Real-time updates complete (for consistency)

---

## Testing Plan

### Real-time Updates
- Unit tests: WebSocket server event handlers
- Integration tests: Full connection → event → broadcast flow
- E2E tests: Multi-tab scenario, reconnection

### Comments
- Unit tests: Comment CRUD operations ✅
- Integration tests: @mention parsing and storage ✅
- E2E tests: Create/edit/delete comments ✅

### Email
- Unit tests: Email template rendering
- Integration tests: Email triggers (mocked SendGrid)
- Manual testing: Real email delivery to Gmail, Outlook, Yahoo

**Coverage Target:** 85% overall (currently 76%)

---

## Definition of Done

A story is done when:
- [x] All acceptance criteria met
- [x] Code reviewed (self-review for solo)
- [x] Tests written and passing (>80% coverage)
- [x] Deployed to staging and verified
- [x] No known critical bugs
- [x] Documentation updated (if API changes)
- [x] Performance acceptable (page load <2s, API <200ms)

---

## Metrics

### Code Metrics (as of Day 3)
- **Total commits this sprint:** 28
- **Commits per day avg:** 9.3
- **Lines added:** +2,347
- **Lines deleted:** -438
- **Net change:** +1,909 LOC

### Quality Metrics
- **Test coverage:** 76% → 82% (target 85%)
- **Build time:** 42s (acceptable)
- **Lighthouse score:** 91 (good)

### Team Health (Solo Dev)
- **Energy level:** 8/10 (high)
- **Sprint progress satisfaction:** 9/10 (ahead of schedule)
- **Technical debt concerns:** Low (paying down as we go)
- **Blockers:** 1 (WebSocket deployment research)

---

## Daily Standup Notes

### Day 3 (Feb 13)
**Yesterday:** Completed commenting feature with mentions
**Today:** Set up WebSocket server, authentication middleware
**Blockers:** Researching Vercel serverless + WebSocket compatibility
**Notes:** 9 commits. Server setup complete. CORS was tricky but resolved.

### Day 2 (Feb 12)
**Yesterday:** Completed user profile customization
**Today:** Built commenting feature with @mentions
**Blockers:** None
**Notes:** 11 commits. Mention autocomplete performance fixed. Great progress.

### Day 1 (Feb 11)
**Yesterday:** Sprint planning
**Today:** Implemented profile customization (images, bio, social links)
**Blockers:** S3 CORS (resolved)
**Notes:** 8 commits. First story complete. Off to strong start!

---

## Sprint Review Preparation

**Demo Plan (Day 10):**
1. Show user profile customization
2. Demo task commenting with @mentions
3. Demo real-time task updates (multi-tab)
4. Show email notifications (if complete)
5. Discuss metrics and velocity

**Acceptance:**
- All completed stories meet acceptance criteria
- Staging environment stable
- No critical bugs

---

## Retrospective Prompts

**For Sprint 3 retrospective (Day 10):**

**What went well:**
- What helped us succeed this sprint?
- What should we continue doing?

**What went poorly:**
- What blocked or slowed us down?
- What should we stop doing?

**Action items:**
- Concrete improvements for Sprint 4
- Assignee and deadline for each

**Metrics:**
- Velocity: X points (target: 20)
- Commit frequency: X commits/day (target: 8-12)
- Test coverage: X% (target: 85%)

---

## Notes & Learnings

### Technical Learnings
- Socket.io requires custom Next.js server (breaks some features)
- S3 CORS must be configured for browser uploads
- Mention autocomplete needs debouncing for performance

### Process Learnings
- Bead method working excellently (9-11 commits/day)
- Memory system saving ~10 min/session
- Ahead of schedule through Day 3

### Patterns to Document
- WebSocket server setup with Next.js
- S3 direct upload from browser
- Mention autocomplete optimization

---

**Sprint created:** February 10, 2026
**Last updated:** February 13, 2026 (Day 3)
**Next update:** Daily during sprint execution
