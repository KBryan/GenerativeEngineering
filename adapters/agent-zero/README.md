# Agent Zero Adapter

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: Mapping the universal agentic engineering framework to Agent Zero conventions

---

## Overview

This adapter maps the vendor-neutral framework files to Agent Zero's native conventions. Agent Zero is a hierarchical autonomous agent framework that:

- **Reads `AGENTS.md` natively** from the project root as its primary project configuration.
- **Loads skills from `usr/skills/`** — each skill is a directory containing a `SKILL.md` file.
- **Executes `Justfile` commands directly** via its terminal tool.

This means the mapping for Agent Zero is minimal — the universal files are already close to Agent Zero's native format.

For the full cross-tool philosophy, see [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md).

---

## Prerequisites

- A repository that has adopted the agentic engineering workflow framework
- Agent Zero running with the project active (via `.a0proj/project.json`)
- Bash available (for the `generate.sh` script)

---

## Setup Options

### Option 1: Generate (Recommended)

Run the script to copy skill files into Agent Zero's expected skill directory:

```bash
bash adapters/agent-zero/generate.sh
```

This creates `usr/skills/{name}/SKILL.md` for each skill in the universal `skills/` directory.

### Option 2: Symlink

Symlink individual skills to avoid duplication:

```bash
mkdir -p usr/skills

for skill_dir in skills/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "usr/skills/$skill_name"
        ln -s "$(pwd)/$skill_dir/SKILL.md" "usr/skills/$skill_name/SKILL.md"
    fi
done
```

> **Note**: Agent Zero's skill discovery scans `usr/skills/*/SKILL.md`, so the directory structure must match.

### Option 3: Manual Copy

Copy skill directories manually:

```bash
mkdir -p usr/skills/add-api-endpoint
cp skills/add-api-endpoint/SKILL.md usr/skills/add-api-endpoint/SKILL.md

mkdir -p usr/skills/create-migration
cp skills/create-migration/SKILL.md usr/skills/create-migration/SKILL.md

mkdir -p usr/skills/setup-linting
cp skills/setup-linting/SKILL.md usr/skills/setup-linting/SKILL.md
# ... add more skills as needed
```

---

## Key Mapping Notes

| Universal File | Agent Zero File | Notes |
|---|---|---|
| `AGENTS.md` | `AGENTS.md` (read from project root) | **No mapping needed** — Agent Zero reads this natively |
| `skills/*/SKILL.md` | `usr/skills/*/SKILL.md` | Copied or symlinked into Agent Zero's skill directory |
| `Justfile` | `Justfile` (run directly) | **No mapping needed** — Agent Zero executes `just` via terminal |
| `templates/*.md` | (read directly) | Agent Zero can read templates from their universal location |
| `docs/*.md` | (read directly) | Agent Zero reads documentation from its universal location |

---

## Verification

After setup, verify Agent Zero can discover the skills:

```bash
# Check that skills are in Agent Zero's directory
ls -la usr/skills/

# In an Agent Zero session, mention a skill name or task that should trigger it
# The agent will auto-discover and load the relevant SKILL.md
```

Expected result: Agent Zero loads `AGENTS.md` as project context and discovers skills in `usr/skills/`.

---

## Maintenance

### Adding a New Skill

1. Create `skills/new-skill-name/SKILL.md` following the [SKILL.md template](../../templates/SKILL.md)
2. Re-run `bash adapters/agent-zero/generate.sh` (or manually copy the new skill)
3. Verify with `ls usr/skills/new-skill-name/SKILL.md`

### Updating AGENTS.md

Agent Zero reads `AGENTS.md` directly from the project root. Just edit it — no adapter step needed.

### Removing a Skill

1. Delete the universal skill directory: `rm -rf skills/old-skill/`
2. Remove from Agent Zero's directory: `rm -rf usr/skills/old-skill/`
3. Or simply re-run `generate.sh` which only copies current skills

---

## Cross-Tool Compatibility

Because Agent Zero reads `AGENTS.md` natively, the universal file IS the Agent Zero file. The only mapping needed is for skills, which go from `skills/*/SKILL.md` to `usr/skills/*/SKILL.md`.

Other agent tools (Claude Code, Cursor, OpenCode) use different conventions. The universal files remain the single source of truth.

See [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md) for the full cross-tool sharing standard.
