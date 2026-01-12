#!/bin/bash
# HTML/CSS development hooks for Claude Code
# Handles: validation, formatting, linting

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    html|htm)
        # Prettier formatting
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        fi

        # HTMLHint linting
        if command -v htmlhint >/dev/null 2>&1; then
            htmlhint "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
    css)
        # Prettier formatting
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        fi

        # Stylelint linting
        if command -v stylelint >/dev/null 2>&1; then
            stylelint "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
    scss|less)
        # Prettier formatting
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        fi

        # Stylelint linting
        if command -v stylelint >/dev/null 2>&1; then
            stylelint "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
esac

exit 0
