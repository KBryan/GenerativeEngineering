# Agentic Engineering Workflow Framework

> **Version**: v2.0
> **Date**: 2026-04-06

A modular, vendor-neutral standard for how autonomous coding agents should operate within software engineering teams. Drop the parts you need into any project, with any capable agent, in any language.

---

## Design Principles

| Principle | What It Means |
|---|---|
| **Vendor-neutral** | Core docs never reference a specific agent tool. Vendor specifics live in `adapters/`. |
| **Modular** | Every document is independent. Adopt one file or all fifteen. |
| **Incremental adoption** | Start with a 5-minute setup (Tier 1) and grow into advanced orchestration (Tier 3). |
| **Any language, any agent** | The lifecycle and risk model work whether you ship Python, Rust, TypeScript, or COBOL. |
| **Actionable over aspirational** | Every section tells you what to *do*, not what to *think about*. |
| **Templates are real files** | Copy-paste ready, with `<!-- CUSTOMIZE: -->` markers where you fill in your specifics. |

---

## Quick Start (5 Minutes — Tier 1)

```bash
# 1. Copy the agent config template into your repo
cp templates/AGENTS.md your-repo/AGENTS.md

# 2. Fill in the CUSTOMIZE sections
$EDITOR your-repo/AGENTS.md

# 3. Read the 7-stage lifecycle (10 min read)
open docs/workflow.md

# Done. Your agent now has project context and a work standard.
```

That's it for minimum viable adoption. Your agent reads `AGENTS.md` for project context and follows the lifecycle in `workflow.md`.

---

## Framework Structure

```
agentic-workflow/
├── README.md                          ← You are here
├── docs/
│   ├── REVIEW.md                      ← V1.0 review & migration guide
│   ├── workflow.md                    ← Core 7-stage lifecycle standard
│   ├── risk-model.md                  ← Risk classification & controls
│   ├── bootstrap-protocol.md          ← Repository bootstrap guide
│   ├── cross-tool-standard.md         ← Cross-tool skill sharing
│   └── repository-structure.md        ← Standard repo structure
├── templates/
│   ├── AGENTS.md                      ← Project config for agents
│   ├── SKILL.md                       ← Canonical skill template
│   ├── plan-template.md               ← Task plan template
│   ├── review-template.md             ← Review checklist template
│   ├── validation-readme.md           ← Validation entrypoints
│   ├── bootstrap-prompt.md            ← Universal bootstrap prompt
│   └── Justfile                       ← Lifecycle entry points
└── adapters/
    └── README.md                      ← How to create tool adapters
```

---

## Adoption Tiers

### Tier 1: Minimum Viable (5 minutes)

| What | Why |
|---|---|
| Copy `templates/AGENTS.md` into your repo | Gives the agent project context, coding rules, and architecture overview |
| Read `docs/workflow.md` | Understand the 7-stage lifecycle your agent should follow |

**Result**: Agent has project awareness and a structured work process.

### Tier 2: Standard (30 minutes)

| What | Why |
|---|---|
| Everything in Tier 1 | Foundation |
| Copy `templates/plan-template.md` | Structured task planning |
| Copy `templates/review-template.md` | Consistent review checklists |
| Copy `templates/validation-readme.md` | Documented validation commands |
| Read `docs/risk-model.md` | Calibrate controls to change risk |
| Copy `templates/Justfile` | One-command lifecycle actions |

**Result**: Full lifecycle with validation, planning, and risk-appropriate controls.

### Tier 3: Advanced (2 hours)

| What | Why |
|---|---|
| Everything in Tier 2 | Foundation |
| Run bootstrap protocol (`docs/bootstrap-protocol.md`) | Full repo audit and setup |
| Adopt skill standard (`docs/cross-tool-standard.md`) | Reusable, portable agent skills |
| Align repo structure (`docs/repository-structure.md`) | Canonical file organization |
| Create tool adapter (`adapters/README.md`) | Map to your specific agent tool |

**Result**: Production-grade agentic engineering with cross-tool portability.

---

## Document Index

| Document | Purpose | Adoption Tier |
|---|---|---|
| [docs/workflow.md](docs/workflow.md) | Core 7-stage lifecycle and agent execution rules | Tier 1 |
| [docs/risk-model.md](docs/risk-model.md) | Risk classification, controls matrix, escalation policy | Tier 2 |
| [docs/bootstrap-protocol.md](docs/bootstrap-protocol.md) | Repository audit and bootstrap procedure | Tier 3 |
| [docs/cross-tool-standard.md](docs/cross-tool-standard.md) | Cross-tool skill sharing standard | Tier 3 |
| [docs/repository-structure.md](docs/repository-structure.md) | Canonical repository structure | Tier 3 |
| [docs/REVIEW.md](docs/REVIEW.md) | V1.0 analysis and migration guide | Reference |
| [templates/AGENTS.md](templates/AGENTS.md) | Project configuration for agents | Tier 1 |
| [templates/SKILL.md](templates/SKILL.md) | Skill definition template | Tier 3 |
| [templates/plan-template.md](templates/plan-template.md) | Task planning template | Tier 2 |
| [templates/review-template.md](templates/review-template.md) | Review checklist template | Tier 2 |
| [templates/validation-readme.md](templates/validation-readme.md) | Validation command reference | Tier 2 |
| [templates/bootstrap-prompt.md](templates/bootstrap-prompt.md) | Universal bootstrap prompt | Tier 3 |
| [templates/Justfile](templates/Justfile) | Lifecycle automation commands | Tier 2 |
| [adapters/README.md](adapters/README.md) | Tool adapter creation guide | Tier 3 |

---

## Contributing

This framework is designed to evolve. To propose changes:

1. Open an issue describing the problem and proposed solution
2. Reference the specific document(s) affected
3. Maintain the design principles above in any modification
4. Update version headers when making breaking changes

---

## License

This framework is released for use by any engineering team. Adapt freely.
