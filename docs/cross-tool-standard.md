# Cross-Tool Skill Sharing Standard

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: How to write agent skills once and use them across multiple agent tools

---

## Core Principle

**Write once, wrap many times.**

Agent skills encode repeatable engineering tasks — "add an API endpoint", "create a database migration", "set up a new microservice". The logic of these tasks is universal. Only the delivery mechanism (which agent reads the skill, what file format it expects) varies.

This standard defines how to author skills so they work with any capable agent tool, and how to create thin adapters for specific tools.

---

## The 3-Layer Model

```
┌─────────────────────────────────────┐
│  Layer 3: Repository Overlays       │  Per-repo customization
│  (project-specific overrides)       │  of shared skills
├─────────────────────────────────────┤
│  Layer 2: Tool Adapters             │  Tool-specific wrappers
│  (claude, opencode, agent-zero...)  │  that read shared skills
├─────────────────────────────────────┤
│  Layer 1: Shared Library            │  Universal skill definitions
│  (skills/, SKILL.md format)         │  tool-agnostic
└─────────────────────────────────────┘
```

### Layer 1: Shared Library

The canonical skill definitions. Written in the universal [SKILL.md format](../templates/SKILL.md). These contain:
- What the skill does
- When to use it
- Step-by-step instructions
- Inputs, outputs, and validation criteria
- Example invocations

**Location**: `skills/` directory at repo root or in a shared skills repository.

**Rule**: Shared skills MUST NOT reference any specific agent tool. They describe WHAT to do, not HOW a specific tool should do it.

### Layer 2: Tool Adapters

Thin wrappers that translate shared skills into a specific tool's native format. Each adapter:
- Reads from the shared library
- Produces files in the tool's expected format and location
- Maps skill concepts to tool-specific constructs

**Location**: `adapters/<tool-name>/` directory.

**Rule**: Adapters contain ONLY tool-specific mapping logic. All skill content lives in Layer 1.

See [adapters/README.md](../adapters/README.md) for how to build adapters.

### Layer 3: Repository Overlays

Project-specific customizations layered on top of shared skills. These handle:
- Project-specific file paths and naming conventions
- Custom validation commands
- Technology-specific details (e.g., "our API endpoints use FastAPI, not Flask")

**Location**: Inline in the project's `AGENTS.md` or in a `skills/overrides/` directory.

**Rule**: Overlays extend shared skills; they do not replace them.

---

## The 4 Universal Contracts

Every skill, regardless of which agent tool will execute it, must define these four contracts:

### 1. Capability Contract

What the skill does and when to apply it.

```markdown
## Capability
- **Name**: [unique identifier, e.g., `add-api-endpoint`]
- **Description**: [one sentence — what this skill produces]
- **Trigger**: [when an agent should use this skill]
- **Prerequisites**: [what must exist before this skill can run]
- **Produces**: [what artifacts this skill creates or modifies]
```

### 2. Execution Contract

The step-by-step procedure.

```markdown
## Execution Steps
1. [First step — specific, actionable]
2. [Second step — with expected output]
3. ...

## Decision Points
- If [condition], then [branch A]
- If [condition], then [branch B]
```

### 3. Prompt Contract

How to instruct the agent. This is the natural language instruction set.

```markdown
## Agent Instructions
[Clear, imperative instructions the agent follows.
 Written as if speaking directly to the agent.
 No tool-specific references.]
```

### 4. Workflow Contract

How this skill integrates with the [lifecycle](workflow.md).

```markdown
## Workflow Integration
- **Risk Level**: [default risk classification for this skill]
- **Lifecycle Stages**: [which stages this skill covers or modifies]
- **Validation**: [specific validation steps for this skill's output]
- **Review Notes**: [what reviewers should check for this skill's output]
```

---

## What Must Be Universal

These elements are defined in the shared library (Layer 1) and MUST NOT vary by tool:

| Element | Reason |
|---|---|
| Skill name and description | Consistent identification across tools |
| Execution steps | The engineering task is the same regardless of tool |
| Acceptance criteria | Quality standards don't change by tool |
| Risk classification | Risk is inherent to the task, not the tool |
| Validation commands | Tests and linters are tool-agnostic |

## What Stays Tool-Specific

