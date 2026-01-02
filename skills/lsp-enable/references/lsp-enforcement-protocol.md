# LSP Enforcement Protocol

Mandatory behavioral patterns for LSP-first code intelligence.

## The Three Iron Laws

### Iron Law 1: Pre-Edit Navigation

```
NO MODIFYING UNFAMILIAR CODE WITHOUT goToDefinition FIRST
```

**Applies when:**
- About to edit a function you haven't written
- Modifying code in an unfamiliar codebase
- Changing code you haven't touched in 30+ days
- Implementing changes suggested by external review

**Required actions:**
1. `goToDefinition` - Navigate to implementation
2. Read and understand the code
3. `hover` - Verify type signatures
4. THEN make changes

**Violations:**
- "I'll just change this function" (without reading it)
- "The name tells me what it does" (names lie)
- "I'll figure it out from the error" (wastes iterations)

### Iron Law 2: Pre-Refactor Impact Analysis

```
NO REFACTORING WITHOUT findReferences IMPACT ANALYSIS FIRST
```

**Applies when:**
- Renaming any symbol (function, variable, type, constant)
- Changing function signatures
- Modifying interface contracts
- Relocating or deleting code
- Changing exported APIs

**Required actions:**
1. `findReferences` - Get all usages
2. Count and categorize usages
3. Plan updates for each usage
4. THEN refactor with full awareness

**Violations:**
- "It's probably only used here" (probably = bug)
- "I'll fix compilation errors after" (creates cascading issues)
- "Quick rename, should be fine" (famous last words)

### Iron Law 3: Post-Edit Diagnostics

```
NO CLAIMING CODE WORKS WITHOUT LSP DIAGNOSTICS VERIFICATION
```

**Applies when:**
- About to claim changes are complete
- Before committing code
- Before moving to next task
- When stating "tests pass" or "build succeeds"

**Required actions:**
1. Check LSP diagnostics for errors
2. Verify no new warnings introduced
3. Confirm imports resolve
4. Run build/typecheck if available
5. THEN claim success with evidence

**Violations:**
- "Looks good to me" (looking ≠ verifying)
- "Should work now" (should = unverified)
- "Fixed the bug" (without confirming symptom gone)

## Enforcement Scenarios

### Scenario 1: Modifying Existing Function

```
TRIGGER: User asks to modify function X

1. CHECK: Have I read function X? (No → goToDefinition)
2. CHECK: Do I know who calls X? (No → findReferences)
3. MODIFY: Make changes
4. VERIFY: LSP diagnostics clean?
5. CONFIRM: State changes with evidence
```

### Scenario 2: Implementing Feature

```
TRIGGER: User asks to implement feature touching existing code

1. NAVIGATE: goToDefinition for each touched file
2. ANALYZE: findReferences for modified symbols
3. UNDERSTAND: hover for type contracts
4. IMPLEMENT: Write code
5. VERIFY: LSP diagnostics after changes
6. CONFIRM: Evidence of success
```

### Scenario 3: Refactoring Code

```
TRIGGER: User asks to refactor/rename/restructure

1. SCOPE: findReferences → count all usages
2. PLAN: List all files requiring changes
3. EXECUTE: Make changes systematically
4. VERIFY: LSP diagnostics clean
5. CONFIRM: All usages updated
```

### Scenario 4: Debugging Issue

```
TRIGGER: User reports bug or unexpected behavior

1. TRACE: goToDefinition → follow code path
2. ANALYZE: incomingCalls → understand call chain
3. INSPECT: hover → verify types at boundaries
4. FIX: Make minimal change
5. VERIFY: LSP diagnostics + original symptom resolved
```

## Fallback Protocol

When LSP is unavailable:

### Step 1: Warn

```
"LSP is not available for this operation.
Results may include false positives or miss some usages."
```

### Step 2: Suggest Fix

```
"To enable LSP:
1. Set ENABLE_LSP_TOOL=1 in your shell profile
2. Ensure language server is installed (e.g., pyright, gopls)
3. Restart Claude Code session"
```

### Step 3: Fall Back with Documentation

```
"Falling back to grep-based search.
NOTE: This may include:
- Matches in comments or strings
- Similarly-named but different symbols
- May miss aliased or re-exported usages"
```

### Step 4: Document Limitation

In any output or summary:
```
"[grep fallback - verify completeness manually]"
```

## Red Flag Patterns

### Pattern: Skipping Navigation

**Symptom:** Proposing changes without reading code first

**Detection phrases:**
- "I'll change this to..."
- "We should update the..."
- "Let me fix this by..."

**Correction:** STOP. Use goToDefinition first.

### Pattern: Blind Refactoring

**Symptom:** Renaming or restructuring without impact analysis

**Detection phrases:**
- "I'll rename this to..."
- "Let's move this to..."
- "We can delete this..."

**Correction:** STOP. Use findReferences first.

### Pattern: Unverified Claims

**Symptom:** Claiming success without evidence

**Detection phrases:**
- "This should work now"
- "Fixed the issue"
- "Changes are complete"

**Correction:** STOP. Run verification first.

### Pattern: Grep for Semantics

**Symptom:** Using grep for semantic code operations

**Detection phrases:**
- "Let me grep for the function"
- "I'll search for usages"
- "Looking for references with grep"

**Correction:** Use LSP instead. Grep is for text, not semantics.

## Compliance Checklist

Before claiming any code task complete:

- [ ] Used goToDefinition for unfamiliar code
- [ ] Used findReferences before refactoring
- [ ] Checked LSP diagnostics after changes
- [ ] No unverified claims ("should work", "probably fine")
- [ ] Evidence provided for success claims
- [ ] If LSP unavailable: documented fallback limitation

## Integration with Other Skills

This protocol integrates with:

- **Verification Before Completion**: Use LSP diagnostics as verification evidence
- **Systematic Debugging**: Use LSP for root cause tracing
- **Code Review**: Use findReferences for impact assessment
