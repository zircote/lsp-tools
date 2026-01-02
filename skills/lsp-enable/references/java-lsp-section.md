# CLAUDE.md LSP Section for Java

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar classes, methods, or interfaces
- Use LSP `findReferences` before refactoring—critical for inheritance hierarchies
- Use LSP `documentSymbol` to understand class structure before major edits
- Prefer LSP navigation over grep—it resolves through imports and inheritance

### Verification Workflow
- Check LSP diagnostics after each edit to catch compilation and type errors
- Run `mvn compile` or `gradle build` for project-wide verification
- Verify imports are correct and organized

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation and inheritance
- [ ] Find all references to assess change impact (especially for interface methods)
- [ ] Review type signatures, generics, and annotations via hover
- [ ] Check if modifying public API used by other modules

### Error Handling
- If LSP reports errors, fix them before proceeding
- Pay attention to null safety warnings
- Use LSP diagnostics to understand generic type mismatches

## Java Tooling

### Build Systems

#### Maven
- Compile: `mvn compile`
- Test: `mvn test`
- Package: `mvn package`
- Clean: `mvn clean`
- Install: `mvn install`

#### Gradle
- Compile: `gradle compileJava` or `./gradlew compileJava`
- Build: `gradle build` or `./gradlew build`
- Test: `gradle test` or `./gradlew test`
- Clean: `gradle clean`

### Quality Gates
- Checkstyle: `mvn checkstyle:check` or `gradle checkstyleMain`
- SpotBugs: `mvn spotbugs:check` or `gradle spotbugsMain`
- PMD: `mvn pmd:check`
- Test: `mvn test` or `gradle test`

### Before Committing
Maven:
```bash
mvn clean compile test checkstyle:check
```

Gradle:
```bash
./gradlew clean build check
```

### Useful Commands
- `mvn dependency:tree` — View dependency tree
- `gradle dependencies` — View Gradle dependencies
- `mvn versions:display-dependency-updates` — Check for updates

## Language Server Details

- **Server**: Eclipse JDT Language Server (jdtls)
- **Install**: Download from Eclipse releases or `brew install jdtls` (macOS)
- **Requires**: Java 21+ for the server, project can target earlier versions
- **Features**: Full Java support including generics, annotations, refactoring
