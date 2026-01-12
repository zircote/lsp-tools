#!/bin/bash
# LSP Tools - Master Hook Dispatcher
# Routes hook calls to language-specific scripts based on file extension
# Handles: PostToolUse (non-blocking), PreToolUse (blocking pre-commit)

set -o pipefail

# Determine paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$HOOKS_DIR/.." && pwd)}"
CONFIG_FILE="$HOOKS_DIR/hooks-config.json"

# Mode: post (default) or pre-commit
MODE="${1:-post}"

# Debug mode
DEBUG="${LSP_HOOKS_DEBUG:-0}"
debug_log() {
	[[ "$DEBUG" == "1" ]] && echo "[DEBUG] $*" >&2
}

# Load and validate config
load_config() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		debug_log "Config file not found: $CONFIG_FILE"
		return 1
	fi

	# Validate JSON syntax
	if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
		echo "Error: Invalid JSON in $CONFIG_FILE" >&2
		return 1
	fi

	return 0
}

# Check if hooks are globally enabled
is_globally_enabled() {
	local enabled
	enabled=$(jq -r '.global.enabled // true' "$CONFIG_FILE" 2>/dev/null)
	[[ "$enabled" == "true" ]]
}

# Get config value
get_config() {
	local path="$1"
	local default="$2"
	jq -r "$path // \"$default\"" "$CONFIG_FILE" 2>/dev/null
}

# Map file extension to language
map_extension_to_language() {
	local file_path="$1"
	local filename ext language

	filename=$(basename "$file_path")
	ext="${file_path##*.}"

	# Special case: Dockerfile (no extension or special patterns)
	if [[ "$filename" == "Dockerfile" ]] || [[ "$filename" == Dockerfile.* ]]; then
		echo "dockerfile"
		return 0
	fi

	# Special case: files with specific names
	case "$filename" in
	Gemfile | Rakefile)
		echo "ruby"
		return 0
		;;
	go.mod | go.sum)
		echo "go"
		return 0
		;;
	Cargo.toml | Cargo.lock)
		echo "rust"
		return 0
		;;
	package.json | tsconfig.json)
		echo "typescript"
		return 0
		;;
	pyproject.toml | requirements.txt)
		echo "python"
		return 0
		;;
	terragrunt.hcl)
		echo "terraform"
		return 0
		;;
	esac

	# Handle no extension
	if [[ "$ext" == "$filename" ]]; then
		# Check shebang for shell scripts
		if [[ -f "$file_path" ]]; then
			if head -1 "$file_path" 2>/dev/null | grep -qE '^#!.*(bash|sh|zsh|ksh)'; then
				echo "bash"
				return 0
			fi
		fi
		return 1
	fi

	# Look up extension in config
	language=$(jq -r --arg ext "$ext" '.extensions[$ext] // empty' "$CONFIG_FILE" 2>/dev/null)

	if [[ -n "$language" ]]; then
		echo "$language"
		return 0
	fi

	return 1
}

# Check if language is enabled
is_language_enabled() {
	local language="$1"
	local enabled
	enabled=$(jq -r --arg lang "$language" '.languages[$lang].enabled // false' "$CONFIG_FILE" 2>/dev/null)
	[[ "$enabled" == "true" ]]
}

# Get language script path
get_language_script() {
	local language="$1"
	local script_path
	script_path=$(jq -r --arg lang "$language" '.languages[$lang].script // empty' "$CONFIG_FILE" 2>/dev/null)

	if [[ -z "$script_path" ]]; then
		return 1
	fi

	# Resolve relative path from hooks directory
	local full_path="$HOOKS_DIR/$script_path"

	if [[ -f "$full_path" ]]; then
		echo "$full_path"
		return 0
	fi

	debug_log "Script not found: $full_path"
	return 1
}

