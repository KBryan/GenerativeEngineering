# Validation Entrypoints

> **Version**: v2.0
> **Date**: 2026-04-06
> **Template**: Copy this file to your repository and fill in the actual commands.

This file documents every validation command an agent (or human) can run to verify code quality. Agents read this file to know how to validate their changes.

---

## Quick Validate (run all checks)

<!-- CUSTOMIZE: Replace with your project's all-in-one validation command -->

```bash
# Run all validation checks in sequence
just validate
# OR if not using Justfile:
YOUR_LINT_COMMAND && YOUR_TEST_COMMAND && YOUR_TYPECHECK_COMMAND && YOUR_BUILD_COMMAND
```

---

## Individual Checks

### Lint

<!-- CUSTOMIZE: Your linter command -->

```bash
YOUR_LINT_COMMAND
# Examples:
#   ruff check .
#   eslint . --ext .ts,.tsx
#   cargo clippy -- -D warnings
#   go vet ./...
#   rubocop
```

**Expected output**: Zero warnings, zero errors.

### Format Check

<!-- CUSTOMIZE: Your formatter command in check mode -->

```bash
YOUR_FORMAT_COMMAND
# Examples:
#   ruff format --check .
#   prettier --check "src/**/*.{ts,tsx}"
#   cargo fmt --check
#   gofmt -l .
```

**Expected output**: No files need reformatting.

### Tests

<!-- CUSTOMIZE: Your test command -->

```bash
YOUR_TEST_COMMAND
# Examples:
#   pytest
#   npm test
#   cargo test
#   go test ./...
#   bundle exec rspec
```

**Expected output**: All tests pass. Record baseline: X passed, Y failed, Z skipped.

### Type Check

<!-- CUSTOMIZE: Your type checker command, or remove this section if N/A -->

```bash
YOUR_TYPECHECK_COMMAND
# Examples:
#   mypy src/
#   tsc --noEmit
#   (Go and Rust: type checking is part of compilation)
```

**Expected output**: No type errors.

### Build

<!-- CUSTOMIZE: Your build command, or remove this section if N/A -->

```bash
YOUR_BUILD_COMMAND
# Examples:
#   python -m build
#   npm run build
#   cargo build
#   go build ./...
#   docker build -t myapp .
```

**Expected output**: Build completes without errors.

### End-to-End Tests

<!-- CUSTOMIZE: Your E2E test command, or remove this section if N/A -->

```bash
YOUR_E2E_COMMAND
# Examples:
#   playwright test
#   cypress run
#   (many projects don't have E2E — remove this section if not applicable)
```

**Expected output**: All E2E tests pass.

---

## Baseline Record

<!-- CUSTOMIZE: Record your current baseline after running all checks -->

```
Date: YYYY-MM-DD
Tests: X passed, Y failed, Z skipped
Lint: pass
Format: pass
Type check: pass / N/A
Build: pass / N/A
E2E: pass / N/A
Known failures: [list any pre-existing failures]
```

---

## Notes

<!-- CUSTOMIZE: Any project-specific validation notes -->

- [e.g., "Some integration tests require DATABASE_URL to be set"]
- [e.g., "E2E tests require the dev server to be running"]
- [e.g., "Type checking is slow — only required for Medium+ risk changes"]

---

*This file follows the [Agentic Engineering Workflow Framework](../../docs/workflow.md) v2.0 standard.*
