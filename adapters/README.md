# Tool Adapter Creation Guide

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: How to create adapters that map the universal workflow framework to specific agent tools

---

## What Is an Adapter?

An adapter is a thin translation layer between this framework's universal standards and a specific agent tool's native conventions. The adapter maps:

- **File names**: `AGENTS.md` → tool-specific config file name
- **File locations**: repository root → tool-specific config directory
- **File format**: markdown → tool's expected format (if different)
- **Skill delivery**: `skills/*/SKILL.md` → tool's skill/command format

Adapters contain ZERO workflow logic. All workflow, risk, and lifecycle content lives in the universal docs. Adapters only handle delivery.

---

## Adapter Directory Structure

```
adapters/
├── README.md                    ← You are here
├── claude-code/
│   ├── README.md                ← Setup instructions for Claude Code
│   ├── mapping.md               ← File mapping table
│   └── generate.sh              ← Optional: script to generate .claude/ files
├── cursor/
│   ├── README.md
│   ├── mapping.md
│   └── generate.sh
├── agent-zero/
│   ├── README.md
│   ├── mapping.md
│   └── generate.sh
└── opencode/
    ├── README.md
    ├── mapping.md
    └── generate.sh
```

---

## Creating a New Adapter

### Step 1: Identify the Tool's Conventions

Answer these questions about your agent tool:

| Question | Your Answer |
|---|---|
| Where does the tool look for project configuration? | e.g., `.claude/CLAUDE.md`, `.cursorrules`, `AGENTS.md` |
| What format does the config file use? | e.g., Markdown, YAML, JSON, plain text |
| Where does the tool look for skills/commands? | e.g., `.claude/commands/`, inline in config, `skills/` |
| Does the tool support symlinks? | Yes / No |
| Does the tool auto-discover files or need explicit registration? | Auto / Explicit |
| Does the tool support multiple config files or just one? | Multiple / Single |

### Step 2: Create the Mapping

Create `adapters/<tool-name>/mapping.md` documenting how universal files map to tool-specific files:

```markdown
# [Tool Name] Adapter — File Mapping

| Universal File | Tool-Specific File | Notes |
|---|---|---|
| `AGENTS.md` | `.tool/config.md` | Main project configuration |
| `skills/*/SKILL.md` | `.tool/commands/*.md` | One file per skill |
| `templates/plan-template.md` | (no mapping needed) | Agent reads directly |
| `templates/review-template.md` | (no mapping needed) | Agent reads directly |
| `Justfile` | (no mapping needed) | Agent runs directly |
```

### Step 3: Choose an Adapter Strategy

See [docs/cross-tool-standard.md](../docs/cross-tool-standard.md) for detailed strategy comparison.

| Strategy | When to Use | Implementation |
|---|---|---|
| **Mirror** | Getting started, few files | Copy files manually |
| **Symlink** | Tool supports symlinks, no format change needed | `ln -s` commands |
| **Generate** | Multiple tools, many skills, CI/CD integration | Script that reads universal → writes tool-specific |

### Step 4: Implement the Adapter

Create `adapters/<tool-name>/generate.sh` (or equivalent):

```bash
#!/bin/bash
# Adapter: [Tool Name]
# Generates tool-specific configuration from universal framework files.
#
# Usage: bash adapters/<tool-name>/generate.sh

set -euo pipefail

TOOL_DIR=".tool"  # Replace with tool's config directory

# Create tool config directory
mkdir -p "$TOOL_DIR"
mkdir -p "$TOOL_DIR/commands"

# Map AGENTS.md → tool config
echo "Mapping AGENTS.md → $TOOL_DIR/config.md"
cp AGENTS.md "$TOOL_DIR/config.md"

# Map skills → tool commands
for skill_dir in skills/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        echo "Mapping skill: $skill_name"
        cp "$skill_dir/SKILL.md" "$TOOL_DIR/commands/$skill_name.md"
    fi
done

echo "Adapter generation complete."
```

### Step 5: Document the Setup

Create `adapters/<tool-name>/README.md`:

```markdown
# [Tool Name] Adapter

## Prerequisites
- [Tool Name] installed and configured
- Repository bootstrapped with AGENTS.md (see docs/bootstrap-protocol.md)

## Setup

### Option A: Generate (Recommended)
bash adapters/<tool-name>/generate.sh

### Option B: Symlink
ln -s AGENTS.md .tool/config.md
for d in skills/*/; do ln -s "../../$d/SKILL.md" ".tool/commands/$(basename $d).md"; done

