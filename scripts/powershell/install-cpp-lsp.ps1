# LSP Tools - C/C++ LSP Server Installation
# Installs clangd

$ErrorActionPreference = "Stop"

Write-Host "=== C/C++ LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: clangd"
Write-Host ""

# Check if already installed
$clangd = Get-Command clangd -ErrorAction SilentlyContinue
if ($clangd) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "clangd is already installed"
    try { & clangd --version | Select-Object -First 1 } catch { }
    exit 0
}

# Try winget
$winget = Get-Command winget -ErrorAction SilentlyContinue
if ($winget) {
    Write-Host "Installing LLVM (includes clangd) via winget..."
    winget install LLVM.LLVM

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "C/C++ LSP server installed!"
    Write-Host ""
    Write-Host "[IMPORTANT] " -ForegroundColor Yellow -NoNewline
    Write-Host "Add LLVM to PATH and restart terminal"
    Write-Host "  Default location: C:\Program Files\LLVM\bin"
    exit 0
}

# Try choco
$choco = Get-Command choco -ErrorAction SilentlyContinue
if ($choco) {
    Write-Host "Installing LLVM (includes clangd) via chocolatey..."
    choco install llvm -y

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "C/C++ LSP server installed!"
    exit 0
}

# Try scoop
$scoop = Get-Command scoop -ErrorAction SilentlyContinue
if ($scoop) {
    Write-Host "Installing LLVM (includes clangd) via scoop..."
    scoop install llvm

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "C/C++ LSP server installed!"
    exit 0
}

Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
Write-Host "No package manager found (winget, choco, or scoop required)"
Write-Host ""
Write-Host "Install manually from: https://releases.llvm.org"
exit 1
