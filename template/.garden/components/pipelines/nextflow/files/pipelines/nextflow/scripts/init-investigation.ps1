#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Initialize a new Nextflow investigation with directory structure and metadata

.DESCRIPTION
    Creates investigation directory, copies templates, tracks git state, and registers in database

.PARAMETER Type
    Investigation type: development, production, or planning

.PARAMETER Name
    Short investigation name (will be slugified)

.PARAMETER Purpose
    Description of investigation purpose

.PARAMETER Dataset
    Dataset name (for production investigations)

.PARAMETER Scenario
    Execution scenario: local-local, local-remote, tower, planning-only

.PARAMETER ParamsTemplate
    Parameter template to use: default-params, full-dataset, etc.

.EXAMPLE
    ./init-investigation.ps1 -Type development -Name "test-run" -Purpose "Testing pipeline"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('development', 'production', 'planning')]
    [string]$Type,
    
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter(Mandatory=$false)]
    [string]$Purpose = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Dataset = "",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('local-local', 'local-remote', 'tower', 'planning-only')]
    [string]$Scenario = "local-local",
    
    [Parameter(Mandatory=$false)]
    [string]$ParamsTemplate = "default-params"
)

# Script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BASE_DIR = Split-Path -Parent $SCRIPT_DIR
$TEMPLATES_DIR = Join-Path $BASE_DIR "investigations" "templates"
$EXPTS_DIR = Join-Path $BASE_DIR "investigations"

# Generate investigation ID
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmm"
$SLUG = $Name -replace '[^a-z0-9-]', '-' -replace '-+', '-' -replace '^-|-$', ''
$EXP_ID = "${TIMESTAMP}_deve-${SLUG}"

if ($Type -eq "production") {
    $EXP_ID = "${TIMESTAMP}_prod-${SLUG}"
} elseif ($Type -eq "planning") {
    $EXP_ID = "${TIMESTAMP}_plan-${SLUG}"
}

Write-Host "🧪 Creating investigation: $EXP_ID" -ForegroundColor Blue

# Create directory structure
$EXP_DIR = Join-Path $EXPTS_DIR $Type "runs" $EXP_ID

Write-Host "📁 Creating directory structure..." -ForegroundColor Blue
New-Item -ItemType Directory -Path $EXP_DIR -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $EXP_DIR "work") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $EXP_DIR "results") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $EXP_DIR "nextflow-logs") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $EXP_DIR "reports") -Force | Out-Null

# Copy templates
Write-Host "📄 Copying templates..." -ForegroundColor Blue

# Copy metadata template
$MetadataTemplate = Join-Path $TEMPLATES_DIR "metadata.yaml.template"
$MetadataFile = Join-Path $EXP_DIR "metadata.yaml"
if (Test-Path $MetadataTemplate) {
    (Get-Content $MetadataTemplate) `
        -replace '{{INVESTIGATION_ID}}', $EXP_ID `
        -replace '{{TYPE}}', $Type `
        -replace '{{PURPOSE}}', $Purpose `
        -replace '{{SCENARIO}}', $Scenario `
        -replace '{{CREATED_AT}}', (Get-Date -Format "yyyy-MM-dd HH:mm:ss") `
        -replace '{{RESEARCHER}}', $env:USERNAME |
        Set-Content $MetadataFile
}

# Copy execution template
$ExecutionTemplate = Join-Path $TEMPLATES_DIR "execution.yaml.template"
$ExecutionFile = Join-Path $EXP_DIR "execution.yaml"
if (Test-Path $ExecutionTemplate) {
    (Get-Content $ExecutionTemplate) `
        -replace '{{INVESTIGATION_ID}}', $EXP_ID `
        -replace '{{SCENARIO}}', $Scenario |
        Set-Content $ExecutionFile
}

# Copy parameter template
$ParamsTemplatePath = Join-Path $BASE_DIR "investigations" "configs" "params-templates" "$ParamsTemplate.yaml"
$ParamsFile = Join-Path $EXP_DIR "params.yaml"
if (Test-Path $ParamsTemplatePath) {
    Copy-Item $ParamsTemplatePath $ParamsFile
    Write-Host "✅ Copied parameter template: $ParamsTemplate" -ForegroundColor Green
}

# Copy other templates
$Templates = @("README.md", "investigation-plan.md", "execution-log.md", "results-manifest.yaml", "samplesheet.csv", "tower-info.yaml")
foreach ($Template in $Templates) {
    $TemplatePath = Join-Path $TEMPLATES_DIR "$Template.template"
    $DestPath = Join-Path $EXP_DIR $Template
    if (Test-Path $TemplatePath) {
        (Get-Content $TemplatePath) -replace '{{INVESTIGATION_ID}}', $EXP_ID | Set-Content $DestPath
    }
}

# Track git commit
Write-Host "📝 Tracking git commit..." -ForegroundColor Blue
$GitScript = Join-Path $SCRIPT_DIR "track-git-commit.ps1"
if (Test-Path $GitScript) {
    & $GitScript -InvestigationDir $EXP_DIR
} else {
    Write-Warning "Git tracking script not found"
}

# Register in database
Write-Host "💾 Registering in database..." -ForegroundColor Blue
$RegisterScript = Join-Path $SCRIPT_DIR "register-investigation.py"
& python3 $RegisterScript create --id $EXP_ID --type $Type --scenario $Scenario --purpose $Purpose

# Create symlink
$SymlinkDir = Join-Path $EXPTS_DIR $Type "active"
$SymlinkPath = Join-Path $SymlinkDir $Name

if (Test-Path $SymlinkPath) {
    Remove-Item $SymlinkPath -Force
}

# Create symbolic link (requires elevated privileges on Windows)
try {
    New-Item -ItemType SymbolicLink -Path $SymlinkPath -Target $EXP_DIR -Force | Out-Null
    Write-Host "🔗 Created symlink: $Type/active/$Name -> $EXP_ID" -ForegroundColor Green
} catch {
    Write-Warning "Could not create symlink (may require elevated privileges on Windows)"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ Investigation created successfully!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "  Investigation ID: $EXP_ID"
Write-Host "  Type:          $Type"
Write-Host "  Scenario:      $Scenario"
Write-Host "  Location:      $EXP_DIR"
Write-Host "  Symlink:       investigations/$Type/active/$Name"

Write-Host "`n📝 Next Steps:"
Write-Host "  1. Edit investigation plan: $EXP_DIR\investigation-plan.md"
Write-Host "  2. Configure parameters: $EXP_DIR\params.yaml"
Write-Host "  3. Update samplesheet:   $EXP_DIR\samplesheet.csv"

Write-Host "`n🚀 Run Commands:"
Write-Host "  just run-local $EXP_ID"
Write-Host "  just run-aws $EXP_ID"
Write-Host "  just run-tower $EXP_ID"
