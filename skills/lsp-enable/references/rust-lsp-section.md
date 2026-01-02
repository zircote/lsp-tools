# CLAUDE.md LSP Section for Rust

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar functions, structs, or traits
- Use LSP `findReferences` before refactoring any symbol—critical for trait implementations
- Use LSP `documentSymbol` to understand module structure before major edits
- Prefer LSP navigation over grep—it resolves through use statements and re-exports

### Verification Workflow
- Check LSP diagnostics after each edit to catch borrow checker and type errors immediately
- Run `cargo check` for fast project-wide verification (faster than `cargo build`)
- Run `cargo clippy` for idiomatic Rust suggestions
- Verify imports and use statements resolve correctly via LSP

### Pre-Edit Checklist
- [ ] Navigate to definition to understand ownership and lifetimes
- [ ] Find all references to assess change impact (especially for trait methods)
- [ ] Review type signatures and trait bounds via hover
- [ ] Check if modifying a public API that other crates depend on

### Error Handling
- If LSP reports errors, fix them before proceeding—Rust compiler errors are precise
- Treat clippy warnings seriously—they often prevent subtle bugs
- Use LSP diagnostics to understand borrow checker issues

## Rust Tooling

### Build & Check
- Fast check: `cargo check`
- Full build: `cargo build`
- Release build: `cargo build --release`
- Run: `cargo run`

### Quality Gates
- Lint: `cargo clippy -- -D warnings`
- Format: `cargo fmt`
- Format check: `cargo fmt -- --check`
- Test: `cargo test`
- Doc test: `cargo test --doc`

### Before Committing
Run full quality suite:
```bash
cargo fmt -- --check && cargo clippy -- -D warnings && cargo test
```

### Useful Commands
- `cargo doc --open` — Generate and view documentation
- `cargo tree` — View dependency tree
- `cargo update` — Update dependencies
- `cargo audit` — Check for security vulnerabilities

## Language Server Details

- **Server**: rust-analyzer (official Rust Language Server)
- **Install**: `rustup component add rust-analyzer` or download from releases
- **Features**: Full Rust support including macros, proc-macros, async, lifetimes
