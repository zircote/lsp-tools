# Copilot instructions

You are working in a Claude Code plugin for LSP-first code intelligence with strong enforcement patterns.

## Priorities

1. Keep changes small and reviewable.
2. Update README.md and CHANGELOG.md when changing user-facing behavior.
3. Maintain the Three Iron Laws enforcement in SKILL.md.

## Key Files

- `.claude-plugin/plugin.json` - Plugin manifest
- `commands/lsp-setup.md` - `/lsp-setup` command for project configuration
- `skills/lsp-enable/SKILL.md` - Main enforcement skill with Three Iron Laws
- `skills/lsp-enable/references/` - Per-language LSP sections and hooks

## Commands

- Setup: `/lsp-tools:lsp-setup` (configures hooks and CLAUDE.md for detected languages)
- Verify: `/lsp-tools:lsp-setup --verify-only` (checks LSP server status)

## When Adding Language Support

1. Create `references/{language}-lsp-section.md` with CLAUDE.md guidance
2. Create `references/{language}-hooks.json` with development hooks
3. Add installation scripts to `scripts/bash/` and `scripts/powershell/`
4. Update `lsp-server-registry.md` with installation commands
5. Update `SETUP-GUIDE-ALL-LANGUAGES.md`
6. Update README.md supported languages table
