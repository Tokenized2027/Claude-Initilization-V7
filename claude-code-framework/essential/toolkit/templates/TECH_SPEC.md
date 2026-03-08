# Tech Spec — [PROJECT_NAME]

> **Version:** 1.0
> **PRD Reference:** `docs/PRD.md`
> **Date:** [DATE]
> **Status:** Draft | In Review | Approved

---

## 1. System Architecture Overview

[2-3 sentence description of what the system does and how it's structured]

### Architecture Diagram (Text)

```
[Component A] --HTTP--> [Component B] --SQL--> [Database]
                              |
                              +--> [External API]
```

## 2. Tech Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| Frontend | | |
| Backend | | |
| Database | | |
| LLM/AI | | |
| Hosting | | |
| CI/CD | | |

## 3. Component Breakdown

### Component: [Name]
- **Responsibility:** [What it does]
- **Inputs:** [What data it receives]
- **Outputs:** [What data it produces]
- **Dependencies:** [What it relies on]
- **Key files:** [File paths]

*(Repeat for each major component)*

## 4. Data Model / Schema

### Table: [name]
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| | | | |

*(Repeat for each table/collection)*

### Data Flow
1. [Trigger] → [Process] → [Store/Output]
2. ...

## 5. API Design

### Endpoint: `[METHOD] /api/v1/[path]`
- **Purpose:** [What it does]
- **Auth:** [Required | Public]
- **Request:**
```json
{
  "field": "type — description"
}
```
- **Response (200):**
```json
{
  "field": "type — description"
}
```
- **Error codes:** 400 (bad input), 401 (unauthorized), 500 (server error)

*(Repeat for each endpoint)*

## 6. File/Folder Structure

```
project-root/
├── src/
│   ├── components/
│   ├── services/
│   ├── utils/
│   └── ...
├── tests/
├── docs/
│   ├── PRD.md
│   └── TECH_SPEC.md
├── .claude/
│   ├── hooks/
│   └── settings.json
├── CLAUDE.md
├── STATUS.md
├── .env.example
├── .gitignore
└── README.md
```

## 7. Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| | | | |

## 8. Integration Points

| Service | Purpose | Auth Method | Rate Limits | Fallback |
|---------|---------|------------|-------------|----------|
| | | | | |

## 9. Authentication & Authorization

- **Method:** [JWT / OAuth / API Key / etc.]
- **User roles:** [Admin, User, etc.]
- **Session handling:** [How sessions work]
- **Security notes:** [Sensitive data handling, encryption]

## 10. Error Handling Strategy

- **API errors:** [Standard error response format]
- **External API failures:** [Retry logic, fallbacks, circuit breakers]
- **Logging:** [What gets logged, where, at what level]
- **Alerting:** [What triggers alerts]

## 11. Testing Strategy

| Test Type | Tool | Coverage Target | What's Tested |
|-----------|------|----------------|--------------|
| Unit | | 80%+ | |
| Integration | | | |
| E2E | Playwright | | |

## 12. Deployment

- **Target:** [Vercel / Docker / AWS / etc.]
- **Build process:** [Steps]
- **Environment configs:** [dev, staging, prod]
- **Rollback strategy:** [How to revert]

## 13. Technical Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|-----------|
| | | | |

## 14. Phases & Implementation Order

### Phase 1 — MVP
1. [ ] [Task — estimated time]
2. [ ] ...

### Phase 2
1. [ ] ...

---

## HANDOFF BRIEF

- **Project name:** [Name]
- **What we're building:** [1 sentence]
- **Architecture summary:** [3-5 key decisions]
- **Tech stack:** [List]
- **File structure:** [Condensed tree]
- **Key integration points:** [APIs, services]
- **Open decisions:** [What still needs deciding]
- **MVP scope:** [What to build first]
