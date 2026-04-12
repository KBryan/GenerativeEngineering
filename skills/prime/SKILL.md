# Skill: prime

> **Version**: 1.0
> **Date**: 2026-04-12
> **Executable version of**: [docs/bootstrap-protocol.md](../../docs/bootstrap-protocol.md)

---

## Capability Contract

- **Name**: `prime`
- **Description**: Automatically scans a repository and generates a completed AGENTS.md configuration file, filling in project-specific details from actual code analysis.
- **Trigger**: When asked to bootstrap, prime, or configure a repository for agent development; when AGENTS.md is missing or incomplete.
- **Prerequisites**: Repository must be a git repo with committed files.
- **Produces**: Completed AGENTS.md, updated validation commands in Justfile (if applicable), baseline test results saved to `.agent/baseline.md`, maturity classification saved to `.agent/maturity.md`.
- **Risk Level**: Medium

---

## Execution Contract

### Steps

#### Step 1: Scan Repository Structure

Discover the project's file layout, languages, and frameworks.

- **Input**: `repo_path` (defaults to current working directory)
- **Output**: List of project files, identified languages, directory structure
- **Validation**: Command exits successfully and produces file list
- **Commands**:
```bash
# List tracked files
git ls-files

# Discover file tree
find . -maxdepth 4 -type f \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  -not -path '*/.venv/*' | sort

# Detect primary languages and their versions
# Look for project manifests
for f in pyproject.toml package.json Cargo.toml go.mod pom.xml build.gradle Gemfile mix.exs; do
  if [ -f "$f" ]; then
    echo "Found: $f"
    head -50 "$f"
  fi
done
```

#### Step 2: Read README and Existing Config

Extract project context from existing documentation and configuration.

- **Input**: Discovered config files from Step 1
- **Output**: Project name, purpose, language, framework, dependency info
- **Validation**: Key fields are populated (not placeholder values)
- **Commands**:
```bash
# Read README
cat README.md 2>/dev/null || echo "No README.md found"

# Read CI/CD configuration
for f in .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile; do
  if [ -f "$f" ]; then
    echo "Found CI config: $f"
    cat "$f" | head -30
  fi
done

# Read existing agent config (do NOT overwrite)
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md found (will create new)"

# Read linter/formatter config
for f in .eslintrc* tsconfig.json mypy.ini setup.cfg ruff.toml .flake8 prettier.config.*; do
  if [ -f "$f" ]; then echo "Found linter config: $f"; fi
done
```

#### Step 3: Classify Maturity

Determine the repository's current agent-readiness level.

- **Input**: Audit results from Steps 1-2
- **Output**: Maturity level (0-4) saved to `.agent/maturity.md`
- **Validation**: Level is an integer 0-4 with documented justification
- **Classification criteria**:

| Level | Name | Criteria |
|---|---|---|
| 0 | Bare | No AGENTS.md, no validation commands documented |
| 1 | Base | AGENTS.md with project overview exists |
| 2 | Better | Base + documented test/lint/build commands that work |
| 3 | More | Better + templates + risk model + skills defined |
| 4 | Custom | More + custom risk overrides + team escalation paths |

- **Commands**:
```bash
mkdir -p .agent
cat > .agent/maturity.md << 'MATURITY_EOF'
# Repository Maturity Classification

**Date**: [auto-filled with current date]
**Level**: [0-4 — determined from audit]
**Justification**: [explain what exists and what is missing]

## What Exists
- [list discovered configs, test setup, etc.]

## What is Missing
- [list what would advance to next level]

## Path to Next Level
- [concrete steps to advance one level]
MATURITY_EOF
```

#### Step 4: Generate AGENTS.md

Create or update the AGENTS.md file with real project information.

- **Input**: All gathered information from Steps 1-3
- **Output**: Completed `AGENTS.md` in the repository root
- **Validation**: AGENTS.md contains no `<!-- CUSTOMIZE: -->` placeholder comments; all sections have real content
- **Decision**:
  - If AGENTS.md does not exist → create fresh from template
  - If AGENTS.md exists but is incomplete (has CUSTOMIZE placeholders) → fill missing sections, preserve existing content
  - If AGENTS.md exists and is complete, `overwrite=false` → merge new findings, do not remove existing content
  - If AGENTS.md exists and is complete, `overwrite=true` → replace with freshly generated version
