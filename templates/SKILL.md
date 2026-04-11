# Skill: YOUR_SKILL_NAME

> **Version**: 1.0
> **Date**: YYYY-MM-DD
> **Template**: Copy this file to `skills/your-skill-name/SKILL.md` and fill in all sections.

---

## Capability Contract

<!-- CUSTOMIZE: Define what this skill does and when to use it -->

- **Name**: `your-skill-name` (lowercase, hyphenated, unique identifier)
- **Description**: One sentence — what this skill produces when executed.
- **Trigger**: When should an agent activate this skill? (e.g., "when asked to add a new REST endpoint")
- **Prerequisites**: What must exist before this skill can run? (e.g., "project uses FastAPI", "database migrations configured")
- **Produces**: What artifacts does this skill create or modify? (e.g., "new route file, test file, OpenAPI schema update")

---

## Execution Contract

<!-- CUSTOMIZE: Define the step-by-step procedure -->

### Steps

1. **[Step Name]**: Description of first action.
   - Input: what this step needs
   - Output: what this step produces
   - Validation: how to confirm this step succeeded

2. **[Step Name]**: Description of second action.
   - Input: what this step needs
   - Output: what this step produces
   - Validation: how to confirm this step succeeded

3. **[Step Name]**: Description of third action.
   - Input: what this step needs
   - Output: what this step produces
   - Validation: how to confirm this step succeeded

<!-- Add or remove steps as needed -->

### Decision Points

<!-- CUSTOMIZE: Define branching logic -->

- If [condition A], then [take action X]
- If [condition B], then [take action Y]
- If [unexpected state], then escalate with context

### Rollback

<!-- CUSTOMIZE: How to undo this skill's changes if something goes wrong -->

1. [Rollback step 1]
2. [Rollback step 2]

---

## Prompt Contract

<!-- CUSTOMIZE: Write the natural language instructions an agent should follow -->

### Agent Instructions

```
You are executing the [YOUR_SKILL_NAME] skill.

[Write clear, imperative instructions here. Address the agent directly.
 Use "you" language. Be specific about what to create, where to put it,
 and how to validate it.

 Do NOT reference any specific agent tool. These instructions must work
 with any capable coding agent.

 Example:
 "Create a new file at src/routes/[name].py using the existing route files
  as a pattern. The file must include: route handler, request/response models,
  input validation, error handling, and a test file at tests/test_[name].py.
  Run the test suite after creation to verify no regressions."]
```

### Inputs

<!-- CUSTOMIZE: What information does the agent need to execute this skill? -->

| Input | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | e.g., the name of the endpoint, migration, or component |
| `description` | string | No | e.g., what this endpoint does |
| `options` | string | No | e.g., additional configuration flags |

### Outputs

<!-- CUSTOMIZE: What does successful execution look like? -->

| Output | Location | Description |
|---|---|---|
| Source file | `src/...` | The primary artifact created |
| Test file | `tests/...` | Tests covering the new artifact |
| Documentation | `docs/...` | Updated documentation (if applicable) |

---

## Workflow Contract

<!-- CUSTOMIZE: How this skill integrates with the engineering lifecycle -->

- **Default Risk Level**: Low / Medium / High
- **Lifecycle Stages Covered**: Which stages of the [7-stage lifecycle](../../docs/workflow.md) this skill addresses
- **Plan Required**: Yes / No (based on risk level)
- **Human Review Required**: Yes / No (based on risk level)

### Validation Checklist

<!-- CUSTOMIZE: Specific checks for this skill's output -->

- [ ] All new files follow project naming conventions
- [ ] New code passes linter
- [ ] New tests pass
- [ ] Existing tests still pass (no regressions)
- [ ] Documentation updated (if behavior change)
- [ ] [Skill-specific check 1]
- [ ] [Skill-specific check 2]

### Review Notes

<!-- CUSTOMIZE: What should reviewers pay attention to for this skill's output? -->

- Check that [specific concern for this type of change]
- Verify that [another specific concern]
- Ensure that [quality attribute] is maintained

---

## Examples

<!-- CUSTOMIZE: Provide at least one concrete example of this skill in action -->

### Example 1: [Scenario Name]

**Input**:
```
name: user-profile
description: CRUD operations for user profiles
```

**Expected Output**:
```
Created:
  - src/routes/user_profile.py (route handler with GET, POST, PUT, DELETE)
  - src/models/user_profile.py (request/response Pydantic models)
  - tests/test_user_profile.py (tests for all CRUD operations)
  - Updated docs/api.md with new endpoint documentation

Validation:
  - All tests pass (148 pass, 0 fail)
  - Linter passes
  - Type checker passes
```

---

## Compatibility

<!-- CUSTOMIZE: Note any constraints on where this skill can be used -->

- **Languages**: [e.g., Python 3.10+, any, TypeScript only]
- **Frameworks**: [e.g., FastAPI, any REST framework, framework-agnostic]
- **Dependencies**: [e.g., requires SQLAlchemy, no special dependencies]

---

## Changelog

| Version | Date | Changes |
|---|---|---|
| 1.0 | YYYY-MM-DD | Initial skill definition |

---

*This skill follows the [Cross-Tool Skill Sharing Standard](../../docs/cross-tool-standard.md) v2.0.*
