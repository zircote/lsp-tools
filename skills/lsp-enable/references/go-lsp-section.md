# CLAUDE.md LSP Section for Go

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar functions, types, or interfaces
- Use LSP `findReferences` before refactoring any symbol—critical for interface implementations
- Use LSP `documentSymbol` to understand package structure before major edits
- Prefer LSP navigation over grep—it resolves through packages and embedded types

### Verification Workflow
- Check LSP diagnostics after each edit to catch type and compilation errors
- Run `go build ./...` for project-wide verification
- Run `go vet ./...` for suspicious constructs
- Verify imports are correct and unused imports are removed (goimports handles this)

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation
- [ ] Find all references to assess change impact (especially for interface methods)
- [ ] Review type signatures and interface contracts via hover
- [ ] Check if modifying exported (capitalized) symbols used by other packages

### Error Handling
- If LSP reports errors, fix them before proceeding
- Go compiler errors are usually clear and actionable
- Use `go vet` output to catch subtle issues LSP might miss

## Go Tooling

### Build & Run
- Build: `go build ./...`
- Run: `go run .`
- Install: `go install`

### Quality Gates
- Vet: `go vet ./...`
- Format: `gofmt -w .` or `goimports -w .`
- Format check: `gofmt -l .` (lists unformatted files)
- Lint: `golangci-lint run`
- Test: `go test ./...`
- Test with coverage: `go test -cover ./...`

### Before Committing
Run full quality suite:
```bash
gofmt -l . | grep -q . && exit 1 || true && go vet ./... && go test ./...
```

Or with golangci-lint:
```bash
golangci-lint run && go test ./...
```

### Useful Commands
- `go mod tidy` — Clean up go.mod and go.sum
- `go mod download` — Download dependencies
- `go doc <package>` — View package documentation
- `go generate ./...` — Run go:generate directives

## Language Server Details

- **Server**: gopls (official Go Language Server)
- **Install**: `go install golang.org/x/tools/gopls@latest`
- **Features**: Full Go support including generics, cgo, modules
