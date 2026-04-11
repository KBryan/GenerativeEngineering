# Agentic Engineering Workflow v1.0 — Review & Analysis

> **Version**: v2.0 Review Document
> **Date**: 2026-04-06
> **Status**: Complete

---

## Executive Summary

The v1.0 Agentic Engineering Workflow document is an ambitious and technically rich attempt to codify how autonomous coding agents should operate within software engineering teams. It demonstrates deep understanding of real-world failure modes — scope drift, untested changes, silent regressions — and proposes a structured lifecycle to prevent them.

However, the document suffers from critical structural problems that prevent practical adoption: vendor lock-in to a single agent architecture, massive redundancy (bootstrap described three times), leaked secret placeholders in prose, file citation artifacts from its generation process, and a monolithic structure that forces all-or-nothing adoption. This review provides a detailed analysis and a migration path to v2.0.

---

## What Works Well

| Strength | Detail |
|---|---|
| **7-stage lifecycle** | The Intake → Plan → Implement → Validate → Review → Document → Merge pipeline is sound and maps to real engineering workflows. |
| **Risk classification** | Low/Medium/High tiers with escalating controls is practical and well-calibrated. |
| **Agent execution rules** | The 8 rules (no unrelated changes, always validate, etc.) capture hard-won lessons about agent behavior. |
| **Validation-first mindset** | Requiring agents to run existing tests before and after changes prevents the most common agent failure mode. |
| **Bootstrap concept** | The idea of auditing a repo before an agent starts working is valuable and underserved in the ecosystem. |
| **Skill sharing vision** | The cross-tool skill sharing model (shared library → adapters → overlays) is architecturally sound. |
| **Maturity ladder** | Base → Better → More → Custom → Orchestrator gives teams a growth path. |

---

## Critical Issues

| # | Issue | Severity | Impact | Recommendation |
|---|---|---|---|---|
| 1 | **Secret placeholders in prose** | 🔴 Critical | Literal `§§secret()` references appear as regular words in narrative text. If published or shared, this leaks the secret aliasing pattern and potentially the existence of specific secrets. | Strip all secret references. Use generic placeholders like `YOUR_API_KEY` in templates. |
| 2 | **File citation artifacts** | 🔴 Critical | Strings like `fileciteturn1file0L42-L78` pollute the document throughout. These are generation artifacts, not content. | Remove all citation artifacts via regex sweep. |
| 3 | **Heavy vendor coupling** | 🟠 High | Document assumes Claude Code with `.claude/` directory structure, `CLAUDE.md` file naming, and Spree Agent Architecture throughout. Teams using other agents cannot adopt without rewriting. | Extract all vendor-specific content into adapter modules. Core docs must be agent-agnostic. |
| 4 | **Bootstrap described 3 times** | 🟠 High | The bootstrap protocol appears in sections 2, 5, and appendix with slight variations. Contradictions between versions create confusion about which is canonical. | Consolidate into single `bootstrap-protocol.md`. |
| 5 | **Repo structure defined twice** | 🟠 High | Two competing directory structures appear with different file names and purposes. | Single canonical `repository-structure.md`. |
| 6 | **Monolithic structure** | 🟠 High | ~800 lines in one document covering workflow + bootstrap + skills + architecture. Teams cannot adopt the lifecycle without also adopting the skill system. | Split into independent, cross-referenced modules. |
| 7 | **No actual templates** | 🟡 Medium | Document describes what templates should contain but never provides copy-paste-ready versions. Teams must author templates from scratch. | Provide complete, customizable templates for every artifact. |
| 8 | **Mixed concerns** | 🟡 Medium | Workflow rules, repository conventions, tool configuration, and organizational process are interleaved within sections. | Separate into distinct documents by concern. |
| 9 | **No versioning strategy** | 🟡 Medium | No guidance on how teams should version their workflow config or manage changes to the framework itself. | Add version headers and change management guidance. |
| 10 | **Aspirational vs. actionable** | 🟡 Medium | Several sections describe ideals ("teams should...") without concrete implementation steps or templates. | Every section must include specific actions, commands, or templates. |

---

## Structural Analysis

### Current Structure (v1.0)

```
Single monolithic document (~800 lines)
├── Workflow lifecycle (good content, buried deep)
├── Bootstrap protocol (repeated 3x with variations)
├── Repository structure (defined 2x, conflicting)
├── Vendor-specific architecture alignment
├── Cross-tool skill system
├── Template descriptions (no actual templates)
├── Secret placeholders scattered throughout
└── File citation artifacts throughout
```

### Problems with This Structure

1. **Cognitive overload**: Reader must parse 800 lines to find the relevant section
2. **Impossible partial adoption**: Can't use the lifecycle without the skill system
3. **Update fragility**: Changing bootstrap requires edits in 3 locations
4. **Vendor lock**: Core principles entangled with Claude Code specifics
5. **No separation of concerns**: Organizational process mixed with technical configuration

---

## Recommendations for v2.0 Modular Rewrite

### Architecture

- **Split into 7 independent documents** + templates + adapters
- **Each document self-contained** with cross-references to related docs
- **Templates are real files**, not descriptions of files
- **Adapters directory** isolates all tool-specific content
- **Version header on every document** for change tracking

### Content Standards

- Zero secret placeholders — use `YOUR_*` or `<!-- CUSTOMIZE: -->` markers
- Zero vendor assumptions in core docs
- Every section must answer: "What do I do?" not "What should I think about?"
- Tables for comparison, checklists for processes, code blocks for examples

### Adoption Model

- **Tier 1 (5 min)**: Copy `AGENTS.md` template + read `workflow.md`
- **Tier 2 (30 min)**: Add validation, risk model, plan templates
- **Tier 3 (2 hr)**: Full bootstrap, cross-tool skills, custom adapters

---

## Migration Path: v1.0 → v2.0

| Step | Action | Effort |
|---|---|---|
| 1 | Adopt `docs/workflow.md` as the canonical lifecycle reference | 10 min |
| 2 | Replace any existing `CLAUDE.md` / agent config with `templates/AGENTS.md` | 15 min |
| 3 | Consolidate bootstrap scripts to match `docs/bootstrap-protocol.md` | 30 min |
| 4 | Map existing skills to `templates/SKILL.md` format | 1 hr |
| 5 | Create tool adapter if using a non-standard agent | 1-2 hr |
| 6 | Align repository structure with `docs/repository-structure.md` | 30 min |
| 7 | Remove all v1.0 artifacts (secret refs, citation strings, duplicate sections) | 15 min |

**Total estimated migration: 3-5 hours for a typical repository.**

---

## Conclusion

The v1.0 document contains excellent engineering judgment buried under structural problems. The v2.0 modular rewrite preserves all valuable content while making it accessible, adoptable, and vendor-neutral. Teams should migrate incrementally starting with Tier 1 adoption.
