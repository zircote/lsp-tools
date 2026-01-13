#!/bin/bash
# Go hooks - format silently, pass diagnostics via additionalContext
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

diagnostics=""

case "$ext" in
    go)
        # Format silently
        command -v gofmt >/dev/null && gofmt -w "$file_path" 2>/dev/null || true
        command -v goimports >/dev/null && goimports -w "$file_path" 2>/dev/null || true
        # Collect vet diagnostics
        diagnostics=$(go vet "$file_path" 2>&1 | head -15 || true)
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
