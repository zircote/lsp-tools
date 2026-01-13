#!/bin/bash
# Hook - format/lint, pass diagnostics via additionalContext
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0

diagnostics=""
filename=$(basename "$file_path")
if [[ "$filename" == "Dockerfile" || "$filename" == Dockerfile.* ]]; then
    if command -v hadolint >/dev/null 2>&1; then
        diagnostics=$(hadolint "$file_path" 2>&1 | head -10 || true)
    fi
fi

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
