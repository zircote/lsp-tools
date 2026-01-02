# CLAUDE.md LSP Section for TypeScript/JavaScript

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar functions, classes, or types
- Use LSP `findReferences` before refactoring any symbol to understand full impact
- Use LSP `documentSymbol` to get file structure overview before major edits
- Prefer LSP navigation over grep/search—it resolves through type aliases and re-exports

### Verification Workflow
- Check LSP diagnostics after each edit to catch type errors immediately
- Run `npm run typecheck` (or `npx tsc --noEmit`) for project-wide verification
- Verify imports resolve correctly via LSP after adding new dependencies

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation and types
- [ ] Find all references to assess change impact
- [ ] Review type signatures via hover before modifying function signatures
- [ ] Check interface/type definitions before implementing

### Error Handling
- If LSP reports errors, fix them before proceeding to next task
- Treat TypeScript errors as blocking—don't accumulate type debt
- Use LSP diagnostics output to guide fixes, not guesswork

## TypeScript Tooling

### Package Management
- Use project's package manager: `npm`, `pnpm`, `yarn`, or `bun`
- Check `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, or `bun.lockb` to determine which

### Quality Gates
- Typecheck: `npx tsc --noEmit`
- Lint: `npx eslint . --fix` or `npx biome check --apply`
- Format: `npx prettier --write .` or `npx biome format --write`
- Test: `npm test` or `npx vitest` or `npx jest`

### Before Committing
Run full quality suite:
```bash
npx tsc --noEmit && npx eslint . && npx prettier --check . && npm test
```

## Language Server Details

- **Server**: vtsls (recommended) or typescript-language-server
- **Install**: `npm install -g @vtsls/language-server typescript`
- **Features**: Full TypeScript/JavaScript support including JSX/TSX
