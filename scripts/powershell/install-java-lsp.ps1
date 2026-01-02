# LSP Tools - Java LSP Server Installation
# Installs Eclipse JDT Language Server (jdtls)

$ErrorActionPreference = "Stop"

Write-Host "=== Java LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: jdtls (Eclipse JDT Language Server)"
Write-Host ""

# Check if already installed
$jdtls = Get-Command jdtls -ErrorAction SilentlyContinue
if ($jdtls) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "jdtls is already installed"
    exit 0
}

# Check for existing installation directory
$installDir = Join-Path $env:USERPROFILE "jdtls"
if (Test-Path $installDir) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "jdtls found in $installDir"
    Write-Host "Add jdtls to PATH or create a wrapper script"
    exit 0
}

# Check Java version (jdtls requires Java 21+)
$java = Get-Command java -ErrorAction SilentlyContinue
if (-not $java) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Java is required but not installed"
    Write-Host "Install OpenJDK 21+ from https://adoptium.net"
    exit 1
}

$javaVersionOutput = & java -version 2>&1 | Select-Object -First 1
$javaVersion = [regex]::Match($javaVersionOutput, '"(\d+)').Groups[1].Value
if ([int]$javaVersion -lt 21) {
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host "Java 21+ required for jdtls (found Java $javaVersion)"
    Write-Host "Upgrade Java from https://adoptium.net"
}

# Try scoop
$scoop = Get-Command scoop -ErrorAction SilentlyContinue
if ($scoop) {
    Write-Host "Installing jdtls via scoop..."
    scoop bucket add java
    scoop install jdtls

    Write-Host ""
    Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
    Write-Host "Java LSP server installed via scoop!"
    exit 0
}

# Manual installation
Write-Host "Installing jdtls manually..."
Write-Host ""

$downloadUrl = "http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"
$tempFile = Join-Path $env:TEMP "jdt-language-server-latest.tar.gz"

Write-Host "Downloading jdtls..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

Write-Host "Extracting to $installDir..."
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# Use tar if available (Windows 10+)
$tar = Get-Command tar -ErrorAction SilentlyContinue
if ($tar) {
    tar -xzf $tempFile -C $installDir
} else {
    # Fallback: inform user to extract manually
    Write-Host "[INFO] " -ForegroundColor Yellow -NoNewline
    Write-Host "Please extract manually: $tempFile -> $installDir"
}

Remove-Item $tempFile -ErrorAction SilentlyContinue

# Create wrapper script
$localBin = Join-Path $env:USERPROFILE ".local\bin"
New-Item -ItemType Directory -Path $localBin -Force | Out-Null

$wrapperContent = @"
@echo off
java ^
    -Declipse.application=org.eclipse.jdt.ls.core.id1 ^
    -Dosgi.bundles.defaultStartLevel=4 ^
    -Declipse.product=org.eclipse.jdt.ls.core.product ^
    -noverify ^
    -Xms1G ^
    -jar "%USERPROFILE%\jdtls\plugins\org.eclipse.equinox.launcher_*.jar" ^
    -configuration "%USERPROFILE%\jdtls\config_win" ^
    %*
"@

$wrapperPath = Join-Path $localBin "jdtls.cmd"
Set-Content -Path $wrapperPath -Value $wrapperContent

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "Java LSP server installed!"
Write-Host ""
Write-Host "Wrapper script created at: $wrapperPath"
Write-Host ""
Write-Host "[NOTE] " -ForegroundColor Yellow -NoNewline
Write-Host "Add $localBin to PATH"
