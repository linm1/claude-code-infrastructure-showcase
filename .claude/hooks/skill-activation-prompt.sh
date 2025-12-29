#!/bin/bash
set -e

# Windows compatibility: use current directory if CLAUDE_PROJECT_DIR not set
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

cd "$PROJECT_DIR/.claude/hooks"
cat | npx tsx skill-activation-prompt.ts
