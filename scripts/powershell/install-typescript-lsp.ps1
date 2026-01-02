# LSP Tools - TypeScript/JavaScript LSP Server Installation
# Installs vtsls (@vtsls/language-server)

$ErrorActionPreference = "Stop"

Write-Host "=== TypeScript/JavaScript LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: vtsls (@vtsls/language-server)"
Write-Host ""

# Check if already installed
$vtsls = Get-Command vtsls -ErrorAction SilentlyContinue
if ($vtsls) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "vtsls is already installed"
    try { & vtsls --version } catch { }
    exit 0
}

# Check via npm
$npmCheck = npm list -g @vtsls/language-server 2>&1 | Select-String "vtsls"
if ($npmCheck) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "@vtsls/language-server is installed via npm"
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

Write-Host "Installing @vtsls/language-server and typescript..."
npm install -g @vtsls/language-server typescript

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "TypeScript LSP server installed!"
Write-Host ""
Write-Host "Verify installation:"
Write-Host "  npm list -g @vtsls/language-server"