# Handle PostToolUse - non-blocking file edit hooks
handle_post_tool_use() {
	# Read JSON input from stdin
	local input
	input=$(cat)

	# Extract file path
	local file_path
	file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

	if [[ -z "$file_path" ]]; then
		debug_log "No file_path in input"
		exit 0
	fi

	# Skip if file doesn't exist
	if [[ ! -f "$file_path" ]]; then
		debug_log "File does not exist: $file_path"
		exit 0
	fi

	debug_log "Processing file: $file_path"

	# Determine language from extension
	local language
	language=$(map_extension_to_language "$file_path")

	if [[ -z "$language" ]]; then
		debug_log "No language mapping for file: $file_path"
		exit 0
	fi

	debug_log "Detected language: $language"

	# Check if language is enabled
	if ! is_language_enabled "$language"; then
		debug_log "Language disabled: $language"
		exit 0
	fi

	# Get script path
	local script_path
	script_path=$(get_language_script "$language")

	if [[ -z "$script_path" ]]; then
		debug_log "No script for language: $language"
		exit 0
	fi

	debug_log "Using script: $script_path"

	# Ensure script is executable
	if [[ ! -x "$script_path" ]]; then
		chmod +x "$script_path" 2>/dev/null || true
	fi

	# Check parallel execution config
	local parallel_exec
	parallel_exec=$(get_config '.global.parallelExecution' 'true')

	# Export environment variables for the script
	export CLAUDE_FILE_PATH="$file_path"
	export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"
	export CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

	# Execute language script
	if [[ "$parallel_exec" == "true" ]]; then
		# Run in background subshell for parallel execution
		(
			echo "$input" | bash "$script_path" 2>&1 || true
		) &

		# Wait with timeout (10 seconds)
		local pid=$!
		local timeout=10
		local count=0
		while kill -0 $pid 2>/dev/null && [[ $count -lt $((timeout * 10)) ]]; do
			sleep 0.1
			((count++))
		done

		# Kill if still running
		if kill -0 $pid 2>/dev/null; then
			kill $pid 2>/dev/null || true
			debug_log "Script timed out after ${timeout}s"
		fi
	else
		# Run synchronously
		echo "$input" | bash "$script_path" 2>&1 || true
	fi

	exit 0
}

# Handle PreToolUse - blocking pre-commit quality gate
handle_pre_commit() {
	# Read JSON input from stdin
	local input
	input=$(cat)

	# Extract tool input (the bash command)
	local tool_input
	tool_input=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

	# Only process git commit commands
	if ! echo "$tool_input" | grep -qE 'git\s+commit'; then
		exit 0
	fi

	debug_log "Pre-commit check triggered"

	# Get list of staged files
	local staged_files
	staged_files=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || echo "")

	if [[ -z "$staged_files" ]]; then
		debug_log "No staged files"
		exit 0
	fi

	# Collect unique languages from staged files
	declare -A languages_map
	while IFS= read -r file; do
		[[ -z "$file" ]] && continue
		local lang
		lang=$(map_extension_to_language "$file" 2>/dev/null)
		if [[ -n "$lang" ]]; then
			languages_map["$lang"]=1
		fi
	done <<<"$staged_files"

	if [[ ${#languages_map[@]} -eq 0 ]]; then
		debug_log "No recognized languages in staged files"
		exit 0
	fi

	# Run pre-commit checks for each language
	local has_failures=0

	for language in "${!languages_map[@]}"; do
		# Check if language is enabled
		if ! is_language_enabled "$language"; then
			continue
		fi

		# Check if pre-commit is enabled for this language
		local pre_commit_enabled
		pre_commit_enabled=$(jq -r --arg lang "$language" '.languages[$lang].preCommit.enabled // false' "$CONFIG_FILE" 2>/dev/null)

		if [[ "$pre_commit_enabled" != "true" ]]; then
			continue
		fi

		# Get pre-commit command
		local pre_commit_cmd
		pre_commit_cmd=$(jq -r --arg lang "$language" '.languages[$lang].preCommit.command // empty' "$CONFIG_FILE" 2>/dev/null)

		if [[ -z "$pre_commit_cmd" ]]; then
			continue
		fi

		echo "Running pre-commit checks for $language..."

		# Export environment
		export CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

		# Execute pre-commit command (blocking)
		if ! eval "$pre_commit_cmd"; then
			echo "Pre-commit checks FAILED for $language"
			has_failures=1
		else
			echo "Pre-commit checks passed for $language"
		fi
	done

	if [[ $has_failures -eq 1 ]]; then
		echo ""
		echo "Pre-commit quality gate failed. Fix issues before committing."
		exit 1
	fi

	exit 0
}

# Main entry point
main() {
	# Load configuration
	if ! load_config; then
		debug_log "Failed to load config, exiting"
		exit 0
	fi

	# Check if globally enabled
	if ! is_globally_enabled; then
		debug_log "Hooks globally disabled"
		exit 0
	fi

	# Route based on mode
	case "$MODE" in
	post | --post | --post-tool-use)
		handle_post_tool_use
		;;
	pre | --pre | --pre-commit)
		handle_pre_commit
		;;
	*)
		echo "Unknown mode: $MODE" >&2
		echo "Usage: $0 [post|pre]" >&2
		exit 1
		;;
	esac
}

# Run main
main
