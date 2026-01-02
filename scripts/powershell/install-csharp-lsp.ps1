# LSP Tools - C# LSP Server Installation
# Installs OmniSharp

$ErrorActionPreference = "Stop"

Write-Host "=== C# LSP Server Installation ===" -ForegroundColor Cyan
Write-Host "Server: OmniSharp"
Write-Host ""

# Check if already installed
$omnisharp = Get-Command omnisharp -ErrorAction SilentlyContinue
if ($omnisharp) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "OmniSharp is already installed"
    try { & omnisharp --version } catch { }
    exit 0
}

# Check for .NET SDK (includes language server)
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnet) {
    $dotnetVersion = & dotnet --version
    $majorVersion = [int]($dotnetVersion.Split('.')[0])

    if ($majorVersion -ge 6) {
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host ".NET $dotnetVersion includes built-in language server"
        Write-Host "OmniSharp standalone is optional with .NET 6+"
        exit 0
    }
}

# Download from GitHub releases
Write-Host "Installing OmniSharp from GitHub releases..."

$installDir = Join-Path $env:USERPROFILE ".local\omnisharp"
$localBin = Join-Path $env:USERPROFILE ".local\bin"

# Determine architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "win-x64" } else { "win-x86" }

$releasesUrl = "https://api.github.com/repos/OmniSharp/omnisharp-roslyn/releases/latest"

Write-Host "Fetching latest release for $arch..."
$releases = Invoke-RestMethod -Uri $releasesUrl
$asset = $releases.assets | Where-Object { $_.name -like "*$arch*" -and $_.name -like "*.zip" } | Select-Object -First 1

if (-not $asset) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Could not find release for $arch"
    exit 1
}

$downloadUrl = $asset.browser_download_url
$tempFile = Join-Path $env:TEMP "omnisharp.zip"

Write-Host "Downloading from: $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile

Write-Host "Extracting to $installDir..."
Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive -Path $tempFile -DestinationPath $installDir
Remove-Item $tempFile -ErrorAction SilentlyContinue

# Create wrapper
New-Item -ItemType Directory -Path $localBin -Force | Out-Null
$wrapperContent = "@echo off`n`"%USERPROFILE%\.local\omnisharp\OmniSharp.exe`" %*"
Set-Content -Path (Join-Path $localBin "omnisharp.cmd") -Value $wrapperContent

Write-Host ""
Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
Write-Host "C# LSP server installed!"
Write-Host ""
Write-Host "Installed to: $installDir"
Write-Host ""
Write-Host "[NOTE] " -ForegroundColor Yellow -NoNewline
Write-Host "Add $localBin to PATH"
