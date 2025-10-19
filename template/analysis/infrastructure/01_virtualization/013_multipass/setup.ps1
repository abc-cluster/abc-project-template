#Requires -Version 7.0
<#
.SYNOPSIS
    Multipass VM setup script

.DESCRIPTION
    Creates and configures a Multipass VM for {{ project_name }}
    
.EXAMPLE
    .\setup.ps1

.NOTES
    Requires Multipass: https://multipass.run/install
    This is a Jinja2 template that will be processed during project generation
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$VmName = "{{ project_name|lower|replace(' ', '-') }}"
$CloudInit = Join-Path $PSScriptRoot "cloud-init/{{ multipass_profile }}.yaml"

Write-Host "🚀 Multipass VM Setup for {{ project_name }}" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Multipass is installed
if (-not (Get-Command multipass -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Multipass not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Multipass from:" -ForegroundColor Yellow
    Write-Host "  https://multipass.run/install" -ForegroundColor Yellow
    Write-Host ""
    if ($IsWindows) {
        Write-Host "For Windows: Download and install from the website" -ForegroundColor Yellow
    } elseif ($IsMacOS) {
        Write-Host "For macOS: brew install multipass" -ForegroundColor Yellow
    } else {
        Write-Host "For Linux: sudo snap install multipass" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host "✓ Multipass found: $(multipass version)" -ForegroundColor Green
Write-Host ""

# Check if VM already exists
try {
    $vmInfo = multipass info $VmName 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "ℹ VM '$VmName' already exists" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "VM Info:" -ForegroundColor Cyan
        multipass info $VmName
        Write-Host ""
        Write-Host "To recreate the VM, first delete it with:" -ForegroundColor Yellow
        Write-Host "  multipass delete $VmName" -ForegroundColor Yellow
        Write-Host "  multipass purge" -ForegroundColor Yellow
        exit 0
    }
} catch {
    # VM doesn't exist, continue with creation
}

Write-Host "📦 Creating new VM '$VmName'..." -ForegroundColor Green
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Memory:     {{ multipass_memory }}" -ForegroundColor White
Write-Host "  CPUs:       {{ multipass_cpus }}" -ForegroundColor White
Write-Host "  Disk:       {{ multipass_disk }}" -ForegroundColor White
Write-Host "  Cloud-init: $CloudInit" -ForegroundColor White
Write-Host "  Image:      Ubuntu 22.04 LTS" -ForegroundColor White
Write-Host ""

# Launch VM
multipass launch --name $VmName `
    --memory {{ multipass_memory }} `
    --cpus {{ multipass_cpus }} `
    --disk {{ multipass_disk }} `
    --cloud-init $CloudInit `
    22.04

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create VM" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ VM setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Access the VM:" -ForegroundColor Yellow
Write-Host "   multipass shell $VmName" -ForegroundColor White
Write-Host ""
Write-Host "2. Mount your project files:" -ForegroundColor Yellow
Write-Host "   multipass mount . ${VmName}:/home/datascientist/{{ project_name|lower|replace(' ', '-') }}" -ForegroundColor White
Write-Host ""
Write-Host "3. Get VM info:" -ForegroundColor Yellow
Write-Host "   multipass info $VmName" -ForegroundColor White
Write-Host ""
Write-Host "4. Stop the VM:" -ForegroundColor Yellow
Write-Host "   multipass stop $VmName" -ForegroundColor White
Write-Host ""
Write-Host "5. Delete the VM (when no longer needed):" -ForegroundColor Yellow
Write-Host "   multipass delete $VmName && multipass purge" -ForegroundColor White
Write-Host ""
