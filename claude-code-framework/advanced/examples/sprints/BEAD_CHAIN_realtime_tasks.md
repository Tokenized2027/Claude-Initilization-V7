# Bead Chain: Real-time Task Updates with WebSockets

**Story:** Real-time task updates with WebSockets (8 points)
**Feature:** Enable real-time synchronization of task changes across all connected clients
**Created:** 2026-02-10
**Status:** In Progress (9/18 beads complete)

---

## Summary

**Total Beads:** 18
**Total Estimated Time:** ~7.5 hours (450 minutes)
**Beads Completed:** 9 (240 minutes actual)
**Beads Remaining:** 9 (210 minutes estimated)

**Progress:** 50% complete

---

## Bead List

### Phase 1: WebSocket Server Setup (Complete ✅)

#### Bead 1: Socket.io server configuration (30 min) ✅
**Status:** Completed (2026-02-12, 09:15-09:40)
**Actual Time:** 25 minutes
**Commit:** a7f3d2e

**Task:**
- Install Socket.io dependencies (`socket.io`, `socket.io-client`)
- Create custom Next.js server for Socket.io
- Basic server setup (port, initialization)
- Test server starts without errors

**Acceptance:**
- `npm run dev` starts server on port 3000
- Socket.io server listening
- No errors in console
- Basic health check works

**Notes:**
- Used Next.js custom server approach
- Server configuration in `server.js`
- Faster than expected (25 min vs 30 min)

---

#### Bead 2: WebSocket authentication middleware (30 min) ✅
**Status:** Completed (2026-02-12, 10:00-10:30)
**Actual Time:** 30 minutes
**Commit:** b8e4f3a

**Task:**
- Create Socket.io middleware to verify JWT
- Extract user ID from token
- Reject connections with invalid tokens
- Set user data in socket context

**Acceptance:**
- Connections without valid JWT are rejected
- Valid JWT allows connection
- `socket.data.userId` populated
- Error messages clear for debugging

**Notes:**
- Reused existing JWT verification logic from HTTP auth
- Middleware pattern clean and testable
- On time

---

#### Bead 3: Connection event handlers (25 min) ✅
**Status:** Completed (2026-02-12, 10:45-11:10)
**Actual Time:** 25 minutes
**Commit:** c9d5g4b

**Task:**
- Handle `connection` event
- Handle `disconnect` event
- Log connection/disconnection
- Store active connections in memory

**Acceptance:**
- Server logs when client connects
- Server logs when client disconnects
- Connection count accurate
- No memory leaks on disconnect

**Notes:**
- Simple Map for connection storage (works for single server)
- Will need Redis for multi-server scaling (future)
- Faster than expected

---

#### Bead 4: Room management for projects (35 min) ✅
**Status:** Completed (2026-02-12, 11:20-11:55)
**Actual Time:** 35 minutes
**Commit:** d0e6h5c

**Task:**
- Join client to project-specific rooms
- Leave rooms on disconnect
- Verify user has access to project
- Room naming convention (`project:{projectId}`)

**Acceptance:**
- Client joins correct project room
- Client cannot join unauthorized projects
- Disconnection removes from all rooms
- Room list accurate

**Notes:**
- Used `socket.join()` for rooms
- Verified project access via Prisma query
- Took longer due to access verification logic

---

#### Bead 5: CORS configuration (20 min) ✅
**Status:** Completed (2026-02-12, 13:00-13:20)
**Actual Time:** 20 minutes
**Commit:** f2g8j7e

**Task:**
- Configure Socket.io CORS for frontend
- Allow localhost in development
- Restrict to production domain in production
- Test CORS from frontend

**Acceptance:**
- Frontend can connect in development
- Production CORS restrictive
- No CORS errors in console
- Credentials allowed

**Notes:**
- CORS config in server initialization
- Environment-based allowed origins
- On time

---

#### Bead 6: Basic event structure (task update stub) (20 min) ✅
**Status:** Completed (2026-02-12, 13:30-13:50)
**Actual Time:** 20 minutes
**Commit:** g3h9k8f

**Task:**
- Create stub for `task:update` event handler
- Define event payload structure
- Broadcast to room (no actual logic yet)
- Test event is received by clients in room

**Acceptance:**
- Event handler registered
- Payload structure documented
- Broadcast works (verified with Socket.io admin UI)
- Clients in different rooms don't receive event

**Notes:**
- Payload: `{ taskId, updatedFields, userId }`
- Clean separation of concerns
- On time

---

#### Bead 7: WebSocket server tests (40 min) ✅
**Status:** Completed (2026-02-12, 14:00-14:40)
**Actual Time:** 40 minutes
**Commit:** e1f7i6d

**Task:**
- Test connection with valid JWT
- Test connection rejection with invalid JWT
- Test room joining
- Test event broadcasting

**Acceptance:**
- 100% coverage on connection logic
- All tests pass
- Tests run fast (<5s)
- Clear test descriptions

