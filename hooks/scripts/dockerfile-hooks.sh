#!/bin/bash
# Dockerfile development hooks for Claude Code
# Handles: linting, best practices

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

filename=$(basename "$file_path")
ext="${file_path##*.}"

# Check if it's a Dockerfile
is_dockerfile=false
if [[ "$filename" == "Dockerfile" ]] || [[ "$filename" == Dockerfile.* ]] || [[ "$ext" == "dockerfile" ]]; then
    is_dockerfile=true
fi

if [ "$is_dockerfile" = true ]; then
    # Hadolint (linting)
    if command -v hadolint >/dev/null 2>&1; then
        hadolint "$file_path" 2>/dev/null || true
    fi

    # Dockerfile syntax check via docker
    if command -v docker >/dev/null 2>&1; then
        docker build --check "$file_path" 2>/dev/null || true
    fi

    # Surface TODO/FIXME comments
    grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true
fi

exit 0
