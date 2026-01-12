#!/bin/bash
# Haskell development hooks for Claude Code
# Handles: linting, formatting

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    hs|lhs)
        # Ormolu (formatting)
        if command -v ormolu >/dev/null 2>&1; then
            ormolu --mode inplace "$file_path" 2>/dev/null || true
        # Or use fourmolu
        elif command -v fourmolu >/dev/null 2>&1; then
            fourmolu --mode inplace "$file_path" 2>/dev/null || true
        fi

        # HLint (linting)
        if command -v hlint >/dev/null 2>&1; then
            hlint "$file_path" 2>/dev/null || true
        fi

        # Stan (static analysis)
        if command -v stan >/dev/null 2>&1; then
            stan "$file_path" 2>/dev/null || true
        fi

        # Surface TODO/FIXME comments
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
        ;;
esac

exit 0
