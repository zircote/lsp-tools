# LSP Tools - Ruby LSP Server Installation
# Installs ruby-lsp

$ErrorActionPreference = "Stop"

Write-Host "=== Ruby LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: ruby-lsp"
Write-Host ""

# Check if ruby-lsp already installed
$rubyLsp = Get-Command ruby-lsp -ErrorAction SilentlyContinue
if ($rubyLsp) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "ruby-lsp is already installed"
    try { & ruby-lsp --version } catch { }
    exit 0
}

# Check if solargraph (alternative) already installed
$solargraph = Get-Command solargraph -ErrorAction SilentlyContinue
if ($solargraph) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "solargraph (alternative Ruby LSP) is already installed"
    try { & solargraph --version } catch { }
    exit 0
}

# Check Ruby and gem
$ruby = Get-Command ruby -ErrorAction SilentlyContinue
if (-not $ruby) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Ruby is required but not installed"
    Write-Host "Install from https://rubyinstaller.org"
    exit 1
}

$gem = Get-Command gem -ErrorAction SilentlyContinue
if (-not $gem) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "gem is required but not found"
    exit 1
}

$rubyVersion = & ruby -v
Write-Host "Ruby version: $rubyVersion"

Write-Host "Installing ruby-lsp gem..."
gem install ruby-lsp

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "Ruby LSP server installed!"
Write-Host ""
Write-Host "Verify installation:"
Write-Host "  ruby-lsp --version"
Write-Host ""
Write-Host "[ALTERNATIVE] " -ForegroundColor Yellow -NoNewline
Write-Host "Solargraph:"
Write-Host "  gem install solargraph"
