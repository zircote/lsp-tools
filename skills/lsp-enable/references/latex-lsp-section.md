# CLAUDE.md LSP Section for LaTeX

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` to navigate to label, citation, and command definitions
- Use LSP `findReferences` to find all usages of labels and citations
- Use LSP `documentSymbol` to understand document structure (sections, chapters)
- Use hover for package documentation and command help

### Verification Workflow
- Check LSP diagnostics after each edit for syntax and reference errors
- Build document to verify compilation: `latexmk` or `pdflatex`
- Check for undefined references and citations

### Pre-Edit Checklist
- [ ] Navigate to label/citation definitions before referencing
- [ ] Find all references before renaming labels
- [ ] Review command documentation via hover
- [ ] Check document structure with documentSymbol

### Error Handling
- If LSP reports errors, fix them before proceeding
- Pay attention to undefined reference warnings
- Check for missing packages

## LaTeX Tooling

### Build Commands

#### Latexmk (Recommended)
```bash
# Build PDF
latexmk -pdf document.tex

# Build with continuous preview
latexmk -pdf -pvc document.tex

# Clean auxiliary files
latexmk -c

# Clean all including output
latexmk -C
```

#### Direct Compilation
```bash
# Single pass
pdflatex document.tex

# With bibliography (multiple passes)
pdflatex document.tex
bibtex document
pdflatex document.tex
pdflatex document.tex

# XeLaTeX for Unicode/fonts
xelatex document.tex

# LuaLaTeX
lualatex document.tex
```

### Quality Gates
- ChkTeX: `chktex document.tex` (style/lint checker)
- lacheck: `lacheck document.tex` (consistency checker)
- Build: `latexmk -pdf document.tex`

### Before Committing
```bash
chktex document.tex && latexmk -pdf document.tex
```

### Useful Commands
- `texdoc <package>` — View package documentation
- `kpsewhich <file>` — Find file in TeX distribution
- `tlmgr install <package>` — Install TeX package (TeX Live)

## Language Server Details

- **Server**: texlab
- **Install**: 
  - macOS: `brew install texlab`
  - Arch: `pacman -S texlab`
  - Windows: `scoop install texlab` or `choco install texlab`
  - Cargo: `cargo install --locked texlab`
- **Features**: Build, forward/inverse search, completion, diagnostics, formatting
