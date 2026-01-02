# CLAUDE.md LSP Section for Kotlin

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar classes, functions, or extensions
- Use LSP `findReferences` before refactoring—critical for extension functions
- Use LSP `documentSymbol` to understand class structure before major edits
- Prefer LSP navigation over grep—it resolves through imports and extension receivers

### Verification Workflow
- Check LSP diagnostics after each edit to catch type and null safety errors
- Run `gradle build` or `./gradlew build` for project-wide verification
- Pay attention to nullability warnings—Kotlin's null safety is a key feature

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation
- [ ] Find all references, especially for extension functions and properties
- [ ] Review type signatures and nullability via hover
- [ ] Check if modifying public API used by other modules

### Error Handling
- If LSP reports errors, fix them before proceeding
- Take nullability errors seriously—they prevent runtime NPEs
- Use LSP diagnostics to understand type inference issues

## Kotlin Tooling

### Build & Run (Gradle)
- Compile: `./gradlew compileKotlin`
- Build: `./gradlew build`
- Test: `./gradlew test`
- Run: `./gradlew run`
- Clean: `./gradlew clean`

### Quality Gates
- Lint: `./gradlew ktlintCheck` (with ktlint plugin)
- Format: `./gradlew ktlintFormat`
- Detekt: `./gradlew detekt` (static analysis)
- Test: `./gradlew test`

### Before Committing
```bash
./gradlew ktlintCheck detekt build
```

### Useful Commands
- `./gradlew dependencies` — View dependency tree
- `./gradlew tasks` — List available tasks

## Language Server Details

- **Server**: kotlin-lsp (JetBrains)
- **Install**: `brew install JetBrains/utils/kotlin-lsp` (macOS) or download from releases
- **Requires**: Java 17+
- **Note**: Currently supports JVM-only Kotlin Gradle projects
