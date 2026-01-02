# LSP Tools - LaTeX LSP Server Installation
# Installs texlab

$ErrorActionPreference = "Stop"

Write-Host "=== LaTeX LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: texlab"
Write-Host ""

# Check if already installed
$texlab = Get-Command texlab -ErrorAction SilentlyContinue
if ($texlab) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "texlab is already installed"
    try { & texlab --version } catch { }
    exit 0
}

# Try winget
$winget = Get-Command winget -ErrorAction SilentlyContinue
if ($winget) {
    Write-Host "Installing texlab via winget..."
    winget install texlab.texlab

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "LaTeX LSP server installed via winget!"
    exit 0
}

# Try scoop
$scoop = Get-Command scoop -ErrorAction SilentlyContinue
if ($scoop) {
    Write-Host "Installing texlab via scoop..."
    scoop install texlab

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "LaTeX LSP server installed via scoop!"
    exit 0
}

# Try cargo
$cargo = Get-Command cargo -ErrorAction SilentlyContinue
if ($cargo) {
    Write-Host "Installing texlab via cargo..."
    cargo install --locked texlab

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "LaTeX LSP server installed via cargo!"
    exit 0
}

# Download from GitHub releases
Write-Host "Installing texlab from GitHub releases..."

$installDir = Join-Path $env:USERPROFILE ".local\texlab"
$localBin = Join-Path $env:USERPROFILE ".local\bin"

$releasesUrl = "https://api.github.com/repos/latex-lsp/texlab/releases/latest"

Write-Host "Fetching latest release..."
$releases = Invoke-RestMethod -Uri $releasesUrl
$asset = $releases.assets | Where-Object { $_.name -like "*x86_64-windows*" } | Select-Object -First 1

if (-not $asset) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Could not find Windows release"
    Write-Host "Manual download: https://github.com/latex-lsp/texlab/releases"
    exit 1
}

$downloadUrl = $asset.browser_download_url
$tempFile = Join-Path $env:TEMP "texlab.zip"

Write-Host "Downloading from: $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

Write-Host "Extracting to $installDir..."
Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Expand-Archive -Path $tempFile -DestinationPath $installDir
Remove-Item $tempFile -ErrorAction SilentlyContinue

# Create wrapper/symlink
New-Item -ItemType Directory -Path $localBin -Force | Out-Null
Copy-Item (Join-Path $installDir "texlab.exe") (Join-Path $localBin "texlab.exe")

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "LaTeX LSP server installed!"
Write-Host ""
Write-Host "[NOTE] " -ForegroundColor Yellow -NoNewline
Write-Host "Requires a TeX distribution (MiKTeX or TeX Live)"
Write-Host ""
Write-Host "[NOTE] " -ForegroundColor Yellow -NoNewline
Write-Host "Add $localBin to PATH"
