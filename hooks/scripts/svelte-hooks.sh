#!/bin/bash
# Svelte development hooks for Claude Code
# Fast-only hooks - heavy commands shown as hints

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    svelte)
        # Prettier formatting (fast - single file)
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" --plugin prettier-plugin-svelte 2>/dev/null || true
        fi

        # ESLint auto-fix (fast - single file)
        if command -v eslint >/dev/null 2>&1; then
            eslint --fix "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true

        # Hints for on-demand commands
        echo "💡 svelte-check && npm test"
        ;;
esac

exit 0