- **Commands**:
```bash
# Create AGENTS.md using the template structure from templates/AGENTS.md
# Fill every CUSTOMIZE section with real discovered values
# Do NOT leave any placeholder comments
cat > AGENTS.md << 'AGENTS_EOF'
# AGENTS.md — [discovered project name]

> **Version**: v2.0
> **Date**: [current date]

## Project Overview
**Name**: [from README or pyproject.toml/package.json]
**Purpose**: [from README or inferred from code]
**Primary Language**: [detected language and version]
**Framework**: [detected framework]
**Repository Type**: [single / monorepo]

[... fill all sections from templates/AGENTS.md with real values ...]
AGENTS_EOF
```

#### Step 5: Validate and Baseline

Run validation commands and record baseline results.

- **Input**: Validation commands discovered in Steps 1-2
- **Output**: Baseline results saved to `.agent/baseline.md`
- **Validation**: At least one validation command runs; results are recorded
- **Skip condition**: If `skip_validation` is true, skip this step and note it in baseline
- **Commands**:
```bash
# Try common test commands (adapt based on what was discovered in Step 1)
# Python: pytest
# Node: npm test
# Go: go test ./...
# Rust: cargo test
YOUR_TEST_COMMAND

# Try common lint commands
YOUR_LINT_COMMAND

# Try build command (if applicable)
YOUR_BUILD_COMMAND

# Record baseline results
mkdir -p .agent
cat > .agent/baseline.md << 'BASELINE_EOF'
# Validation Baseline

**Date**: [current date]
**Maturity Level**: [from Step 3]

## Test Results
[output from test command]

## Lint Results
[output from lint command]

## Build Results
[output from build command, if applicable]

## Action Items
- [list any failures or commands that need manual configuration]
BASELINE_EOF
```

#### Step 6: Review and Confirm

Present the generated AGENTS.md and classification for user approval.

- **Input**: AGENTS.md, maturity.md, baseline.md
- **Output**: User confirmation (or list of changes for revision)
- **Validation**: User has reviewed and approved all generated content
- **Commands**:
```bash
echo "=== Bootstrap Complete ==="
echo ""
echo "Maturity Level: [from .agent/maturity.md]"
echo ""
echo "Files created:"
echo "  - AGENTS.md"
echo "  - .agent/maturity.md"
echo "  - .agent/baseline.md"
echo ""
echo "Review AGENTS.md and confirm it accurately represents this project."
echo "Edit any sections that need adjustment."

git diff --stat 2>/dev/null || echo "(not a git repo or no changes)"
```

### Decision Points

| Condition | Action |
|---|---|
| AGENTS.md does not exist | Create new from template with discovered values |
| AGENTS.md exists but has CUSTOMIZE placeholders | Fill in missing sections, preserve existing content |
| AGENTS.md exists and is complete, `overwrite=false` | Merge new findings, do not remove existing sections |
| AGENTS.md exists and is complete, `overwrite=true` | Replace with freshly generated version |
| No test/lint/build commands found | Note in AGENTS.md that commands need manual configuration; skip validation step |
| Repository is not a git repo | Warn user; proceed with `find` instead of `git ls-files` |
| Validation commands fail | Record failures in baseline.md; note as action item in AGENTS.md |

### Rollback

1. Restore previous AGENTS.md: `git checkout AGENTS.md` (if versioned)
2. Remove generated artifacts: `rm -rf .agent/maturity.md .agent/baseline.md`
3. If `.agent/` directory is now empty: `rmdir .agent/`
4. Re-run with corrected parameters or manual adjustments

---

## Prompt Contract

### Agent Instructions

```
You are executing the prime skill to bootstrap this repository.

Your goal is to audit the repository, understand its structure, and create
a complete AGENTS.md configuration file that any coding agent can use to
work effectively in this codebase.

Follow these 6 steps in order:

1. SCAN — Run git ls-files and find to discover the file tree. Identify
   languages, frameworks, and build systems from config files.

2. READ — Examine README.md, pyproject.toml, package.json, Cargo.toml,
   or any project manifest. Read existing CI config and linter config.
   If AGENTS.md already exists, read it and merge — do not discard
   existing content unless explicitly told to overwrite.

3. CLASSIFY — Determine the maturity level (0-4) based on what exists.
   Save the classification to .agent/maturity.md with justification
   and path to next level.

4. GENERATE — Create or update AGENTS.md using the template structure
   from templates/AGENTS.md. Fill in EVERY section with real discovered
   values — no placeholder CUSTOMIZE comments should remain. Use actual
   commands, actual paths, actual descriptions.

5. VALIDATE — Run whatever test, lint, and build commands you discovered.
   Record the baseline results (pass/fail/skip counts) in .agent/baseline.md.
   If validation commands fail, note what failed and what needs fixing.

6. REVIEW — Present the generated AGENTS.md, maturity classification, and
   baseline results. Ask the user to confirm or request changes.

Do not skip steps. Do not leave placeholder values. Every section of
AGENTS.md must contain real information from your audit.
```

