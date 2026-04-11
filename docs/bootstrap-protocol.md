# Repository Bootstrap Protocol

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: Universal — one canonical bootstrap process for any repository and any agent

---

## Overview

Bootstrapping is the process of auditing a repository and configuring it so that an autonomous agent can work effectively. It happens once per repository (with periodic refreshes) and produces the artifacts an agent needs: project configuration, validation commands, risk overrides, and architectural context.

This document consolidates the bootstrap process into a single, authoritative reference.

---

## When to Bootstrap

| Situation | Action |
|---|---|
| Agent encounters a repository for the first time | Full bootstrap |
| Major architectural change (new framework, language, or service) | Re-bootstrap affected sections |
| New team member onboarding an agent | Verify existing bootstrap is current |
| Quarterly review | Audit bootstrap artifacts for drift |

---

## Phase 1: Repository Audit

Before configuring anything, understand what exists. Run through this checklist:

### Audit Checklist

```markdown
## Repository Audit Checklist

### Project Basics
- [ ] Primary language(s) and version(s)
- [ ] Package manager and dependency file location
- [ ] Build system (make, gradle, cargo, npm scripts, etc.)
- [ ] Monorepo or single-project structure

### Existing Configuration
- [ ] Does an agent config file already exist? (AGENTS.md, CLAUDE.md, .cursorrules, etc.)
- [ ] CI/CD pipeline present? (GitHub Actions, GitLab CI, Jenkins, etc.)
- [ ] Linter configuration? (.eslintrc, .flake8, rustfmt.toml, etc.)
- [ ] Type checking configured? (tsconfig.json, mypy.ini, etc.)
- [ ] Formatter configured? (prettier, black, gofmt, etc.)

### Testing
- [ ] Test framework identified (pytest, jest, go test, etc.)
- [ ] Test command documented or discoverable
- [ ] Current test pass rate (run tests, record baseline)
- [ ] Test coverage tool configured?

### Architecture
- [ ] Service boundaries identified (if multi-service)
- [ ] Database(s) and ORM/query layer identified
- [ ] External API integrations cataloged
- [ ] Authentication/authorization mechanism identified
- [ ] Key environment variables documented

### Documentation
- [ ] README exists and is current
- [ ] API documentation exists (OpenAPI, GraphQL schema, etc.)
- [ ] Architecture decision records (ADRs) present?
- [ ] Deployment documentation present?

### Risk Areas
- [ ] Security-sensitive code paths identified (auth, payments, PII)
- [ ] Performance-critical paths identified
- [ ] Areas with poor test coverage identified
- [ ] Known technical debt documented
```

---

## Phase 2: Maturity Classification

Based on the audit, classify the repository's agent-readiness maturity:

| Level | Name | Description | What Exists | What to Add |
|---|---|---|---|---|
| 0 | **Bare** | No agent configuration at all | Source code only | Everything |
| 1 | **Base** | Minimum viable agent support | `AGENTS.md` with project overview | Validation commands, risk areas |
| 2 | **Better** | Structured validation | Base + documented test/lint/build commands | Plan templates, review checklists |
| 3 | **More** | Full lifecycle support | Better + templates + risk model | Cross-tool skills, bootstrap prompt |
| 4 | **Custom** | Team-specific optimizations | More + custom risk overrides + team escalation | Tool adapters, orchestration |
| 5 | **Orchestrator** | Multi-agent coordination | Custom + agent routing + task decomposition | Monitoring, automated triage |

### Decision Rules

- **Start at Level 1.** Always. Even 5 minutes of setup dramatically improves agent performance.
- **Advance when the current level creates friction.** Don't over-engineer upfront.
- **Level 2 is the sweet spot for most teams.** Covers 80% of agent failure modes.
- **Level 4+ is for teams running agents in production CI/CD pipelines.**

---

## Phase 3: Bootstrap Procedure

Follow these steps in order. Each step builds on the previous.

### Step 1: Create AGENTS.md (Required — Level 1)

Copy [templates/AGENTS.md](../templates/AGENTS.md) into the repository root and fill in the `<!-- CUSTOMIZE: -->` sections.

**Minimum viable content:**
- Repository name and purpose (1-2 sentences)
- Primary language and framework
- How to install dependencies
- How to run tests
- How to run the linter
- Key directories and their purpose

**Time**: 5-10 minutes

### Step 2: Document Validation Commands (Required — Level 2)

Copy [templates/validation-readme.md](../templates/validation-readme.md) and fill in the actual commands for your project.

**Minimum viable content:**
- Lint command
- Test command
- Build command (if applicable)
- Type check command (if applicable)

**Time**: 5 minutes

### Step 3: Configure Risk Overrides (Recommended — Level 2)

