#!/bin/bash
# Silent hook - formatting only, no output
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
# Formatter would run here if configured
exit 0
