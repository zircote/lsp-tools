#!/bin/bash
# Bash hooks - format silently, pass diagnostics via additionalContext
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

diagnostics=""

case "$ext" in
    sh|bash|zsh|ksh)
        # Format silently
        command -v shfmt >/dev/null && shfmt -w "$file_path" 2>/dev/null || true
        # Collect ShellCheck diagnostics
        if command -v shellcheck >/dev/null 2>&1; then
            diagnostics=$(shellcheck -f gcc "$file_path" 2>&1 | head -15 || true)
        fi
        ;;
esac

if [[ -n "$diagnostics" ]]; then
    escaped=$(echo "$diagnostics" | jq -Rs .)
    cat <<JSONEOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $escaped
  }
}
JSONEOF
fi

exit 0
