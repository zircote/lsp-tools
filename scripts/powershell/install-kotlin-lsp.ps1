# LSP Tools - Kotlin LSP Server Installation
# Installs kotlin-language-server

$ErrorActionPreference = "Stop"

Write-Host "=== Kotlin LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: kotlin-language-server"
Write-Host ""

# Check if already installed
$kotlinLsp = Get-Command kotlin-language-server -ErrorAction SilentlyContinue
if ($kotlinLsp) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "kotlin-language-server is already installed"
    try { & kotlin-language-server --version } catch { }
    exit 0
}

# Check Java version (Kotlin LSP requires Java 17+)
$java = Get-Command java -ErrorAction SilentlyContinue
if (-not $java) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Java is required but not installed"
    Write-Host "Install OpenJDK 17+ from https://adoptium.net"
    exit 1
}

$javaVersionOutput = & java -version 2>&1 | Select-Object -First 1
$javaVersion = [regex]::Match($javaVersionOutput, '"(\d+)').Groups[1].Value
if ([int]$javaVersion -lt 17) {
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host "Java 17+ required for Kotlin LSP (found Java $javaVersion)"
    Write-Host "Upgrade Java from https://adoptium.net"
}

# Download from GitHub releases
Write-Host "Installing kotlin-language-server from GitHub releases..."

$installDir = Join-Path $env:USERPROFILE ".local\kotlin-language-server"
$localBin = Join-Path $env:USERPROFILE ".local\bin"

$releasesUrl = "https://api.github.com/repos/fwcd/kotlin-language-server/releases/latest"

Write-Host "Fetching latest release..."
$releases = Invoke-RestMethod -Uri $releasesUrl
$asset = $releases.assets | Where-Object { $_.name -like "*server.zip" } | Select-Object -First 1

if (-not $asset) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Could not find release download"
    Write-Host "Manual installation: https://github.com/fwcd/kotlin-language-server/releases"
    exit 1
}

$downloadUrl = $asset.browser_download_url
$tempFile = Join-Path $env:TEMP "kotlin-lsp.zip"

Write-Host "Downloading from: $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

Write-Host "Extracting to $installDir..."
Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive -Path $tempFile -DestinationPath (Split-Path $installDir)
$extractedDir = Get-ChildItem (Split-Path $installDir) -Directory | Where-Object { $_.Name -like "server*" } | Select-Object -First 1
if ($extractedDir) {
    Rename-Item $extractedDir.FullName $installDir
}
Remove-Item $tempFile -ErrorAction SilentlyContinue

# Create wrapper
New-Item -ItemType Directory -Path $localBin -Force | Out-Null
$wrapperContent = "@echo off`n`"%USERPROFILE%\.local\kotlin-language-server\bin\kotlin-language-server.bat`" %*"
Set-Content -Path (Join-Path $localBin "kotlin-language-server.cmd") -Value $wrapperContent

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "Kotlin LSP server installed!"
Write-Host ""
Write-Host "Installed to: $installDir"
Write-Host ""
Write-Host "[NOTE] " -ForegroundColor Yellow -NoNewline
Write-Host "Add $localBin to PATH"
