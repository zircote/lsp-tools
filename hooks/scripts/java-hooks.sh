#!/bin/bash
# Java development hooks dispatcher
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
    java)
        # Format with google-java-format if available (fast - single file)
        if command -v google-java-format >/dev/null 2>&1; then
            google-java-format --replace "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Security: Check for common issues (fast - grep only)
        if grep -qE '(Runtime\.getRuntime\(\)\.exec|ProcessBuilder)' "$file_path" 2>/dev/null; then
            echo "⚠️ Command execution detected - ensure proper input validation"
        fi

        # Null safety hint (fast - grep only)
        if grep -qE 'null\s*[!=]=|==\s*null' "$file_path" 2>/dev/null; then
            echo "💡 Consider using @Nullable/@NonNull annotations"
        fi

        # Test file hint
        if [[ "$filename" == *Test.java ]] || [[ "$filename" == *Tests.java ]]; then
            echo "💡 mvn test -Dtest=$(basename "$filename" .java)"
        else
            echo "💡 mvn compile && mvn test"
        fi
        ;;

    xml)
        if [[ "$filename" == "pom.xml" ]]; then
            echo "💡 mvn validate && mvn versions:display-dependency-updates"
        fi
        ;;

    gradle|kts)
        if [[ "$filename" == "build.gradle" ]] || [[ "$filename" == "build.gradle.kts" ]]; then
            echo "💡 ./gradlew compileJava && ./gradlew dependencyUpdates"
        fi
        ;;

    md)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
