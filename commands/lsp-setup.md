---
name: lsp-setup
description: Set up LSP hooks and CLAUDE.md sections for the current project
argument-hint: "[language] or auto-detect"
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - AskUserQuestion
---

<help_check>
## Help Check

If `$ARGUMENTS` contains `--help` or `-h`:

**Output this help and HALT (do not proceed further):**

<help_output>
```
LSP_SETUP(1)                                         User Commands                                         LSP_SETUP(1)

NAME
    lsp-setup - Set up LSP hooks, verify servers, and configure CLAUDE.md

SYNOPSIS
    /lsp-tools:lsp-setup [language...] [options]

DESCRIPTION
    Complete LSP toolchain setup: detects languages (including Markdown and
    Terraform), verifies LSP servers are installed, offers to install missing
    servers, configures hooks, and updates CLAUDE.md with LSP guidance.

    SPECIALIZED PLUGINS: If zircote/*-lsp plugins are installed (rust-lsp,
    terraform-lsp, markdown-lsp), hooks for those languages are skipped since
    the specialized plugins provide their own hooks.

OPTIONS
    --help, -h           Show this help message
    --skip-install       Skip LSP server installation prompts
    --skip-hooks         Skip hooks installation
    --skip-claudemd      Skip CLAUDE.md modifications
    --verify-only        Only verify LSP servers, don't install anything

LANGUAGES
    TypeScript/JavaScript, Python, Go, Rust, Java, Kotlin, C/C++, C#,
    PHP, Ruby, HTML/CSS, LaTeX, Markdown, Terraform

SPECIALIZED PLUGINS (hooks provided by plugin, not lsp-tools)
    zircote/rust-lsp       16 hooks (clippy, security, dependencies)
    zircote/terraform-lsp  17 hooks (tflint, trivy, checkov, terragrunt)
    zircote/markdown-lsp   4 hooks (links, frontmatter, code blocks, syntax)

EXAMPLES
    /lsp-tools:lsp-setup                     Auto-detect and full setup
    /lsp-tools:lsp-setup typescript python   Setup specific languages
    /lsp-tools:lsp-setup --verify-only       Check LSP server status
    /lsp-tools:lsp-setup --skip-install      Setup hooks only

SEE ALSO
    /lsp-tools:* for related commands

                                                                      LSP_SETUP(1)
```
</help_output>

**After outputting help, HALT immediately. Do not proceed with command execution.**
</help_check>

---

# LSP Setup Command

Complete Language Server Protocol toolchain setup for the current project.

## What This Command Does

1. Detects languages used in the project (or accepts explicit language arguments)
2. **Detects installed `zircote/*-lsp` plugins** (skip hooks for covered languages)
3. Checks system prerequisites (package managers, runtimes)
4. Verifies each required LSP server is installed
5. **Prompts user for each missing server** with install option
6. Copies appropriate LSP hooks to `.claude/hooks.json` (only for languages without specialized plugins)
7. Optionally appends LSP guidance to `CLAUDE.md`

---

## Execution Steps

<step number="1" name="Parse Arguments and Detect Languages">

**Parse command arguments:**
- Check for flags: `--skip-install`, `--skip-hooks`, `--skip-claudemd`, `--verify-only`
- Remaining arguments are language names

**If languages provided explicitly** (e.g., `typescript`, `go`, `rust`), use those.

**Otherwise, auto-detect** by scanning for file extensions:

| Extensions | Language |
|------------|----------|
| `.ts`, `.tsx`, `.js`, `.jsx` | TypeScript/JavaScript |
| `.py`, `.pyi` | Python |
| `.go` | Go |
| `.rs` | Rust |
| `.java` | Java |
| `.kt` | Kotlin |
| `.cpp`, `.c`, `.h`, `.hpp` | C/C++ |
| `.cs` | C# |
| `.php` | PHP |
| `.rb` | Ruby |
| `.html`, `.css`, `.scss` | HTML/CSS |
| `.tex` | LaTeX |
| `.md`, `.markdown` | Markdown |
| `.tf`, `.tfvars`, `.hcl` | Terraform |

Use Glob to scan: `**/*.{ts,tsx,js,jsx,py,pyi,go,rs,java,kt,cpp,c,h,cs,php,rb,html,css,tex,md,markdown,tf,tfvars,hcl}`

**Output detected languages to user.**

</step>

<step number="2" name="Detect Installed zircote/*-lsp Plugins">

Check if any specialized `zircote/*-lsp` plugins are installed that provide their own hooks.

**Specialized Plugin Registry:**

| Language | Plugin Name | Hooks Provided |
|----------|-------------|----------------|
| Rust | `zircote/rust-lsp` | 16 hooks (clippy, security, dependencies) |
| Terraform | `zircote/terraform-lsp` | 17 hooks (tflint, trivy, checkov) |
| Markdown | `zircote/markdown-lsp` | 4 hooks (links, frontmatter, code blocks) |

