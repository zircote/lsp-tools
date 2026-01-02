# CLAUDE.md LSP Section for HTML/CSS

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` to navigate to CSS class/ID definitions
- Use LSP `findReferences` to find all usages of CSS selectors
- Use LSP `documentSymbol` to understand document structure
- Use hover for CSS property documentation and browser support info

### Verification Workflow
- Check LSP diagnostics after each edit for syntax errors
- Validate HTML with linters or W3C validator
- Check CSS for unused rules and browser compatibility

### Pre-Edit Checklist
- [ ] Navigate to CSS definitions before changing class names
- [ ] Find all references to classes before renaming
- [ ] Review browser compatibility via hover for CSS properties
- [ ] Check document structure with documentSymbol

### Error Handling
- If LSP reports errors, fix them before proceeding
- Pay attention to accessibility warnings
- Check for deprecated HTML attributes

## HTML Tooling

### Linting & Validation
- HTMLHint: `npx htmlhint src/**/*.html`
- Prettier: `npx prettier --write "**/*.html"`
- W3C Validator: Use online validator or `npm install -g html-validator-cli`

### Before Committing
```bash
npx prettier --check "**/*.html" && npx htmlhint src/**/*.html
```

## CSS Tooling

### Linting & Formatting
- Stylelint: `npx stylelint "**/*.css"`
- Stylelint fix: `npx stylelint "**/*.css" --fix`
- Prettier: `npx prettier --write "**/*.css"`
- PostCSS: For transformations and autoprefixing

### SCSS/Sass
- Compile: `npx sass src:dist`
- Watch: `npx sass --watch src:dist`
- Lint: `npx stylelint "**/*.scss"`

### Before Committing
```bash
npx prettier --check "**/*.css" "**/*.scss" && npx stylelint "**/*.css" "**/*.scss"
```

### Useful Tools
- PurgeCSS — Remove unused CSS
- Autoprefixer — Add vendor prefixes
- cssnano — Minify CSS

## Language Server Details

- **HTML Server**: vscode-html-language-server
- **CSS Server**: vscode-css-language-server
- **Install**: `npm install -g vscode-langservers-extracted`
- **Features**: Syntax validation, completion, hover docs, formatting
