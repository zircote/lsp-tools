# LSP Tools - Prerequisite Checker for Windows
# Verifies system prerequisites for LSP server installation

$ErrorActionPreference = "Continue"

# Track missing prerequisites
$script:MissingPrereqs = @()

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[MISSING] " -ForegroundColor Red -NoNewline
    Write-Host $Message
    $script:MissingPrereqs += $Message
}

function Test-Command {
    param(
        [string]$Name,
        [string]$Command,
        [string]$InstallHint = ""
    )

    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if ($cmd) {
        try {
            $version = & $Command --version 2>&1 | Select-Object -First 1
            Write-Ok "$Name`: $version"
        } catch {
            Write-Ok "$Name`: installed"
        }
        return $true
    } else {
        Write-Fail "$Name not found"
        if ($InstallHint) {
            Write-Host "       Install: $InstallHint" -ForegroundColor Gray
        }
        return $false
    }
}

Write-Host "=== LSP Tools Prerequisite Check ===" -ForegroundColor Cyan
Write-Host "OS: Windows $([Environment]::OSVersion.Version)"
Write-Host ""

Write-Host "--- Package Managers ---" -ForegroundColor Cyan
Test-Command "npm" "npm" "Install Node.js from https://nodejs.org"
Test-Command "pip" "pip" "Install Python from https://python.org"
Test-Command "winget" "winget" "Should be pre-installed on Windows 10/11"
Test-Command "choco" "choco" "Install from https://chocolatey.org"
Test-Command "scoop" "scoop" "Install from https://scoop.sh"

Write-Host ""
Write-Host "--- Language Runtimes ---" -ForegroundColor Cyan
Test-Command "Node.js" "node" "Install from https://nodejs.org"
Test-Command "Python" "python" "Install from https://python.org"
Test-Command "Go" "go" "Install from https://go.dev/dl/"
Test-Command "Rust (cargo)" "cargo" "Install from https://rustup.rs"
Test-Command "Ruby" "ruby" "Install from https://rubyinstaller.org"
Test-Command "PHP" "php" "Install via XAMPP or direct download"
Test-Command "Java" "java" "Install OpenJDK 21+ from https://adoptium.net"
Test-Command ".NET SDK" "dotnet" "Install from https://dotnet.microsoft.com"
Test-Command "Composer" "composer" "Install from https://getcomposer.org"

Write-Host ""
Write-Host "--- Optional Tools ---" -ForegroundColor Cyan
Test-Command "rustup" "rustup" "Install from https://rustup.rs" | Out-Null

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($script:MissingPrereqs.Count -eq 0) {
    Write-Host "All prerequisites satisfied!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Missing prerequisites: $($script:MissingPrereqs.Count)" -ForegroundColor Yellow
    foreach ($prereq in $script:MissingPrereqs) {
        Write-Host "  - $prereq" -ForegroundColor Yellow
    }
    exit 1
}