**Detection method:**

Check for plugin installation by looking for plugin cache directories or using Claude Code's plugin list:

```bash
# Check plugin cache locations
PLUGIN_CACHE_DIRS=(
  "${HOME}/.claude/plugins/cache"
  "${HOME}/.config/claude/plugins/cache"
)

SPECIALIZED_PLUGINS=()

for cache_dir in "${PLUGIN_CACHE_DIRS[@]}"; do
  # Check for rust-lsp
  if [[ -d "${cache_dir}/zircote/rust-lsp" ]] || [[ -d "${cache_dir}/rust-lsp" ]]; then
    SPECIALIZED_PLUGINS+=("rust")
  fi
  # Check for terraform-lsp
  if [[ -d "${cache_dir}/zircote/terraform-lsp" ]] || [[ -d "${cache_dir}/terraform-lsp" ]]; then
    SPECIALIZED_PLUGINS+=("terraform")
  fi
  # Check for markdown-lsp
  if [[ -d "${cache_dir}/zircote/markdown-lsp" ]] || [[ -d "${cache_dir}/markdown-lsp" ]]; then
    SPECIALIZED_PLUGINS+=("markdown")
  fi
done
```

**Also check project-local `.claude/settings.json`** for enabled plugins:

```bash
if [[ -f ".claude/settings.json" ]]; then
  if jq -e '.plugins[]? | select(. | test("rust-lsp"))' .claude/settings.json >/dev/null 2>&1; then
    SPECIALIZED_PLUGINS+=("rust")
  fi
  if jq -e '.plugins[]? | select(. | test("terraform-lsp"))' .claude/settings.json >/dev/null 2>&1; then
    SPECIALIZED_PLUGINS+=("terraform")
  fi
  if jq -e '.plugins[]? | select(. | test("markdown-lsp"))' .claude/settings.json >/dev/null 2>&1; then
    SPECIALIZED_PLUGINS+=("markdown")
  fi
fi
```

**Output detected specialized plugins:**

```
Specialized zircote/*-lsp plugins detected:
  ✓ rust-lsp (16 hooks) - hooks will be provided by plugin
  ✓ terraform-lsp (17 hooks) - hooks will be provided by plugin

Languages requiring lsp-tools hooks: TypeScript, Python, Go
```

**Store list of languages covered by specialized plugins** for use in Step 7 (Install Hooks).

</step>

<step number="3" name="Check System Prerequisites">

Run the prerequisite check script to verify package managers and runtimes.

**Detect OS:**
```bash
case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux) OS="linux" ;;
    MINGW*|MSYS*|CYGWIN*) OS="windows" ;;
esac
```

**For Unix/macOS:**
```bash
bash "${CLAUDE_PLUGIN_DIR}/scripts/bash/check-prerequisites.sh"
```

**For Windows (PowerShell):**
```powershell
& "${CLAUDE_PLUGIN_DIR}/scripts/powershell/check-prerequisites.ps1"
```

**Report missing prerequisites** but continue (servers may still install via available package managers).

</step>

<step number="4" name="Verify LSP Servers">

For each detected language, check if the corresponding LSP server is installed.

**Server verification commands:**

| Language | Server | Verify Command |
|----------|--------|----------------|
| TypeScript/JS | vtsls | `command -v vtsls \|\| npm list -g @vtsls/language-server 2>/dev/null \| grep -q vtsls` |
| Python | pyright | `command -v pyright` |
| Rust | rust-analyzer | `command -v rust-analyzer` |
| Go | gopls | `command -v gopls` |
| Java | jdtls | `command -v jdtls \|\| [ -d "$HOME/jdtls" ]` |
| Kotlin | kotlin-language-server | `command -v kotlin-language-server` |
| C/C++ | clangd | `command -v clangd` |
| C# | omnisharp | `command -v omnisharp \|\| command -v OmniSharp` |
| PHP | phpactor | `command -v phpactor \|\| command -v intelephense` |
| Ruby | ruby-lsp | `command -v ruby-lsp \|\| command -v solargraph` |
| HTML/CSS | vscode-html-language-server | `command -v vscode-html-language-server` |
| LaTeX | texlab | `command -v texlab` |
| Markdown | marksman | `command -v marksman` |
| Terraform | terraform-ls | `command -v terraform-ls` |

**Track which servers are:**
- Installed (green checkmark)
- Missing (red X)

**If `--verify-only` flag set:** Output status report and HALT.

</step>

<step number="5" name="Prompt for Missing Server Installation">

**Skip this step if `--skip-install` flag is set.**

For **EACH missing server**, use AskUserQuestion to prompt:

