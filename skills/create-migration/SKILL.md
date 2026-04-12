# Skill: create-migration

> **Version**: 1.0
> **Date**: 2026-04-06
> **Trigger**: When asked to create or modify a database schema

---

## Capability Contract

- **Name**: `create-migration`
- **Description**: Creates a database migration file (up + down/rollback) following the project's migration framework conventions.
- **Trigger**: When asked to create, modify, or drop a database table; add, alter, or remove a column; create an index; or run a database migration.
- **Prerequisites**: Project has a migration tool configured (e.g., Alembic, Django migrations, knex, Prisma, flyway). The migration directory and configuration exist.
- **Produces**: New migration file(s) with both upgrade and downgrade operations, and updated documentation.

---

## Execution Contract

### Steps

1. **Review current schema**: Examine the existing database schema, models, and recent migrations to understand the current state. Identify naming conventions, migration numbering/ordering, and the project's migration framework.
   - Input: Migration directory, model files, database configuration
   - Output: Understanding of current schema, migration naming convention, and framework version chain
   - Validation: Can identify the migration tool, the latest migration number/revision, and the model naming patterns

2. **Create migration file**: Generate a new migration file with both upgrade (forward) and downgrade (rollback) operations. Follow the project's naming convention and ordering scheme. Include all schema changes: table creation, column addition/modification, index creation, constraint additions.
   - Input: Schema change description, naming convention, latest migration revision
   - Output: New migration file at the conventional location
   - Validation: File follows naming convention; upgrade function creates/modifies the intended schema; downgrade function reverses all changes

3. **Create rollback**: Ensure the downgrade/rollback function in the migration file properly reverses every operation in the upgrade function. Each CREATE must have a DROP; each ADD COLUMN must have a DROP COLUMN; each ALTER must have a reversing ALTER.
   - Input: The migration file's upgrade operations
   - Output: Complete downgrade function within the same migration file
   - Validation: Every upgrade operation has a corresponding downgrade operation; downgrade order reverses upgrade order to handle dependencies

4. **Validate**: Run the migration against a development/test database. Verify the upgrade applies cleanly and the downgrade rolls back cleanly. Run any existing model tests to confirm no breakage.
   - Input: Migration file, database connection
   - Output: Migration runs without errors in both directions
   - Validation: `up` migration succeeds; `down` migration succeeds; model tests pass; no data loss on upgrade

5. **Document**: Add a migration log entry or update the project's schema documentation. Include: what changed, why, and any manual steps required (e.g., data backfills that cannot be done in the migration itself).
   - Input: Migration description, schema change summary
   - Output: Updated migration log or schema documentation
   - Validation: Documentation reflects the actual schema change

### Decision Points

- If using Alembic (SQLAlchemy), generate an autogenerate migration if models exist, or a manual revision if making raw SQL changes. Always review auto-generated migrations for accuracy.
- If the project uses Django migrations, use `python manage.py makemigrations` and then review the generated file before applying.
- If the schema change involves data migration (not just DDL), include data transformation logic in the migration file with proper error handling.
- If the change is irreversible (e.g., dropping a column with data that cannot be reconstructed), mark the migration as HIGH risk and request human review before proceeding.

### Rollback

1. Run `downgrade` on the migration to roll back the database change
2. Delete the migration file
3. Remove any model changes that prompted the migration
4. Re-run the test suite to confirm clean state
5. Remove documentation entries added in Step 5

---

## Prompt Contract

### Agent Instructions

```
You are executing the create-migration skill.

You will create a database migration. Follow these steps:

1. FIRST: Examine the existing migration directory and model files to understand:
   - What migration tool/framework the project uses
   - The naming convention for migration files
   - The current schema state (latest migration, existing tables)
   - Model patterns and relationships

2. CREATE a migration file with both upgrade and downgrade operations:
   - Follow the project's naming convention exactly
   - The upgrade function should create/alter all intended schema objects
   - The downgrade function should reverse EVERY upgrade operation in the correct order
   - Add a docstring/comment describing what the migration does and why

3. VERIFY the downgrade is complete: every upgrade operation has a corresponding reversal.
   - CREATE TABLE -> DROP TABLE
   - ADD COLUMN -> DROP COLUMN
   - ADD INDEX -> DROP INDEX
   - ALTER COLUMN -> reverse ALTER
   - Data transformations -> reverse transformation (or note if irreversible)

4. TEST the migration: run it up and down against a development database. Confirm zero errors.

5. DOCUMENT the change: update schema documentation or migration log with what changed and why.

IMPORTANT: Database migrations are HIGH risk by default (see risk-model.md). If the change is irreversible or affects production data, always request human review before applying.

Note: This skill is tool-agnostic. Follow the patterns you discover in Step 1. Whether the project uses Alembic, Django, Prisma, knex, Flyway, or any other migration tool, use that tool's conventions.
```

### Inputs

| Input | Type | Required | Description |
|---|---|---|---|
| `description` | string | Yes | What the migration does (e.g., "Add email column to users table") |
| `change_type` | string | Yes | Type of change: create_table, alter_table, add_column, drop_column, add_index, add_constraint, data_migration |
| `table_name` | string | Yes | Primary table affected by the migration |
| `schema_details` | object | Yes | Detailed specification of columns, types, constraints, indexes to add/modify |
| `irreversible` | boolean | No | Whether the migration cannot be cleanly rolled back (default: false) |

### Outputs

| Output | Location | Description |
|---|---|---|
| Migration file | `migrations/versions/` or `migrations/` | New migration with upgrade and downgrade functions |
| Schema documentation | `docs/` or migration log | Updated schema documentation reflecting the change |

---

## Workflow Contract

- **Default Risk Level**: High (database schema changes are irreversible in production)
- **Lifecycle Stages Covered**: Intake (1), Plan (2), Implement (3), Validate (4), Document (5)
- **Plan Required**: Yes — HIGH risk always requires a written plan
- **Human Review Required**: Yes — all database migrations should be reviewed by a human before applying to production

### Validation Checklist

- [ ] Migration file follows project naming convention
- [ ] Upgrade function implements the intended schema change
- [ ] Downgrade function reverses every upgrade operation
- [ ] Downgrade operations are in correct dependency-reversing order
- [ ] Migration runs successfully in upgrade direction
- [ ] Migration runs successfully in downgrade direction
- [ ] Existing model tests pass
- [ ] No data loss on upgrade (or data migration is explicitly handled)
- [ ] Migration has a descriptive docstring/comment
- [ ] Irreversible changes are flagged and documented
- [ ] Schema documentation updated

### Review Notes

- Verify the downgrade is complete and correct — missed rollback operations cause problems in production
- Check that column types match the application model expectations
- Confirm foreign key constraints have proper ON DELETE behavior
- Ensure data migrations (if any) handle edge cases like NULL values
- If the migration is irreversible, it MUST be flagged for manual human review
