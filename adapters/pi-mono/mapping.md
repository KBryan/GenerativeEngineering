# pi-mono Adapter — File Mapping

> **Version**: v1.0
> **Date**: 2026-04-12

---

## Mapping Table

| Universal File | pi-mono File | Format | Notes |
|---|---|---|---|
| `AGENTS.md` | `AGENTS.md` (project root) | Markdown → Markdown | **No mapping needed** — pi-mono reads AGENTS.md natively from project root |
| `CONTRIBUTING.md` | `CONTRIBUTING.md` (project root) | Markdown → Markdown | **No mapping needed** — pi-mono reads CONTRIBUTING.md for contribution guidelines |
| `skills/add-api-endpoint/SKILL.md` | `skills/add-api-endpoint.md` (shared) or `packages/add-api-endpoint/SKILL.md` | Markdown → Markdown | Shared skill or per-package skill |
| `skills/create-migration/SKILL.md` | `skills/create-migration.md` (shared) or `packages/create-migration/SKILL.md` | Markdown → Markdown | Shared skill or per-package skill |
| `skills/setup-linting/SKILL.md` | `skills/setup-linting.md` (shared) or `packages/setup-linting/SKILL.md` | Markdown → Markdown | Shared skill or per-package skill |
| `skills/*/SKILL.md` | `skills/{skill_name}.md` (shared) or `packages/{name}/SKILL.md` | Markdown → Markdown | Each skill mapped to shared dir or per-package directory |
| `templates/plan-template.md` | (no mapping needed) | — | pi-mono reads directly from `templates/` |
| `templates/review-template.md` | (no mapping needed) | — | pi-mono reads directly from `templates/` |
| `templates/validation-readme.md` | (no mapping needed) | — | pi-mono reads directly from `templates/` |
| `templates/Justfile` | (no mapping needed) | — | pi-mono executes `just` commands via terminal |
| `docs/workflow.md` | (no mapping needed) | — | pi-mono reads directly from `docs/` |
| `docs/risk-model.md` | (no mapping needed) | — | pi-mono reads directly from `docs/` |
| `docs/bootstrap-protocol.md` | (no mapping needed) | — | pi-mono reads directly from `docs/` |

---

## Notes

- **AGENTS.md is native** — pi-mono reads it directly from the project root. No format change, no copy, no symlink needed.
- **CONTRIBUTING.md is native** — pi-mono reads it directly from the project root for contribution guidelines. No mapping needed.
- **Skills have two mapping strategies** — pi-mono is monorepo-aware and supports both shared skills (`skills/{name}.md`) and per-package skills (`packages/{name}/SKILL.md`). Choose based on your monorepo structure.
- **No format transformation** — both universal and pi-mono files use Markdown.
- **Templates and docs are referenced directly** — pi-mono can read them from their universal locations without any adapter step.
- **Justfile is executable directly** — pi-mono's terminal integration can run `just` commands natively.

### Choosing Between Shared and Per-Package Skills

- **Use shared skills** (`skills/{name}.md`) when the skill applies across all packages in the monorepo.
- **Use per-package skills** (`packages/{name}/SKILL.md`) when a skill is specific to one package and should not pollute other packages' context.
- Both strategies can coexist — shared skills provide defaults, per-package skills provide overrides.

---

## Cross-Tool Reference

For the complete cross-tool sharing standard, see [docs/cross-tool-standard.md](../../docs/cross-tool-standard.md).
