#!/bin/bash
# Hook - format/lint, pass diagnostics via additionalContext
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0

diagnostics=""
ext="${file_path##*.}"
case "$ext" in
    yaml|yml)
        if command -v yamllint >/dev/null 2>&1; then
            diagnostics=$(yamllint -f parsable "$file_path" 2>&1 | grep -E "error|warning" | head -10 || true)
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
