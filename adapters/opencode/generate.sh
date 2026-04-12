#!/usr/bin/env bash
set -euo pipefail

# OpenCode Adapter — Generate Script
# Reads universal framework files and writes them to OpenCode's expected locations.
# See: adapters/opencode/README.md

# --- Configuration ---
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OPENCODE_DIR="${REPO_ROOT}/.opencode"
OPENCODE_SKILLS="${OPENCODE_DIR}/skills"
AGENTS_FILE="AGENTS.md"
SKILLS_DIR="skills"

# --- Create directories ---
mkdir -p "${OPENCODE_DIR}"
mkdir -p "${OPENCODE_SKILLS}"

# --- Map AGENTS.md -> .opencode/config.md ---
if [ -f "${REPO_ROOT}/${AGENTS_FILE}" ]; then
    cp "${REPO_ROOT}/${AGENTS_FILE}" "${OPENCODE_DIR}/config.md"
    echo "Mapped: ${AGENTS_FILE} -> .opencode/config.md"
else
    echo "WARNING: ${AGENTS_FILE} not found in repository root. Skipping."
fi

# --- Map skills/*/SKILL.md -> .opencode/skills/{skill_name}.md ---
mapped_skills=0
for skill_dir in "${REPO_ROOT}/${SKILLS_DIR}"/*/; do
    skill_file="${skill_dir}SKILL.md"
    if [ -f "${skill_file}" ]; then
        skill_name=$(basename "$skill_dir")
        cp "${skill_file}" "${OPENCODE_SKILLS}/${skill_name}.md"
        echo "Mapped: skills/${skill_name}/SKILL.md -> .opencode/skills/${skill_name}.md"
        mapped_skills=$((mapped_skills + 1))
    fi
done

if [ "${mapped_skills}" -eq 0 ]; then
    echo "NOTE: No skills found in ${SKILLS_DIR}/. Add skills to enable OpenCode skill discovery."
fi

# --- Justfile requires no mapping (OpenCode runs terminal commands directly) ---
echo "Mapped: Justfile -> direct (OpenCode runs terminal commands natively)"

# --- Summary ---
echo ""
echo "OpenCode adapter generation complete."
echo "Config:  ${OPENCODE_DIR}/config.md $([ -f "${OPENCODE_DIR}/config.md" ] && echo "[present]" || echo "[missing]")"
echo "Skills:  ${mapped_skills} skill(s) in ${OPENCODE_SKILLS}/"
echo ""
echo "To verify, run:  ls -la ${OPENCODE_DIR}/ ${OPENCODE_SKILLS}/"
