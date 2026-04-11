# Risk Classification & Controls

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: Universal risk model for agent-driven engineering tasks

---

## Overview

Every task an agent performs carries risk. This document defines how to classify that risk and what controls are required at each level. The goal is not to slow agents down — it's to scale oversight with consequence. A typo fix doesn't need a written plan. A database migration does.

---

## Risk Levels

### 🟢 Low Risk

**Definition**: Changes with limited blast radius that are easily reversible and unlikely to affect users or other systems.

**Examples**:
- Documentation updates (README, comments, docstrings)
- Fixing typos or formatting in non-functional code
- Adding or updating dev dependencies
- Test-only changes (adding tests, fixing flaky tests)
- Configuration changes in development environments
- Code style / linting fixes with no behavioral change
- Updating log messages

**Characteristics**:
- Affects ≤ 3 files
- No behavioral change to production code, OR
- Changes are isolated to test/docs/config
- Easy to revert (single commit)
- No external system dependencies

---

### 🟡 Medium Risk

**Definition**: Changes that modify application behavior, touch shared code paths, or could cause user-visible regressions if done incorrectly.

**Examples**:
- Bug fixes in application logic
- Adding new features to existing modules
- Refactoring internal implementations (same external behavior)
- Updating production dependencies
- API changes (additive — new endpoints, new optional fields)
- Database query changes (not schema)
- CI/CD pipeline modifications
- Environment configuration changes for staging/production

**Characteristics**:
- Modifies production code behavior
- Affects 4-15 files, OR
- Touches code paths shared by multiple features
- Requires tests to verify correctness
- Revertible but may need coordination

---

### 🔴 High Risk

**Definition**: Changes that could cause data loss, security vulnerabilities, service outages, or are difficult to reverse.

**Examples**:
- Database schema migrations
- Authentication or authorization changes
- Payment processing or financial calculation changes
- API breaking changes (removing endpoints, changing required fields)
- Infrastructure changes (networking, DNS, load balancers)
- Data migration or transformation scripts
- Cryptographic implementation changes
- Multi-service deployment coordination
- Performance-critical path changes under heavy production load
- Removing or replacing core dependencies
- Changes affecting PII, HIPAA, PCI, or other regulated data

**Characteristics**:
- Affects 15+ files, OR
- Touches security-sensitive code, OR
- Involves irreversible operations (data deletion, schema changes), OR
- Requires multi-system coordination, OR
- Could cause financial, legal, or reputational damage if wrong

---

## Risk Decision Tree

Use this tree to classify a task when the risk level isn't immediately obvious.

```
Start
  │
  ├─ Does this change touch security, auth, payments, or PII?
  │   └─ YES → 🔴 HIGH
  │
  ├─ Is this change irreversible (schema migration, data deletion)?
  │   └─ YES → 🔴 HIGH
  │
  ├─ Could failure cause a service outage or data loss?
  │   └─ YES → 🔴 HIGH
  │
  ├─ Does this modify production application behavior?
  │   ├─ NO → 🟢 LOW (docs, tests, dev config only)
  │   └─ YES ─┐
  │           │
  │           ├─ Does it touch shared code paths used by multiple features?
  │           │   └─ YES → 🟡 MEDIUM (at minimum)
  │           │
  │           ├─ Does it affect external APIs or integrations?
  │           │   └─ YES → 🟡 MEDIUM (at minimum)
  │           │
  │           ├─ Is the change isolated to a single module with good test coverage?
  │           │   └─ YES → 🟡 MEDIUM
  │           │
  │           └─ Otherwise → 🟡 MEDIUM
  │
  └─ When in doubt → 🟡 MEDIUM (err on the side of more controls)
```

---

## Required Controls Matrix

