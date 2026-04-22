# FastAPI Service — Claude Instructions

> Claude reads this file automatically at the start of every session.

## What this project is

`[One sentence: what does this API do, who calls it.]`

Example: "A service that accepts a URL and returns a plain text summary of the page."

## Stack

- Python 3.11+
- FastAPI + uvicorn
- `uv` for dependency management (fast and simple, no Poetry rituals)
- Pydantic v2 for request and response models
- Docker for deployment
- `[Database: Postgres / SQLite / none]`
- `[Auth: API key in header / JWT / none]`

## File layout

```
app/
  main.py           FastAPI app + route registration
  routes/           one file per resource (users.py, items.py)
  models/           Pydantic request/response models
  db/               database client + queries (if any)
  deps.py           FastAPI dependencies (auth, db session)
tests/
  test_routes.py
Dockerfile
pyproject.toml      uv managed
.env.example
```

## Rules for Claude

### Always

- Return JSON, set proper HTTP status codes.
- Validate every request body with a Pydantic model.
- Document every route: summary, description, response model.
- Use async handlers when the route does I/O.
- Log at INFO on entry and exit of each route. Log errors with stack traces.
- Put secrets in environment variables. Use a `Settings` class with `pydantic-settings`.

### Never

- Return raw database rows. Always shape the response through a Pydantic model.
- Catch `Exception` and silently swallow. Let FastAPI's handler deal with unknowns.
- Commit `.env`. `.env.example` lists all expected variables with placeholder values.
- Add dependencies without asking. Start with FastAPI, uvicorn, pydantic.

## Common commands

```bash
uv sync                              # install dependencies
uv run uvicorn app.main:app --reload # dev server
uv run pytest                        # tests
docker build -t myservice .          # container build
docker run -p 8000:8000 myservice    # run container
```

## Health and readiness

Every service exposes:

- `GET /health` — returns `{"status": "ok"}` if the process is up. No dependencies checked.
- `GET /ready` — returns 200 only if all downstreams (DB, queue, external API) are reachable.

## Checklist before shipping

- [ ] All routes have request + response models.
- [ ] `/health` and `/ready` implemented.
- [ ] New env vars in `.env.example`.
- [ ] `docker build` succeeds.
- [ ] `curl localhost:8000/health` returns 200 from inside the container.
