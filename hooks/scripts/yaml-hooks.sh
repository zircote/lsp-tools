#!/bin/bash
# YAML hooks - lint with error output only
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

case "$ext" in
    yaml|yml)
        if command -v yamllint >/dev/null 2>&1; then
            yamllint -f parsable "$file_path" 2>&1 | grep -E "error|warning" | head -10 || true
        fi
        ;;
esac
exit 0
