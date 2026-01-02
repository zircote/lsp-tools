# LSP Decision Matrix

When to use LSP vs Grep vs Glob vs Read.

## Quick Decision Tree

```
WHAT ARE YOU LOOKING FOR?
│
├─ A SYMBOL (function, class, variable, type)
│  │
│  ├─ Its definition/implementation
│  │  └─ LSP: goToDefinition
│  │
│  ├─ All its usages
│  │  └─ LSP: findReferences
│  │
│  ├─ Its type/documentation
│  │  └─ LSP: hover
│  │
│  └─ Similar symbols by name
│     └─ LSP: workspaceSymbol
│
├─ FILE STRUCTURE
│  │
│  ├─ Symbols in a specific file
│  │  └─ LSP: documentSymbol
│  │
│  └─ Files matching a pattern
│     └─ Glob: *.ts, src/**/*.py
│
├─ LITERAL TEXT
│  │
│  ├─ TODO/FIXME comments
│  │  └─ Grep: TODO|FIXME
│  │
│  ├─ String literals
│  │  └─ Grep: "error message"
│  │
│  ├─ Configuration values
│  │  └─ Grep: API_KEY, DATABASE_URL
│  │
│  └─ Error messages
│     └─ Grep: "Failed to connect"
│
├─ CALL GRAPH / DEPENDENCIES
│  │
│  ├─ Who calls this function
│  │  └─ LSP: incomingCalls
│  │
│  └─ What this function calls
│     └─ LSP: outgoingCalls
│
└─ SPECIFIC FILE CONTENT
   └─ Read: when you know exact file path
```

## Comparison Matrix

| Need | LSP | Grep | Glob | Read |
|------|-----|------|------|------|
| Find function definition | goToDefinition | Slow, inaccurate | N/A | N/A |
| Find all usages | findReferences | Returns false positives | N/A | N/A |
| Get type info | hover | N/A | N/A | Read definition file |
| Search symbol by name | workspaceSymbol | Works but imprecise | N/A | N/A |
| Find TODO comments | N/A | TODO\|FIXME | N/A | N/A |
| Find config values | N/A | CONFIG_NAME | N/A | N/A |
| Find files by pattern | N/A | N/A | *.test.ts | N/A |
| Read known file | N/A | N/A | N/A | Direct read |

## When LSP is Superior

### Large Codebases (100+ files)

| Operation | Grep Time | LSP Time |
|-----------|-----------|----------|
| Find function definition | 45+ seconds | ~50ms |
| Find all references | 60+ seconds | ~100-500ms |
| Get type signature | Read multiple files | ~30ms |

### Semantic Accuracy

| Search | Grep Matches | LSP Matches |
|--------|--------------|-------------|
| `getUserById` | 500+ (comments, strings, similar names) | 23 (exact function references) |
| `User` | 1000+ (UserName, UserType, "User", etc.) | 45 (actual type usages) |

### Token Efficiency

| Scenario | Grep Tokens | LSP Tokens |
|----------|-------------|------------|
| Find usages in large project | 2000+ (scanning output) | 500 |
| Navigate to definition | Multiple attempts | Single call |
| Understand type | Read multiple files | Single hover |

## When Grep is Appropriate

### Literal Text Searches

```
✓ Grep: Find all TODO comments
✓ Grep: Search for error message text
✓ Grep: Find configuration key names
✓ Grep: Search for magic strings
```

### Pattern Matching

```
✓ Grep: Find all console.log statements
✓ Grep: Search for deprecated API usage patterns
✓ Grep: Find hardcoded values
```

### Documentation/Comments

```
✓ Grep: Search README files
✓ Grep: Find JIRA ticket references
✓ Grep: Search for author annotations
```

## When Glob is Appropriate

### File Discovery

```
✓ Glob: Find all test files (*.test.ts)
✓ Glob: Find all config files (*.config.js)
✓ Glob: List files in directory (src/**/*.py)
✓ Glob: Find files by extension
```

### Build/Structure Analysis

```
✓ Glob: Count files by type
✓ Glob: Find entry points
✓ Glob: Discover module structure
```

## When Read is Appropriate

### Known File Path

```
✓ Read: Open specific config file
✓ Read: Read package.json
✓ Read: View known source file
```

### Small File Operations

```
✓ Read: Read 1-3 specific files
✓ Read: View file when LSP unavailable
```

## Codebase Size Heuristics

| Codebase Size | Recommendation |
|---------------|----------------|
| < 10 files | Grep/Read acceptable |
| 10-50 files | Prefer LSP, grep fallback OK |
| 50-100 files | Strong preference for LSP |
| 100+ files | LSP required for efficiency |
| 500+ files | LSP mandatory, grep wastes tokens |

## Anti-Patterns

### DON'T: Grep for Semantic Operations

```
✗ grep "function getUserById" → Use goToDefinition
✗ grep "getUserById(" → Use findReferences
✗ grep "interface User" → Use goToDefinition
```

### DON'T: LSP for Text Searches

```
✗ LSP for TODO comments → Use grep
✗ LSP for error messages → Use grep
✗ LSP for config values → Use grep
```

### DON'T: Read Multiple Files for Navigation

```
✗ Read file1, file2, file3 to find definition → Use goToDefinition
✗ Read all files to find usages → Use findReferences
```

## Combination Patterns

### Pattern 1: Explore Then Navigate

```
1. Glob: Find relevant files (*.service.ts)
2. LSP documentSymbol: Get file structure
3. LSP goToDefinition: Navigate to specific symbol
```

### Pattern 2: Search Then Verify

```
1. Grep: Find potential matches
2. LSP findReferences: Verify actual usages
3. LSP hover: Confirm types
```

### Pattern 3: Refactor Flow

```
1. LSP findReferences: Get all usages
2. Glob: Confirm file list
3. LSP goToDefinition: Understand each usage context
4. Make changes
5. LSP diagnostics: Verify
```
