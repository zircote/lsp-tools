#!/bin/bash
# TypeScript hooks - format silently, pass diagnostics via additionalContext
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

diagnostics=""

case "$ext" in
    ts|tsx|js|jsx|mts|cts|mjs|cjs)
        # Format silently
        command -v prettier >/dev/null && prettier --write "$file_path" 2>/dev/null || true
        # Collect ESLint diagnostics
        if command -v eslint >/dev/null 2>&1; then
            diagnostics=$(eslint --format compact "$file_path" 2>&1 | grep -E "Error|Warning" | head -15 || true)
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
