#!/bin/bash
# Rust hooks - format silently, output only on errors
set -o pipefail
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
ext="${file_path##*.}"

case "$ext" in
    rs)
        # Format silently
        command -v rustfmt >/dev/null && rustfmt "$file_path" 2>/dev/null || true
        # Clippy output only if errors (run on file's crate)
        dir=$(dirname "$file_path")
        while [[ "$dir" != "/" && ! -f "$dir/Cargo.toml" ]]; do dir=$(dirname "$dir"); done
        if [[ -f "$dir/Cargo.toml" ]]; then
            cd "$dir" && cargo clippy --message-format=short 2>&1 | grep -E "^error|^warning" | head -10 || true
        fi
        ;;
esac
exit 0
