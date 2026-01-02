# LSP Tools - Python LSP Server Installation
# Installs pyright language server

$ErrorActionPreference = "Stop"

Write-Host "=== Python LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: pyright"
Write-Host ""

# Check if already installed
$pyright = Get-Command pyright -ErrorAction SilentlyContinue
if ($pyright) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "pyright is already installed"
    try { & pyright --version } catch { }
    exit 0
}

# Check available package managers
$npm = Get-Command npm -ErrorAction SilentlyContinue
$pip = Get-Command pip -ErrorAction SilentlyContinue

# Prefer npm (faster, no Python version conflicts)
if ($npm) {
    Write-Host "Installing pyright via npm (recommended)..."
    npm install -g pyright
} elseif ($pip) {
    Write-Host "Installing pyright via pip..."
    pip install pyright
} else {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "No package manager found (npm or pip required)"
    exit 1
}

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "Python LSP server installed!"
Write-Host ""
Write-Host "Verify installation:"
Write-Host "  pyright --version"
