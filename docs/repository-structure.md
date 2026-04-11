# Standard Repository Structure

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: One canonical directory layout for agent-ready repositories

---

## Overview

This document defines a single, canonical repository structure that any agent can navigate. It is not prescriptive about language or framework — it defines WHERE agent-relevant files live so that agents (and humans) always know where to look.

Adopt the parts that apply to your project. Ignore what doesn't.

---

## Universal Structure

```
your-repo/
├── AGENTS.md                    # Agent project configuration (required)
├── README.md                    # Human-facing project overview
├── Justfile                     # Lifecycle automation entry points (optional)
│
├── src/                         # Application source code
│   └── ...                      # Language/framework-specific layout
│
├── tests/                       # Test suites
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── e2e/                     # End-to-end tests (if applicable)
│
├── docs/                        # Project documentation
│   ├── architecture.md          # Architecture decisions and diagrams
│   ├── api.md                   # API documentation (or OpenAPI spec)
│   └── runbook.md               # Operational procedures
│
├── scripts/                     # Build, deploy, and utility scripts
│   └── ...                      
│
├── skills/                      # Agent skill definitions (optional, Tier 3+)
│   ├── add-api-endpoint/        
│   │   └── SKILL.md             
│   └── create-migration/        
│       └── SKILL.md             
│
├── .agent/                      # Agent working directory (optional)
│   ├── plans/                   # Task plans created during work
│   ├── reviews/                 # Review checklists
│   └── escalations/             # Escalation summaries
│
└── <tool-specific>/             # Tool adapter files (optional)
    └── ...                      # e.g., .claude/, .cursor/, .opencode/
```

---

## Directory Reference

### Required

| Path | Purpose | When to Add |
|---|---|---|
| `AGENTS.md` | Agent project configuration: what this project is, how to build/test/lint, coding conventions, risk areas | Always — this is the minimum viable bootstrap |
| `README.md` | Human-facing project overview | Should already exist in any project |

### Standard (Recommended)

| Path | Purpose | When to Add |
|---|---|---|
| `src/` | Application source code | Standard for most projects; adapt name to convention (`lib/`, `app/`, `pkg/`, etc.) |
| `tests/` | Test suites organized by type | When you have tests (you should always have tests) |
| `docs/` | Project documentation | When documentation exists beyond README |
| `scripts/` | Build, deploy, and utility scripts | When you have automation scripts |
| `Justfile` | Lifecycle entry points for common commands | Tier 2+ adoption; provides `just test`, `just lint`, etc. |

### Optional (Tier 3+)

| Path | Purpose | When to Add |
|---|---|---|
| `skills/` | Reusable agent skill definitions in SKILL.md format | When you have repeatable agent tasks worth encoding |
| `.agent/` | Agent working directory for plans, reviews, escalations | When you want persistent agent work artifacts |
| `<tool-specific>/` | Tool adapter files (`.claude/`, `.cursor/`, etc.) | When using a specific agent tool that requires its own config directory |

---

## File Reference

### AGENTS.md

The single most important file for agent operation. Contains everything an agent needs to understand the project and work effectively.

**Template**: [templates/AGENTS.md](../templates/AGENTS.md)

**Minimum content**:
- Project name and purpose
- Primary language and framework
- How to install dependencies
- How to run tests, linter, and build
- Key directories and their purpose
- Risk areas

### Justfile

Exposes lifecycle commands as simple targets. Agents use this to discover and run standard operations.

**Template**: [templates/Justfile](../templates/Justfile)

**Standard targets**:
- `just validate` — run all checks (lint + test + typecheck + build)
- `just test` — run test suite
- `just lint` — run linter
- `just plan` — create a new task plan from template
- `just review` — create a new review checklist from template

### skills/*/SKILL.md

Each skill lives in its own directory under `skills/`. The directory name is the skill identifier.

**Template**: [templates/SKILL.md](../templates/SKILL.md)

**Structure**:
```
skills/
├── add-api-endpoint/
│   ├── SKILL.md              # Skill definition (required)
│   └── examples/             # Example inputs/outputs (optional)
├── create-migration/
│   └── SKILL.md
└── README.md                 # Skill index (optional)
```

### .agent/ Directory

Working directory where agents store artifacts created during task execution. This directory can be `.gitignore`d or committed depending on team preference.

```
.agent/
├── plans/
│   └── 2026-04-06-fix-login-timeout.md
├── reviews/
│   └── 2026-04-06-fix-login-timeout-review.md
└── escalations/
    └── 2026-04-06-auth-refactor-escalation.md
```

---

## Adapting to Your Project

### Language-Specific Source Directories

The `src/` convention is flexible. Use whatever your ecosystem expects:

| Language | Common Source Dir | Notes |
|---|---|---|
| Python | `src/` or package name at root | Document in AGENTS.md |
| TypeScript/JavaScript | `src/` or `lib/` | Document in AGENTS.md |
| Go | Root or `cmd/`, `pkg/`, `internal/` | Standard Go layout |
| Rust | `src/` | Cargo convention |
| Java/Kotlin | `src/main/java/`, `src/main/kotlin/` | Maven/Gradle convention |
| Ruby | `lib/` | Gem convention |

**Rule**: It doesn't matter which convention you use. What matters is that it's documented in `AGENTS.md`.

### Monorepo Structure

For monorepos, each service or package gets its own `AGENTS.md`:

```
monorepo/
├── AGENTS.md                    # Root-level overview and shared conventions
├── services/
│   ├── auth/
│   │   ├── AGENTS.md            # Auth service-specific config
│   │   ├── src/
│   │   └── tests/
│   └── api/
│       ├── AGENTS.md            # API service-specific config
│       ├── src/
│       └── tests/
├── packages/
│   └── shared-lib/
│       ├── AGENTS.md
│       └── src/
└── skills/                      # Shared skills across services
```

### Minimal Structure

The absolute minimum for agent readiness:

```
your-repo/
├── AGENTS.md                    # Tell the agent what this is and how to validate
└── ... (your existing code)
```

Everything else is additive improvement.

---

## What NOT to Put in the Repository

| Item | Why Not | Where Instead |
|---|---|---|
| API keys, tokens, credentials | Security risk | Environment variables, secrets manager |
| Agent tool binaries | Bloats repo, version-specific | Install via package manager |
| Generated adapter files (if using Generate strategy) | Build artifacts | Generate in CI or add to `.gitignore` |
| Large training data or models | Bloats repo | Object storage, DVC, Git LFS |

---

## Cross-References

- **AGENTS.md template**: [templates/AGENTS.md](../templates/AGENTS.md)
- **Skill template**: [templates/SKILL.md](../templates/SKILL.md)
- **Justfile template**: [templates/Justfile](../templates/Justfile)
- **Bootstrap procedure**: [docs/bootstrap-protocol.md](bootstrap-protocol.md)
- **Cross-tool skill sharing**: [docs/cross-tool-standard.md](cross-tool-standard.md)
