#Requires -Version 7.0
<#
.SYNOPSIS
    Add shell platform selection to all justfiles

.DESCRIPTION
    Batch updates all justfiles in the template project to add shell configuration variables

.EXAMPLE
    .\update-justfiles.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

# Shell configuration header to add
$ShellConfig = @"
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }

"@

# Find all justfiles
$Justfiles = Get-ChildItem -Path . -Recurse -Include "*.just", "justfile" |
    Where-Object { $_.FullName -notmatch ".pixi" -and $_.FullName -notmatch "node_modules" } |
    Sort-Object FullName

Write-Host "🔍 Found $($Justfiles.Count) justfiles to update:" -ForegroundColor Cyan
$Justfiles | ForEach-Object { Write-Host "  - $($_.FullName.Replace((Get-Location).Path + '\', ''))" }
Write-Host ""

# Counter
$Count = 0
$Skipped = 0
$Updated = 0

# Process each justfile
foreach ($file in $Justfiles) {
    $Count++
    
    # Check if already has shell configuration
    $content = Get-Content $file.FullName -Raw
    if ($content -match "SHELL_TYPE :=") {
        Write-Host "⏭️  Skipping $($file.Name) (already has shell configuration)" -ForegroundColor Yellow
        $Skipped++
        continue
    }
    
    Write-Host "✏️  Updating $($file.Name)..." -ForegroundColor Green
    
    # Add shell configuration at the top
    $newContent = $ShellConfig + $content
    Set-Content -Path $file.FullName -Value $newContent -NoNewline
    
    $Updated++
}

Write-Host ""
Write-Host "✅ Update complete!" -ForegroundColor Green
Write-Host "   Total files: $Count"
Write-Host "   Updated: $Updated"
Write-Host "   Skipped: $Skipped"
