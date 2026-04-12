# Lifecycle Tutorial: From Issue to Merge

> **Difficulty**: Intermediate
> **Time**: ~30 minutes to read, ~2 hours to execute
> **Prerequisites**: Familiarity with the ADWS Task Manager project, git, and basic Python/FastAPI

---

## Introduction

This tutorial walks through the complete **7-stage agentic engineering lifecycle** — Intake → Plan → Implement → Validate → Review → Document → Merge/Escalate — using a realistic feature request for the **ADWS Task Manager** project.

The lifecycle is defined in [docs/workflow.md](workflow.md) and the risk controls are in [docs/risk-model.md](risk-model.md). Every task, from a one-line typo fix to a multi-file refactor, follows these stages — but the rigor scales with risk. This tutorial shows a **Medium risk** change in full detail so you can see every control in action.

By the end, you will understand:

- How to classify a task and determine its risk level
- How to write a plan that an agent (or human) can execute unambiguously
- How to implement, validate, review, and document a change
- When controls can be skipped or simplified for lower-risk tasks

---

## The Issue

A user opens GitHub issue #1 on the Task Manager repository:

---

> **Feature: Add priority filtering and sorting to task list endpoint**
>
> **Labels**: `enhancement`, `medium-risk`
>
> The `GET /tasks` endpoint currently returns all tasks in insertion order with no way to narrow results. For the daily stand-up view, users need to:
>
> 1. **Filter** tasks by priority (e.g., show only `high` priority items)
> 2. **Sort** tasks by `created_date` in ascending or descending order
>
> #### Acceptance Criteria
>
> - [ ] `GET /tasks?priority=high` returns only tasks with priority `high`
> - [ ] `GET /tasks?sort_by=created_at&sort_order=desc` returns tasks sorted by creation date, newest first
> - [ ] `GET /tasks` (no params) still works as before — returns all tasks
> - [ ] Invalid `priority` values return a 422 error
> - [ ] All existing tests continue to pass

---

This is a realistic, well-scoped feature request. It modifies a shared endpoint, changes production behavior, and touches multiple files — but it does not involve security-critical code, data loss risk, or irreversible operations. By the risk decision tree in [risk-model.md](risk-model.md), this is a **🟡 Medium risk** change.

Let's walk through it.

---

## Stage 1: Intake

**Purpose**: Understand the task fully before touching any code.

### Classify the Task

| Field | Value |
|---|---|
| **Classification** | Feature |
| **Risk Level** | 🟡 Medium |
| **Reason** | Modifies production code on a shared endpoint; affects external API behavior; adds query parameters |

