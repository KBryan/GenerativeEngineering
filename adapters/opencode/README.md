# OpenCode Adapter

> **Version**: v2.0
> **Date**: 2026-04-12
> **Scope**: Mapping the universal agentic engineering framework to OpenCode conventions

---

## Overview

This adapter translates the vendor-neutral framework files into [OpenCode](https://github.com/opencode-ai/opencode)'s native format. OpenCode is a terminal-based AI coding agent that reads project configuration from the repository root and stores skill definitions in `.opencode/skills/`.

Key mappings:

- **AGENTS.md** → `.opencode/config.md` (or left as `AGENTS.md` in project root — OpenCode reads both)
- **skills/*/SKILL.md** → `.opencode/skills/{skill_name}.md` (OpenCode skill discovery path)
- **Justfile** → direct usage (OpenCode executes terminal commands natively)

For the full cross-tool philosophy, see [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md).

---

## Prerequisites

- [OpenCode](https://github.com/opencode-ai/opencode) installed and available on `PATH`
- A repository that has adopted the agentic engineering workflow framework (AGENTS.md, skills/, Justfile)
- Bash available (for the `generate.sh` script)

---

## Setup Options

### Option 1: Generate (Recommended)

Run the script to copy universal files into OpenCode's expected locations:

```bash
bash adapters/opencode/generate.sh
```

This creates `.opencode/config.md` from `AGENTS.md` and `.opencode/skills/{name}.md` from each `skills/*/SKILL.md`.

### Option 2: Symlink

If your environment supports symlinks, you can link directly to the universal files for automatic synchronization:

```bash
mkdir -p .opencode/skills
ln -s "$(pwd)/AGENTS.md" .opencode/config.md

for skill_dir in skills/*/; do
    if [ -f "${skill_dir}SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        ln -s "$(pwd)/${skill_dir}SKILL.md" ".opencode/skills/${skill_name}.md"
    fi
done
```

> **Note**: Symlinks may not work reliably on all platforms or when the repository is moved.

### Option 3: Manual Copy

Manually copy files to their OpenCode locations:

```bash
mkdir -p .opencode/skills
cp AGENTS.md .opencode/config.md

cp skills/add-api-endpoint/SKILL.md .opencode/skills/add-api-endpoint.md
cp skills/create-migration/SKILL.md .opencode/skills/create-migration.md
cp skills/setup-linting/SKILL.md .opencode/skills/setup-linting.md
# ... add more skills as needed
```

Re-copy after any changes to universal files.

---

## File Mapping

See [mapping.md](./mapping.md) for the full mapping table.

| Universal File | OpenCode File | How |
|---|---|---|
| `AGENTS.md` | `.opencode/config.md` | Direct copy (or symlink)| `AGENTS.md` | `.LL.md` | `.opencode/skills/{name}.md` | One file per skill |
| `Justfile` | (no mapping needed) | OpenCode runs `just` commands directly |
| `templates/plan-template.md` | (no mapping needed) | Agent reads directly |
| `templates/review-template.md` | (no mapping needed) | Agent reads directly |

---

## Verification

After setup, verify OpenCode can see the files:

```bash
# Check that config.md exists
ls -la .opencode/config.md

# Check that skill files are available
ls -la .opencode/skills/

# Confirm AGENTS.md content propagated
diff AGENTS.md .opencode/config.md

# Start OpenCode and verify it loads project configuration
opencode
```

Expected result: OpenCode loads `.opencode/config.md` as project context and skill files appear in `.opencode/skills/`.

---

## Maintenance

### Adding a New Skill

1. Create `skills/new-skill-name/SKILL.md` following the [SKILL.md template](../../templates/SKILL.md)
2. Re-run `bash adapters/opencode/generate.sh` (or manually copy the new skill)
3. Verify with `ls .opencode/skills/new-skill-name.md`

### Updating AGENTS.md

After editing `AGENTS.md`, re-run the generate script or re-copy:

```bash
bash adapters/opencode/generate.sh
```

### Removing a Skill

1. Delete the skill directory: `rm -rf skills/old-skill/`
2. Remove the OpenCode skill file: `rm .opencode/skills/old-skill.md`
3. Or simply re-run `generate.sh` which only copies current skills

---

## Cross-Tool Compatibility

OpenCode's `.opencode/` directory is specific to OpenCode. Other agent tools (Claude Code, Agent Zero, Cursor) use different conventions. The universal files in `AGENTS.md` and `skills/` remain the single source of truth — adapters handle the translation.

See [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md) for the full cross-tool sharing standard.
