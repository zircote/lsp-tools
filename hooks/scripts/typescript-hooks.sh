#!/bin/bash
# TypeScript hooks - format silently, lint with error output only
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

case "$ext" in
    ts|tsx|js|jsx|mts|cts|mjs|cjs)
        # Format silently
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        fi
        # ESLint - output only errors
        if command -v eslint >/dev/null 2>&1; then
            eslint --format compact "$file_path" 2>&1 | grep -E "Error|Warning" | head -10 || true
        fi
        ;;
esac
exit 0
