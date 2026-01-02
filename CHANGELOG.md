# Changelog

All notable changes to the LSP Tools plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-01-02

### Added

- **Specialized Plugin Integration** - Detects installed `zircote/*-lsp` plugins and defers hook installation
  - `zircote/rust-lsp` - 16 hooks (clippy, security, dependencies)
  - `zircote/terraform-lsp` - 17 hooks (tflint, trivy, checkov, terragrunt)
  - `zircote/markdown-lsp` - 4 hooks (links, frontmatter, code blocks, syntax)
  - When specialized plugins are installed, lsp-tools skips hooks for those languages to avoid conflicts

- **Markdown Language Support** - New language support with marksman LSP server
  - `references/markdown-lsp-section.md` for CLAUDE.md guidance
  - `scripts/bash/install-markdown-lsp.sh` and `scripts/powershell/install-markdown-lsp.ps1`

- **Terraform Language Support** - New language support with terraform-ls LSP server
  - `references/terraform-lsp-section.md` for CLAUDE.md guidance
  - `scripts/bash/install-terraform-lsp.sh` and `scripts/powershell/install-terraform-lsp.ps1`

### Changed

- `/lsp-tools:lsp-setup` now includes plugin detection step (Step 2)
- Language detection expanded to 14 languages (added `.md`, `.markdown`, `.tf`, `.tfvars`, `.hcl`)
- Hook installation step now skips languages covered by specialized plugins
- Help text updated with SPECIALIZED PLUGINS section
- Final report distinguishes between lsp-tools hooks and specialized plugin hooks

## [0.3.0] - 2025-12-27

### Added

- **LSP Server Installation Scripts** - Per-language scripts for automated LSP server installation
  - Bash scripts for Unix/macOS (`scripts/bash/install-{language}-lsp.sh`)
  - PowerShell scripts for Windows (`scripts/powershell/install-{language}-lsp.ps1`)
  - Covers all 12 supported languages (TypeScript, Python, Rust, Go, Java, Kotlin, C/C++, C#, PHP, Ruby, HTML/CSS, LaTeX)

- **Prerequisite Verification** - System prerequisite checks before installation
  - `check-prerequisites.sh` (bash) and `check-prerequisites.ps1` (PowerShell)
  - Verifies package managers (npm, pip, brew, apt, winget, choco, scoop)
  - Verifies language runtimes (Node.js, Python, Go, Rust, Java, etc.)

- **LSP Server Verification** - Quick status check for all LSP servers
  - `verify-lsp-servers.sh` (bash) and `verify-lsp-servers.ps1` (PowerShell)
  - Reports installed/missing status for each language server

- **LSP Server Registry** - Comprehensive reference documentation
  - `references/lsp-server-registry.md` with installation commands for all platforms
  - Verification commands, minimum versions, and PATH requirements

- **Enhanced `/lsp-tools:lsp-setup` Command**
  - New `--verify-only` flag to check LSP server status without installing
  - New `--skip-install` flag to skip server installation prompts
  - New `--skip-hooks` flag to skip hooks installation
  - New `--skip-claudemd` flag to skip CLAUDE.md modifications
  - **Per-server installation prompts** - User approval for each missing server
  - Full prerequisite verification before installation
  - Post-installation verification to confirm success

### Changed

- `/lsp-tools:lsp-setup` now includes full LSP toolchain setup (servers, environment, hooks, CLAUDE.md)
- SKILL.md updated with server installation section and script references

## [0.2.0] - 2025-12-26

### Fixed

- All 12 language hook files now use `$CLAUDE_PROJECT_DIR` instead of relative paths
  - Ensures hooks work correctly regardless of current working directory
  - Commands like `go vet ./...`, `cargo test`, `./gradlew build` now properly cd to project root
  - File existence checks use absolute paths (e.g., `"$CLAUDE_PROJECT_DIR/pom.xml"`)

### Changed

- Updated hook command patterns:
  - Project-wide operations now use `cd "$CLAUDE_PROJECT_DIR" && <command>`
  - File-specific operations still use `$CLAUDE_FILE_PATHS` (already absolute)

## [0.1.1] - 2025-12-24

### Added

- Comprehensive LSP setup and troubleshooting guide (`docs/LSP-GUIDE.md`)
  - Setup instructions for bash, zsh, fish shells
  - Language-specific setup for 12 languages
  - Usage guide with operation reference and best practices
  - Troubleshooting section with common issues and solutions
  - FAQ and quick reference checklists

## [0.1.0] - 2024-12-23

### Added

#### Core Skill: `lsp-enable`
- **Three Iron Laws** for mandatory LSP usage:
  1. No modifying unfamiliar code without `goToDefinition` first
  2. No refactoring without `findReferences` impact analysis first
  3. No claiming code works without LSP diagnostics verification
- **Decision Tree** for choosing between LSP, Grep, Glob, and Read
- **Pre-Edit Protocol** with mandatory checklist
- **Post-Edit Verification** workflow
- **LSP Availability Check** with graceful fallback
- **Token Optimization Awareness** documentation

#### Command: `/lsp-setup`
- Auto-detect project languages by file extensions
- Copy appropriate hooks to `.claude/hooks.json`
- Merge with existing hooks if present
- Optionally append LSP sections to `CLAUDE.md`
- Support for explicit language arguments

#### Language Support (12 languages)
- TypeScript/JavaScript (vtsls)
- Python (pyright)
- Go (gopls)
- Rust (rust-analyzer)
- Java (jdtls)
- Kotlin (kotlin-language-server)
- C/C++ (clangd)
- C# (OmniSharp)
- PHP (phpactor)
- Ruby (ruby-lsp)
- HTML/CSS (vscode-langservers)
- LaTeX (texlab)

#### Reference Documentation
- `lsp-operations-guide.md` - Complete guide to all 9 LSP operations
- `lsp-enforcement-protocol.md` - Detailed enforcement patterns
- `lsp-decision-matrix.md` - Tool selection guidance
- `lsp-setup-verification.md` - Installation and troubleshooting
- `SETUP-GUIDE-ALL-LANGUAGES.md` - Quick setup reference

#### Per-Language Resources
- `{language}-lsp-section.md` - CLAUDE.md sections for each language
- `{language}-hooks.json` - Pre-configured hooks for each language

### Technical Details

- Plugin structure follows Claude Code plugin best practices
- Skills use progressive disclosure (lean SKILL.md, detailed references)
- Hooks use `${CLAUDE_PLUGIN_DIR}` for portability
- Strong enforcement patterns modeled after systematic-debugging skill

[0.4.0]: https://github.com/zircote/marketplace/releases/tag/lsp-tools-v0.4.0
[0.3.0]: https://github.com/zircote/marketplace/releases/tag/lsp-tools-v0.3.0
[0.2.0]: https://github.com/zircote/marketplace/releases/tag/lsp-tools-v0.2.0
[0.1.1]: https://github.com/zircote/marketplace/releases/tag/lsp-tools-v0.1.1
[0.1.0]: https://github.com/zircote/marketplace/releases/tag/lsp-tools-v0.1.0
