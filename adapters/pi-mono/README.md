# pi-mono Adapter

> **Version**: v1.0
> **Date**: 2026-04-12
> **Scope**: Mapping the universal agentic engineering framework to pi-mono conventions

---

## Overview

This adapter maps the universal framework files to [pi-mono](https://github.com/badlogic/pi-mono) conventions. pi-mono is a monorepo tool for building AI agents with these key characteristics:

- **Reads `AGENTS.md` natively** from the project root as its primary project configuration — no mapping needed.
- **Reads `CONTRIBUTING.md` natively** for contribution guidelines — no mapping needed.
- **Uses `packages/` for monorepo packages** — skills map to `packages/{name}/SKILL.md` for per-package skills, or to a shared `skills/` directory.
- **Executes `Justfile` commands directly** via terminal — no mapping needed.
- **Monorepo-aware** — supports both shared and per-package skill organization.

Because pi-mono is monorepo-aware, the adapter offers two skill organization strategies:

1. **Shared skills directory** — all skills in a top-level `skills/` directory that packages reference.
2. **Per-package skills** — skills placed inside `packages/{name}/SKILL.md` scoped to that package.

For the full cross-tool philosophy, see [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md).

---

## Prerequisites

- A repository that has adopted the agentic engineering workflow framework
- pi-mono installed and configured (see https://github.com/badlogic/pi-mono)
- A monorepo structure with `packages/` directory (or willingness to create one)
- Bash available (for the `generate.sh` script)

---

## Setup Options

### Option 1: Generate (Recommended)

Run the script to copy skill files into pi-mono's expected directories:

```bash
bash adapters/pi-mono/generate.sh
```

This creates a shared `skills/` directory with each universal skill copied as `skills/{skill_name}.md`. If the `packages/` directory exists, it also maps per-package skills.

### Option 2: Symlink

Symlink the shared skills directory to avoid duplication:

```bash
mkdir -p skills

for skill_dir in skills/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        ln -s "$(pwd)/$skill_dir/SKILL.md" "skills/$skill_name.md"
    fi
done

# For per-package skills:
for pkg_dir in packages/*/; do
    pkg_name=$(basename "$pkg_dir")
    if [ -f "skills/$pkg_name/SKILL.md" ]; then
        mkdir -p "$pkg_dir"
        ln -s "$(pwd)/skills/$pkg_name/SKILL.md" "packages/$pkg_name/SKILL.md"
    fi
done
```

> **Note**: pi-mono discovers skills in `packages/{name}/SKILL.md` for per-package skills, or `skills/{name}.md` in the shared directory. Choose the strategy that matches your monorepo structure.

### Option 3: Manual Copy

Copy skill files manually to the desired locations:

```bash
# Shared skills
mkdir -p skills
cp skills/add-api-endpoint/SKILL.md skills/add-api-endpoint.md
cp skills/create-migration/SKILL.md skills/create-migration.md
cp skills/setup-linting/SKILL.md skills/setup-linting.md

# Per-package skills (optional)
mkdir -p packages/my-service
cp skills/my-service/SKILL.md packages/my-service/SKILL.md
```

---

## Key Mapping Notes

| Universal File | pi-mono File | Notes |
|---|---|---|
| `AGENTS.md` | `AGENTS.md` (project root) | **No mapping needed** — pi-mo| `AGENTS.md` | `AGENTS.m| `CONTRIBUTING.md` | `CONTRIBUTING.md` (project root) | **No mapping needed** — pi-mono reads this for contribution guidelines |
| `skills/*/SKILL.md` | `skills/{skill_name}.md` (shared) or `packages/{name}/SKILL.md` | Shared or per-package skill organization |
| `Justfile` | `Justfile` (project root) | **No mapping needed** — pi-mono runs `just` commands via terminal |
| `templates/*.md` | (read directly) | pi-mono reads templates from their universal location |
| `docs/*.md` | (read directly) | pi-mono reads documentation from its universal location |

---

## Verification

After setup, verify pi-mono can discover the mapped files:

```bash
# Check that shared skills are in place
ls -la skills/*.md

# Check per-package skills (if applicable)
ls -la packages/*/SKILL.md

# Verify AGENTS.md is readable at project root
test -s AGENTS.md && echo "PASS: AGENTS.md exists" || echo "FAIL: AGENTS.md missing"

# Verify CONTRIBUTING.md (if present)
test -s CONTRIBUTING.md && echo "PASS: CONTRIBUTING.md exists" || echo "NOTE: CONTRIBUTING.md not present"
```

Expected result: pi-mono loads `AGENTS.md` as project context, reads `CONTRIBUTING.md` for guidelines, and discovers skills in `skills/` or `packages/`.

---

## Maintenance

### Adding a New Skill

1. Create `skills/new-skill-name/SKILL.md` following the [SKILL.md template](../../templates/SKILL.md)
2. Re-run `bash adapters/pi-mono/generate.sh` (or manually copy to `skills/new-skill-name.md`)
3. Verify with `ls skills/new-skill-name.md`

### Updating AGENTS.md

pi-mono reads `AGENTS.md` directly from the project root. Just edit it — no adapter step needed.

### Updating CONTRIBUTING.md

pi-mono reads `CONTRIBUTING.md` directly from the project root. Just edit it — no adapter step needed.

### Removing a Skill

1. Delete the universal skill directory: `rm -rf skills/old-skill/`
2. Remove from pi-mono's directory: `rm -f skills/old-skill.md`
3. Or re-run `generate.sh` which only copies current skills

### Switching Between Shared and Per-Package Skills

If your monorepo grows and you want to move a shared skill to a specific package:

1. Move the skill file: `mv skills/skill-name.md packages/pkg-name/SKILL.md`
2. Update any cross-references in `AGENTS.md`
3. Verify pi-mono discovers the skill in its new location

---

## Cross-Tool Compatibility

Because pi-mono reads `AGENTS.md` and `CONTRIBUTING.md` natively, the universal files ARE the pi-mono files. The primary mapping is for skills, which can be organized as shared (`skills/{name}.md`) or per-package (`packages/{name}/SKILL.md`).

Other agent tools (Agent Zero, Claude Code, OpenCode) use different conventions. The universal files remain the single source of truth.

See [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md) for the full cross-tool sharing standard.
