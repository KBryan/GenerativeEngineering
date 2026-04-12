#!/usr/bin/env bash
# Agent Zero Adapter — Generate Script
# Reads universal skill definitions and writes them to Agent Zero's skill directory.
#
# Note: AGENTS.md needs NO mapping — Agent Zero reads it natively from the project root.
# Only skills need to be copied to usr/skills/.
#
# Usage: bash adapters/agent-zero/generate.sh

set -euo pipefail

# --- Configuration ---
A0_SKILLS_DIR="usr/skills"
UNIVERSAL_SKILLS_DIR="skills"

# --- Create skills directory ---
mkdir -p "$A0_SKILLS_DIR"

# --- Map skills/*/SKILL.md → usr/skills/{name}/SKILL.md ---
mapped_skills=0
for skill_dir in "${UNIVERSAL_SKILLS_DIR}"/*/; do
    skill_file="${skill_dir}SKILL.md"
    if [ -f "$skill_file" ]; then
        skill_name=$(basename "$skill_dir")
        target_dir="${A0_SKILLS_DIR}/${skill_name}"
        mkdir -p "$target_dir"
        cp "$skill_file" "${target_dir}/SKILL.md"
        echo "Mapped: ${skill_file} → ${target_dir}/SKILL.md"
        mapped_skills=$((mapped_skills + 1))
    fi
done

if [ "$mapped_skills" -eq 0 ]; then
    echo "NOTE: No skills found in ${UNIVERSAL_SKILLS_DIR}/. Add skills to enable Agent Zero skill discovery."
fi

# --- Summary ---
echo ""
echo "Agent Zero adapter generation complete."
echo "AGENTS.md: Read natively from project root (no copy needed)"
echo "Skills:    ${mapped_skills} skill(s) in ${A0_SKILLS_DIR}/"
echo ""
echo "To verify, run:  ls -la ${A0_SKILLS_DIR}/"
