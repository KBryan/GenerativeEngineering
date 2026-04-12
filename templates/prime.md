# Prime: Repository Auto-Bootstrap Prompt

> **Version**: 1.0.0
> **Date**: 2026-04-12
> **Related**: [docs/bootstrap-protocol.md](../docs/bootstrap-protocol.md) | [skills/prime/SKILL.md](../skills/prime/SKILL.md)

This is a self-contained prompt. Copy it into any capable coding agent and it will bootstrap the repository. No external references or tool-specific knowledge required.

---

## Instructions

You are executing the prime skill to bootstrap this repository. Your goal is to audit the repository, understand its structure, and create a complete `AGENTS.md` configuration file that any coding agent can use to work effectively in this codebase.

Follow these 6 steps in order. Do not skip steps. Do not leave placeholder values.

---

### Step 1: Scan Repository Structure

Discover what this project contains.

Run these commands:

```bash
# List all tracked files
git ls-files

# Discover the file tree (excluding noise)
find . -maxdepth 4 -type f \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  -not -path '*/.venv/*' \
  -not -path '*/target/*' \
  -not -path '*/dist/*' \
  -not -path '*/.next/*' | sort

# Identify project manifests
for f in pyproject.toml setup.py setup.cfg requirements.txt \
         package.json pnpm-lock.yaml yarn.lock \
         Cargo.toml go.mod pom.xml build.gradle \
         Gemfile mix.exs composer.json; do
  if [ -f "$f" ]; then
    echo "=== $f ==="
    head -30 "$f"
  fi
done
```

**What to capture**: List of languages, frameworks, build tools, and the directory structure.

**Decision point**: If `git ls-files` fails (not a git repo), fall back to `find` and warn the user.

---

### Step 2: Read README and Existing Config

Extract project context. Read everything that already exists.

```bash
# Read the project README
cat README.md 2>/dev/null || echo "No README.md found"

# Read existing agent configuration (DO NOT overwrite without permission)
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md found (will create new)"

# Read CI/CD configuration
for f in .github/workflows/*.yml .github/workflows/*.yaml \
         .gitlab-ci.yml Jenkinsfile .circleci/config.yml; do
  if [ -f "$f" ]; then
    echo "=== CI: $f ==="
    head -40 "$f"
  fi
done

# Read linter/formatter config
for f in .eslintrc .eslintrc.js .eslintrc.json tsconfig.json \
         mypy.ini setup.cfg ruff.toml pyproject.toml \
         .flake8 .prettierrc .prettierrc.json \
         rustfmt.toml clippy.toml; do
  if [ -f "$f" ]; then
    echo "=== Lint config: $f ==="
    head -20 "$f"
  fi
done

# Check for environment files
cat .env.example 2>/dev/null || echo "No .env.example found"
ls -la .env* 2>/dev/null || echo "No .env files found"
```

**What to capture**: Project name, purpose, test/lint/build commands, existing configuration.

**Decision point**: If AGENTS.md already exists, read it carefully. You will merge new information into it, not overwrite it (unless explicitly told to overwrite).

---

### Step 3: Classify Maturity

Based on your audit, classify the repository's agent-readiness level:

| Level | Name | Criteria |
|---|---|---|
| 0 | **Bare** | No AGENTS.md, no agent configuration at all |
| 1 | **Base** | AGENTS.md exists with project overview |
| 2 | **Better** | Base + documented test/lint/build commands that work |
| 3 | **More** | Better + templates + risk model + skills defined |
| 4 | **Custom** | More + custom risk overrides + team escalation paths |

**Decision logic**:
- If no AGENTS.md exists → Level 0
- If AGENTS.md exists but validation commands are missing or broken → Level 1
- If AGENTS.md + validation commands work → Level 2
- If Level 2 + planning templates + risk model → Level 3
- If Level 3 + custom risk overrides + team escalation → Level 4

Save the classification:

```bash
mkdir -p .agent
cat > .agent/maturity.md << EOF
# Repository Maturity Classification

**Date**: $(date +%Y-%m-%d)
**Level**: [0-4]
**Name**: [Bare/Base/Better/More/Custom]
**Justification**: [explain what exists and what is missing]

## What Exists
- [list discovered configs, test setup, etc.]

## What is Missing
- [list what would advance to next level]

## Path to Next Level
- [concrete steps to advance one level]
EOF
```

---

### Step 4: Generate AGENTS.md

Create or update `AGENTS.md` in the repository root. Use the template structure below. **Fill in every section with real information from your audit.** Do NOT leave placeholder comments.

**Decision**:
- If AGENTS.md does not exist → Create new
- If AGENTS.md exists but has `<!-- CUSTOMIZE: -->` placeholders → Fill in missing sections
- If AGENTS.md exists and is complete → Merge new findings; do NOT remove existing sections

#### AGENTS.md Template

Copy and fill this template. Replace ALL bracketed placeholders with real values.