```
LSP server for [Language] is not installed.

Server: [server-name]
Install command: [primary install command]

Would you like to install it now?
```

**Options:**
1. "Yes, install now" - Execute installation script
2. "Skip this server" - Continue without installing
3. "Skip all remaining" - Stop prompting for remaining servers

**Per-server installation scripts:**

| Language | Bash Script | PowerShell Script |
|----------|-------------|-------------------|
| TypeScript | `scripts/bash/install-typescript-lsp.sh` | `scripts/powershell/install-typescript-lsp.ps1` |
| Python | `scripts/bash/install-python-lsp.sh` | `scripts/powershell/install-python-lsp.ps1` |
| Rust | `scripts/bash/install-rust-lsp.sh` | `scripts/powershell/install-rust-lsp.ps1` |
| Go | `scripts/bash/install-go-lsp.sh` | `scripts/powershell/install-go-lsp.ps1` |
| Java | `scripts/bash/install-java-lsp.sh` | `scripts/powershell/install-java-lsp.ps1` |
| Kotlin | `scripts/bash/install-kotlin-lsp.sh` | `scripts/powershell/install-kotlin-lsp.ps1` |
| C/C++ | `scripts/bash/install-cpp-lsp.sh` | `scripts/powershell/install-cpp-lsp.ps1` |
| C# | `scripts/bash/install-csharp-lsp.sh` | `scripts/powershell/install-csharp-lsp.ps1` |
| PHP | `scripts/bash/install-php-lsp.sh` | `scripts/powershell/install-php-lsp.ps1` |
| Ruby | `scripts/bash/install-ruby-lsp.sh` | `scripts/powershell/install-ruby-lsp.ps1` |
| HTML/CSS | `scripts/bash/install-html-css-lsp.sh` | `scripts/powershell/install-html-css-lsp.ps1` |
| LaTeX | `scripts/bash/install-latex-lsp.sh` | `scripts/powershell/install-latex-lsp.ps1` |
| Markdown | `scripts/bash/install-markdown-lsp.sh` | `scripts/powershell/install-markdown-lsp.ps1` |
| Terraform | `scripts/bash/install-terraform-lsp.sh` | `scripts/powershell/install-terraform-lsp.ps1` |

**Note:** For Markdown, Rust, and Terraform, if the corresponding `zircote/*-lsp` plugin is installed, the plugin's `/setup` command should be used instead of these scripts for full toolchain setup.

**Execute installation:**

For Unix/macOS:
```bash
bash "${CLAUDE_PLUGIN_DIR}/scripts/bash/install-${language}-lsp.sh"
```

For Windows:
```powershell
& "${CLAUDE_PLUGIN_DIR}/scripts/powershell/install-${language}-lsp.ps1"
```

**After each installation, re-verify** to confirm success.

</step>

<step number="6" name="Check ENABLE_LSP_TOOL Environment">

Verify the `ENABLE_LSP_TOOL` environment variable is set:

```bash
if [[ "${ENABLE_LSP_TOOL:-}" != "1" ]]; then
    echo "[WARN] ENABLE_LSP_TOOL is not set"
fi
```

If not set, inform user:
```
ENABLE_LSP_TOOL environment variable is not set.

Add to your shell profile (~/.bashrc, ~/.zshrc):
  export ENABLE_LSP_TOOL=1

Or add to Claude Code settings.json:
  { "env": { "ENABLE_LSP_TOOL": "1" } }
```

</step>

<step number="7" name="Install Hooks">

**Skip this step if `--skip-hooks` flag is set.**

**IMPORTANT: Skip hooks for languages covered by specialized `zircote/*-lsp` plugins.**

The specialized plugins (`rust-lsp`, `terraform-lsp`, `markdown-lsp`) include their own hooks that are automatically installed with the plugin. Installing duplicate hooks from lsp-tools would cause conflicts.

**Filter out languages with specialized plugins:**

```bash
# Languages detected in Step 1
DETECTED_LANGUAGES=("typescript" "python" "rust" "go")

# Languages covered by specialized plugins from Step 2
SPECIALIZED_LANGUAGES=("rust")  # From SPECIALIZED_PLUGINS array

# Languages that need lsp-tools hooks
LANGUAGES_NEEDING_HOOKS=()
for lang in "${DETECTED_LANGUAGES[@]}"; do
  if [[ ! " ${SPECIALIZED_LANGUAGES[*]} " =~ " ${lang} " ]]; then
    LANGUAGES_NEEDING_HOOKS+=("$lang")
  fi
done

# Result: LANGUAGES_NEEDING_HOOKS=("typescript" "python" "go")
```

**If all detected languages are covered by specialized plugins:**

```
All detected languages are covered by specialized zircote/*-lsp plugins:
  - Rust → zircote/rust-lsp (16 hooks)

No additional hooks needed from lsp-tools. Skipping hooks installation.
```

