#!/bin/bash
# Swift development hooks for Claude Code
# Fast-only hooks - heavy commands shown as hints

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    swift)
        # SwiftFormat (fast - single file)
        if command -v swiftformat >/dev/null 2>&1; then
            swiftformat "$file_path" --quiet 2>/dev/null || true
        fi

        # SwiftLint auto-correct (fast - single file)
        if command -v swiftlint >/dev/null 2>&1; then
            swiftlint lint --path "$file_path" --quiet 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true

        # Hints for on-demand commands
        echo "💡 swiftc -parse && swift build && swift test"
        ;;
esac

exit 0
