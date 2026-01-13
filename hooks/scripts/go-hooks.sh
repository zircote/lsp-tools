#!/bin/bash
# Go hooks - format silently, lint with error output only
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

case "$ext" in
    go)
        # Format silently
        command -v gofmt >/dev/null && gofmt -w "$file_path" 2>/dev/null || true
        command -v goimports >/dev/null && goimports -w "$file_path" 2>/dev/null || true
        # Vet - output only errors
        go vet "$file_path" 2>&1 | head -10 || true
        ;;
esac
exit 0
