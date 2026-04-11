# Task Plan: [TITLE]

> **Date**: YYYY-MM-DD
> **Risk Level**: Low / Medium / High
> **Status**: Draft / Approved / In Progress / Complete

---

## Objective

<!-- CUSTOMIZE: One sentence describing what this task accomplishes -->

[What will be different when this task is done?]

---

## Context

<!-- CUSTOMIZE: Why is this task needed? Link to issue/ticket if applicable -->

- **Issue/Ticket**: [link or reference]
- **Requested by**: [person or system]
- **Background**: [1-3 sentences of context]

---

## Acceptance Criteria

<!-- CUSTOMIZE: Testable conditions that must be satisfied when the task is complete -->

- [ ] [Criterion 1 — specific and testable]
- [ ] [Criterion 2 — specific and testable]
- [ ] [Criterion 3 — specific and testable]
- [ ] All existing tests pass
- [ ] No new linter warnings

---

## Relevant Files

<!-- CUSTOMIZE: Files that will be read or modified -->

| File | Action | Rationale |
|---|---|---|
| `src/example.py` | Modify | Contains the function to fix |
| `tests/test_example.py` | Modify | Add test for the fix |
| `docs/api.md` | Read only | Reference for expected behavior |

---

## Implementation Steps

<!-- CUSTOMIZE: Ordered steps to complete the task -->

1. **Read and understand**: Review relevant files and existing tests
2. **Establish baseline**: Run `YOUR_TEST_COMMAND` and record results
3. **Implement change**: [describe what to change and why]
4. **Add/update tests**: [describe what tests to add]
5. **Validate**: Run full validation suite
6. **Self-review**: Complete review checklist
7. **Document**: Write commit message and PR description

---

## Validation Commands

<!-- CUSTOMIZE: Exact commands to validate the change -->

```bash
# Run tests
YOUR_TEST_COMMAND

# Run linter
YOUR_LINT_COMMAND

# Run type checker (if applicable)
YOUR_TYPECHECK_COMMAND

# Run build (if applicable)
YOUR_BUILD_COMMAND
```

---

## Risks

<!-- CUSTOMIZE: What could go wrong and how to mitigate -->

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [Risk 1] | Low/Med/High | Low/Med/High | [How to prevent or recover] |
| [Risk 2] | Low/Med/High | Low/Med/High | [How to prevent or recover] |

### Rollback Strategy

<!-- Required for High risk tasks -->

[How to undo these changes if something goes wrong after merge]

---

## Documentation Updates

<!-- CUSTOMIZE: What documentation needs to change -->

- [ ] README.md — [if applicable, describe what to update]
- [ ] AGENTS.md — [if conventions, commands, or architecture changed]
- [ ] API docs — [if public interface changed]
- [ ] No documentation updates needed

---

## Open Questions

<!-- CUSTOMIZE: Anything that needs clarification before or during implementation -->

1. [Question that might affect implementation]
2. [Question about edge cases or expected behavior]

---

## Notes

<!-- Optional: Any additional context, links, or observations -->

---

*Plan created following the [Agentic Engineering Workflow](../../docs/workflow.md) v2.0 — Stage 2: Plan*
