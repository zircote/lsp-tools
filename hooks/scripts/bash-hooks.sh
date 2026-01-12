#!/bin/bash
# Bash/Shell development hooks for Claude Code
# Handles: linting, formatting

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"
filename=$(basename "$file_path")

# Check for shell files by extension or shebang
is_shell=false
case "$ext" in
    sh|bash|zsh|ksh)
        is_shell=true
        ;;
    *)
        # Check shebang for files without extension
        if head -1 "$file_path" 2>/dev/null | grep -qE '^#!.*(bash|sh|zsh|ksh)'; then
            is_shell=true
        fi
        ;;
esac

if [ "$is_shell" = true ]; then
    # ShellCheck (linting)
    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck "$file_path" 2>/dev/null || true
    fi

    # shfmt (formatting)
    if command -v shfmt >/dev/null 2>&1; then
        shfmt -w "$file_path" 2>/dev/null || true
    fi

    # Bash syntax check
    bash -n "$file_path" 2>&1 || true

    # Surface TODO/FIXME comments
    grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
fi

exit 0
