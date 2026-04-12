# Skill: add-task-endpoint

## Capability Contract

| Field | Value |
|---|---|
| Name | add-task-endpoint |
| Risk Level | Low |
| Trigger | Agent needs to add a new CRUD endpoint to the Task Manager API |

## Description

Add a new endpoint to the Task Manager API, following the FastAPI patterns specific
to **this project**. This skill is a project-specific specialization of the universal
`add-api-endpoint` skill — it assumes FastAPI, pytest, and the exact directory structure
defined in `AGENTS.md`.

## Steps

1. **Define the route signature** — Add the route decorator and function signature to
   `src/task_manager/app.py`. Use `@app.get`, `@app.post`, `@app.put`, or `@app.delete`
   with a `response_model` parameter. Follow the existing naming convention:
   `api_{verb}_{resource}`.

2. **Add/extend Pydantic models** — If the endpoint needs new input or output schemas,
   add them to `src/task_manager/models.py`. Use separate models for creation, update,
   and response (never reuse input models for output). Follow the existing pattern:
   `{Resource}Create`, `{Resource}Update`, `{Resource}Response`.

3. **Add database functions** — Implement data access in `src/task_manager/database.py`.
   Never read or write the `_tasks` dict directly from `app.py`. Follow the existing
   functions as a template: `list_{resources}`, `get_{resource}`, `create_{resource}`,
   `update_{resource}`, `delete_{resource}`.

4. **Write tests** — Add integration tests in `tests/test_app.py` using FastAPI
   `TestClient`. Name tests `test_{verb}_{resource}_{scenario}`. Always include a happy
   path test and at least one error case (e.g., not found, validation error). Use the
   `_clean_db` fixture to reset state between tests.

5. **Validate** — Run `just validate` to confirm lint, tests, type checking, and build
   all pass. If any check fails, fix before submitting.

## Inputs

| Input | Type | Required | Description |
|---|---|---|---|
| resource_name | string | yes | Name of the resource (e.g., "label", "comment") |
| http_method | string | yes | HTTP method (GET, POST, PUT, DELETE) |
| fields | list | yes | List of field definitions [{name, type, required}] |

## Outputs

| Output | Location |
|---|---|
| Route handler | `src/task_manager/app.py` |
| Pydantic models | `src/task_manager/models.py` |
| Database functions | `src/task_manager/database.py` |
| Tests | `tests/test_app.py` |

## Compatibility

- **Framework**: FastAPI
- **Language**: Python 3.12+
- **Testing**: pytest + FastAPI TestClient
- **Linter**: ruff

## Changelog

| Version | Date | Author | Change |
|---|---|---|---|
| 1.0 | 2026-04-12 | prime skill | Initial project-specific skill |
