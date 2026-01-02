# LSP Operations Guide

Complete reference for all nine LSP operations available in Claude Code.

## Required Parameters

All LSP operations require these three parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `filePath` | string | Absolute path to the file (e.g., `/Users/project/src/app.ts`) |
| `line` | integer | Line number, 1-based (as shown in editors) |
| `character` | integer | Column position, 1-based (as shown in editors) |

## Navigation Operations

### goToDefinition

**Purpose:** Jump to where a symbol (function, class, variable, type) is defined.

**Use when:**
- Understanding unfamiliar code before modifying
- Tracing imports to their source
- Verifying actual implementation
- Navigating from usage to definition

**Example scenarios:**
- Cursor on `getUserById()` → navigate to function definition
- Cursor on imported type → navigate to type definition
- Cursor on variable → navigate to declaration

**Advantage over grep:** Resolves through type aliases, re-exports, and inheritance.

### findReferences

**Purpose:** Find all places in the codebase where a symbol is used.

**Use when:**
- Before refactoring or renaming
- Understanding impact of changes
- Finding all callers of a function
- Tracking constant/config usage

**Example scenarios:**
- Find all calls to `validateUser()` before changing signature
- Find all usages of `UserType` before modifying
- Find all imports of a module before relocating

**Advantage over grep:** Returns only actual references, not comments or strings.

### goToImplementation

**Purpose:** Find implementations of interfaces, abstract methods, or protocols.

**Use when:**
- Working with polymorphic code
- Finding concrete implementations
- Understanding inheritance hierarchies
- Verifying interface contracts

**Example scenarios:**
- Interface `Repository` → find all implementing classes
- Abstract method `process()` → find all concrete implementations
- Protocol method → find all conforming types

## Information Operations

### hover

**Purpose:** Get type information, documentation, and signatures for a symbol.

**Use when:**
- Understanding function parameters and return types
- Viewing docstrings without navigating
- Verifying type compatibility
- Understanding API contracts

**Example scenarios:**
- Hover on function call → see parameter types and return type
- Hover on variable → see inferred type
- Hover on import → see module documentation

**Advantage:** Instant information without file navigation.

### documentSymbol

**Purpose:** Get all symbols (functions, classes, variables) in a file.

**Use when:**
- Understanding file structure
- Finding a symbol in a large file
- Getting overview of module exports
- Navigating within a file

**Example scenarios:**
- List all functions in a 500-line file
- Find all exported types in a module
- Get class method list

### workspaceSymbol

**Purpose:** Search for symbols by name across the entire workspace.

**Use when:**
- Finding where a utility is defined
- Discovering related implementations
- Searching for symbol by partial name
- Cross-module symbol discovery

**Example scenarios:**
- Search for all types containing "User"
- Find all functions matching "validate*"
- Locate helper functions across modules

## Call Analysis Operations

### prepareCallHierarchy

**Purpose:** Get call hierarchy information for a function or method at a position.

**Use when:**
- Preparing to analyze call graphs
- Starting call hierarchy exploration
- Understanding function context

**Note:** This is typically the first step before using incomingCalls or outgoingCalls.

### incomingCalls

**Purpose:** Find all functions/methods that call a specific function.

**Use when:**
- Understanding who depends on a function
- Impact analysis before changes
- Finding entry points to a function
- Debugging call chains

**Example scenarios:**
- Find all callers of `processPayment()` before modifying
- Trace how `handleError()` is invoked
- Identify entry points to critical functions

### outgoingCalls

**Purpose:** Find all functions/methods called by a specific function.

**Use when:**
- Understanding function dependencies
- Tracing execution flow
- Identifying side effects
- Debugging nested calls

**Example scenarios:**
- Find all functions called by `initializeApp()`
- Trace what `handleRequest()` depends on
- Map dependency chain of a complex function

## Operation Selection Matrix

| I need to... | Use |
|--------------|-----|
| Understand what a function does | `goToDefinition` |
| Find all usages before refactoring | `findReferences` |
| Find interface implementations | `goToImplementation` |
| Get type info quickly | `hover` |
| See file structure | `documentSymbol` |
| Search for symbol by name | `workspaceSymbol` |
| Find who calls this function | `incomingCalls` |
| Find what this function calls | `outgoingCalls` |

## Error Handling

**LSP operation failed?**

1. Verify file exists and path is absolute
2. Check line/character are 1-based and valid
3. Verify LSP server is running for file type
4. Check `ENABLE_LSP_TOOL=1` is set

**Common issues:**
- 0-based vs 1-based positions (LSP uses 1-based)
- Relative vs absolute paths (LSP requires absolute)
- LSP server not started for language
- File not saved (LSP may not see unsaved changes)

## Performance Characteristics

| Operation | Typical Latency | Scope |
|-----------|-----------------|-------|
| goToDefinition | ~50ms | Single target |
| findReferences | ~100-500ms | Workspace-wide |
| hover | ~30ms | Local |
| documentSymbol | ~50ms | Single file |
| workspaceSymbol | ~200ms | Workspace-wide |
| incomingCalls | ~100-300ms | Workspace-wide |
| outgoingCalls | ~100-300ms | Workspace-wide |

All operations are significantly faster than equivalent grep searches on large codebases.
