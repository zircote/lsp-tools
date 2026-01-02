# CLAUDE.md LSP Section for Python

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar functions, classes, or modules
- Use LSP `findReferences` before refactoring any symbol to understand full impact
- Use LSP `documentSymbol` to get file structure overview before major edits
- Prefer LSP navigation over grep—it resolves through imports and re-exports

### Verification Workflow
- Check LSP diagnostics after each edit to catch type errors immediately
- Run `pyright` or `mypy` for project-wide type verification
- Verify imports resolve correctly via LSP after adding new dependencies

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation
- [ ] Find all references to assess change impact
- [ ] Review type annotations via hover before modifying function signatures
- [ ] Check class/protocol definitions before implementing

### Error Handling
- If LSP reports errors, fix them before proceeding to next task
- Treat type errors as blocking when using strict type checking
- Use LSP diagnostics output to guide fixes, not guesswork

## Python Tooling

### Package Management
- Use project's package manager: `pip`, `uv`, `poetry`, or `pdm`
- Check `pyproject.toml`, `requirements.txt`, or `poetry.lock` to determine which

### Quality Gates
- Typecheck: `pyright` or `mypy .`
- Lint: `ruff check .` or `flake8`
- Format: `ruff format .` or `black .`
- Test: `pytest` or `python -m pytest`

### Before Committing
Run full quality suite:
```bash
ruff format . && ruff check . && pyright && pytest
```

Or with traditional tools:
```bash
black . && flake8 && mypy . && pytest
```

## Language Server Details

- **Server**: pyright (recommended) or pylsp
- **Install**: `npm install -g pyright` or `pip install pyright`
- **Features**: Full Python support including type inference, protocols, generics
