#!/bin/bash
# Bash hooks - format silently, lint with error output only
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

case "$ext" in
    sh|bash|zsh|ksh)
        # Format silently
        command -v shfmt >/dev/null && shfmt -w "$file_path" 2>/dev/null || true
        # ShellCheck - output only errors/warnings
        if command -v shellcheck >/dev/null 2>&1; then
            shellcheck -f gcc "$file_path" 2>&1 | head -15 || true
        fi
        ;;
esac
exit 0
