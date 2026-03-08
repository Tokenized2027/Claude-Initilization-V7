
# Database Migration Generator

## SQL Migration Template

```sql
-- migrations/001_add_email_to_users.sql

-- Up Migration
ALTER TABLE users ADD COLUMN email VARCHAR(255) UNIQUE;
CREATE INDEX idx_users_email ON users(email);

-- Down Migration (for rollback)
-- DROP INDEX idx_users_email;
-- ALTER TABLE users DROP COLUMN email;
```

## Prisma Migration

```bash
# Create migration
npx prisma migrate dev --name add_email_to_users

# Apply migration
npx prisma migrate deploy
```

## Alembic (Python) Migration

```python
# migrations/versions/001_add_email.py
from alembic import op
import sqlalchemy as sa

revision = '001'
down_revision = None

def upgrade():
    op.add_column('users', sa.Column('email', sa.String(255), unique=True))
    op.create_index('idx_users_email', 'users', ['email'])

def downgrade():
    op.drop_index('idx_users_email', table_name='users')
    op.drop_column('users', 'email')
```
