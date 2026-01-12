#!/bin/bash
# Zig development hooks for Claude Code
# Handles: formatting, building

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    zig|zon)
        # Zig fmt (formatting)
        if command -v zig >/dev/null 2>&1; then
            zig fmt "$file_path" 2>/dev/null || true
        fi

        # Zig check (syntax validation)
        # Note: This requires a build.zig in the project
        # if command -v zig >/dev/null 2>&1; then
        #     zig build --summary none 2>/dev/null || true
        # fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
esac

exit 0
