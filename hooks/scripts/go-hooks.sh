#!/bin/bash
# Go development hooks dispatcher
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
    go)
        # Format with gofmt or goimports (fast - single file)
        if command -v goimports >/dev/null 2>&1; then
            goimports -w "$file_path" 2>/dev/null || true
        else
            gofmt -w "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Error handling check (fast - grep only)
        if grep -qE 'err\s*:?=.*\n\s*[^if]' "$file_path" 2>/dev/null; then
            echo "⚠️ Possible unhandled error - ensure all errors are checked"
        fi

        # Hints for on-demand commands (no execution)
        echo "💡 go vet && go build && go test"
        ;;

    mod)
        if [[ "$filename" == "go.mod" ]]; then
            # Hints for on-demand commands
            echo "💡 go mod tidy && go mod verify"
            echo "💡 govulncheck ./...  # security check"
        fi
        ;;

    sum)
        if [[ "$filename" == "go.sum" ]]; then
            echo "💡 go mod verify"
        fi
        ;;

    md)
        # Markdown lint (fast)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
