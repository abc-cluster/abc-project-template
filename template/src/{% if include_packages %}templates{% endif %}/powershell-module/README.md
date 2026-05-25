# PowerShell Module Template

This template provides a standardized structure for developing PowerShell modules in academic research contexts.

## Features

- Modern PowerShell module structure with manifest (.psd1)
- Comprehensive function organization (Public/Private)
- Pester testing framework integration
- Academic citation support
- Cross-platform compatibility (PowerShell Core)
- Research-focused cmdlets and functions
- Parameter validation and error handling
- Help documentation with examples

## Usage

```bash
just create-powershell-module ResearchAnalysis "Advanced data analysis module"
```

## Structure

```
ResearchAnalysis/
├── ResearchAnalysis.psd1        # Module manifest
├── ResearchAnalysis.psm1        # Module file
├── Public/                      # Exported functions
│   ├── Invoke-ResearchAnalysis.ps1
│   └── Test-ResearchData.ps1
├── Private/                     # Internal functions
│   └── Write-ResearchLog.ps1
├── Tests/                       # Pester tests
│   └── ResearchAnalysis.Tests.ps1
├── Docs/                        # Documentation
├── en-US/                       # Help files
└── README.md                    # Module documentation
```

## PowerShell Components

The template includes:

- **Invoke-ResearchAnalysis**: Main analysis cmdlet with pipeline support
- **Test-ResearchData**: Data validation and quality checks
- **Write-ResearchLog**: Internal logging functionality
- Comprehensive Pester tests
- Parameter validation and type checking
- Pipeline-aware functions
- Academic citation formatting

## Distribution

- **PowerShell Gallery**: Official PowerShell package repository
- **Local installation**: Import-Module for development
- **Cross-platform**: Works on Windows, macOS, and Linux

## Example Usage

```powershell
# Import the module
Import-Module ResearchAnalysis

# Analyze data from CSV
$results = Invoke-ResearchAnalysis -InputData "data.csv" -Parameter 2.0

# Validate data quality
$validation = Test-ResearchData -Data $results

# Pipeline usage
Get-ChildItem "*.csv" | Invoke-ResearchAnalysis -Parameter 1.5
```
