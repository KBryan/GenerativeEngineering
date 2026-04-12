# Skill: setup-linting

> **Version**: 1.0
> **Date**: 2026-04-06
> **Trigger**: When asked to add or configure a linter

---

## Capability Contract

- **Name**: `setup-linting`
- **Description**: Configures and enables a code linter for the project, including rules, configuration, ignore patterns, and CI integration.
- **Trigger**: When asked to add a linter, configure linting, set up code quality checks, or add static analysis to a project.
- **Prerequisites**: Project has source code that needs linting. Package manager is configured.
- **Produces**: Linter configuration file, updated package manifest (dependencies), CI/validation integration, and documented lint commands.

---

## Execution Contract

### Steps

1. **Audit existing lint config**: Check whether the project already has any linter configuration, lint scripts, or lint-related dependencies. Identify the language, framework, and existing tooling.
   - Input: Project directory, package manifest (package.json, pyproject.toml, Cargo.toml, etc.)
   - Output: List of existing lint tools, config files, and gaps in coverage
   - Validation: Complete inventory of existing lint-related files and dependencies

2. **Configure linter**: Select and configure the appropriate linter for the project's primary language. Create or update the configuration file with rules that match the project's coding standards from `AGENTS.md`. Include: rule settings, file ignore patterns, environment targets, and any plugin extensions.
   - Input: Language/framework, existing coding conventions from AGENTS.md, existing config (if any)
   - Output: Linter configuration file (e.g., `.eslintrc.yml`, `pyproject.toml [tool.ruff]`, `.golangci.yml`)
   - Validation: Config file is valid YAML/TOML/JSON; linter runs without config errors

3. **Add to CI/validation**: Add the linter command to the project's validation pipeline. Update the `Justfile` (if present) with a `lint` target. If CI configuration exists (e.g., `.github/workflows/`, `.gitlab-ci.yml`), add a lint step. Add the linter as a dev dependency in the package manifest.
   - Input: Linter command, CI config location, Justfile location
   - Output: Updated Justfile with `lint` target, updated CI config with lint step, updated package manifest with dev dependency
   - Validation: `just lint` runs the linter; CI config is valid (YAML parses correctly)

4. **Validate**: Run the linter against the entire codebase. Fix any configuration issues. Verify the exit code is 0 or that only pre-existing violations are reported (not new violations introduced by the setup).
   - Input: Linter command
   - Output: Linter output showing current violations; configuration is correct
   - Validation: Linter runs successfully; config is valid; `just lint` works; CI config parses without errors

### Decision Points

- If the project already has a linter configured, audit the existing config and enhance it rather than replacing it — check for missing rules, outdated settings, or uncovered file types.
- If the project uses multiple languages, configure the primary language's linter first, then add additional linters for secondary languages (e.g., ESLint for JS + Ruff for Python in a polyglot project).
- If the project has many pre-existing lint violations, configure the linter to warn (not fail CI) initially, add a baseline/exceptions file, and create a follow-up task to fix existing violations incrementally.
- If the project uses a formatter (e.g., Prettier, Black, gofmt), configure the linter to complement rather than conflict with the formatter's rules.

### Rollback

1. Remove the linter configuration file
2. Remove linter dev dependency from the package manifest
3. Remove `lint` target from the Justfile
4. Remove lint step from CI configuration
5. Verify the project still builds and tests pass without the linter

---

## Prompt Contract

### Agent Instructions

```
You are executing the setup-linting skill.

You will configure a code linter for this project. Follow these steps:

1. FIRST: Audit the project for existing lint configuration:
   - Check for existing config files (.eslintrc*, .flake8, pyproject.toml lint sections, .golangci.yml, etc.)
   - Check package manifest for existing lint dependencies
   - Check Justfile for existing lint targets
   - Check CI config for existing lint steps
   - Identify the project's primary language and framework

2. CONFIGURE the linter:
   - Select the best linter for the language (Ruff/Python, ESLint/JS-TS, golangci-lint/Go, Clippy/Rust)
   - Create or update the configuration file with rules matching AGENTS.md coding conventions
   - Add appropriate ignore patterns (vendor/, node_modules/, generated files, migration files)
   - Configure rule strictness appropriate for the project's maturity

3. ADD to validation pipeline:
   - Add a `lint` target to the Justfile
   - Add the linter as a dev dependency in the package manifest
   - Add a lint step to CI configuration (if CI exists)
   - Document the lint command in AGENTS.md under Development Commands

4. VALIDATE by running the linter across the entire codebase:
   - Fix any configuration errors
   - Report the number of existing violations (but do NOT fix all of them — that's a separate task)
   - If there are many pre-existing violations, consider setting up a baseline/exceptions file
   - Confirm `just lint` works correctly

Note: This skill is tool-agnostic. Whether the project uses Python/Ruff, JS/ESLint, Go/golangci-lint, Rust/Clippy, or any other linter, follow that tool's configuration conventions.
```

### Inputs

| Input | Type | Required | Description |
|---|---|---|---|
| `linter` | string | No | Specific linter to use (e.g., "ruff", "eslint"). If not specified, choose the best linter for the project's language. |
| `strictness` | string | No | Rule strictness level: "minimal" (errors only), "recommended" (errors + common warnings), "strict" (all rules). Default: "recommended" |
| `fail_ci_on_violations` | boolean | No | Whether CI should fail on existing violations (default: false for existing projects, true for new projects) |

### Outputs

| Output | Location | Description |
|---|---|---|
| Linter config file | Project root or config directory | Linter configuration with rules, ignores, and plugins |
| Updated package manifest | `pyproject.toml` / `package.json` / etc. | Linter added as dev dependency |
| Updated Justfile | `Justfile` | New `lint` target added |
| Updated CI config | `.github/workflows/` or equivalent | New lint step added (if CI exists) |

---

## Workflow Contract

- **Default Risk Level**: Low (linter config changes do not modify production code behavior)
- **Lifecycle Stages Covered**: Intake (1), Implement (2-3), Validate (4)
- **Plan Required**: No — Low risk task does not require a written plan
- **Human Review Required**: No — but recommended to review the linter rule selections

### Validation Checklist

- [ ] Linter configuration file is valid and parses without errors
- [ ] Linter runs successfully on the codebase
- [ ] Linter rules align with AGENTS.md coding conventions
- [ ] Ignore patterns cover generated/vendor files
- [ ] `just lint` target works
- [ ] CI lint step is correctly configured (if CI exists)
- [ ] Dev dependency is added to the package manifest
- [ ] AGENTS.md Development Commands section updated with lint command
- [ ] No conflicts with existing formatter configuration

### Review Notes

- Verify linter rule selections make sense for the project's language and maturity level
- Check that ignore patterns aren't too broad (hiding real issues)
- Confirm CI integration matches the project's CI system
- Ensure the lint command is documented in AGENTS.md
