#!/bin/bash
# Ruby development hooks dispatcher
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
    rb|rake)
        # Syntax check (fast)
        ruby -c "$file_path" 2>&1 | head -10 || true

        # Format with RuboCop auto-correct (fast - single file)
        if command -v rubocop >/dev/null 2>&1; then
            rubocop -a "$file_path" 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -nE '(TODO|FIXME|XXX|HACK):?' "$file_path" 2>/dev/null | head -10 || true

        # SQL injection check (fast - grep only)
        if grep -qE 'where\s*\(\s*["\x27].*#\{' "$file_path" 2>/dev/null; then
            echo "⚠️ Potential SQL injection - use parameterized queries"
        fi

        # Test file hint
        if [[ "$filename" == *_spec.rb ]]; then
            echo "💡 bundle exec rspec $file_path"
        elif [[ "$filename" == *_test.rb ]] || [[ "$filename" == test_*.rb ]]; then
            echo "💡 bundle exec ruby $file_path"
        else
            echo "💡 rubocop && bundle exec rspec"
        fi
        ;;

    gemspec)
        echo "💡 gem build $file_path"
        ;;

    Gemfile|gemfile)
        echo "💡 bundle check && bundle-audit check"
        ;;

    yml|yaml)
        # YAML syntax check (fast)
        if command -v ruby >/dev/null 2>&1; then
            ruby -e "require 'yaml'; YAML.load_file('$file_path')" 2>&1 || echo "⚠️ Invalid YAML syntax"
        fi
        ;;

    md)
        if command -v markdownlint >/dev/null 2>&1; then
            markdownlint "$file_path" 2>&1 | head -20 || true
        fi
        ;;
esac

exit 0
