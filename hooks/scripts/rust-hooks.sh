#!/bin/bash
# Rust hooks - format silently, pass diagnostics via additionalContext
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

diagnostics=""

case "$ext" in
    rs)
        # Format silently
        command -v rustfmt >/dev/null && rustfmt "$file_path" 2>/dev/null || true
        
        # Collect clippy diagnostics
        dir=$(dirname "$file_path")
        while [[ "$dir" != "/" && ! -f "$dir/Cargo.toml" ]]; do dir=$(dirname "$dir"); done
        if [[ -f "$dir/Cargo.toml" ]] && command -v cargo >/dev/null 2>&1; then
            diagnostics=$(cd "$dir" && cargo clippy --message-format=short 2>&1 | grep -E "^error|^warning" | head -15 || true)
        fi
        ;;
esac

# Output JSON with additionalContext if we have diagnostics
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
