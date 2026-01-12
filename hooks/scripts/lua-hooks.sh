#!/bin/bash
# Lua development hooks for Claude Code
# Handles: linting, formatting

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    lua)
        # StyLua (formatting)
        if command -v stylua >/dev/null 2>&1; then
            stylua "$file_path" 2>/dev/null || true
        fi

        # Luacheck (linting)
        if command -v luacheck >/dev/null 2>&1; then
            luacheck "$file_path" 2>/dev/null || true
        fi

        # Lua syntax check
        if command -v luac >/dev/null 2>&1; then
            luac -p "$file_path" 2>&1 || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
esac

exit 0
