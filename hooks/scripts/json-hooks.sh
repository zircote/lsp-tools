#!/bin/bash
# Hook - format/lint, pass diagnostics via additionalContext
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0

diagnostics=""
ext="${file_path##*.}"
case "$ext" in
    json|jsonc)
        # Validate JSON
        if command -v jq >/dev/null 2>&1; then
            diagnostics=$(jq empty "$file_path" 2>&1 || true)
        fi
        # Format silently
        command -v prettier >/dev/null && prettier --write "$file_path" 2>/dev/null || true
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