**Notes:**
- Used `socket.io-client` for test client
- Mocked Prisma for project access checks
- Took longer than estimated (good tests worth it)

---

#### Bead 8: Server error handling (25 min) ✅
**Status:** Completed (2026-02-12, 15:00-15:25)
**Actual Time:** 25 minutes
**Commit:** h4i0l9g

**Task:**
- Wrap event handlers in try-catch
- Log errors with context
- Emit error events to client
- Prevent server crash on bad input

**Acceptance:**
- Invalid payloads don't crash server
- Errors logged with stack trace
- Client receives error event
- Connection stays alive after error

**Notes:**
- Standard error handling pattern
- Client error events have codes
- On time

---

#### Bead 9: Server documentation (15 min) ✅
**Status:** Completed (2026-02-12, 15:30-15:45)
**Actual Time:** 15 minutes
**Commit:** i5j1m0h

**Task:**
- Document server architecture in README
- Document event payload structures
- Document room naming convention
- Add inline code comments where needed

**Acceptance:**
- README section on WebSocket server
- Event payloads documented
- Comments on non-obvious code
- Easy for future me to understand

**Notes:**
- Created `docs/WEBSOCKET_ARCHITECTURE.md`
- Clear event schema definitions
- On time

---

### Phase 2: Client-Side WebSocket Hook (Not Started)

#### Bead 10: useWebSocket hook structure (30 min) ⏳
**Status:** Pending
**Estimated:** 30 minutes

**Task:**
- Create `hooks/useWebSocket.ts`
- Set up Socket.io client connection
- Handle connection state (connecting, connected, disconnected)
- Return connection status to component

**Acceptance:**
- Hook can be called from any component
- Connection state tracked in hook
- Connects to server on mount
- Disconnects on unmount
- No memory leaks

**Notes:**
- Will use React context for connection sharing
- One connection per app, not per component

---

#### Bead 11: Authentication in client connection (20 min) ⏳
**Status:** Pending
**Estimated:** 20 minutes

**Task:**
- Send JWT in connection handshake
- Retrieve JWT from httpOnly cookie
- Handle authentication errors
- Retry connection if auth fails (with limit)

**Acceptance:**
- JWT sent correctly
- Server accepts connection with valid token
- Connection rejected with invalid token
- Error messages clear
- Max 3 retry attempts

---

#### Bead 12: Reconnection logic with exponential backoff (35 min) ⏳
**Status:** Pending
**Estimated:** 35 minutes

**Task:**
- Implement exponential backoff for reconnection
- Backoff formula: `Math.min(1000 * 2^attempt, 30000)` ms
- Max 10 reconnection attempts
- Reset backoff on successful connection
- Show reconnection state in UI

**Acceptance:**
- First retry: 1s delay
- Second retry: 2s delay
- Third retry: 4s delay
- Max delay: 30s
- Gives up after 10 attempts
- UI shows "Reconnecting..." status

---

#### Bead 13: Event subscription API (25 min) ⏳
**Status:** Pending
**Estimated:** 25 minutes

**Task:**
- Create `subscribe(eventName, callback)` method
- Create `unsubscribe(eventName, callback)` method
- Clean up subscriptions on unmount
- Type-safe event names

**Acceptance:**
- Can subscribe to events from hook
- Callbacks invoked when event received
- Unsubscribe works correctly
- No duplicate subscriptions
- TypeScript autocomplete for event names

---

#### Bead 14: Client-side hook tests (35 min) ⏳
**Status:** Pending
**Estimated:** 35 minutes

**Task:**
- Test hook connection lifecycle
- Test event subscription
- Test reconnection logic
- Mock Socket.io client

**Acceptance:**
- 100% coverage on hook
- All tests pass
- Tests run fast
- Clear test descriptions

---

### Phase 3: Task Event Implementation (Not Started)

#### Bead 15: Task create event (30 min) ⏳
**Status:** Pending
**Estimated:** 30 minutes

**Task:**
- Emit `task:create` event from task creation endpoint
- Include full task data in payload
- Broadcast to project room
- Update UI optimistically on client

**Acceptance:**
- Event emitted on task creation
- All clients in project receive event
- New task appears in UI immediately
- Optimistic update works correctly

---

#### Bead 16: Task update event (30 min) ⏳
**Status:** Pending
**Estimated:** 30 minutes

**Task:**
- Emit `task:update` event from task update endpoint
- Include updated fields in payload
- Broadcast to project room
- Update UI optimistically on client

**Acceptance:**
- Event emitted on task update
- All clients see update immediately
- Only changed fields sent
- Optimistic update works correctly

---

#### Bead 17: Task delete event (25 min) ⏳
**Status:** Pending
**Estimated:** 25 minutes

**Task:**
- Emit `task:delete` event from task delete endpoint
- Include task ID in payload
- Broadcast to project room
- Remove from UI optimistically on client

**Acceptance:**
- Event emitted on task deletion
- Task removed from all clients immediately
- Optimistic update works correctly
- No errors if task already removed

