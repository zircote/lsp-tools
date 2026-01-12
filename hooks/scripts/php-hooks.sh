#!/bin/bash
# PHP development hooks for Claude Code
# Fast-only hooks - heavy commands shown as hints

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"

case "$ext" in
    php|phtml)
        # Syntax check (fast)
        php -l "$file_path" 2>&1 || true

        # PHP-CS-Fixer formatting (fast - single file)
        if command -v php-cs-fixer >/dev/null 2>&1; then
            php-cs-fixer fix "$file_path" --quiet 2>/dev/null || true
        fi

        # TODO/FIXME check (fast - grep only)
        grep -n -E '(TODO|FIXME|HACK|XXX|BUG):' "$file_path" 2>/dev/null || true

        # Hints for on-demand commands
        echo "💡 phpstan analyse && phpcs --standard=PSR12"
        ;;
esac

exit 0
