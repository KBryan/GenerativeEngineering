#!/usr/bin/env bash
# pi-mono Adapter — Generate Script
# Reads universal skill definitions and writes them to pi-mono's expected directories.
#
# pi-mono reads AGENTS.md and CONTRIBUTING.md natively from the project root —
# no mapping needed for those files. Only skills need to be mapped.
#
# Skills can be organized as:
#   - Shared: skills/{skill_name}.md
#   - Per-package: packages/{package_name}/SKILL.md
#
# Usage: bash adapters/pi-mono/generate.sh

set -euo pipefail

# --- Configuration ---
PIMONO_SKILLS_DIR="skills"
PIMONO_PACKAGES_DIR="packages"
UNIVERSAL_SKILLS_DIR="skills"

# --- Validate universal files ---
errors=0

if [ ! -f "AGENTS.md" ]; then
    echo "ERROR: AGENTS.md not found in project root. This file is required."
    errors=$((errors + 1))
else
    echo "OK: AGENTS.md found in project root (pi-mono reads it natively — no copy needed)"
fi

if [ -f "CONTRIBUTING.md" ]; then
    echo "OK: CONTRIBUTING.md found in project root (pi-mono reads it natively — no copy needed)"
else
    echo "NOTE: CONTRIBUTING.md not present (optional — pi-mono reads it if it exists)"
fi

if [ "$errors" -gt 0 ]; then
    echo ""
    echo "Validation failed with $errors error(s). Fix the above issues and re-run."
    exit 1
fi

# --- Create shared skills directory ---
mkdir -p "$PIMONO_SKILLS_DIR"

# --- Map skills/*/SKILL.md → skills/{skill_name}.md (shared) ---
mapped_skills=0
for skill_dir in "${UNIVERSAL_SKILLS_DIR}"/*/; do
    skill_file="${skill_dir}SKILL.md"
    if [ -f "$skill_file" ]; then
        skill_name=$(basename "$skill_dir")
        target_file="${PIMONO_SKILLS_DIR}/${skill_name}.md"
        cp "$skill_file" "$target_file"
        echo "Mapped (shared): ${skill_file} → ${target_file}"
        mapped_skills=$((mapped_skills + 1))
    fi
done

if [ "$mapped_skills" -eq 0 ]; then
    echo "NOTE: No skills found in ${UNIVERSAL_SKILLS_DIR}/. Add skills to enable pi-mono skill discovery."
fi

# --- Handle monorepo packages/ structure ---
mapped_packages=0
if [ -d "$PIMONO_PACKAGES_DIR" ]; then
    echo ""
    echo "Found packages/ directory — checking for per-package skill mappings..."
    for pkg_dir in "${PIMONO_PACKAGES_DIR}"/*/; do
        if [ -d "$pkg_dir" ]; then
            pkg_name=$(basename "$pkg_dir")
            universal_skill="${UNIVERSAL_SKILLS_DIR}/${pkg_name}/SKILL.md"
            if [ -f "$universal_skill" ]; then
                mkdir -p "${PIMONO_PACKAGES_DIR}/${pkg_name}"
                cp "$universal_skill" "${PIMONO_PACKAGES_DIR}/${pkg_name}/SKILL.md"
                echo "Mapped (per-package): ${universal_skill} → ${PIMONO_PACKAGES_DIR}/${pkg_name}/SKILL.md"
                mapped_packages=$((mapped_packages + 1))
            fi
        fi
    done

    if [ "$mapped_packages" -eq 0 ]; then
        echo "NOTE: No per-package skills mapped. All skills are in shared directory."
    fi
else
    echo "NOTE: No packages/ directory found. All skills mapped to shared directory only."
fi

# --- Summary ---
echo ""
echo "pi-mono adapter generation complete."
echo "AGENTS.md:       Read natively from project root (no copy needed)"
echo "CONTRIBUTING.md: Read natively from project root (if present, no copy needed)"
echo "Skills (shared): ${mapped_skills} skill(s) in ${PIMONO_SKILLS_DIR}/"
if [ -d "$PIMONO_PACKAGES_DIR" ]; then
    echo "Skills (package): ${mapped_packages} skill(s) in ${PIMONO_PACKAGES_DIR}/"
fi
echo ""
echo "To verify, run:  ls -la ${PIMONO_SKILLS_DIR}/*.md"
