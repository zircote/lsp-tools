#!/bin/bash
# SQL development hooks for Claude Code
# Handles: formatting, linting

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    sql)
        # sqlfluff (linting and formatting)
        if command -v sqlfluff >/dev/null 2>&1; then
            sqlfluff fix "$file_path" 2>/dev/null || true
            sqlfluff lint "$file_path" 2>/dev/null || true
        fi

        # sqlfmt (formatting alternative)
        if command -v sqlfmt >/dev/null 2>&1; then
            sqlfmt "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
esac

exit 0
