# CLAUDE.md — Solo Vibe Coder Edition (Python/Flask)

> This is the consolidated system prompt for solo developers building Python/Flask backends with Claude Code.
> Copy this file into the root of every new Python project as `CLAUDE.md`.

---

## Project Info

- **Repo:** [GIT_REPO_URL]
- **Stack:** Python 3.12 + Flask + SQLAlchemy + PostgreSQL
- **Owner:** [Your name/handle]
- **Purpose:** [One sentence describing what this project does]

## Linked Project Files

- PRD: `./docs/PRD.md`
- Tech Spec: `./docs/TECH_SPEC.md`
- Status: `./STATUS.md`
- Changelog: `./CHANGELOG.md`

---

## Who You're Working With

You are working with a solo developer who builds through AI-assisted "vibe coding." They:
- Have strong conceptual understanding of systems and products
- Rely on you (Claude) to write and debug all code
- Work alone on full-stack projects from idea to deployment
- Need direct, action-oriented guidance with exact commands and complete files

**Communication style:** Brief, conversational, action-first. No preambles. Show results.

---

## CRITICAL RULES — NO EXCEPTIONS

### 1. COMPLETE FILES ONLY
- Never say "the rest stays the same" or give partial code
- Every file you produce must be complete and copy-pasteable
- No truncation, no shortcuts, no "..." placeholders

### 2. NEVER ASSUME FILE STATE
- If you need to modify an existing file, ask to see it first
- Always verify current state before making changes

### 3. COMMANDS FIRST, EXPLANATION LATER
- Lead with exact terminal commands
- Then provide complete code files
- Brief explanation only if needed

### 4. HANDLE ALL EDGE CASES
- Every endpoint validates input and returns meaningful errors
- Every database query handles connection failures
- Every external API call has timeout and retry logic

### 5. VERIFY BEFORE WRITING
- Confirm: new file or modifying existing?
- If modifying, ask for current contents first

---

## Code Quality Standards

### Python Standards
1. **Type hints on all functions.** Parameters and return types.
2. **No dead code.** No commented-out blocks, no unused imports.
3. **DRY principle.** Extract shared logic to `utils/` or service modules.
4. **Single responsibility.** One module, one purpose. If >200 lines, split.
5. **Fail fast.** Validate inputs early. Raise clear exceptions.

### Project Structure

```
project-root/
├── app/
│   ├── __init__.py          # Flask app factory
│   ├── config.py            # Configuration from env vars
│   ├── models/              # SQLAlchemy models
│   │   ├── __init__.py
│   │   └── user.py
│   ├── routes/              # Flask blueprints
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   └── api.py
│   ├── services/            # Business logic
│   │   └── user_service.py
│   └── utils/               # Shared helpers
│       └── validators.py
├── migrations/              # Alembic migrations
├── tests/
│   ├── conftest.py
│   └── test_routes/
├── .env.example
├── .gitignore
├── CLAUDE.md
├── STATUS.md
├── requirements.txt
├── pyproject.toml
└── Dockerfile
```

### Flask Patterns

```python
# ✅ GOOD: Blueprint with validation and error handling
from flask import Blueprint, request, jsonify
from app.models.user import User
from app.services.user_service import UserService
import logging

logger = logging.getLogger(__name__)
api = Blueprint('api', __name__, url_prefix='/api')

@api.route('/users', methods=['GET'])
def list_users():
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        users = UserService.get_paginated(page, per_page)
        return jsonify({
            'success': True,
            'data': [u.to_dict() for u in users.items],
            'meta': {
                'page': page,
                'total_pages': users.pages,
                'total_items': users.total
            }
        })
    except Exception as e:
        logger.error(f"Failed to list users: {e}")
        return jsonify({
            'success': False,
            'error': {'code': 'INTERNAL_ERROR', 'message': 'Failed to fetch users'}
        }), 500

@api.route('/users', methods=['POST'])
def create_user():
    data = request.get_json()
    if not data:
        return jsonify({
            'success': False,
            'error': {'code': 'VALIDATION_ERROR', 'message': 'Request body required'}
        }), 400

    required = ['email', 'name']
    missing = [f for f in required if f not in data]
    if missing:
        return jsonify({
            'success': False,
            'error': {'code': 'VALIDATION_ERROR', 'message': f'Missing fields: {missing}'}
        }), 400

    try:
        user = UserService.create(data)
        return jsonify({'success': True, 'data': user.to_dict()}), 201
    except ValueError as e:
        return jsonify({
            'success': False,
            'error': {'code': 'VALIDATION_ERROR', 'message': str(e)}
        }), 400
    except Exception as e:
        logger.error(f"Failed to create user: {e}")
        return jsonify({
            'success': False,
            'error': {'code': 'INTERNAL_ERROR', 'message': 'Failed to create user'}
        }), 500
```

### Database Patterns

```python
# ✅ GOOD: Model with to_dict and proper types
from app import db
from datetime import datetime, timezone

class User(db.Model):
    __tablename__ = 'users'

    id: int = db.Column(db.Integer, primary_key=True)
    email: str = db.Column(db.String(255), unique=True, nullable=False)
    name: str = db.Column(db.String(100), nullable=False)
    role: str = db.Column(db.String(20), default='user', nullable=False)
    created_at: datetime = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'email': self.email,
            'name': self.name,
            'role': self.role,
            'created_at': self.created_at.isoformat()
        }
```

### Configuration

```python
# ✅ GOOD: Config from env vars, never hardcoded
import os

class Config:
    SECRET_KEY = os.environ['SECRET_KEY']
    SQLALCHEMY_DATABASE_URI = os.environ['DATABASE_URL']
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False
```

---

## Logging

- Use Python `logging` module, not `print()`
- Set up structured logging with timestamps
- Log levels: DEBUG (data flow), INFO (operations), WARNING (recoverable), ERROR (failures)

```python
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(name)s %(levelname)s %(message)s'
)
logger = logging.getLogger(__name__)
```

---

## Git Discipline

- Commit after every completed unit of work
- Never commit directly to main — use feature branches
- Commit format: `type(scope): description`
  - `feat(api): add user registration endpoint`
  - `fix(auth): handle expired JWT tokens`
  - `refactor(models): extract base model class`

---

## Environment Variables

- Never hardcode secrets, URLs, or configuration
- All config comes from environment variables via `os.environ`
- Every env var documented in `.env.example`
- Never commit `.env` files

---

## Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test
pytest tests/test_routes/test_auth.py -v
```

---

## Self-Correction Protocol

When corrected on something substantive, add the correction below:

| Date | Correction |
|------|-----------|
| | |

---

## Project-Specific Rules

<!-- Add project-specific instructions below -->
