# Issue #1: Feature: Add priority filtering and sorting to task list endpoint

> **Labels**: `enhancement`, `medium-risk`
> **Assignee**: agent
> **Status**: Open
> **Created**: 2026-04-12

---

## Problem

The `GET /tasks` endpoint currently returns all tasks in insertion order with no way to narrow results. For the daily stand-up view, users need to:

1. **Filter** tasks by priority (e.g., show only `high` priority items)
2. **Sort** tasks by `created_at` in ascending or descending order

Currently, clients must fetch all tasks and filter/sort client-side, which is inefficient and makes the API harder to use.

## Proposed Solution

Add optional query parameters to `GET /tasks`:

- `priority` — filter tasks by priority value (`low`, `medium`, `high`)
- `sort_by` — field to sort by (`created_at` initially, extensible later)
- `sort_order` — sort direction (`asc` or `desc`, default `asc`)

When no parameters are provided, the endpoint should maintain backward-compatible behavior (return all tasks in insertion order).

## Acceptance Criteria

- [ ] `GET /tasks?priority=high` returns only tasks with priority `high`
- [ ] `GET /tasks?sort_by=created_at&sort_order=desc` returns tasks sorted by creation date, newest first
- [ ] `GET /tasks?sort_by=created_at&sort_order=asc` returns tasks sorted by creation date, oldest first
- [ ] `GET /tasks` (no params) still works as before — returns all tasks
- [ ] `GET /tasks?priority=high&sort_by=created_at&sort_order=desc` combines filter and sort
- [ ] Invalid `priority` values return a 422 error with a clear message
- [ ] Invalid `sort_by` values return a 422 error with a clear message
- [ ] All existing tests continue to pass

## Out of Scope

- Pagination (`limit`/`offset`) — separate feature
- Filtering by `completed` status — can be added later
- Sorting by fields other than `created_at` — extensible in future PRs
- Changing the `TaskResponse` model shape

## Risk Assessment

**Risk Level**: 🟡 Medium

- Modifies a shared, production-facing endpoint
- Adds new query parameters that affect API behavior
- Touches multiple files (database.py, app.py, test_app.py)
- Backward compatible — no parameters means same behavior as before

## Additional Context

- The `TaskResponse` model already includes `priority` and `created_at` fields — no model changes needed
- `VALID_PRIORITIES` is defined in `database.py` as `{"low", "medium", "high"}`
- The `add-task-endpoint` skill in `skills/add-task-endpoint/SKILL.md` documents the pattern for modifying endpoints

---

## Comments

### Comment 1 — agent (2026-04-12)

Clarification questions:

1. **Should `priority` filtering be case-insensitive?**
   My assessment: The current `create_task` endpoint validates priority as lowercase only, so filtering should also be case-sensitive and match exactly. Future consideration: normalize to lowercase on input.

2. **What should the default `sort_order` be?**
   My assessment: When no `sort_order` is specified, maintain backward compatibility — return tasks in insertion order (ascending by `id`), not sorted by `created_at`. The `sort_order` parameter only takes effect when `sort_by` is explicitly provided.

3. **Should an invalid `sort_by` value return an error?**
   My assessment: For this iteration, only `created_at` is supported. If an unsupported `sort_by` is passed, return a `422` with a clear message like `"Invalid sort_by: 'name'. Only 'created_at' is supported."`

### Comment 2 — stakeholder (2026-04-12)

All three suggestions sound right:

1. Case-sensitive priority match — consistent with existing validation ✅
2. Default returns all tasks in insertion order — backward compatible ✅
3. Invalid `sort_by` returns 422 — good error handling ✅

Proceed with implementation.
