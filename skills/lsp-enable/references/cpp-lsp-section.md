# CLAUDE.md LSP Section for C/C++

## Code Intelligence (LSP)

### Navigation & Understanding
- Use LSP `goToDefinition` before modifying unfamiliar functions, classes, or macros
- Use LSP `findReferences` before refactoring—critical for header/implementation pairs
- Use LSP `documentSymbol` to understand file structure and class hierarchies
- Prefer LSP navigation over grep—it resolves through includes and templates

### Verification Workflow
- Check LSP diagnostics after each edit to catch compilation errors
- Run your build system (`make`, `cmake --build`, `ninja`) for full verification
- Verify includes are correct and headers are properly guarded

### Pre-Edit Checklist
- [ ] Navigate to definition to understand implementation (may be in .cpp or .h)
- [ ] Find all references to assess change impact across headers and sources
- [ ] Review type signatures, templates, and macros via hover
- [ ] Check if modifying public API in headers

### Error Handling
- If LSP reports errors, fix them before proceeding
- Pay attention to include errors—they cascade
- Template errors require careful reading of the full error message

## C/C++ Tooling

### Build Systems

#### CMake
```bash
# Configure
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build

# Build with parallel jobs
cmake --build build -j$(nproc)

# Clean
cmake --build build --target clean
```

#### Make
```bash
make
make -j$(nproc)
make clean
```

#### Ninja
```bash
ninja -C build
ninja -C build clean
```

### Quality Gates
- Compile: `cmake --build build`
- Static analysis: `clang-tidy src/*.cpp`
- Format: `clang-format -i src/*.cpp src/*.h`
- Format check: `clang-format --dry-run -Werror src/*.cpp`
- Test: `ctest --test-dir build` or `./build/tests`

### Before Committing
```bash
clang-format --dry-run -Werror src/*.cpp src/*.h && cmake --build build && ctest --test-dir build
```

### Useful Commands
- `compile_commands.json` — Generate for clangd: `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
- `clang-tidy --fix` — Auto-fix lint issues
- `include-what-you-use` — Check include hygiene

## Language Server Details

- **Server**: clangd (LLVM)
- **Install**: 
  - macOS: `brew install llvm`
  - Ubuntu: `sudo apt install clangd`
  - Arch: `sudo pacman -S clang`
- **Requires**: `compile_commands.json` for best results
- **Features**: Full C/C++ support including templates, macros, headers
