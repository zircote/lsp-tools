#!/bin/bash
# YAML development hooks for Claude Code
# Handles: validation, formatting

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    yaml|yml)
        # yamllint (validation)
        if command -v yamllint >/dev/null 2>&1; then
            yamllint "$file_path" 2>/dev/null || true
        fi

        # prettier (formatting)
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        fi

        # yq validation (check valid YAML)
        if command -v yq >/dev/null 2>&1; then
            yq eval '.' "$file_path" >/dev/null 2>&1 || echo "Warning: Invalid YAML in $file_path"
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
esac

exit 0