| Control | 🟢 Low | 🟡 Medium | 🔴 High |
|---|---|---|---|
| **Read AGENTS.md first** | ✅ | ✅ | ✅ |
| **Classify risk** | ✅ | ✅ | ✅ |
| **Written plan** | Optional | ✅ Required | ✅ Required + approval |
| **Run baseline tests** | ✅ | ✅ | ✅ |
| **Run linter** | ✅ | ✅ | ✅ |
| **Add/update tests** | Optional | ✅ Required | ✅ Required |
| **Type checking** | If configured | ✅ Required | ✅ Required |
| **Full build** | If configured | ✅ Required | ✅ Required |
| **Smoke test** | — | Recommended | ✅ Required |
| **Performance check** | — | — | ✅ Required |
| **Self-review checklist** | ✅ | ✅ | ✅ |
| **Human review** | — | Recommended | ✅ Required |
| **Rollback plan** | — | Recommended | ✅ Required |
| **Merge authority** | Agent can merge | Human approves | Human merges |
| **Post-merge monitoring** | — | Recommended | ✅ Required (15 min) |

---

## Escalation Policy

Escalation is not failure — it's a safety mechanism. Agents should escalate early rather than guess.

### When to Escalate

| Trigger | Action |
|---|---|
| Risk is High and no human reviewer is available | Pause and notify. Do not merge. |
| Requirements are ambiguous after one clarification attempt | Escalate with specific questions. |
| Implementation reveals scope is 2x+ larger than planned | Escalate with revised scope proposal. |
| Tests fail and root cause is unclear after 2 attempts | Escalate with diagnostic context. |
| Change requires access/permissions the agent doesn't have | Escalate with specific access request. |
| Agent discovers a security vulnerability during work | Escalate immediately with severity assessment. |
| Conflicting requirements between AGENTS.md and task description | Escalate with the conflict described. |

### Escalation Format

```markdown
## Escalation: [Brief Title]

**Risk Level**: [Low/Medium/High]
**Trigger**: [Why escalation is needed]

### Context
[What task was being performed, what's been done so far]

### Problem
[Specific issue requiring human judgment]

### Options Considered
1. [Option A — pros/cons]
2. [Option B — pros/cons]

### Recommendation
[Agent's suggested course of action, if any]

### Files Affected
- [list of files modified or examined]

### How to Resume
[What the human should do to unblock the agent]
```

---

## Escalation Policy Template

Teams should customize the escalation policy for their context. Copy and adapt:

```markdown
<!-- CUSTOMIZE: Adapt this escalation policy for your team -->

## Team Escalation Policy

### Escalation Channels
- **Primary**: [e.g., Slack #engineering-escalations, GitHub issue, email]
- **Urgent (P0)**: [e.g., PagerDuty, phone tree]

### Response Time Expectations
- **Low risk escalations**: [e.g., next business day]
- **Medium risk escalations**: [e.g., within 4 hours]
- **High risk escalations**: [e.g., within 1 hour]

### Approvers
- **Code changes**: [e.g., any team member with write access]
- **Infrastructure changes**: [e.g., SRE team lead]
- **Security changes**: [e.g., security team + engineering lead]
- **Database migrations**: [e.g., DBA + service owner]

### After-Hours Policy
- [e.g., High risk changes are not merged outside business hours unless P0]
```

---

## Risk Override

Teams may override the default risk classification for specific areas of their codebase by documenting overrides in their `AGENTS.md`:

```markdown
<!-- Example risk overrides in AGENTS.md -->

## Risk Overrides

| Path/Area | Default Risk | Override Risk | Reason |
|---|---|---|---|
| `docs/**` | Low | Low | Documentation-only, no behavioral impact |
| `src/payments/**` | Medium | High | Financial calculations, regulatory scope |
| `tests/**` | Low | Low | Test-only changes |
| `src/auth/**` | Medium | High | Security-critical authentication code |
| `infrastructure/**` | Medium | High | Production infrastructure |
```

---

## Cross-References

- **Lifecycle stages that use this model**: [docs/workflow.md](workflow.md) (all stages reference risk level)
- **Controls by validation stage**: [docs/workflow.md — Stage 4](workflow.md#stage-4-validate)
- **Plan template (required for Medium+)**: [templates/plan-template.md](../templates/plan-template.md)
- **Review template**: [templates/review-template.md](../templates/review-template.md)
