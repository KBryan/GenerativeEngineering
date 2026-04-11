# Core Engineering Lifecycle Standard

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: Universal — applies to any coding agent, any language, any project

---

## Overview

Every agent task follows a 7-stage lifecycle. Stages are sequential but allow backward jumps when validation or review reveals problems. The lifecycle applies regardless of task size — a one-line fix and a multi-file refactor both follow these stages, with controls scaled by [risk level](risk-model.md).

```
┌─────────┐    ┌──────┐    ┌───────────┐    ┌──────────┐    ┌────────┐    ┌──────────┐    ┌───────────────┐
│ 1.Intake │───▶│2.Plan│───▶│3.Implement│───▶│4.Validate│───▶│5.Review│───▶│6.Document│───▶│7.Merge/Escalate│
└─────────┘    └──────┘    └───────────┘    └──────────┘    └────────┘    └──────────┘    └───────────────┘
       ▲                          │                │               │
       └──────────────────────────┴────────────────┴───────────────┘
                              (loop back on failure)
```

---

## Stage 1: Intake

**Purpose**: Understand the task fully before touching any code.

### Required Inputs

- Task description (issue, ticket, verbal request, or automated trigger)
- Access to the repository and its `AGENTS.md` (or equivalent project config)

### Required Outputs

- **Task classification**: Bug fix, feature, refactor, infrastructure, documentation
- **Risk level**: Low / Medium / High (see [Risk Model](risk-model.md))
- **Scope boundary**: Explicit list of what IS and IS NOT in scope
- **Clarification requests**: Any ambiguities that block planning, sent to the requester

### Agent Rules

1. Read `AGENTS.md` (or project config) before any other action.
2. If the task is ambiguous, ask for clarification. Do not guess at requirements.
3. Classify risk level using the decision tree in [Risk Model](risk-model.md).
4. If scope exceeds a single session's capacity, propose decomposition.

### Example

```
Task: "Fix the login timeout bug"
Classification: Bug fix
Risk: Medium (auth system, user-facing)
Scope: Investigate and fix timeout in auth service; NOT refactoring auth flow
Clarifications needed: None — reproduction steps in ticket
```

---

## Stage 2: Plan

**Purpose**: Define what will change, how, and what success looks like — before writing code.

### Required Inputs

- Completed intake (Stage 1 outputs)
- Relevant source files identified and read

### Required Outputs

- **Written plan** using [plan template](../templates/plan-template.md) containing:
  - Objective (one sentence)
  - Acceptance criteria (testable)
  - Files to modify (with rationale)
  - Implementation steps (ordered)
  - Validation commands
  - Risks and mitigations
  - Open questions

### Agent Rules

1. For **Medium and High risk**: the plan MUST be written to a file or presented for approval before implementation begins.
2. For **Low risk**: a mental plan is acceptable, but implementation steps should still be articulated in commit messages or comments.
3. Plans must include rollback strategy for High risk changes.
4. If the plan reveals the task is larger than expected, escalate with a revised scope proposal.

### Example

See [templates/plan-template.md](../templates/plan-template.md) for a complete example.

---

## Stage 3: Implement

**Purpose**: Write the code changes defined in the plan.

### Required Inputs

- Approved plan (Stage 2 output)
- Working development environment

### Required Outputs

- Code changes matching the plan
- All changes confined to planned scope
- Inline comments where logic is non-obvious

### Agent Rules

1. **Run existing tests BEFORE making changes** to establish a baseline. If tests already fail, document which ones and why.
2. Follow the project's coding conventions as defined in `AGENTS.md`.
3. Make changes in small, logical commits where possible.
4. If implementation reveals the plan was wrong, STOP and return to Stage 2.
5. Do not modify files outside the planned scope without explicit justification.

### Example

```
Baseline: ran `make test` — 142 pass, 0 fail, 3 skip
Changes: modified auth/timeout.py lines 45-62, added test in tests/test_timeout.py
Scope note: did NOT touch auth/session.py despite related code — out of scope
```

---

## Stage 4: Validate

**Purpose**: Prove the changes work and haven't broken anything.

### Required Inputs

- Completed implementation (Stage 3 output)
- Baseline test results (from Stage 3, step 1)

### Required Outputs

- **Test results**: All existing tests pass (or known failures documented)
- **New test results**: Tests covering the change pass
- **Lint/format results**: Code passes all configured linters
- **Type check results**: If applicable, type checking passes
- **Build results**: Project builds successfully
- **Regression check**: No new failures compared to baseline

### Required Controls by Risk Level

