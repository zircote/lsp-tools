#!/bin/bash
# Dockerfile hooks - lint with error output only
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0

filename=$(basename "$file_path")
if [[ "$filename" == "Dockerfile" || "$filename" == Dockerfile.* ]]; then
    if command -v hadolint >/dev/null 2>&1; then
        hadolint "$file_path" 2>&1 | head -10 || true
    fi
fi
exit 0
