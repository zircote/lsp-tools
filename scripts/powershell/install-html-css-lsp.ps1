# LSP Tools - HTML/CSS LSP Server Installation
# Installs vscode-langservers-extracted

$ErrorActionPreference = "Stop"

Write-Host "=== HTML/CSS LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: vscode-langservers-extracted"
Write-Host ""

# Check if already installed
$htmlLsp = Get-Command vscode-html-language-server -ErrorAction SilentlyContinue
if ($htmlLsp) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "vscode-html-language-server is already installed"
    try { & vscode-html-language-server --version } catch { }
    exit 0
}

# Check via npm
$npmCheck = npm list -g vscode-langservers-extracted 2>&1 | Select-String "vscode-langservers"
if ($npmCheck) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "vscode-langservers-extracted is installed via npm"
    exit 0
}

# Verify npm is available
$npm = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npm) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "npm is required but not installed"
    Write-Host "Install Node.js from https://nodejs.org"
    exit 1
}

Write-Host "Installing vscode-langservers-extracted..."
npm install -g vscode-langservers-extracted

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "HTML/CSS LSP servers installed!"
Write-Host ""
Write-Host "This package provides:"
Write-Host "  - vscode-html-language-server"
Write-Host "  - vscode-css-language-server"
Write-Host "  - vscode-json-language-server"
Write-Host "  - vscode-eslint-language-server"
Write-Host ""
Write-Host "Verify installation:"
Write-Host "  vscode-html-language-server --version"
