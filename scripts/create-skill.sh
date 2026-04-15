#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ $# -eq 0 ]; then
  echo "Usage: ./scripts/create-skill.sh <skill-name>"
  echo ""
  echo "Skill name must be prefixed with 'mt:' (e.g. mt:my-skill)"
  echo ""
  echo "Examples:"
  echo "  ./scripts/create-skill.sh mt:my-new-skill"
  echo "  ./scripts/create-skill.sh mt:deploy-helper"
  exit 1
fi

SKILL_NAME="$1"

if [[ ! "$SKILL_NAME" =~ ^mt: ]]; then
  echo "Error: Skill name must be prefixed with 'mt:' (got: $SKILL_NAME)"
  exit 1
fi

SKILL_DIR="$REPO_ROOT/skills/$SKILL_NAME"

if [ -d "$SKILL_DIR" ]; then
  echo "Error: Skill '$SKILL_NAME' already exists at $SKILL_DIR"
  exit 1
fi

mkdir -p "$SKILL_DIR"

cat > "$SKILL_DIR/SKILL.md" << SKILLEOF
---
name: $SKILL_NAME
description: "TODO: describe what this skill does and when to use it"
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
---

# $SKILL_NAME

TODO: Add instructions for the agent to follow when this skill is activated.

## When to Use

TODO: Describe the scenarios where this skill should be used.

## Steps

1. TODO: First step
2. TODO: Second step
SKILLEOF

echo "Created $SKILL_DIR/SKILL.md"
echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_DIR/SKILL.md with your skill instructions"
echo "  2. Test: npx skills add ./mt-skills --skill $SKILL_NAME -a claude-code"
echo "  3. Commit and push to publish to skills.sh"
