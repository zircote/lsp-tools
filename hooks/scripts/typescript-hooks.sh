#!/bin/bash
# TypeScript/JavaScript development hooks dispatcher
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
    ts|tsx|js|jsx|mts|cts|mjs|cjs)
        # Format with prettier or biome (fast - single file)
        if command -v prettier >/dev/null 2>&1; then
            prettier --write "$file_path" 2>/dev/null || true
        elif command -v biome >/dev/null 2>&1; then
            biome format --write "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Security: Check for common issues (fast - grep only)
        if grep -qE '(eval\(|innerHTML\s*=|document\.write)' "$file_path" 2>/dev/null; then
            echo "⚠️ Potential security issue: eval/innerHTML/document.write detected"
        fi

        # Console.log detection (fast - grep only)
        if [[ ! "$filename" =~ (test|spec)\. ]] && grep -qn 'console\.' "$file_path" 2>/dev/null; then
            grep -n 'console\.' "$file_path" | head -5
            echo "💡 Consider removing console statements for production"
        fi

        # Hints for on-demand commands
        echo "💡 npx tsc --noEmit && npx eslint . && npm test"
        ;;

    json)
        # Validate JSON syntax (fast)
        if ! jq empty "$file_path" 2>/dev/null; then
            echo "⚠️ Invalid JSON syntax in $filename"
        fi

        if [[ "$filename" == "package.json" ]]; then
            echo "💡 npm audit && npm outdated"
        fi

        if [[ "$filename" == "tsconfig.json" ]]; then
            echo "💡 npx tsc --showConfig"
        fi
        ;;

    md)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
