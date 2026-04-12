# Claude Code Adapter

> **Version**: v2.0
> **Date**: 2026-04-06
> **Scope**: Mapping the universal agentic engineering framework to Claude Code conventions

---

## Overview

This adapter translates the vendor-neutral framework files into Claude Code's native format. Claude Code reads `.claude/CLAUDE.md` for project configuration and `.claude/commands/*.md` for reusable slash commands (skills).

For the full cross-tool philosophy, see [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md).

---

## Prerequisites

- A repository that has adopted the agentic engineering workflow framework
- Claude Code installed and configured
- Bash available (for the `generate.sh` script)

---

## Setup Options

### Option 1: Generate (Recommended)

Run the script to copy universal files into Claude Code's expected locations:

```bash
bash adapters/claude-code/generate.sh
```

This creates `.claude/CLAUDE.md` and `.claude/commands/*.md` from your `AGENTS.md` and `skills/*/SKILL.md` files.

### Option 2: Symlink

If your project doesn't need format changes (both are Markdown), symlinks keep files in sync automatically:

```bash
mkdir -p .claude/commands
ln -s "$(pwd)/AGENTS.md" .claude/CLAUDE.md

for skill_dir in skills/*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        ln -s "$(pwd)/$skill_dir/SKILL.md" ".claude/commands/$skill_name.md"
    fi
done
```

> **Note**: Claude Code must support symlinks in your environment. Test with `ls -la .claude/` after linking.

### Option 3: Manual Copy

Copy files manually if you prefer full control:

```bash
mkdir -p .claude/commands
cp AGENTS.md .claude/CLAUDE.md

cp skills/add-api-endpoint/SKILL.md .claude/commands/add-api-endpoint.md
cp skills/create-migration/SKILL.md .claude/commands/create-migration.md
cp skills/setup-linting/SKILL.md .claude/commands/setup-linting.md
# ... add more skills as needed
```

---

## File Mapping

See [mapping.md](./mapping.md) for the full mapping table.

| Universal File | Claude Code File | How |
|---|---|---|
| `AGENTS.md` | `.claude/CLAUDE.md` | Direct copy or symlink |
| `skills/*/SKILL.md` | `.claude/commands/*.md` | One file per skill |
| `Justfile` | (no mapping needed) | Claude Code can run `just` directly |
| `templates/plan-template.md` | (no mapping needed) | Agent reads directly |
| `templates/review-template.md` | (no mapping needed) | Agent reads directly |

---

## Verification

After setup, verify Claude Code can see the files:

```bash
# Check that CLAUDE.md exists
ls -la .claude/CLAUDE.md

# Check that skill commands are available
ls -la .claude/commands/

# Start Claude Code and test a slash command
# Type /add-api-endpoint (or any skill name) in Claude Code
```

Expected result: Claude Code loads `CLAUDE.md` as project context and skill files appear as slash commands.

---

## Maintenance

### Adding a New Skill

1. Create `skills/new-skill-name/SKILL.md` following the [SKILL.md template](../../templates/SKILL.md)
2. Re-run `bash adapters/claude-code/generate.sh` (or manually copy the new skill)
3. Verify with `ls .claude/commands/new-skill-name.md`

### Updating AGENTS.md

After editing `AGENTS.md`, re-run the generate script or re-copy:

```bash
bash adapters/claude-code/generate.sh
```

### Removing a Skill

1. Delete the skill directory: `rm -rf skills/old-skill/`
2. Remove the Claude Code command: `rm .claude/commands/old-skill.md`
3. Or simply re-run `generate.sh` which only copies current skills

---

## Cross-Tool Compatibility

Claude Code's `.claude/` directory is specific to Claude Code. Other agent tools (Agent Zero, Cursor, OpenCode) use different conventions. The universal files in `AGENTS.md` and `skills/` remain the single source of truth — adapters handle the translation.

See [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md) for the full cross-tool sharing standard.