---

#### Bead 18: Integration tests (E2E multi-tab) (45 min) ⏳
**Status:** Pending
**Estimated:** 45 minutes

**Task:**
- Playwright test: Open two browser tabs
- Create task in tab 1
- Verify task appears in tab 2 immediately
- Update task in tab 2
- Verify update in tab 1
- Delete in tab 1, verify removal in tab 2

**Acceptance:**
- All E2E scenarios pass
- Tests are stable (no flakiness)
- Tests run in <30s
- Clear test output

---

## Velocity Tracking

### Phase 1: WebSocket Server Setup (Complete)
| Bead | Estimated | Actual | Variance |
|------|-----------|--------|----------|
| 1    | 30 min    | 25 min | -5 min ✅ |
| 2    | 30 min    | 30 min | 0 min ✅ |
| 3    | 25 min    | 25 min | 0 min ✅ |
| 4    | 35 min    | 35 min | 0 min ✅ |
| 5    | 20 min    | 20 min | 0 min ✅ |
| 6    | 20 min    | 20 min | 0 min ✅ |
| 7    | 40 min    | 40 min | 0 min ✅ |
| 8    | 25 min    | 25 min | 0 min ✅ |
| 9    | 15 min    | 15 min | 0 min ✅ |
| **Total** | **240 min** | **235 min** | **-5 min** |

**Accuracy:** 98% (very good estimation)

### Phase 2: Client-Side Hook (Not Started)
**Estimated:** 145 minutes (5 beads)

### Phase 3: Task Events (Not Started)
**Estimated:** 130 minutes (4 beads)

### Overall
**Total Estimated:** 515 minutes (~8.5 hours)
**Total Actual (so far):** 235 minutes
**Remaining:** 280 minutes (~4.5 hours)

---

## Lessons Learned

### What Worked Well
- Bead decomposition accurate (98% estimation accuracy so far)
- Each bead resulted in working, testable code
- Clear acceptance criteria made it easy to know when done
- Committing after each bead created great git history

### Challenges
- CORS configuration took trial and error (but only 20 min)
- Tests took longer than estimated (40 min vs 30 min) but worth it
- Custom Next.js server required research (not counted in beads)

### Improvements for Next Bead Chain
- Add 10% buffer to test beads (always take longer)
- Research/learning beads separate from implementation beads
- Consider splitting beads >40 min into smaller beads

---

## Dependencies

**External:**
- `socket.io` (v4.6.1)
- `socket.io-client` (v4.6.1)

**Internal:**
- JWT authentication system (existing)
- Prisma client (existing)
- Task API endpoints (existing)

**Blockers:**
- None currently

---

## Testing Coverage

**Server-Side:**
- Connection lifecycle: 100% ✅
- Authentication: 100% ✅
- Room management: 100% ✅
- Event handlers: Stubs only (will test in Phase 3)

**Client-Side:**
- Not yet started

**E2E:**
- Not yet started

**Target:** 90% overall coverage for WebSocket feature

---

## Deployment Considerations

**Development:**
- Custom Next.js server runs on localhost:3000
- Socket.io on same port as HTTP

**Production (Vercel):**
- ⚠️ **POTENTIAL BLOCKER:** Vercel serverless may not support long-lived connections
- **Backup Plan:** Deploy Socket.io server separately to Railway
- **Decision Point:** After Bead 12 (client connection complete)

---

## Next Session Plan

**Session Goal:** Complete Phase 2 (Client-Side Hook)

**Beads to Execute:**
1. Bead 10: useWebSocket hook structure (30 min)
2. Bead 11: Authentication in client (20 min)
3. Bead 12: Reconnection logic (35 min)
4. Bead 13: Event subscription API (25 min)
5. Bead 14: Hook tests (35 min)

**Expected Time:** 145 minutes (~2.5 hours)
**Expected Commits:** 5

**Prerequisites:**
- None (server complete)

**Success Criteria:**
- Hook can connect to server
- Reconnection works
- Can subscribe to events
- Tests passing

---

## Commit History

All commits for this bead chain:

```
a7f3d2e - feat: Add Socket.io server configuration (Bead 1)
b8e4f3a - feat: Add WebSocket authentication middleware (Bead 2)
c9d5g4b - feat: Implement connection handling (Bead 3)
d0e6h5c - feat: Add project room management (Bead 4)
f2g8j7e - fix: CORS configuration for Socket.io (Bead 5)
g3h9k8f - feat: Add task update event stub (Bead 6)
e1f7i6d - test: Add WebSocket server tests (Bead 7)
h4i0l9g - feat: Add WebSocket error handling (Bead 8)
i5j1m0h - docs: Add WebSocket architecture docs (Bead 9)
```

**Total Commits:** 9
**Average per bead:** 1 (perfect bead discipline ✅)

---

**Created:** 2026-02-10
**Last Updated:** 2026-02-12 (after Bead 9)
**Next Update:** After completing Phase 2

**Status:** 50% complete, on track, no blockers