### Option C: Manual Copy
cp AGENTS.md .tool/config.md

## Verification
1. Open the project in [Tool Name]
2. Verify the agent can read project configuration
3. Verify the agent can discover and execute skills

## Maintenance
Re-run generate.sh after:
- Updating AGENTS.md
- Adding or modifying skills
- Changing framework version
```

---

## Example Adapters

### Claude Code

| Universal | Claude Code | Notes |
|---|---|---|
| `AGENTS.md` | `.claude/CLAUDE.md` | Claude reads CLAUDE.md for project context |
| `skills/*/SKILL.md` | `.claude/commands/*.md` | Slash commands in Claude Code |
| `Justfile` | (direct) | Claude can run `just` commands directly |

```bash
# Quick setup for Claude Code
mkdir -p .claude/commands
cp AGENTS.md .claude/CLAUDE.md
for d in skills/*/; do
    [ -f "$d/SKILL.md" ] && cp "$d/SKILL.md" ".claude/commands/$(basename $d).md"
done
```

### Cursor

| Universal | Cursor | Notes |
|---|---|---|
| `AGENTS.md` | `.cursorrules` | Cursor reads .cursorrules for project context |
| `skills/*/SKILL.md` | Appended to `.cursorrules` | Cursor uses a single config file |
| `Justfile` | (direct) | Cursor can run terminal commands |

```bash
# Quick setup for Cursor
cp AGENTS.md .cursorrules
# Append skills to .cursorrules
for d in skills/*/; do
    if [ -f "$d/SKILL.md" ]; then
        echo -e "\n---\n" >> .cursorrules
        cat "$d/SKILL.md" >> .cursorrules
    fi
done
```

### Agent Zero

| Universal | Agent Zero | Notes |
|---|---|---|
| `AGENTS.md` | `AGENTS.md` (direct) | Agent Zero reads AGENTS.md natively |
| `skills/*/SKILL.md` | `usr/skills/*/SKILL.md` | Agent Zero's skill discovery path |
| `Justfile` | (direct) | Agent Zero can run terminal commands |

```bash
# Quick setup for Agent Zero
# AGENTS.md works directly — no mapping needed
# Skills need to be in usr/skills/
mkdir -p usr/skills
for d in skills/*/; do
    skill_name=$(basename "$d")
    mkdir -p "usr/skills/$skill_name"
    cp "$d/SKILL.md" "usr/skills/$skill_name/SKILL.md"
done
```

### OpenCode

| Universal | OpenCode | Notes |
|---|---|---|
| `AGENTS.md` | `AGENTS.md` or `.opencode/config.md` | OpenCode reads from project root |
| `skills/*/SKILL.md` | `.opencode/skills/*.md` | Skill discovery path |
| `Justfile` | (direct) | OpenCode can run terminal commands |

```bash
# Quick setup for OpenCode
mkdir -p .opencode/skills
cp AGENTS.md .opencode/config.md
for d in skills/*/; do
    [ -f "$d/SKILL.md" ] && cp "$d/SKILL.md" ".opencode/skills/$(basename $d).md"
done
```

---

## Adding Support for a New Tool

If your agent tool isn't listed above:

1. Create `adapters/<tool-name>/` directory
2. Follow Steps 1-5 above
3. Test with a real repository
4. Consider contributing your adapter back to the framework

The key insight: the universal files contain all the content. Your adapter only needs to put that content where your tool expects to find it.

---

## Cross-References

- **Cross-tool standard (detailed theory)**: [docs/cross-tool-standard.md](../docs/cross-tool-standard.md)
- **Skill template**: [templates/SKILL.md](../templates/SKILL.md)
- **AGENTS.md template**: [templates/AGENTS.md](../templates/AGENTS.md)
- **Repository structure**: [docs/repository-structure.md](../docs/repository-structure.md)
