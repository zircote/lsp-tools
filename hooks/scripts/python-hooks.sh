#!/bin/bash
# Python hooks - format silently, lint with error output only
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

case "$ext" in
    py|pyi)
        # Format silently
        if command -v ruff >/dev/null 2>&1; then
            ruff format "$file_path" 2>/dev/null || true
            # Lint - output only errors
            ruff check "$file_path" 2>&1 | head -20 || true
        elif command -v black >/dev/null 2>&1; then
            black -q "$file_path" 2>/dev/null || true
        fi
        ;;
esac
exit 0
