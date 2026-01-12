#!/bin/bash
# Elixir development hooks for Claude Code
# Fast-only hooks - heavy commands shown as hints

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    ex|exs)
        # Mix format (fast - single file)
        if command -v mix >/dev/null 2>&1; then
            mix format "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true

        # Hints for on-demand commands
        echo "💡 mix credo --strict && mix test"
        ;;
    eex|heex|leex)
        # Format templates (fast - single file)
        if command -v mix >/dev/null 2>&1; then
            mix format "$file_path" 2>/dev/null || true
        fi
        ;;
esac

exit 0
