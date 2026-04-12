# OpenCode Adapter — File Mapping

> **Version**: v2.0
> **Date**: 2026-04-12

---

## Mapping Table

| Universal File | OpenCode File | Format | Notes |
|---|---|---|---|
| `AGENTS.md` | `.opencode/config.md` | Markdown → Markdown | OpenCode primary config; can also be read as `AGENTS.md` from project root |
| `skills/add-api-endpoint/SKILL.md` | `.opencode/skills/add-api-endpoint.md` | Markdown → Markdown | Skill discovered via `.opencode/skills/` directory |
| `skills/create-migration/SKILL.md` | `.opencode/skills/create-migration.md` | Markdown → Markdown | Skill discovered via `.opencode/skills/` directory |
| `skills/setup-linting/SKILL.md` | `.opencode/skills/setup-linting.md` | Markdown → Markdown | Skill discovered via `.opencode/skills/` directory |
| `skills/prime/SKILL.md` | `.opencode/skills/prime.md` | Markdown → Markdown | Skill discovered via `.opencode/skills/` directory |
| `skills/*/SKILL.md` | `.opencode/skills/{name}.md` | Markdown → Markdown | One file per skill directory, flattened into `.opencode/skills/` |
| `templates/plan-template.md` | (no mapping needed) | — | OpenCode reads directly from `templates/` |
| `templates/review-template.md` | (no mapping needed) | — | OpenCode reads directly from `templates/` |
| `templates/validation-readme.md` | (no mapping needed) | — | OpenCode reads directly from `templates/` |
| `templates/Justfile` | (no mapping needed) | — | OpenCode executes `just` commands directly |
| `docs/workflow.md` | (no mapping needed) | — | OpenCode reads directly from `docs/` |
| `docs/risk-model.md` | (no mapping needed) | — | OpenCode reads directly from `docs/` |
| `Justfile` | (no mapping needed) | — | OpenCode can run terminal commands directly |

---

## Notes

- **No format transformation required** — both the universal files and OpenCode config use Markdown.
- **Symlink-friendly** — since the format is the same, symlinks work on platforms that support them.
- **Skills are flattened** — each `SKILL.md` becomes a single `.md` file in `.opencode/skills/`, named by skill directory.
- **AGENTS.md is the single source of truth** — never edit `.opencode/config.md` directly; always edit `AGENTS.md` and re-run the adapter.
- **Templates and docs are referenced directly** — OpenCode can read them from their universal locations without copying.

---

## Cross-Tool Reference

For the compFor the compFor the compFor the compFor the compFor the compFor the compFor the compFor thstandard.md).
