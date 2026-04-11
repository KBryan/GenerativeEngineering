# Universal Bootstrap Prompt

> **Version**: v2.0
> **Date**: 2026-04-06
> **Usage**: Copy the prompt below and paste it into any capable coding agent to bootstrap a repository.

This prompt is self-contained. It does not reference any specific framework, tool, or organization. It works with any agent that can read files, run commands, and write files.

---

## The Prompt

Copy everything between the triple-backtick fences:

````markdown
You are bootstrapping this repository for autonomous agent development. Your goal
is to audit the repository, understand its structure, and create a configuration
file that will help any coding agent work effectively in this codebase.

Follow these steps in order:

## Step 1: Audit the Repository

Examine the following and record what you find:

- **Languages**: What programming languages are used? What versions?
- **Package manager**: What dependency manager is used? Where is the dependency file?
- **Build system**: How is the project built? (make, npm scripts, cargo, gradle, etc.)
- **Test framework**: What testing framework is used? What is the test command?
- **Linter**: What linter is configured? What is the lint command?
- **Type checker**: Is static type checking configured? What is the command?
- **CI/CD**: Is there a CI/CD pipeline? Where is it configured?
- **Documentation**: Does a README exist? API docs? Architecture docs?
- **Project structure**: What are the key directories and their purposes?
- **Environment**: What environment variables are needed? Is there a .env.example?

Run these commands to gather information:
```bash
# Discover project structure
find . -maxdepth 3 -type f -name "*.json" -o -name "*.toml" -o -name "*.yaml" \
  -o -name "*.yml" -o -name "Makefile" -o -name "Justfile" -o -name "*.cfg" \
  -o -name "*.ini" | head -30

# Check for existing agent config
ls -la AGENTS.md CLAUDE.md .cursorrules .opencode/ 2>/dev/null

# Check for CI/CD
ls -la .github/workflows/ .gitlab-ci.yml Jenkinsfile 2>/dev/null

# Check for test and lint config
ls -la pytest.ini setup.cfg pyproject.toml jest.config.* .eslintrc* \
  tsconfig.json mypy.ini Cargo.toml go.mod 2>/dev/null
```

## Step 2: Classify Agent-Readiness

Based on your audit, classify the repository:

- **Level 0 (Bare)**: No agent configuration exists
- **Level 1 (Base)**: An AGENTS.md or equivalent exists with project overview
- **Level 2 (Better)**: Level 1 + validation commands are documented and working
- **Level 3+ (Advanced)**: Level 2 + templates, risk model, skills defined

## Step 3: Run Validation Commands

Attempt to run whatever validation commands you discovered:

```bash
# Try common test commands (adapt based on what you found)
# Python: pytest, Go: go test ./..., Node: npm test, Rust: cargo test
YOUR_TEST_COMMAND

# Try common lint commands
# Python: ruff check ., Go: go vet ./..., Node: eslint ., Rust: cargo clippy
YOUR_LINT_COMMAND
```

Record the baseline results: how many tests pass, fail, skip.

## Step 4: Create AGENTS.md

Create (or update) an AGENTS.md file in the repository root with this structure:

```markdown
# AGENTS.md

## Project Overview
- **Name**: [discovered project name]
- **Purpose**: [inferred from README and code]
- **Primary Language**: [language and version]
- **Framework**: [framework if applicable]

## Development Commands

### Setup
[dependency installation command]

### Validation
[test command — with baseline results]
[lint command]
[type check command — if applicable]
[build command — if applicable]

## Key Directories
| Directory | Purpose |
|---|---|
| [dir] | [purpose] |

## Risk Areas
| Path | Risk Level | Notes |
|---|---|---|
| [path] | High/Medium/Low | [why] |

## Coding Conventions
[inferred from existing code, linter config, and documentation]
```

Fill in every section with real information from your audit. Do not use
placeholders — use actual values you discovered.

## Step 5: Verify

Confirm that:
1. AGENTS.md exists and contains real project information
2. Every command listed in AGENTS.md actually works when run
3. The baseline test results are recorded accurately

## Step 6: Report

Summarize:
- Current agent-readiness level (0-3+)
- What you created or updated
- Baseline validation results
- Recommended next steps to improve agent-readiness
````

---

## Usage Notes

- This prompt works with any coding agent that can execute terminal commands and write files.
- The agent will adapt the audit commands to what it discovers in the repository.
- For repositories with existing agent config, the agent will update rather than overwrite.
- The prompt produces a Level 1 bootstrap. To reach Level 2+, follow [docs/bootstrap-protocol.md](../docs/bootstrap-protocol.md).

---

*Part of the [Agentic Engineering Workflow Framework](../README.md) v2.0.*
