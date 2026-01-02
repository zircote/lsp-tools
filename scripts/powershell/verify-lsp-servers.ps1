# LSP Tools - Verify LSP Server Installations
# Checks which LSP servers are installed and reports status

$ErrorActionPreference = "Continue"

# Arrays to track status
$script:Installed = @()
$script:Missing = @()

function Test-LspServer {
    param(
        [string]$Name,
        [string]$Command,
        [string]$FallbackCheck = ""
    )

    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if ($cmd) {
        try {
            $version = & $Command --version 2>&1 | Select-Object -First 1
            Write-Host "[OK] " -ForegroundColor Green -NoNewline
            Write-Host "$Name`: $version"
        } catch {
            Write-Host "[OK] " -ForegroundColor Green -NoNewline
            Write-Host "$Name`: installed"
        }
        $script:Installed += $Name
        return $true
    } elseif ($FallbackCheck -and (Invoke-Expression $FallbackCheck 2>$null)) {
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host "$Name`: installed (via package manager)"
        $script:Installed += $Name
        return $true
    } else {
        Write-Host "[MISSING] " -ForegroundColor Red -NoNewline
        Write-Host $Name
        $script:Missing += $Name
        return $false
    }
}

Write-Host "=== LSP Server Status ===" -ForegroundColor Cyan
Write-Host ""

# Check each language server
Test-LspServer "TypeScript (vtsls)" "vtsls" "npm list -g @vtsls/language-server 2>&1 | Select-String 'vtsls'"
Test-LspServer "Python (pyright)" "pyright"
Test-LspServer "Rust (rust-analyzer)" "rust-analyzer"
Test-LspServer "Go (gopls)" "gopls"
Test-LspServer "Java (jdtls)" "jdtls" "Test-Path `"$env:USERPROFILE\jdtls`""
Test-LspServer "Kotlin (kotlin-language-server)" "kotlin-language-server"
Test-LspServer "C/C++ (clangd)" "clangd"
Test-LspServer "C# (omnisharp)" "omnisharp" "Get-Command OmniSharp -ErrorAction SilentlyContinue"
Test-LspServer "PHP (phpactor)" "phpactor" "Get-Command intelephense -ErrorAction SilentlyContinue"
Test-LspServer "Ruby (ruby-lsp)" "ruby-lsp" "Get-Command solargraph -ErrorAction SilentlyContinue"
Test-LspServer "HTML/CSS (vscode-html-language-server)" "vscode-html-language-server"
Test-LspServer "LaTeX (texlab)" "texlab"

Write-Host ""
Write-Host "=== Environment ===" -ForegroundColor Cyan
if ($env:ENABLE_LSP_TOOL -eq "1") {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host "ENABLE_LSP_TOOL=1"
} else {
    Write-Host "[MISSING] " -ForegroundColor Red -NoNewline
    Write-Host "ENABLE_LSP_TOOL not set"
    Write-Host "       Set environment variable:"
    Write-Host "         `$env:ENABLE_LSP_TOOL = '1'"
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Installed: " -NoNewline
Write-Host $script:Installed.Count -ForegroundColor Green
Write-Host "Missing: " -NoNewline
Write-Host $script:Missing.Count -ForegroundColor Red

if ($script:Missing.Count -gt 0) {
    Write-Host ""
    Write-Host "To install missing servers, use /lsp-tools:lsp-setup"
    exit 1
}

exit 0
