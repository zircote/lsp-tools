#!/bin/bash
# Scala development hooks for Claude Code
# Handles: formatting, linting, building

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    scala|sc)
        # Scalafmt (formatting)
        if command -v scalafmt >/dev/null 2>&1; then
            scalafmt "$file_path" 2>/dev/null || true
        fi

        # Scalafix (linting/refactoring)
        if command -v scalafix >/dev/null 2>&1; then
            scalafix "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
    sbt)
        # Format SBT files
        if command -v scalafmt >/dev/null 2>&1; then
            scalafmt "$file_path" 2>/dev/null || true
        fi
        ;;
esac

exit 0
