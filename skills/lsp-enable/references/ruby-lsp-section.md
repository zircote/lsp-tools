# CLAUDE.md LSP Section for Ruby

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar classes, modules, or methods
- Use LSP `findReferences` before refactoring—important for mixins and monkey patches
- Use LSP `documentSymbol` to understand class/module structure
- Prefer LSP navigation over grep—it resolves through require and include

### Verification Workflow
- Check LSP diagnostics after each edit to catch syntax and type errors
- Run `ruby -c` for syntax checking
- Use RuboCop for style and lint checking
- Run tests with RSpec or Minitest

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation
- [ ] Find all references, especially for methods that might be overridden
- [ ] Review method signatures and YARD docs via hover
- [ ] Check if modifying public API used by other gems

### Error Handling
- If LSP reports errors, fix them before proceeding
- RuboCop errors often indicate potential bugs, not just style issues
- Use LSP diagnostics to understand method resolution

## Ruby Tooling

### Bundler
- Install: `bundle install`
- Update: `bundle update`
- Execute: `bundle exec <command>`
- Add gem: `bundle add <gem>`

### Quality Gates
- Syntax check: `ruby -c file.rb`
- RuboCop: `bundle exec rubocop`
- RuboCop autofix: `bundle exec rubocop -A`
- RSpec: `bundle exec rspec`
- Minitest: `bundle exec rake test`

### Before Committing
```bash
bundle exec rubocop && bundle exec rspec
```

### Useful Commands
- `bundle outdated` — Check for gem updates
- `bundle show <gem>` — Show gem location
- `gem list` — List installed gems

## Language Server Details

- **Server**: ruby-lsp (Shopify) or solargraph
- **Install ruby-lsp**: `gem install ruby-lsp`
- **Install solargraph**: `gem install solargraph`
- **Features**: Navigation, completion, diagnostics, formatting
- **Note**: ruby-lsp is newer and faster; solargraph has more features
