# Agentic Development Workspace (ADWS) — Sample

This directory is a **reference implementation** of an Agentic Development Workspace —
what a repository looks like after being primed with the
[GenerativeEngineering](https://github.com/KBryan/GenerativeEngineering) framework.

## What is this?

The **prime** skill scans a bare repository, classifies its maturity, and generates:

- `AGENTS.md` — fully filled-in project configuration (no `CUSTOMIZE` placeholders)
- `.agent/baseline.md` — validation baseline record
- `.agent/maturity.md` — maturity assessment
- `Justfile` — runnable development commands
- Project-specific skills under `skills/`

This sample shows the **after** state. It is a small but realistic FastAPI task
management API so you can see exactly what each generated artifact looks like.

## Demo project: Task Manager API

A minimal REST API for managing tasks, built with:

- **Python 3.12**
- **FastAPI** — async web framework
- **Pydantic v2** — data validation
- **In-memory dict storage** — no external database
- **pytest** — testing

## How to use this sample

1. **Study `AGENTS.md`** — this is the key deliverable of `prime`. It is fully filled
   in with real values, no placeholders. Use it as a reference for what your own
   `AGENTS.md` should look like.

2. **Run the Justfile commands**:

   ```bash
   cd adws
   just setup      # install dependencies
   just validate   # lint + test + typecheck + build
   just dev        # start the dev server
   ```

3. **Copy relevant sections** into your own project. The structure, commands, and
   conventions in `AGENTS.md` are meant to be adapted per project.

4. **Read the project-specific skill** in `skills/add-task-endpoint/SKILL.md` to see
   how universal skills get narrowed down into project-specific ones.

5. **Check `.agent/`** for sample baseline and maturity records.

## Relationship to the framework

| Concept | In this sample |
|---|---|
| `prime` skill output | `AGENTS.md` (filled in) + `.agent/` records |
| `Justfile` template | Working commands for this project |
| Project-specific skill | `skills/add-task-endpoint/SKILL.md` |
| Validation baseline | `.agent/baseline.md` |
| Maturity assessment | `.agent/maturity.md` (Level 3: Advanced) |

## Learn more

- [Framework documentation](../docs/workflow.md)
- [Risk model](../docs/risk-model.md)
- [Repository structure](../docs/repository-structure.md)
- [Prime skill](../skills/prime/SKILL.md)
