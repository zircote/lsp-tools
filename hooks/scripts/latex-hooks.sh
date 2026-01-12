#!/bin/bash
# LaTeX development hooks for Claude Code
# Handles: linting, building

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    tex|cls|sty)
        # ChkTeX (linting)
        if command -v chktex >/dev/null 2>&1; then
            chktex "$file_path" 2>/dev/null || true
        fi

        # lacheck (additional linting)
        if command -v lacheck >/dev/null 2>&1; then
            lacheck "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
    bib)
        # biber validation
        if command -v biber >/dev/null 2>&1; then
            biber --validate-datamodel "$file_path" 2>/dev/null || true
        fi
        ;;
esac

exit 0
