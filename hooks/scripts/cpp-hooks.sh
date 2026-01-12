#!/bin/bash
# C/C++ development hooks dispatcher
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
    c|h)
        # Format with clang-format (fast - single file)
        if command -v clang-format >/dev/null 2>&1; then
            clang-format -i "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Memory safety hints (fast - grep only)
        if grep -qE '(malloc|calloc|realloc|free)\s*\(' "$file_path" 2>/dev/null; then
            echo "📝 Manual memory management detected - ensure matching free() calls"
        fi

        # Hints for on-demand commands
        echo "💡 clang -fsyntax-only -Wall && clang-tidy"
        ;;

    cpp|cc|cxx|hpp|hxx|hh)
        # Format with clang-format (fast - single file)
        if command -v clang-format >/dev/null 2>&1; then
            clang-format -i "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # Modern C++ hints (fast - grep only)
        if grep -qE 'new\s+[A-Z]|delete\s+' "$file_path" 2>/dev/null; then
            echo "💡 Raw new/delete detected - consider smart pointers"
        fi

        # Hints for on-demand commands
        echo "💡 clang++ -fsyntax-only -std=c++17 -Wall && cppcheck"
        ;;

    cmake)
        if [[ "$filename" == "CMakeLists.txt" ]]; then
            echo "💡 cmake -B build -S . && cmake --build build"
        fi
        ;;

    md)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
