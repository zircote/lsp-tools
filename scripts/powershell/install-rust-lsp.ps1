# LSP Tools - Rust LSP Server Installation
# Installs rust-analyzer

$ErrorActionPreference = "Stop"

Write-Host "=== Rust LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: rust-analyzer"
Write-Host ""

# Check if already installed
$rustAnalyzer = Get-Command rust-analyzer -ErrorAction SilentlyContinue
if ($rustAnalyzer) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "rust-analyzer is already installed"
    try { & rust-analyzer --version } catch { }
    exit 0
}

# Prefer rustup (official method)
$rustup = Get-Command rustup -ErrorAction SilentlyContinue
if ($rustup) {
    Write-Host "Installing rust-analyzer via rustup (recommended)..."
    rustup component add rust-analyzer

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "Rust LSP server installed!"
    Write-Host ""
    Write-Host "Verify installation:"
    Write-Host "  rust-analyzer --version"
    exit 0
}

# Try winget
$winget = Get-Command winget -ErrorAction SilentlyContinue
if ($winget) {
    Write-Host "[INFO] " -ForegroundColor Yellow -NoNewline
    Write-Host "rustup not found, attempting winget..."
    winget install Rustlang.Rustup

    Write-Host ""
    Write-Host "[INFO] " -ForegroundColor Yellow -NoNewline
    Write-Host "Rustup installed. Please restart terminal and run:"
    Write-Host "  rustup component add rust-analyzer"
    exit 0
}

# Try choco
$choco = Get-Command choco -ErrorAction SilentlyContinue
if ($choco) {
    Write-Host "[INFO] " -ForegroundColor Yellow -NoNewline
    Write-Host "rustup not found, attempting chocolatey..."
    choco install rustup.install -y

    Write-Host ""
    Write-Host "[INFO] " -ForegroundColor Yellow -NoNewline
    Write-Host "Rustup installed. Please restart terminal and run:"
    Write-Host "  rustup component add rust-analyzer"
    exit 0
}

Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
Write-Host "Cannot install rust-analyzer"
Write-Host ""
Write-Host "Please install Rust via rustup first:"
Write-Host "  https://rustup.rs"
Write-Host ""
Write-Host "Then run:"
Write-Host "  rustup component add rust-analyzer"
exit 1
