#Requires -Version 7.0
<#
.SYNOPSIS
    Setup Java environment using SDKMAN

.DESCRIPTION
    Installs GraalVM Java distribution via SDKMAN and sets it as default
    
.EXAMPLE
    .\setup_java.ps1

.NOTES
    Requires SDKMAN to be installed: https://sdkman.io/
    On Windows, use Git Bash or WSL for SDKMAN
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "☕ Java Environment Setup" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Check if SDKMAN is available
$sdkmanInit = "$env:USERPROFILE/.sdkman/bin/sdkman-init.sh"
if (-not (Test-Path $sdkmanInit)) {
    $sdkmanInit = "$env:HOME/.sdkman/bin/sdkman-init.sh"
}

if (-not (Test-Path $sdkmanInit)) {
    Write-Host "❌ SDKMAN not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install SDKMAN first:" -ForegroundColor Yellow
    Write-Host "  curl -s `"https://get.sdkman.io`" | bash"
    Write-Host ""
    Write-Host "On Windows, use Git Bash or WSL to install SDKMAN" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ SDKMAN found" -ForegroundColor Green
Write-Host ""

# Function to run sdk command
function Invoke-SdkCommand {
    param([string]$Command)
    
    # SDKMAN requires bash environment
    if ($IsWindows) {
        # Try to use bash (Git Bash or WSL)
        if (Get-Command bash -ErrorAction SilentlyContinue) {
            bash -c "source `"$sdkmanInit`" && sdk $Command"
        } else {
            Write-Error "Bash not found. Install Git Bash or use WSL for SDKMAN on Windows"
        }
    } else {
        bash -c "source `"$sdkmanInit`" && sdk $Command"
    }
}

# Install GraalVM (replace '24-graal' with preferred version)
Write-Host "📦 Installing GraalVM Java 24..." -ForegroundColor Yellow
Invoke-SdkCommand "install java 24-graal"

# Alternative LTS versions (uncommented if needed):
# Invoke-SdkCommand "install java 21.0.7-graal"
# Invoke-SdkCommand "install java 21.0.7-zulu"
# Invoke-SdkCommand "install java 21.0.7-librca"
# Invoke-SdkCommand "install java 21.0.7.fx-librca"

Write-Host ""
Write-Host "🔧 Setting GraalVM as default JDK..." -ForegroundColor Yellow
Invoke-SdkCommand "default java 24-graal"

Write-Host ""
Write-Host "✅ Java setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Verifying installation..." -ForegroundColor Cyan
Invoke-SdkCommand "current java"
Write-Host ""

# Verify with java -version (this should work in current shell after SDKMAN setup)
Write-Host "Java version:" -ForegroundColor Cyan
java -version
