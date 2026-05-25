#Requires -Version 7.0
<#
.SYNOPSIS
    PowerShell scratch script with strict error handling

.DESCRIPTION
    A template script for PowerShell with best practices:
    - Requires PowerShell 7.0+
    - Strict error handling (Stop on errors)
    - Set-StrictMode for additional safety
    - Verbose output enabled by default

.EXAMPLE
    .\scratch.ps1

.EXAMPLE
    .\scratch.ps1 -Verbose

.NOTES
    This is equivalent to the Bash script with:
    set -xue -o pipefail
#>

[CmdletBinding()]
param()

# Equivalent to set -e (exit on error)
$ErrorActionPreference = "Stop"

# Equivalent to set -u (error on undefined variables) and other strict checks
Set-StrictMode -Version Latest

# Equivalent to set -x (print commands as they execute)
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
    $VerbosePreference = "Continue"
}

# Your script logic goes here
Write-Verbose "PowerShell scratch script running with strict mode"
Write-Host "✓ Script initialized successfully" -ForegroundColor Green
