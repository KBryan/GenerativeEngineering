# Claude Code Adapter — File Mapping

> **Version**: v2.0
> **Date**: 2026-04-06

---

## Mapping Table

| Universal File | Claude Code File | Format | Notes |
|---|---|---|---|
| `AGENTS.md` | `.claude/CLAUDE.md` | Markdown → Markdown | Direct copy; no format transformation needed |
| `skills/add-api-endpoint/SKILL.md` | `.claude/commands/add-api-endpoint.md` | Markdown → Markdown | Becomes a `/add-api-endpoint` slash command |
| `skills/create-migration/SKILL.md` | `.claude/commands/create-migration.md` | Markdown → Markdown | Becomes a `/create-migration` slash command |
| `skills/setup-linting/SKILL.md` | `.claude/commands/setup-linting.md` | Markdown → Markdown | Becomes a `/setup-linting` slash command |
| `skills/*/SKILL.md` | `.claude/commands/{name}.md` | Markdown → Markdown | One command file per skill directory |
| `templates/plan-template.md` | (no mapping needed) | — | Claude Code reads directly from `templates/` |
| `templates/review-template.md` | (no mapping needed) | — | Claude Code reads directly from `templates/` |
| `templates/validation-readme.md` | (no mapping needed) | — | Claude Code reads directly from `templates/` |
| `templates/Justfile` | (no mapping needed) | — | Claude Code can execute `just` commands directly |
| `docs/workflow.md` | (no mapping needed) | — | Claude Code reads directly from `docs/` |
| `docs/risk-model.md` | (no mapping needed) | — | Claude Code reads directly from `docs/` |

---

## Notes

- **No format transformation required** — both the universal files and Claude Code's config use Markdown.
- **Symlink-friendly** — since the format is the same, symlinks work when Claude Code's filesystem supports them.
- **Skills become slash commands** — each `SKILL.md` is exposed as a `/command` in Claude Code's interface.
- **AGENTS.md is the single source of truth** — never edit `.claude/CLAUDE.md` directly; always edit `AGENTS.md` and re-run the adapter.
- **Templates and docs are referenced directly** — Claude Code can read them from their universal locations without copying.

---

## Cross-Tool Reference

For the complete cross-tool sharing standard, see [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md).
