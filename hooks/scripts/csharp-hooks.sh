#!/bin/bash
# C# development hooks dispatcher
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
dir=$(dirname "$file_path")

# Find project root
find_project_root() {
    local d="$1"
    while [ "$d" != "/" ]; do
        [ -f "$d/*.sln" ] 2>/dev/null && echo "$d" && return
        [ -f "$d/*.csproj" ] 2>/dev/null && echo "$d" && return
        d=$(dirname "$d")
    done
}

project_root=$(find_project_root "$dir")

case "$ext" in
    cs)
        # Format with dotnet format
        if command -v dotnet >/dev/null 2>&1 && [ -n "$project_root" ]; then
            cd "$project_root"
            dotnet format --include "$file_path" 2>/dev/null || true
        fi

        # Build check
        if [ -n "$project_root" ]; then
            cd "$project_root"
            dotnet build --no-restore -v q 2>&1 | tail -20 || true
        fi

        # TODO/FIXME check
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Null safety
        if grep -qE '!\.|\.Value' "$file_path" 2>/dev/null; then
            echo "⚠️ Null-forgiving operator or .Value detected - ensure null safety"
        fi

        # Test file detection
        if [[ "$filename" == *Test.cs ]] || [[ "$filename" == *Tests.cs ]]; then
            echo "💡 Run tests: dotnet test --filter $(basename "$filename" .cs)"
        fi

        # Async/await check
        if grep -qE 'async\s+' "$file_path" 2>/dev/null; then
            if grep -qE '\.Result|\.Wait\(\)' "$file_path" 2>/dev/null; then
                echo "⚠️ Sync-over-async detected (.Result/.Wait) - consider async all the way"
            fi
        fi

        # IDisposable check
        if grep -qE 'new\s+[A-Z].*Connection|new\s+[A-Z].*Stream|new\s+[A-Z].*Client' "$file_path" 2>/dev/null; then
            if ! grep -qE 'using\s*\(' "$file_path" 2>/dev/null; then
                echo "💡 Consider using statement for IDisposable resources"
            fi
        fi
        ;;

    csproj)
        # Restore packages
        if command -v dotnet >/dev/null 2>&1; then
            dotnet restore "$file_path" 2>&1 | tail -10 || true
        fi

        # Security audit
        if command -v dotnet >/dev/null 2>&1; then
            dotnet list "$file_path" package --vulnerable 2>&1 | head -20 || true
        fi

        # Outdated packages
        echo "💡 Check updates: dotnet list package --outdated"
        ;;

    sln)
        if command -v dotnet >/dev/null 2>&1; then
            dotnet build "$file_path" -v q 2>&1 | tail -10 || true
        fi
        ;;

    md)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