**Risk reasoning** (from the [decision tree](risk-model.md#risk-decision-tree)):

1. Does this touch security, auth, payments, or PII? → No
2. Is it irreversible (schema migration, data deletion)? → No
3. Could failure cause a service outage or data loss? → No
4. Does it modify production application behavior? → Yes
   - Does it touch shared code paths used by multiple features? → Yes (the `/tasks` endpoint is the primary list endpoint)
   - → **🟡 Medium**

### Define the Scope Boundary

**IN scope**:
- Add `priority` query parameter to `GET /tasks` for filtering
- Add `sort_by` and `sort_order` query parameters to `GET /tasks` for sorting
- Validate `priority` parameter against `VALID_PRIORITIES`
- Add integration tests for filtering and sorting
- Update `database.py` with a new `list_tasks_filtered()` function

**NOT in scope**:
- Changing the `TaskResponse` model (the response shape stays the same)
- Adding pagination (`limit`/`offset`) — that is a separate feature
- Adding filtering by `completed` status — can be added later
- Adding sorting by fields other than `created_at` — extend later
- Changing the behavior of `GET /tasks` with no parameters

### Clarification Requests

Before proceeding, the agent asks:

1. **Should `priority` filtering be case-insensitive?** The current `create_task` endpoint validates priority as lowercase only (`low`, `medium`, `high`), so filtering should also be case-sensitive and match exactly. In the future, consider normalizing to lowercase.

2. **What should the default `sort_order` be?** If no `sort_order` is specified, the endpoint should maintain backward compatibility and return tasks in insertion order (ascending by `id`), not sorted by `created_at`.

3. **Should an invalid `sort_by` value return an error?** For this iteration, only `created_at` is supported. If an unsupported `sort_by` is passed, return a `422` with a clear message.

> **Key principle**: If a task is ambiguous, ask for clarification. Do not guess at requirements. (See [workflow.md Stage 1](workflow.md#stage-1-intake))

---

## Stage 2: Plan

**Purpose**: Define what will change, how, and what success looks like — before writing code.

Since this is a Medium risk change, a written plan is **required** before implementation begins. The plan is saved to `adws/.agent/plans/2026-04-12-priority-filtering.md`.

See the complete filled-in plan at [`adws/.agent/plans/2026-04-12-priority-filtering.md`](../adws/.agent/plans/2026-04-12-priority-filtering.md). Here is an annotated summary:

### Objective

Add priority filtering and created_at sorting to the `GET /tasks` endpoint without breaking existing behavior.

### Acceptance Criteria

- `GET /tasks?priority=high` returns only high-priority tasks
- `GET /tasks?sort_by=created_at&sort_order=desc` returns tasks sorted newest first
- `GET /tasks` with no params returns all tasks in insertion order (backward compatible)
- Invalid `priority` or `sort_by` values return 422
- All existing tests pass unchanged

### Files to Modify

| File | Action | Rationale |
|---|---|---|
| `src/task_manager/database.py` | Modify | Add `list_tasks_filtered()` function |
| `src/task_manager/app.py` | Modify | Add query parameters to `GET /tasks` route |
| `tests/test_app.py` | Modify | Add tests for filtering and sorting |

### Implementation Steps

1. Run `just test` to establish baseline — all 8 tests should pass
2. Add `list_tasks_filtered()` in `database.py`
3. Update `api_list_tasks()` in `app.py` to accept `priority`, `sort_by`, `sort_order` query params
4. Add test cases in `test_app.py`
5. Run `just validate` to confirm lint, test, typecheck, and build pass

### Validation Commands

```bash
just test          # Run pytest
just lint          # Run ruff check
just typecheck     # Run mypy
just validate      # Run all checks
```

### Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Breaking existing `/tasks` behavior | Low | High | Default params preserve current behavior; test `GET /tasks` with no params |
| Invalid sort_by value causes crash | Low | Medium | Validate `sort_by` against allowed values, return 422 |
| Regression in unrelated endpoints | Low | Medium | Run full validation suite, not just new tests |

---

## Stage 3: Implement

**Purpose**: Write the code changes defined in the plan.

Before making changes, run the existing test suite to establish a baseline:

```bash
$ just test
# Expected: 8 passed, 0 failed, 0 skipped
```

### Understanding the Current Code

The `GET /tasks` endpoint currently looks like this in `app.py`:

```python
@app.get("/tasks", response_model=list[TaskResponse])
def api_list_tasks():
    """List all tasks."""
    return db_list_tasks()
```

And the database layer has a simple `list_tasks()` function:

```python
def list_tasks() -> list[TaskResponse]:
    """Return all tasks."""
    return list(_tasks.values())
```

The `TaskResponse` model already includes `priority` and `created_at` fields — we don't need to change the model.

### Change 1: `database.py` — Add `list_tasks_filtered()`

Add a new function after the existing `list_tasks()` function:

```python
def list_tasks_filtered(
    priority: Optional[str] = None,
    sort_by: Optional[str] = None,
    sort_order: Optional[str] = "asc",
) -> list[TaskResponse]:
    """Return tasks filtered by priority, optionally sorted by a field.

    Args:
        priority: If provided, only return tasks matching this priority.
        sort_by: If provided, sort by this field (currently only "created_at").
        sort_order: "asc" or "desc". Defaults to "asc".

    Returns:
        List of matching TaskResponse objects.
    """
    tasks = list(_tasks.values())

    # Filter by priority
    if priority is not None:
        if priority not in VALID_PRIORITIES:
            raise ValueError(
                f"Invalid priority: {priority!r}. Must be one of {VALID_PRIORITIES}."
            )
        tasks = [t for t in tasks if t.priority == priority]

    # Sort by specified field
    if sort_by is not None:
        if sort_by != "created_at":
            raise ValueError(
                f"Invalid sort_by: {sort_by!r}. Only 'created_at' is supported."
            )
        reverse = sort_order == "desc"
        tasks = sorted(tasks, key=lambda t: t.created_at, reverse=reverse)

    return tasks
```

**Rationale**: We add a new function rather than modifying `list_tasks()` directly. This keeps the existing function untouched (backward compatible) and lets `app.py` decide which function to call based on whether query parameters are present.

### Change 2: `app.py` — Add Query Parameters to `GET /tasks`

Update the import and the endpoint:

```python
# Add import at the top of app.py
from typing import Optional

from .database import (
    create_task as db_create_task,
    delete_task as db_delete_task,
    get_task as db_get_task,
    list_tasks as db_list_tasks,
    list_tasks_filtered as db_list_tasks_filtered,  # NEW
    reset as db_reset,
    update_task as db_update_task,
)
```

```python
# Replace the existing api_list_tasks function
@app.get("/tasks", response_model=list[TaskResponse])
def api_list_tasks(
    priority: Optional[str] = None,
    sort_by: Optional[str] = None,
    sort_order: Optional[str] = "asc",
):
    """List all tasks, with optional priority filtering and sorting."""
    # If any filter/sort params are provided, use the filtered function
    if priority is not None or sort_by is not None:
        try:
            return db_list_tasks_filtered(
                priority=priority,
                sort_by=sort_by,
                sort_order=sort_order,
            )
        except ValueError as exc:
            return JSONResponse(status_code=422, content={"detail": str(exc)})
    return db_list_tasks()
```

**Why this design**: When no query parameters are provided, `GET /tasks` calls the original `db_list_tasks()` function, preserving exact backward compatibility. Only when `priority` or `sort_by` is present does it route to the new `db_list_tasks_filtered()`.

### Change 3: `tests/test_app.py` — Add Tests

Add these test functions after the existing tests:

```python
def test_list_tasks_filtered_by_priority():
    """GET /tasks?priority=high returns only high-priority tasks."""
    client.post("/tasks", json={"title": "Low task", "priority": "low"})
    client.post("/tasks", json={"title": "High task", "priority": "high"})
    client.post("/tasks", json={"title": "Also high", "priority": "high"})
    response = client.get("/tasks", params={"priority": "high"})
    assert response.status_code == 200
    results = response.json()
    assert len(results) == 2
    assert all(t["priority"] == "high" for t in results)


def test_list_tasks_sorted_by_created_at_desc():
    """GET /tasks?sort_by=created_at&sort_order=desc returns tasks newest first."""
    client.post("/tasks", json={"title": "First"})
    client.post("/tasks", json={"title": "Second"})
    client.post("/tasks", json={"title": "Third"})
    response = client.get("/tasks", params={"sort_by": "created_at", "sort_order": "desc"})
    assert response.status_code == 200
    titles = [t["title"] for t in response.json()]
    assert titles == ["Third", "Second", "First"]


def test_list_tasks_sorted_ascending():
    """GET /tasks?sort_by=created_at&sort_order=asc returns tasks oldest first."""
    client.post("/tasks", json={"title": "First"})
    client.post("/tasks", json={"title": "Second"})
    response = client.get("/tasks", params={"sort_by": "created_at", "sort_order": "asc"})
    assert response.status_code == 200
    titles = [t["title"] for t in response.json()]
    assert titles == ["First", "Second"]


def test_list_tasks_filter_and_sort():
    """GET /tasks?priority=high&sort_by=created_at&sort_order=desc combines filter and sort."""
    client.post("/tasks", json={"title": "Low task", "priority": "low"})
    client.post("/tasks", json={"title": "High A", "priority": "high"})
    client.post("/tasks", json={"title": "High B", "priority": "high"})
    response = client.get(
        "/tasks",
        params={"priority": "high", "sort_by": "created_at", "sort_order": "desc"},
    )
    assert response.status_code == 200
    results = response.json()
    assert len(results) == 2
    assert results[0]["title"] == "High B"
    assert results[1]["title"] == "High A"


def test_list_tasks_invalid_priority():
    """GET /tasks?priority=urgent returns 422 for invalid priority."""
    response = client.get("/tasks", params={"priority": "urgent"})
    assert response.status_code == 422


def test_list_tasks_invalid_sort_by():
    """GET /tasks?sort_by=name returns 422 for unsupported sort field."""
    response = client.get("/tasks", params={"sort_by": "name"})
    assert response.status_code == 422


def test_list_tasks_no_params_backward_compatible():
    """GET /tasks with no params still returns all tasks (backward compatible)."""
    client.post("/tasks", json={"title": "Task A", "priority": "low"})
    client.post("/tasks", json={"title": "Task B", "priority": "high"})
    response = client.get("/tasks")
    assert response.status_code == 200
    assert len(response.json()) == 2
```

### Pattern Reference

The implementation follows the [add-task-endpoint skill](../adws/skills/add-task-endpoint/SKILL.md) pattern:

1. **Define the route signature** — Added query parameters to the existing `GET /tasks` route
2. **Extend models** — Not needed; `TaskResponse` already has `priority` and `created_at`
3. **Add database functions** — `list_tasks_filtered()` follows existing patterns
4. **Write tests** — New tests follow the `test_{verb}_{resource}_{scenario}` naming convention
5. **Validate** — `just validate` to confirm everything passes

---

## Stage 4: Validate

**Purpose**: Prove the changes work and haven't broken anything.

Since this is a Medium risk change, the full validation suite is required:

| Control | Required? | Command |
|---|---|---|
| Run existing tests | ✅ | `just test` |
| Run linter | ✅ | `just lint` |
| Add/update tests | ✅ | 7 new tests added |
| Type check | ✅ | `just typecheck` |
| Full build | ✅ | `just build` |

### Validation Run

```bash
# Establish baseline FIRST (Stage 3, step 1)
$ just test
# Before changes: 8 passed, 0 failed, 0 skipped

# After implementing changes:
$ just test
# ===================== test session starts =====================
# collected 15 items
# tests/test_app.py .....                                        [ 33%]
# tests/test_models.py .....                                      [100%]
# ===================== 15 passed, 0 failed, 0 skipped ====================

$ just lint
# All checks passed!

$ just typecheck
# Success: no issues found in 4 source files

$ just validate
# lint ✓  test ✓  typecheck ✓  build ✓
# All validation checks passed!
```

**Regression check**: Test count went from 8 → 15 (7 new tests added). No existing tests were removed or modified. No failures introduced.

> **Never skip validation.** A change without validation is not complete. (See [workflow.md Stage 4](workflow.md#stage-4-validate))

---

## Stage 5: Review

**Purpose**: Evaluate changes for correctness, style, architecture fit, and risk.

For Medium risk changes, agent self-review is required and human review is recommended. The full review is saved to `adws/.agent/reviews/2026-04-12-priority-filtering.md`.

See the complete filled-in review at [`adws/.agent/reviews/2026-04-12-priority-filtering.md`](../adws/.agent/reviews/2026-04-12-priority-filtering.md). Here is a summary of the key findings:

### Scope Alignment

- ✅ Changes match the approved plan — no out-of-scope modifications
- ✅ No unrelated changes included
- ✅ No files modified outside planned scope (`database.py`, `app.py`, `test_app.py` only)
- ✅ `TaskResponse` model was not changed (per scope boundary)

### Correctness

- ✅ Priority filtering works for all three valid priorities (`low`, `medium`, `high`)
- ✅ Sorting by `created_at` in both `asc` and `desc` order works
- ✅ Combining `priority` filter + `sort_by` sort works correctly
- ✅ Invalid `priority` and `sort_by` values return 422 with clear messages
- ✅ Backward compatibility preserved — `GET /tasks` with no params unchanged

### Regression Risk

- ✅ All 15 tests pass (8 original + 7 new)
- ✅ No existing test was modified
- ✅ Shared code paths (`list_tasks`, database layer) reviewed for side effects
- ✅ Other endpoints (`POST /tasks`, `GET /tasks/{id}`, `PUT /tasks/{id}`, `DELETE /tasks/{id}`) still work

### Disposition

- ✅ **APPROVE**: All checks pass. Ready to merge.

---

## Stage 6: Document

**Purpose**: Ensure the change is understandable to future developers and agents.

### Commit Message

Follow the project's conventional commit format:

```
feat(tasks): add priority filtering and created_at sorting to GET /tasks

- Add list_tasks_filtered() to database.py with priority filter and sort_by support
- Add priority, sort_by, sort_order query parameters to GET /tasks endpoint
- Add 7 integration tests covering filtering, sorting, combined, and error cases
- Maintain backward compatibility: GET /tasks with no params unchanged

Risk level: Medium
Issue: #1
```

### PR Description

```markdown
## What Changed

Added priority filtering and created_at sorting to the `GET /tasks` endpoint.

## Why

Users need to view tasks filtered by priority (e.g., show only high-priority items)
and sorted by creation date. Previously, all tasks were returned in insertion order
with no way to narrow results. Closes #1.

## How to Test

1. `just test` — 15 tests pass
2. `just lint` — no warnings
3. `just typecheck` — passes
4. Manual smoke test:
   - `GET /tasks` — returns all tasks (backward compatible)
   - `GET /tasks?priority=high` — returns only high-priority tasks
   - `GET /tasks?sort_by=created_at&sort_order=desc` — returns tasks sorted newest first
   - `GET /tasks?priority=high&sort_by=created_at&sort_order=desc` — combined filter + sort
   - `GET /tasks?priority=urgent` — returns 422 error

## Risk Level

🟡 Medium — modifies a shared production endpoint; no data migration; backward compatible

## Files Changed

- `src/task_manager/database.py` — added `list_tasks_filtered()`
- `src/task_manager/app.py` — added query parameters to `GET /tasks`
- `tests/test_app.py` — added 7 new test cases
```

### AGENTS.md Update

No update needed for this change — the coding conventions (Pydantic models, database layer pattern, TestClient testing) remain the same. The new `list_tasks_filtered()` function follows the existing `list_tasks()` pattern documented in AGENTS.md.

---

## Stage 7: Merge/Escalate

**Purpose**: Finalize the change or hand off to a human when needed.

### Merge Decision

For this Medium risk change, the agent self-review approved the change. Human review is recommended but not blocking. Since all validation passed:

1. **Approve** ✅ — All checks pass, no regressions, backward compatible
2. Merge the PR
3. No post-merge monitoring required (Medium risk), but recommended to verify the deployed endpoint responds correctly

### When to Escalate

This change did not require escalation, but the risk model defines triggers:

| Trigger | Action |
|---|---|
| Risk is High and no human reviewer is available | Pause and notify. Do not merge. |
| Requirements ambiguous after one clarification attempt | Escalate with specific questions. |
| Implementation reveals scope 2x+ larger than planned | Escalate with revised scope proposal. |
| Tests fail and root cause unclear after 2 attempts | Escalate with diagnostic context. |
| Agent discovers a security vulnerability during work | Escalate immediately with severity assessment. |

If, for example, validation had revealed that the `sort_order` parameter caused a regression in the existing `GET /tasks` behavior, the agent would **escalate** rather than guess at a fix.

---

## Summary

This tutorial walked through the complete 7-stage lifecycle for a realistic Medium risk feature:

| Stage | What We Did |
|---|---|
| **1. Intake** | Classified as Feature, 🟡 Medium risk; defined scope boundaries; asked clarification questions |
| **2. Plan** | Wrote a complete plan using the [plan template](../templates/plan-template.md); defined acceptance criteria, files to modify, implementation steps, risks |
| **3. Implement** | Added `list_tasks_filtered()` in database.py; added query params in app.py; wrote 7 tests following the [add-task-endpoint skill](../adws/skills/add-task-endpoint/SKILL.md) pattern |
| **4. Validate** | Ran `just validate` — 15 tests pass, lint pass, typecheck pass, build pass; no regressions |
| **5. Review** | Filled in the [review template](../templates/review-template.md); verified scope alignment, correctness, testing, regression risk, and architecture fit; disposition: **APPROVE** |
| **6. Document** | Wrote conventional commit message; wrote detailed PR description; confirmed AGENTS.md needs no update |
| **7. Merge/Escalate** | Approved (Medium risk, agent self-review + recommended human review); merged PR; explained escalation triggers |

### Scaling Controls by Risk

The lifecycle scales with risk. A one-line typo fix would look very different:

| Control | 🟢 Low (typo fix) | 🟡 Medium (this feature) | 🔴 High (DB migration) |
|---|---|---|---|
| Written plan | Optional | ✅ Required | ✅ Required + approval |
| Run tests | ✅ | ✅ | ✅ |
| Add new tests | Optional | ✅ Required | ✅ Required |
| Type check | If configured | ✅ Required | ✅ Required |
| Written review | Self-review OK | ✅ Required | ✅ Required + human |
| Human merge approval | Not needed | Recommended | Required |

For a Low risk typo fix, you might skip Stage 2 (written plan) and Stage 5 (formal review), going straight from Intake → Implement → Validate → Document → Merge.

### Key Takeaways

- **Always start with Intake** — even for small changes, classify risk and define scope
- **Write plans for Medium and High risk** — the plan template forces you to think through acceptance criteria and risks before coding
- **Never skip validation** — `just validate` is your safety net
- **Review your own changes** — the review template catches scope creep, missing edge cases, and documentation gaps
- **Escalate early** — if something feels wrong, escalate rather than guess

### Further Reading

- [Core Engineering Lifecycle (workflow.md)](workflow.md) — Full lifecycle specification
- [Risk Classification & Controls (risk-model.md)](risk-model.md) — Risk levels, decision tree, and controls matrix
- [Plan Template](../templates/plan-template.md) — Fill-in template for Stage 2
- [Review Template](../templates/review-template.md) — Fill-in template for Stage 5
- [add-task-endpoint Skill](../adws/skills/add-task-endpoint/SKILL.md) — Project-specific pattern for adding API endpoints
