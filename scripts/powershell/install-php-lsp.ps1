# LSP Tools - PHP LSP Server Installation
# Installs phpactor or intelephense

$ErrorActionPreference = "Stop"

Write-Host "=== PHP LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: intelephense (npm) or phpactor (composer)"
Write-Host ""

# Check if intelephense already installed
$intelephense = Get-Command intelephense -ErrorAction SilentlyContinue
if ($intelephense) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "intelephense is already installed"
    exit 0
}

# Check if phpactor already installed
$phpactor = Get-Command phpactor -ErrorAction SilentlyContinue
if ($phpactor) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "phpactor is already installed"
    try { & phpactor --version } catch { }
    exit 0
}

# Prefer npm (intelephense is easier on Windows)
$npm = Get-Command npm -ErrorAction SilentlyContinue
if ($npm) {
    Write-Host "Installing intelephense via npm..."
    npm install -g intelephense

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "PHP LSP server (intelephense) installed!"
    Write-Host ""
    Write-Host "Verify installation:"
    Write-Host "  intelephense --version"
    exit 0
}

# Try composer
$composer = Get-Command composer -ErrorAction SilentlyContinue
if ($composer) {
    Write-Host "Installing phpactor via Composer global..."
    composer global require phpactor/phpactor

    # Get composer bin path
    $composerHome = & composer config -g home
    $composerBin = Join-Path $composerHome "vendor\bin"

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "PHP LSP server (phpactor) installed!"
    Write-Host ""
    Write-Host "[IMPORTANT] " -ForegroundColor Yellow -NoNewline
    Write-Host "Add Composer bin to PATH:"
    Write-Host "  $composerBin"
    exit 0
}

Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
Write-Host "No package manager found (npm or composer required)"
exit 1
