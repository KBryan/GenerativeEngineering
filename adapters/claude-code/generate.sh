#!/usr/bin/env bash
# Claude Code Adapter — Generate Script
# Reads universal framework files and writes them to Claude Code's expected locations.
#
# Usage: bash adapters/claude-code/generate.sh

set -euo pipefail

# --- Configuration ---
CLAUDE_DIR=".claude"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
AGENTS_FILE="AGENTS.md"
SKILLS_DIR="skills"

# --- Create directories ---
mkdir -p "$CLAUDE_DIR"
mkdir -p "$COMMANDS_DIR"

# --- Map AGENTS.md → .claude/CLAUDE.md ---
if [ -f "$AGENTS_FILE" ]; then
    cp "$AGENTS_FILE" "${CLAUDE_DIR}/CLAUDE.md"
    echo "Mapped: $AGENTS_FILE → ${CLAUDE_DIR}/CLAUDE.md"
else
    echo "WARNING: $AGENTS_FILE not found in repository root. Skipping."
fi

# --- Map skills/*/SKILL.md → .claude/commands/{skill_name}.md ---
mapped_skills=0
for skill_dir in "${SKILLS_DIR}"/*/; do
    skill_file="${skill_dir}SKILL.md"
    if [ -f "$skill_file" ]; then
        skill_name=$(basename "$skill_dir")
        cp "$skill_file" "${COMMANDS_DIR}/${skill_name}.md"
        echo "Mapped: ${skill_file} → ${COMMANDS_DIR}/${skill_name}.md"
        mapped_skills=$((mapped_skills + 1))
    fi
done

if [ "$mapped_skills" -eq 0 ]; then
    echo "NOTE: No skills found in ${SKILLS_DIR}/. Add skills to enable Claude Code slash commands."
fi

# --- Summary ---
echo ""
echo "Claude Code adapter generation complete."
echo "Config:  ${CLAUDE_DIR}/CLAUDE.md"
echo "Skills:  ${mapped_skills} command(s) in ${COMMANDS_DIR}/"
echo ""
echo "To verify, run:  ls -la ${CLAUDE_DIR}/ ${COMMANDS_DIR}/"