### Inputs

| Input | Type | Required | Description |
|---|---|---|---|
| `repo_path` | string | No | Path to the repository root (defaults to current working directory) |
| `overwrite` | boolean | No | If true, replace existing AGENTS.md; if false, merge with existing content (default: false) |
| `skip_validation` | boolean | No | If true, skip running validation commands and note in baseline (default: false) |

### Outputs

| Output | Location | Description |
|---|---|---|
| AGENTS.md | Repository root | Complete project configuration for agents |
| .agent/baseline.md | `.agent/` | Baseline test/lint/build results |
| .agent/maturity.md | `.agent/` | Maturity classification with justification |

---

## Workflow Contract

- **Default Risk Level**: Medium (creates/modifies project configuration files)
- **Lifecycle Stages Covered**: Plan, Review (all validation-related stages)
- **Plan Required**: No (the skill itself is a bootstrapping procedure; no separate plan needed)
- **Human Review Required**: Yes (Step 6 requires user confirmation of generated AGENTS.md)

### Validation Checklist

- [ ] AGENTS.md exists and contains no `<!-- CUSTOMIZE: -->` placeholder comments
- [ ] AGENTS.md project name and purpose match the repository
- [ ] Development commands listed in AGENTS.md actually work when run
- [ ] Risk areas are identified with appropriate severity levels
- [ ] .agent/maturity.md contains a valid level (0-4) with justification
- [ ] .agent/baseline.md records actual validation results
- [ ] If validation commands fail, the failure is documented as an action item

### Review Notes

- Verify that AGENTS.md sections contain real values, not placeholder text
- Check that identified risk areas match the actual codebase sensitivity
- Confirm maturity classification is accurate given what was discovered
- Ensure baseline results reflect actual command output, not assumed outcomes
- If the repo had an existing AGENTS.md, verify no important content was lost

---

## Examples

### Example 1: Fresh Python Repository

**Input**:
```
repo_path: /home/user/my-fastapi-app
overwrite: false
skip_validation: false
```

**Expected Output**:
```
Created:
  - AGENTS.md (project config with FastAPI, pytest, ruff discovered)
  - .agent/maturity.md (Level 1 — AGENTS.md created, no existing config)
  - .agent/baseline.md (test/lint results recorded)

Validation:
  - AGENTS.md contains real project name from pyproject.toml
  - pytest command discovered and run: 24 pass, 2 fail, 0 skip
  - ruff check command discovered and run: 0 errors
  - Risk areas identified: src/auth/ (High), src/api/ (Medium), tests/ (Low)
```

### Example 2: Existing Project with Incomplete AGENTS.md

**Input**:
```
repo_path: /home/user/legacy-service
overwrite: false
skip_validation: false
```

**Expected Output**:
```
Updated:
  - AGENTS.md (merged new findings into existing content)
  - .agent/maturity.md (Level 2 — validation commands now documented and working)
  - .agent/baseline.md (baseline recorded: 142 pass, 3 fail, 8 skip)

Preserved from existing AGENTS.md:
  - Custom risk overrides for src/payments/ (High)
  - Team escalation contacts
  - Environment variable documentation
```

---

## Compatibility

- **Languages**: Any (Python, TypeScript, Go, Rust, Java, Ruby, etc.)
- **Frameworks**: Any (FastAPI, Next.js, Gin, Actix, Spring, Rails, etc.)
- **Dependencies**: Requires git for `git ls-files`; falls back to `find` if not a git repo

---

## Changelog

| Version | Date | Changes |
|---|---|---|
| 1.0 | 2026-04-12 | Initial skill definition |

---

*This skill follows the [Cross-Tool Skill Sharing Standard](../../docs/cross-tool-standard.md) v2.0.*