**Otherwise, proceed with hook installation for remaining languages:**

The hook template files are in the skill's references directory:
`${CLAUDE_PLUGIN_DIR}/skills/lsp-enable/references/`

**Check if `.claude/hooks.json` already exists in the project.**

If it exists:
- Read existing hooks
- Ask user: "Merge with existing hooks or replace?"
- If merge: combine hook arrays, avoiding duplicates by name

If it doesn't exist:
- Create `.claude/` directory if needed

**For single language:**
```bash
mkdir -p .claude
cp "${CLAUDE_PLUGIN_DIR}/skills/lsp-enable/references/${language}-hooks.json" .claude/hooks.json
```

**For multiple languages, merge hooks:**
```bash
jq -s '{ hooks: [ .[0].hooks[], .[1].hooks[] ] | unique_by(.name) }' \
  file1.json file2.json > .claude/hooks.json
```

</step>

<step number="8" name="Update CLAUDE.md">

**Skip this step if `--skip-claudemd` flag is set.**

Ask user: "Would you like to add LSP guidance to your project's CLAUDE.md?"

If yes:
- Check if CLAUDE.md exists
- If exists: append the language-specific LSP section
- If not: create with LSP section as initial content

LSP section files are at:
`${CLAUDE_PLUGIN_DIR}/skills/lsp-enable/references/{language}-lsp-section.md`

</step>

<step number="9" name="Final Verification and Report">

**Re-run server verification** for all detected languages.

**Generate summary report:**

```
LSP Setup Complete
==================

Languages Detected: TypeScript, Python, Rust, Go

Specialized zircote/*-lsp Plugins:
  ✓ Rust → zircote/rust-lsp (16 hooks provided by plugin)

LSP Servers:
  [OK] TypeScript (vtsls): installed
  [OK] Python (pyright): 1.1.389
  [OK] Rust (rust-analyzer): 2024-01-15 (managed by rust-lsp plugin)
  [OK] Go (gopls): v0.16.2

Environment:
  [OK] ENABLE_LSP_TOOL=1

Hooks from lsp-tools:
  - format-on-edit (TypeScript)
  - typecheck-on-edit (TypeScript)
  - format-on-edit (Python)
  - lint-on-edit (Python)
  - format-on-edit (Go)
  - vet-on-edit (Go)

Hooks from Specialized Plugins:
  - Rust: 16 hooks (clippy, security, deps) via zircote/rust-lsp

Files Modified:
  - .claude/hooks.json (created - TypeScript, Python, Go only)
  - CLAUDE.md (appended LSP sections)

Setup complete! Restart Claude Code to activate hooks.
```

</step>

---

## Error Handling

| Error | Recovery |
|-------|----------|
| No supported languages detected | Ask user which language to configure |
| Hook file not found | Report error with path, continue with other languages |
| JSON merge fails | Fall back to replacement with user confirmation |
| Server installation fails | Report error, continue with remaining servers |
| CLAUDE.md append fails | Report error but don't fail entire setup |
| Prerequisites missing | Warn but continue (installation may still work) |

---

## AskUserQuestion Prompts

### Missing Server Prompt

For each missing LSP server, prompt:

```yaml
questions:
  - question: "Install [Language] LSP server ([server-name])?"
    header: "LSP Install"
    multiSelect: false
    options:
      - label: "Yes, install now"
        description: "Run: [install command]"
      - label: "Skip this server"
        description: "Continue without [server-name]"
      - label: "Skip all remaining"
        description: "Don't prompt for any more servers"
```

### Hooks Merge Prompt

```yaml
questions:
  - question: "hooks.json already exists. How should we handle existing hooks?"
    header: "Hooks"
    multiSelect: false
    options:
      - label: "Merge (Recommended)"
        description: "Combine existing hooks with new LSP hooks"
      - label: "Replace"
        description: "Overwrite with new LSP hooks only"
      - label: "Skip"
        description: "Keep existing hooks, don't modify"
```

### CLAUDE.md Prompt

```yaml
questions:
  - question: "Add LSP guidance to CLAUDE.md?"
    header: "CLAUDE.md"
    multiSelect: false
    options:
      - label: "Yes (Recommended)"
        description: "Append LSP workflow guidance for detected languages"
      - label: "No"
        description: "Skip CLAUDE.md modifications"
```

---

## Tips

- Run `/lsp-tools:lsp-setup` to auto-detect and fully configure
- Run `/lsp-tools:lsp-setup --verify-only` to check LSP server status
- Run `/lsp-tools:lsp-setup typescript python` for specific languages
- Run `/lsp-tools:lsp-setup --skip-install` if servers are already installed
- Hooks can be customized after installation in `.claude/hooks.json`
- Re-run setup after adding new languages to a project
