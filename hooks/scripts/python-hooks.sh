#!/bin/bash
# Python development hooks dispatcher
# Fast-only hooks - heavy commands shown as hints

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
    py)
        # Format with ruff or black (fast - single file)
        if command -v ruff >/dev/null 2>&1; then
            ruff format "$file_path" 2>/dev/null || true
            ruff check --select I --fix "$file_path" 2>/dev/null || true
        elif command -v black >/dev/null 2>&1; then
            black --quiet "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Hints for on-demand commands (no execution)
        echo "💡 ruff check && pyright && pytest"
        ;;

    pyi)
        # Type stub files - just hint
        echo "💡 pyright $file_path"
        ;;

    toml)
        if [[ "$filename" == "pyproject.toml" ]]; then
            # Validate pyproject.toml (fast)
            if command -v python >/dev/null 2>&1; then
                python -c "import tomllib; tomllib.load(open('$file_path', 'rb'))" 2>&1 || echo "⚠️ Invalid TOML syntax"
            fi

            # Hints
            echo "💡 pip-audit  # security audit"
        fi
        ;;

    txt)
        if [[ "$filename" == "requirements.txt" ]]; then
            # Check for unpinned versions (fast - grep only)
            if grep -qE '^[a-zA-Z]' "$file_path" 2>/dev/null; then
                unpinned=$(grep -E '^[a-zA-Z][^=<>]*$' "$file_path" 2>/dev/null | head -5)
                if [ -n "$unpinned" ]; then
                    echo "⚠️ Unpinned dependencies detected:"
                    echo "$unpinned"
                fi
            fi

            echo "💡 pip-audit -r $file_path"
        fi
        ;;

    md)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
