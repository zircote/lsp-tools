# CLAUDE.md LSP Section for C#

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar classes, methods, or interfaces
- Use LSP `findReferences` before refactoring—critical for interface implementations
- Use LSP `documentSymbol` to understand class structure and namespaces
- Prefer LSP navigation over grep—it resolves through usings and assemblies

### Verification Workflow
- Check LSP diagnostics after each edit to catch compilation and type errors
- Run `dotnet build` for project-wide verification
- Verify usings are correct and unused ones are removed

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation and inheritance
- [ ] Find all references to assess change impact
- [ ] Review type signatures, generics, and attributes via hover
- [ ] Check if modifying public API used by other projects

### Error Handling
- If LSP reports errors, fix them before proceeding
- Pay attention to nullable reference type warnings (if enabled)
- Use LSP diagnostics to understand generic constraints

## C# Tooling

### .NET CLI
- Build: `dotnet build`
- Run: `dotnet run`
- Test: `dotnet test`
- Clean: `dotnet clean`
- Restore: `dotnet restore`
- Publish: `dotnet publish`

### Quality Gates
- Format: `dotnet format`
- Format check: `dotnet format --verify-no-changes`
- Analyzers: Configure in `.editorconfig` or project file
- Test: `dotnet test`
- Test with coverage: `dotnet test --collect:"XPlat Code Coverage"`

### Before Committing
```bash
dotnet format --verify-no-changes && dotnet build && dotnet test
```

### Useful Commands
- `dotnet list package` — List packages
- `dotnet list package --outdated` — Check for updates
- `dotnet new` — Create new projects/files from templates

## Language Server Details

- **Server**: OmniSharp
- **Install**: 
  - macOS: `brew install omnisharp/omnisharp-roslyn/omnisharp-mono`
  - Or download from OmniSharp releases
- **Features**: Full C# support including generics, LINQ, async/await
