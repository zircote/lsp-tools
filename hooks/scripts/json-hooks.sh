#!/bin/bash
# JSON development hooks for Claude Code
# Handles: validation, formatting

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    json|jsonc)
        # jq validation
        if command -v jq >/dev/null 2>&1; then
            jq empty "$file_path" 2>&1 || echo "Warning: Invalid JSON in $file_path"
        fi

        # Prettier formatting
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments (in case of JSONC)
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
esac

exit 0
