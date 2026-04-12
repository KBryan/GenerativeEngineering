# Task Plan: Add priority filtering and sorting to GET /tasks

> **Date**: 2026-04-12
> **Risk Level**: Medium
> **Status**: Approved

---

## Objective

Add priority filtering and created_at sorting to the `GET /tasks` endpoint without breaking existing behavior.

---

## Context

- **Issue/Ticket**: #1 — Feature: Add priority filtering and sorting to task list endpoint
- **Requested by**: Product (daily stand-up view needs)
- **Background**: The `GET /tasks` endpoint currently returns all tasks in insertion order with no way to narrow results. Users need to filter by priority and sort by creation date. This is a well-scoped, Medium risk change that modifies a shared endpoint while maintaining backward compatibility.

---

## Acceptance Criteria

- [ ] `GET /tasks?priority=high` returns only tasks with priority `high`
- [ ] `GET /tasks?sort_by=created_at&sort_order=desc` returns tasks sorted by creation date, newest first
- [ ] `GET /tasks?sort_by=created_at&sort_order=asc` returns tasks sorted by creation date, oldest first
- [ ] `GET /tasks?priority=high&sort_by=created_at&sort_order=desc` combines filtering and sorting
- [ ] `GET /tasks` (no params) still returns all tasks in insertion order (backward compatible)
- [ ] Invalid `priority` values return 422 with a clear error message
- [ ] Invalid `sort_by` values return 422 with a clear error message
- [ ] All existing tests pass unchanged
- [ ] No new linter warnings

---

## Relevant Files

| File | Action | Rationale |
|---|---|---|
| `src/task_manager/database.py` | Modify | Add `list_tasks_filtered()` function with priority filter and sort support |
| `src/task_manager/app.py` | Modify | Add `priority`, `sort_by`, `sort_order` query parameters to `GET /tasks` endpoint |
| `tests/test_app.py` | Modify | Add 7 integration tests for filtering, sorting, combined, error, and backward compatibility cases |
| `src/task_manager/models.py` | Read only | Verify `TaskResponse` model has `priority` and `created_at` fields (no changes needed) |
| `AGENTS.md` | Read only | Reference for coding conventions and validation commands |
| `skills/add-task-endpoint/SKILL.md` | Read only | Reference for project-specific endpoint patterns |

---

## Implementation Steps

1. **Read and understand**: Review `database.py`, `app.py`, `models.py`, and `test_app.py` to understand current patterns
2. **Establish baseline**: Run `just test` and record results (expected: 8 passed, 0 failed, 0 skipped)
3. **Add `list_tasks_filtered()` in `database.py`**: Create a new function that accepts `priority`, `sort_by`, and `sort_order` parameters. Filter by priority when provided, validate against `VALID_PRIORITIES`. Sort by `created_at` when `sort_by` is provided, validate that only `created_at` is supported. Raise `ValueError` for invalid inputs.
4. **Update `api_list_tasks()` in `app.py`**: Add `priority` (Optional[str]), `sort_by` (Optional[str]), and `sort_order` (Optional[str], default "asc") query parameters. When any filter/sort param is provided, call `db_list_tasks_filtered()` inside a try/except to catch `ValueError` and return 422. When no params are provided, call `db_list_tasks()` (unchanged, backward compatible).
5. **Add tests in `test_app.py`**: Add 7 test functions:
   - `test_list_tasks_filtered_by_priority` — filter by high
   - `test_list_tasks_sorted_by_created_at_desc` — sort newest first
   - `test_list_tasks_sorted_ascending` — sort oldest first
   - `test_list_tasks_filter_and_sort` — combined filter + sort
   - `test_list_tasks_invalid_priority` — 422 for invalid priority
   - `test_list_tasks_invalid_sort_by` — 422 for unsupported sort field
   - `test_list_tasks_no_params_backward_compatible` — verify backward compatibility
6. **Validate**: Run `just validate` to confirm lint, test, typecheck, and build all pass
7. **Self-review**: Complete review checklist using `templates/review-template.md`

---

## Validation Commands

```bash
# Run tests
just test

# Run linter
just lint

# Run type checker
just typecheck

# Run full validation suite
just validate
```

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Breaking existing `GET /tasks` behavior | Low | High | Default params preserve current behavior; `api_list_tasks()` calls `db_list_tasks()` when no params provided; explicit backward compatibility test added |
| Invalid `sort_by` value causes unhandled error | Low | Medium | Validate `sort_by` against allowed values in `list_tasks_filtered()`, raise `ValueError` caught in `app.py` and returned as 422 |
| Regression in unrelated endpoints | Low | Medium | Run full validation suite (`just validate`), not just new tests; verify existing tests still pass |
| Type checking failures from Optional params | Low | Low | Use `Optional[str] = None` for all query params; FastAPI handles type coercion |

### Rollback Strategy

Revert the changes to `database.py`, `app.py`, and `test_app.py`. Since this is a backward-compatible addition (existing `GET /tasks` behavior unchanged), rollback is straightforward — the three files can be reverted independently if needed. No database migration or schema changes involved.

---

## Documentation Updates

- [ ] README.md — No update needed (no new endpoint, just query params on existing endpoint)
- [ ] AGENTS.md — No update needed (coding conventions unchanged; `list_tasks_filtered()` follows existing `list_tasks()` pattern)
- [ ] API docs — FastAPI auto-generates OpenAPI docs from the updated endpoint signature
- [x] No documentation updates needed

---

## Open Questions

1. ~~Should `priority` filtering be case-insensitive?~~ **Resolved**: Case-sensitive, consistent with existing `create_task` validation.
2. ~~What should the default `sort_order` be?~~ **Resolved**: Maintain backward compatibility — no params means insertion order (ascending by `id`), not sorted by `created_at`.
3. ~~Should an invalid `sort_by` value return an error?~~ **Resolved**: Yes, return 422 with a clear message.

---

## Notes

- The `TaskResponse` model already includes `priority` and `created_at` fields — no model changes needed
- `VALID_PRIORITIES` is defined in `database.py` as `{"low", "medium", "high"}`
- The `add-task-endpoint` skill in `skills/add-task-endpoint/SKILL.md` documents the pattern for modifying endpoints
- We add a new `list_tasks_filtered()` function rather than modifying `list_tasks()` to preserve backward compatibility

---

*Plan created following the [Agentic Engineering Workflow](../../docs/workflow.md) v2.0 — Stage 2: Plan*
