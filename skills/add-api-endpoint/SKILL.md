# Skill: add-api-endpoint

> **Version**: 1.0
> **Date**: 2026-04-06
> **Trigger**: When asked to add a new REST endpoint

---

## Capability Contract

- **Name**: `add-api-endpoint`
- **Description**: Adds a new REST API endpoint with route handler, request/response models, input validation, error handling, and corresponding tests.
- **Trigger**: When asked to add, create, or implement a new REST endpoint, API route, or HTTP handler.
- **Prerequisites**: Project has an existing web framework with at least one route already defined (provides patterns to follow). A working test runner is configured.
- **Produces**: New route/handler file, new test file, updated API documentation (if documentation exists).

---

## Execution Contract

### Steps

1. **Read existing patterns**: Examine at least two existing route files and two existing test files to understand naming conventions, import patterns, error handling style, and request/response model patterns used in the project.
   - Input: Project source directory, test directory
   - Output: Understanding of the project's route structure, model patterns, and testing conventions
   - Validation: Can identify the framework (e.g., FastAPI, Express, Flask), the directory where routes live, and how tests are organized

2. **Create route and models**: Create the new endpoint file following the patterns discovered in Step 1. Include the route handler, request model (with field validation), response model, and proper error handling (404, 422, error responses).
   - Input: Endpoint name, HTTP method, path, request schema, response schema
   - Output: New source file at the conventional location (e.g., `src/routes/{name}.py` or `src/handlers/{name}.ts`)
   - Validation: File compiles/parses; imports resolve; route is registered in the application

3. **Create test file**: Write a test file covering the happy path, validation errors, authentication (if required), and edge cases. Follow the project's existing test patterns (assert style, fixtures, test client setup).
   - Input: The new route file, test conventions from Step 1
   - Output: New test file (e.g., `tests/test_{name}.py` or `tests/{name}.test.ts`)
   - Validation: Tests cover at minimum: successful response, input validation failure, not-found/error response

4. **Validate**: Run the project's validation suite — linter, type checker, and all tests — to confirm no regressions.
   - Input: None (runs against entire project)
   - Output: Linter output, type checker output, test results
   - Validation: All checks pass with zero errors; new tests pass; existing tests still pass

5. **Review**: Review the implementation against the project's coding rules from `AGENTS.md`. Check for: consistent naming, proper error types, no hardcoded values, adequate test coverage.
   - Input: The new files, AGENTS.md coding rules
   - Output: Self-review confirmation or list of items to fix
   - Validation: No violations of project coding standards; all acceptance criteria met

6. **Document**: Update API documentation if the project maintains it (e.g., OpenAPI spec, API docs). Add docstrings/comments to the new endpoint describing purpose, parameters, and responses.
   - Input: The new endpoint, existing API docs
   - Output: Updated documentation
   - Validation: API documentation reflects the new endpoint

### Decision Points

- If the project uses a framework with automatic OpenAPI generation (e.g., FastAPI), ensure the route includes proper type annotations for automatic documentation; do NOT manually write OpenAPI specs.
- If no existing route patterns are found (first endpoint), establish a clear convention and document it in `AGENTS.md`; choose patterns aligned with the framework's best practices.
- If the endpoint requires authentication or authorization, follow the project's existing auth middleware/patterns; do NOT reimplement auth from scratch.
- If the endpoint requires database access, follow the project's existing repository/data-access patterns; do NOT write raw SQL in route handlers unless that is the project's established pattern.

### Rollback

1. Delete the newly created route/handler file
2. Delete the newly created test file
3. Remove any route registration added to the application router
4. Revert documentation changes (if any)
5. Re-run validation suite to confirm clean state

---

## Prompt Contract

### Agent Instructions

```
You are executing the add-api-endpoint skill.

You will add a new REST API endpoint to this project. Follow these steps:

1. FIRST: Read 2-3 existing route files and 2-3 existing test files to understand this project's conventions for:
   - File naming and location
   - Import patterns
   - Request/response model definitions
   - Error handling patterns
   - Test structure and assertions

2. CREATE the new endpoint file following the exact patterns you found. Include:
   - Route handler with proper HTTP method
   - Request model with field validation
   - Response model
   - Error handling (at minimum: 404, 422, 500)
   - Docstring describing the endpoint's purpose

3. CREATE the corresponding test file. Write tests for:
   - Happy path (successful response with expected data)
   - Input validation (missing/invalid fields return 422)
   - Error cases (resource not found returns 404)
   - At least one edge case specific to this endpoint

4. RUN the full validation suite (lint, type-check, tests) and confirm everything passes.

5. REVIEW your work against the coding rules in AGENTS.md. Fix any violations.

6. UPDATE API documentation if the project maintains it.

Note: This skill is tool-agnostic. The patterns you discover in Step 1 determine the specific implementation. Whether the project uses FastAPI, Express, Flask, Go's net/http, or any other framework, follow that framework's established conventions.
```

### Inputs

| Input | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | The endpoint name (e.g., "user-profile", "order-items") — used for file naming and route path |
| `method` | string | Yes | HTTP method: GET, POST, PUT, PATCH, or DELETE |
| `path` | string | Yes | URL path pattern (e.g., `/users/{user_id}/orders`) |
| `description` | string | Yes | One-sentence summary of what the endpoint does |
| `request_schema` | object | No | Expected request body fields with types and validation rules |
| `response_schema` | object | Yes | Expected response body structure with field types |
| `auth_required` | boolean | No | Whether the endpoint requires authentication (default: follow project convention) |

### Outputs

| Output | Location | Description |
|---|---|---|
| Route/handler file | `src/routes/{name}.*` or `src/handlers/{name}.*` | Primary implementation file |
| Test file | `tests/test_{name}.*` or `tests/{name}.test.*` | Tests covering happy path, validation, and errors |
| API docs update | `docs/api.md` or OpenAPI spec | New endpoint documented (if project maintains API docs) |
| Route registration | App router file | New route added to the application's route list |

---

## Workflow Contract

- **Default Risk Level**: Medium (modifies production code, adds new API surface)
- **Lifecycle Stages Covered**: Intake (1), Plan (2), Implement (3), Validate (4), Review (5), Document (6)
- **Plan Required**: Yes — for Medium risk, write a brief plan before implementing
- **Human Review Required**: Yes — new API endpoints affect consumers; review the interface contract

### Validation Checklist

- [ ] New file follows project naming conventions
- [ ] New code passes linter
- [ ] New code passes type checker (if applicable)
- [ ] New tests pass
- [ ] Existing tests still pass (no regressions)
- [ ] Request model has field validation
- [ ] Error handling covers at least 404, 422, 500
- [ ] Endpoint is registered in the application router
- [ ] API documentation updated (if maintained)
- [ ] No hardcoded configuration values

### Review Notes

- Verify the endpoint interface matches what was requested
- Confirm error responses follow the project's error format
- Check that authentication/authorization is applied consistently
- Ensure the route does not bypass existing middleware
