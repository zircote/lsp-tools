#!/bin/bash
# Kotlin development hooks dispatcher
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
    kt|kts)
        # Format with ktlint (fast - single file)
        if command -v ktlint >/dev/null 2>&1; then
            ktlint -F "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Null safety check (fast - grep only)
        bang_count=$(grep -c '!!' "$file_path" 2>/dev/null || echo "0")
        if [ "$bang_count" -gt 0 ]; then
            echo "⚠️ $bang_count non-null assertions (!!) detected - consider safer alternatives"
        fi

        # Coroutines hint (fast - grep only)
        if grep -qE 'suspend\s+fun|launch\s*\{|async\s*\{' "$file_path" 2>/dev/null; then
            echo "📝 Coroutines detected - ensure proper scope and exception handling"
        fi

        # Test file hint
        if [[ "$filename" == *Test.kt ]] || [[ "$filename" == *Tests.kt ]]; then
            echo "💡 ./gradlew test --tests $(basename "$filename" .kt)"
        else
            echo "💡 ./gradlew compileKotlin && ./gradlew test"
        fi
        ;;

    gradle)
        echo "💡 ./gradlew compileKotlin && ./gradlew dependencyUpdates"
        ;;

    md)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