```markdown
# AGENTS.md — [REAL PROJECT NAME]

> **Version**: v2.0
> **Date**: [TODAYS DATE]

## Project Overview

**Name**: [real project name from README or config]
**Purpose**: [1-2 sentences from README or inferred from code]
**Primary Language**: [detected language and version, e.g., Python 3.12]
**Framework**: [detected framework, e.g., FastAPI, Next.js, or "None"]
**Repository Type**: [single project / monorepo]

---

## Architecture

- **Service type**: [REST API / web app / CLI / library / microservice]
- **Database**: [e.g., PostgreSQL via SQLAlchemy, or "None"]
- **External integrations**: [e.g., Stripe, AWS S3, or "None identified"]
- **Authentication**: [e.g., JWT, OAuth2, or "None"]
- **Deployment target**: [e.g., AWS ECS, Vercel, or "Not configured"]

### Key Directories

| Directory | Purpose |
|---|---|
| [dir1] | [purpose from scan] |
| [dir2] | [purpose from scan] |

---

## Development Commands

### Setup

```bash
# Install dependencies
[REAL install command, e.g., pip install -e . or npm install]

# Set up environment
cp .env.example .env
```

### Validation

```bash
# Run tests
[REAL test command, e.g., pytest or npm test]

# Run linter
[REAL lint command, e.g., ruff check . or eslint .]

# Run formatter check
[REAL format command, e.g., ruff format --check .]

# Run type checker
[REAL typecheck command, or remove this section]

# Run build
[REAL build command, or remove this section]
```

### Run Locally

```bash
# Start development server
[REAL dev command, e.g., uvicorn main:app --reload]
```

---

## Coding Rules

### Style

- Follow existing code style as enforced by [linter name]
- [Add 2-3 conventions discovered from existing code]

### Patterns

- Error handling: [describe pattern]
- Logging: [describe pattern]
- Testing: [describe pattern]

### Do NOT

- [Add project-specific prohibitions discovered from code review]
- Do not commit credentials or API keys
- Do not modify generated files by hand

---

## Risk Areas

| Path / Area | Risk Level | Notes |
|---|---|---|
| [high-risk-path] | High | [why it's risky] |
| [medium-risk-path] | Medium | [why it needs attention] |
| [low-risk-path] | Low | [why it's safe] |

---

## Review Expectations

### All Changes

- [ ] Tests pass (existing + new)
- [ ] Linter passes with no new warnings
- [ ] No unrelated changes included

### [Project-Specific] Changes

- [ ] [Add review criteria specific to this project]

---

## Escalation

### Channels

- **Standard**: Open a GitHub issue or comment on the PR
- **Urgent**: [Add team-specific escalation method]

### Escalation Triggers

- Any change to [high-risk paths]
- Database migrations affecting production data
- Ambiguous requirements after one clarification attempt

---

## Environment Variables

| Variable | Purpose | Required |
|---|---|---|
| [VAR_NAME] | [what it does] | Yes/No |

---

## Additional Context

### Known Issues

- [Any known issues discovered during scan]

### Recent Changes

- [Notable recent changes from git log]
```

---

### Step 5: Validate and Baseline

Run the validation commands you discovered and record the results.

```bash
# Run the test command discovered in Step 2
[TEST_COMMAND]

# Run the lint command discovered in Step 2
[LINT_COMMAND]

# Run the build command (if applicable)
[BUILD_COMMAND]
```

**Decision points**:
- If a command fails → Record the failure in baseline.md. Note it as an action item in AGENTS.md.
- If no validation commands exist → Write "Not yet configured — manual setup needed" in AGENTS.md for that section.
- If a command takes too long → Record a partial result with a note.

Record the results:

```bash
mkdir -p .agent
cat > .agent/baseline.md << EOF
# Validation Baseline

**Date**: $(date +%Y-%m-%d)
**Maturity Level**: [from Step 3]

## Test Results
[Paste actual test output summary: X pass, Y fail, Z skip]

## Lint Results
[Paste actual lint output summary]

## Build Results
[Paste actual build output summary, or "Not applicable"]

## Action Items
- [List any failing commands that need manual fixing]
- [List any commands that could not be discovered]
EOF
```

---

### Step 6: Review and Confirm

Present your work for review:

```bash
echo "=== Prime Bootstrap Complete ==="
echo ""
echo "Maturity Level: [from .agent/maturity.md]"
echo ""
echo "Files created or updated:"
ls -la AGENTS.md .agent/maturity.md .agent/baseline.md 2>/dev/null
echo ""
echo "Review AGENTS.md and confirm it accurately represents this project."
echo "Edit any sections that need adjustment."

# Show a summary of what was changed
git diff --stat 2>/dev/null || echo "(not a git repo or no changes tracked)"
```

**Confirmation checklist**

- [ ] AGENTS.md contains no placeholder `<!-- CUSTOMIZE: -->` comments
- [ ] Every section of AGENTS.md has real, project-specific information
- [ ] Risk areas are identified with appropriate severity levels
- [ ] All documented validation commands actually work
- [ ] Baseline results in `.agent/baseline.md` reflect real command output
- [ ] Maturity classification in `.agent/maturity.md` is accurate

---

## Rollback Instructions

If the bootstrap produces incorrect or unwanted results:

1. **Restore previous AGENTS.md**: `git checkout AGENTS.md` (if versioned)
2. **Remove generated artifacts**: `rm -rf .agent/maturity.md .agent/baseline.md`
3. **Clean up empty directory**: `rmdir .agent/` (only if empty)
4. **Re-run with corrections**: Re-execute this prompt with corrected parameters or make manual edits

---

*Part of the [Agentic Engineering Workflow Framework](../README.md). Skill definition: [skills/prime/SKILL.md](../skills/prime/SKILL.md).*
