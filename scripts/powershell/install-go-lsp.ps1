# LSP Tools - Go LSP Server Installation
# Installs gopls (official Go language server)

$ErrorActionPreference = "Stop"

Write-Host "=== Go LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: gopls"
Write-Host ""

# Check if already installed
$gopls = Get-Command gopls -ErrorAction SilentlyContinue
if ($gopls) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "gopls is already installed"
    try { & gopls version } catch { }
    exit 0
}

# Check for Go installation
$go = Get-Command go -ErrorAction SilentlyContinue
if (-not $go) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Go is required but not installed"
    Write-Host "Install Go from https://go.dev/dl/"
    exit 1
}

# Get Go version
$goVersion = & go version
Write-Host "Go version: $goVersion"

# Install gopls
Write-Host "Installing gopls via go install..."
go install golang.org/x/tools/gopls@latest

# Check GOPATH/bin is in PATH
$gobin = & go env GOPATH
$gobinPath = Join-Path $gobin "bin"
$envPath = [Environment]::GetEnvironmentVariable("PATH", "User")

if ($envPath -notlike "*$gobinPath*") {
    Write-Host ""
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host "GOPATH\bin not in PATH"
    Write-Host ""
    Write-Host "Add to PATH:"
    Write-Host "  `$env:PATH += `";$gobinPath`""
    Write-Host ""
    Write-Host "Or permanently:"
    Write-Host "  [Environment]::SetEnvironmentVariable(`"PATH`", `"`$env:PATH;$gobinPath`", `"User`")"
}

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "Go LSP server installed!"
Write-Host ""
Write-Host "Verify installation:"
Write-Host "  $gobinPath\gopls.exe version"