| Control | Low | Medium | High |
|---|---|---|---|
| Run existing tests | ✅ | ✅ | ✅ |
| Run linter | ✅ | ✅ | ✅ |
| Add/update tests for changes | Optional | ✅ | ✅ |
| Type check | If configured | ✅ | ✅ |
| Full build | If configured | ✅ | ✅ |
| Manual smoke test | — | Optional | ✅ |
| Performance regression check | — | — | ✅ |

### Agent Rules

1. **Never skip validation.** A change without validation is not complete.
2. If tests fail, diagnose and fix. Do not proceed to review with failing tests.
3. If a test failure is pre-existing and unrelated, document it explicitly.
4. Run the FULL validation suite defined in the project's validation config (see [templates/validation-readme.md](../templates/validation-readme.md)).

---

## Stage 5: Review

**Purpose**: Evaluate changes for correctness, style, architecture fit, and risk.

### Required Inputs

- Validated changes (Stage 4 output)
- The original plan (Stage 2 output)

### Required Outputs

- **Review checklist** using [review template](../templates/review-template.md)
- **Disposition**: Approve, Request Changes, or Escalate

### Agent Rules

1. For **Low risk**: agent self-review using the checklist is sufficient.
2. For **Medium risk**: agent self-review required; human review recommended.
3. For **High risk**: human review REQUIRED before merge.
4. Review must verify the change matches the plan. Unplanned changes require justification.
5. Check for: scope creep, missing error handling, hardcoded values, security issues, missing documentation.

---

## Stage 6: Document

**Purpose**: Ensure the change is understandable to future developers and agents.

### Required Inputs

- Approved changes (Stage 5 output)

### Required Outputs

- **Commit message**: Clear, conventional format (e.g., `fix(auth): resolve login timeout after 30s idle`)
- **PR description**: What changed, why, how to test, risk level
- **Updated documentation**: If the change affects APIs, configuration, or behavior documented elsewhere
- **AGENTS.md updates**: If the change affects project conventions, architecture, or validation commands

### Agent Rules

1. Commit messages must explain WHY, not just WHAT.
2. If the change adds new dependencies, document them.
3. If the change affects other teams or services, note it in the PR description.

---

## Stage 7: Merge / Escalate

**Purpose**: Ship the change or hand off to a human.

### Required Inputs

- Documented changes (Stage 6 output)
- Review disposition (Stage 5 output)

### Required Outputs

- **Merged PR** (if approved and agent has merge authority)
- **Escalation summary** (if human intervention needed)

### Agent Rules

1. For **Low risk with passing checks**: merge if the agent has merge authority.
2. For **Medium risk**: request human merge approval.
3. For **High risk**: always escalate. Provide a complete summary: what changed, test results, risk assessment, and recommended reviewers.
4. If merge fails (conflicts, CI failure), diagnose and loop back to the appropriate stage.

### Escalation Format

```
## Escalation Summary
- **Task**: [description]
- **Risk Level**: [Low/Medium/High]
- **Status**: [what's done, what's blocked]
- **Changes**: [files modified, lines changed]
- **Test Results**: [pass/fail summary]
- **Blocking Issue**: [why escalation is needed]
- **Recommended Action**: [what the human should do]
```

---

## The 8 Agent Execution Rules

These rules apply across ALL stages. They are non-negotiable.

| # | Rule | Rationale |
|---|---|---|
| 1 | **No unrelated changes.** Only modify what the task requires. | Prevents scope creep and unexpected regressions. |
| 2 | **Always validate.** Run the full test/lint/build suite before considering a task complete. | Untested changes are incomplete changes. |
| 3 | **Read before writing.** Understand existing code, tests, and conventions before modifying them. | Prevents redundant code and convention violations. |
| 4 | **Baseline first.** Run tests before making changes to know the starting state. | Distinguishes your regressions from pre-existing failures. |
| 5 | **Plan scales with risk.** Low risk gets a mental plan; High risk gets a written, approved plan. | Balances velocity with safety. |
| 6 | **Ask, don't guess.** If requirements are ambiguous, request clarification instead of assuming. | Wrong assumptions waste more time than questions. |
| 7 | **Document the why.** Commit messages, PR descriptions, and comments explain reasoning, not just mechanics. | Future developers (human and agent) need context. |
| 8 | **Escalate early.** If stuck for more than 2 attempts at the same problem, escalate with context. | Prevents infinite loops and wasted compute. |

---

## Cross-References

- **Risk classification details**: [docs/risk-model.md](risk-model.md)
- **Plan template**: [templates/plan-template.md](../templates/plan-template.md)
- **Review template**: [templates/review-template.md](../templates/review-template.md)
- **Validation commands**: [templates/validation-readme.md](../templates/validation-readme.md)
- **Project configuration**: [templates/AGENTS.md](../templates/AGENTS.md)
- **Repository structure**: [docs/repository-structure.md](repository-structure.md)