Add a Risk Overrides section to your `AGENTS.md` identifying paths that need elevated or reduced risk treatment compared to the defaults in [docs/risk-model.md](risk-model.md).

**Time**: 10 minutes

### Step 4: Add Lifecycle Templates (Recommended — Level 3)

Copy into your repository:
- [templates/plan-template.md](../templates/plan-template.md) — for task planning
- [templates/review-template.md](../templates/review-template.md) — for review checklists

**Time**: 2 minutes (copy only, customize later as needed)

### Step 5: Add Automation Entry Points (Optional — Level 3)

Copy [templates/Justfile](../templates/Justfile) and adapt the commands for your project's build system.

**Time**: 10 minutes

### Step 6: Create Skills (Optional — Level 4)

If your project has repeatable agent tasks (e.g., "add a new API endpoint", "create a migration"), author skills using [templates/SKILL.md](../templates/SKILL.md).

**Time**: 15-30 minutes per skill

### Step 7: Configure Tool Adapter (Optional — Level 4)

If using a specific agent tool, create an adapter following [adapters/README.md](../adapters/README.md).

**Time**: 30-60 minutes

---

## Phase 4: Verification

### Definition of Done

A bootstrap is complete when:

- [ ] `AGENTS.md` exists in the repo root with all required sections filled in
- [ ] An agent can read `AGENTS.md` and understand: what this project is, how to build it, how to test it, and what areas are risky
- [ ] All validation commands documented in `AGENTS.md` or `validation-readme.md` actually work when run
- [ ] Running the test suite produces a known baseline (X pass, Y fail, Z skip)
- [ ] Risk overrides are documented for any security-sensitive or elevated-risk paths

### Verification Commands

```bash
# Verify AGENTS.md exists and is non-empty
test -s AGENTS.md && echo "PASS: AGENTS.md exists" || echo "FAIL: AGENTS.md missing"

# Verify validation commands work (adapt to your project)
make lint    # or: npm run lint, cargo clippy, etc.
make test    # or: npm test, cargo test, pytest, etc.
make build   # or: npm run build, cargo build, etc.

# Record baseline
echo "Baseline recorded: $(date)"
```

---

## Universal Bootstrap Prompt

The following prompt can be pasted into any capable coding agent to initiate a bootstrap. It is also available as a standalone file at [templates/bootstrap-prompt.md](../templates/bootstrap-prompt.md).

```markdown
You are bootstrapping this repository for autonomous agent development.

Follow these steps in order:

1. **Audit**: Examine the repository structure, build system, test framework,
   linter config, and documentation. List what you find.

2. **Classify**: Based on your audit, rate the repository's agent-readiness:
   - Level 0 (Bare): No agent config
   - Level 1 (Base): Has AGENTS.md or equivalent
   - Level 2 (Better): Has validation commands documented
   - Level 3+ (More): Has templates, risk model, skills

3. **Create AGENTS.md**: If none exists (or the existing one is incomplete),
   create or update AGENTS.md in the repo root with:
   - Project name and purpose
   - Primary language/framework
   - Dependency installation command
   - Test command and current baseline
   - Lint command
   - Build command
   - Key directories and their purpose
   - Risk areas (security-sensitive paths, performance-critical code)
   - Coding conventions

4. **Document validation**: Ensure every command in AGENTS.md actually works.
   Run them and record results.

5. **Report**: Summarize what you found, what you created, and what the
   current maturity level is. Recommend next steps.
```

---

## Maintenance

### When to Re-Audit

| Trigger | Scope |
|---|---|
| New major dependency added | Update AGENTS.md dependencies section |
| New service or module added | Update architecture and risk areas |
| CI/CD pipeline changed | Update validation commands |
| Team conventions changed | Update coding rules section |
| Quarterly review | Full audit against checklist |

### Keeping AGENTS.md Current

The most common bootstrap failure is stale configuration. Prevent it by:
1. Including `AGENTS.md` in PR review scope — if a change affects conventions, validation, or architecture, the PR should update `AGENTS.md`
2. Running the bootstrap verification commands in CI
3. Scheduling a quarterly re-audit

---

## Cross-References

- **Core lifecycle**: [docs/workflow.md](workflow.md)
- **Risk model**: [docs/risk-model.md](risk-model.md)
- **AGENTS.md template**: [templates/AGENTS.md](../templates/AGENTS.md)
- **Validation template**: [templates/validation-readme.md](../templates/validation-readme.md)
- **Bootstrap prompt (standalone)**: [templates/bootstrap-prompt.md](../templates/bootstrap-prompt.md)
- **Repository structure**: [docs/repository-structure.md](repository-structure.md)
