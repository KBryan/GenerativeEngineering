# Agent Zero Adapter — File Mapping

> **Version**: v2.0
> **Date**: 2026-04-06

---

## Mapping Table

| Universal File | Agent Zero File | Format | Notes |
|---|---|---|---|
| `AGENTS.md` | `AGENTS.md` (project root) | Markdown → Markdown | **No mapping needed** — Agent Zero reads AGENTS.md natively from project root |
| `skills/add-api-endpoint/SKILL.md` | `usr/skills/add-api-endpoint/SKILL.md` | Markdown → Markdown | Copied to Agent Zero's skill discovery directory |
| `skills/create-migration/SKILL.md` | `usr/skills/create-migration/SKILL.md` | Markdown → Markdown | Copied to Agent Zero's skill discovery directory |
| `skills/setup-linting/SKILL.md` | `usr/skills/setup-linting/SKILL.md` | Markdown → Markdown | Copied to Agent Zero's skill discovery directory |
| `skills/*/SKILL.md` | `usr/skills/{name}/SKILL.md` | Markdown → Markdown | Each skill directory mapped one-to-one |
| `templates/plan-template.md` | (no mapping needed) | — | Agent Zero reads directly from `templates/` |
| `templates/review-template.md` | (no mapping needed) | — | Agent Zero reads directly from `templates/` |
| `templates/validation-readme.md` | (no mapping needed) | — | Agent Zero reads directly from `templates/` |
| `templates/Justfile` | (no mapping needed) | — | Agent Zero executes `just` commands via terminal tool |
| `docs/workflow.md` | (no mapping needed) | — | Agent Zero reads directly from `docs/` |
| `docs/risk-model.md` | (no mapping needed) | — | Agent Zero reads directly from `docs/` |

---

## Notes

- **AGENTS.md is native** — Agent Zero reads it directly from the project root. No format change, no copy, no symlink needed.
- **Skills need directory mapping** — Agent Zero discovers skills via `usr/skills/*/SKILL.md`. Each universal skill directory is copied to a corresponding directory under `usr/skills/`.
- **No format transformation** — both universal and Agent Zero files use Markdown.
- **Templates and docs are referenced directly** — Agent Zero can read them from their universal locations without any adapter step.
- **Justfile is executable directly** — Agent Zero's terminal tool can run `just` commands natively.

---

## Cross-Tool Reference

For the complete cross-tool sharing standard, see [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md).
