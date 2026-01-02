---
title: Add a new language to LSP Tools
---

Add LSP support for a new programming language.

Requirements:
- Create `references/{language}-lsp-section.md` with CLAUDE.md guidance
- Create `references/{language}-hooks.json` with development hooks
- Add `scripts/bash/install-{language}-lsp.sh` installation script
- Add `scripts/powershell/install-{language}-lsp.ps1` installation script
- Update `lsp-server-registry.md` with installation commands
- Update `SETUP-GUIDE-ALL-LANGUAGES.md` with quick reference
- Update README.md supported languages table
- Update CHANGELOG.md with new language
