# Review Checklist: [CHANGE TITLE]

> **Date**: YYYY-MM-DD
> **Risk Level**: Low / Medium / High
> **Reviewer**: Agent self-review / Human reviewer name
> **Disposition**: Approve / Request Changes / Escalate

---

## Change Summary

<!-- CUSTOMIZE: Brief description of what changed and why -->

- **Task**: [link to issue/ticket or description]
- **Plan**: [link to task plan, if applicable]
- **Files changed**: [count]
- **Lines added/removed**: +[X] / -[Y]

---

## Scope Alignment

<!-- Verify the change matches the plan and stays in scope -->

- [ ] Changes match the approved plan (if plan was required)
- [ ] No unrelated changes included
- [ ] No files modified outside the planned scope
- [ ] If unplanned changes exist, justification is documented

---

## Correctness

<!-- Verify the change does what it's supposed to do -->

- [ ] Logic is correct and handles the stated requirements
- [ ] Edge cases are handled (nulls, empty inputs, boundary values)
- [ ] Error handling is present and appropriate
- [ ] No hardcoded values that should be configurable
- [ ] No TODO/FIXME/HACK comments left without linked issues

---

## Testing & Validation

<!-- Verify the change is properly tested -->

- [ ] Existing tests pass (baseline comparison)
- [ ] New/updated tests cover the change
- [ ] Tests are meaningful (not just trivially passing)
- [ ] Linter passes with no new warnings
- [ ] Type checker passes (if applicable)
- [ ] Build succeeds (if applicable)

### Test Results

```
<!-- CUSTOMIZE: Paste actual test output -->
Tests: X passed, Y failed, Z skipped
Linter: pass/fail
Type check: pass/fail/N/A
Build: pass/fail/N/A
```

---

## Regression Risk

<!-- Assess whether this change could break existing functionality -->

- [ ] No regressions detected (test count unchanged or increased)
- [ ] Shared code paths reviewed for unintended side effects
- [ ] Dependent modules checked for compatibility
- [ ] If API changed: consumers reviewed for breaking impact

### Regressions Found

<!-- List any regressions or leave "None detected" -->

None detected.

---

## Documentation

<!-- Verify documentation is current -->

- [ ] Commit messages explain WHY, not just WHAT
- [ ] PR description includes: what changed, why, how to test, risk level
- [ ] README/docs updated if behavior or API changed
- [ ] AGENTS.md updated if conventions, commands, or architecture changed
- [ ] Inline comments added where logic is non-obvious

---

## Architectural Fit

<!-- Verify the change fits the project's architecture -->

- [ ] Follows project coding conventions (as defined in AGENTS.md)
- [ ] Consistent with existing patterns in the codebase
- [ ] No unnecessary complexity introduced
- [ ] Dependencies are appropriate (no bloat, compatible licenses)
- [ ] Security considerations addressed (no secrets, proper auth, input validation)

---

## Operational Impact

<!-- Assess production impact — especially for Medium and High risk -->

- [ ] No database migration required, OR migration is reversible
- [ ] No environment variable changes required, OR documented
- [ ] No infrastructure changes required, OR documented
- [ ] Monitoring/alerting adequate for the change
- [ ] Rollback strategy documented (required for High risk)

---

## Follow-up Recommendations

<!-- CUSTOMIZE: Note anything that should happen after this change merges -->

- [ ] No follow-up needed
- [ ] [Follow-up item 1 — describe and link issue if created]
- [ ] [Follow-up item 2 — describe and link issue if created]

---

## Final Disposition

<!-- Select one -->

- [ ] **APPROVE**: All checks pass. Ready to merge.
- [ ] **REQUEST CHANGES**: Issues found. See comments above.
- [ ] **ESCALATE**: Requires human judgment. See escalation summary below.

### Escalation Summary (if applicable)

<!-- Only fill this in if disposition is ESCALATE -->

```
Reason: [why human judgment is needed]
Blocking issue: [specific concern]
Recommended reviewers: [who should look at this]
Recommended action: [what the human should do]
```

---

*Review completed following the [Agentic Engineering Workflow](../../docs/workflow.md) v2.0 — Stage 5: Review*
