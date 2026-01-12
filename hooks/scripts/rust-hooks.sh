#!/bin/bash
# Rust development hooks dispatcher
# Reads tool input from stdin and runs appropriate checks based on file type

set -o pipefail

# Read JSON input from stdin
input=$(cat)

# Extract file path from tool_input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Exit if no file path
[ -z "$file_path" ] && exit 0

# Get file extension and name
ext="${file_path##*.}"
filename=$(basename "$file_path")

case "$ext" in
    rs)
        # Format (fast - local file only)
        rustfmt "$file_path" 2>/dev/null || true

        # Unsafe detector (fast - grep only)
        if grep -qn 'unsafe' "$file_path" 2>/dev/null; then
            grep -n 'unsafe' "$file_path" | head -5
            echo '⚠️  Unsafe code detected'
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Hints for on-demand commands (no execution)
        echo "💡 cargo check && cargo clippy && cargo test"
        ;;

    md)
        # Markdown lint
        if command -v npx >/dev/null 2>&1; then
            npx markdownlint-cli "$file_path" 2>&1 | head -20 || true
        fi
        ;;

    toml)
        if [[ "$filename" == "Cargo.toml" ]]; then
            # Hints for on-demand dependency analysis (no execution)
            echo "💡 cargo audit && cargo outdated --depth 1"
            echo "💡 cargo machete  # find unused deps"
        fi
        ;;

    lock)
        if [[ "$filename" == "Cargo.lock" ]]; then
            echo "💡 cargo audit  # check for vulnerabilities"
        fi
        ;;
esac

exit 0
