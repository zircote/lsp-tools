#!/bin/bash
# JSON hooks - validate and format
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

case "$ext" in
    json|jsonc)
        # Validate JSON - output errors only
        if command -v jq >/dev/null 2>&1; then
            jq empty "$file_path" 2>&1 || true
        fi
        # Format silently
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        fi
        ;;
esac
exit 0