These elements live in adapters (Layer 2) and vary by tool:

| Element | Why It Varies |
|---|---|
| File format | Tools expect different formats (`.md`, `.yaml`, `.json`, custom) |
| File location | Tools look in different directories (`.claude/`, `.cursor/`, `skills/`) |
| Invocation method | How the agent discovers and activates the skill |
| Context injection | How skill content enters the agent's context window |
| Output format | How the agent reports skill completion |

---

## Adapter Strategies

Three strategies for creating tool adapters, with different tradeoff profiles:

### Strategy 1: Mirror

**How**: Copy shared skill content into the tool's expected format and location.

**Example**: Copy `skills/add-api-endpoint/SKILL.md` → `.claude/commands/add-api-endpoint.md`

| Aspect | Assessment |
|---|---|
| **Simplicity** | High — just file copying with minor reformatting |
| **Maintenance** | Medium — must re-copy when shared skill changes |
| **Fidelity** | High — full skill content available to the tool |
| **Best for** | Small teams, few skills, infrequent changes |

### Strategy 2: Symlink

**How**: Create symbolic links from the tool's expected location to the shared library.

**Example**: `ln -s ../../skills/add-api-endpoint/SKILL.md .claude/commands/add-api-endpoint.md`

| Aspect | Assessment |
|---|---|
| **Simplicity** | High — one-time setup |
| **Maintenance** | Low — changes propagate automatically |
| **Fidelity** | High — always reads the current shared version |
| **Best for** | Teams where the tool supports symlinks and the format is compatible |
| **Caveat** | Not all tools follow symlinks; doesn't work if format transformation is needed |

### Strategy 3: Generate

**How**: Run a script that reads shared skills and generates tool-specific files.

**Example**: `python adapters/claude/generate.py` reads `skills/*/SKILL.md` and produces `.claude/commands/*.md`

| Aspect | Assessment |
|---|---|
| **Simplicity** | Low — requires writing and maintaining a generator script |
| **Maintenance** | Low after setup — regenerate on change |
| **Fidelity** | Highest — can transform format, inject tool-specific instructions, merge overlays |
| **Best for** | Large teams, many skills, multiple tools, CI/CD integration |

### Strategy Comparison

| Criteria | Mirror | Symlink | Generate |
|---|---|---|---|
| Setup effort | Low | Low | Medium |
| Ongoing maintenance | Medium | Low | Low |
| Format flexibility | Low | None | High |
| CI/CD friendly | Yes | Depends | Yes |
| Multi-tool support | Manual per tool | Manual per tool | Scriptable |
| Recommended for | Getting started | Single-tool teams | Production teams |

---

## Example Mapping Table

How a shared skill maps to different agent tools:

| Shared Skill | Claude Code | Cursor | Agent Zero | OpenCode |
|---|---|---|---|---|
| `skills/add-api-endpoint/SKILL.md` | `.claude/commands/add-api-endpoint.md` | `.cursorrules` (append) | `usr/skills/add-api-endpoint/SKILL.md` | `.opencode/skills/add-api-endpoint.md` |
| `skills/create-migration/SKILL.md` | `.claude/commands/create-migration.md` | `.cursorrules` (append) | `usr/skills/create-migration/SKILL.md` | `.opencode/skills/create-migration.md` |
| `AGENTS.md` (project config) | `.claude/CLAUDE.md` | `.cursorrules` | `AGENTS.md` | `.opencode/config.md` |
| Risk overrides | In `CLAUDE.md` | In `.cursorrules` | In `AGENTS.md` | In `config.md` |

---

## Creating a New Shared Skill

1. Copy [templates/SKILL.md](../templates/SKILL.md)
2. Fill in all four contracts (Capability, Execution, Prompt, Workflow)
3. Place in `skills/<skill-name>/SKILL.md`
4. Test with at least one agent tool
5. Create adapter mappings for your team's tools
6. Document in the skill index (if your team maintains one)

---

## Cross-References

- **Skill template**: [templates/SKILL.md](../templates/SKILL.md)
- **Adapter guide**: [adapters/README.md](../adapters/README.md)
- **Core lifecycle**: [docs/workflow.md](workflow.md)
- **Repository structure**: [docs/repository-structure.md](repository-structure.md)
