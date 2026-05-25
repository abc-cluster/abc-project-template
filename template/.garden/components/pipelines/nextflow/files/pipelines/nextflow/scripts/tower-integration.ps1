#Requires -Version 7.0
<#
.SYNOPSIS
    Tower Integration Script for Nextflow experiments

.DESCRIPTION
    Fetches Tower metadata and links it to local experiments

.PARAMETER ExperimentDir
    Path to experiment directory

.PARAMETER Workspace
    Tower workspace (default: value from TOWER_WORKSPACE env var or 'default')

.EXAMPLE
    .\tower-integration.ps1 experiments/development/runs/exp_20250117_1000

.EXAMPLE
    .\tower-integration.ps1 experiments/production/runs/exp_20250117_1500 my-workspace

.NOTES
    Requires:
    - Tower CLI (tw) must be installed: pipx install tower-cli
    - Tower access token must be configured: tw login
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$ExperimentDir,
    
    [Parameter(Position=1)]
    [string]$Workspace = $env:TOWER_WORKSPACE ?? "default"
)

$ErrorActionPreference = "Stop"

# Script directory
$ScriptDir = $PSScriptRoot
$BaseDir = Split-Path $ScriptDir -Parent

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ " -ForegroundColor Blue -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "✗ " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

# Check prerequisites
function Test-Prerequisites {
    if (-not (Get-Command tw -ErrorAction SilentlyContinue)) {
        Write-ErrorMsg "Tower CLI (tw) not found"
        Write-ErrorMsg "Install with: pipx install tower-cli"
        exit 1
    }
    
    try {
        $null = tw info 2>&1
    } catch {
        Write-ErrorMsg "Tower CLI not authenticated"
        Write-ErrorMsg "Run: tw login"
        exit 1
    }
    
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
        Write-Warning "jq not found - JSON parsing will be limited"
        Write-Warning "Install with: brew install jq (macOS) or choco install jq (Windows)"
    }
}

# Detect Tower run ID from various sources
function Get-TowerRunId {
    param([string]$ExpDir)
    
    Write-Info "Detecting Tower run ID..."
    
    # Method 1: Check .nextflow.log for Tower run ID
    $nextflowLog = Join-Path $ExpDir ".nextflow.log"
    if (Test-Path $nextflowLog) {
        $content = Get-Content $nextflowLog -Raw
        if ($content -match "run_id=([a-zA-Z0-9_-]+)") {
            $runId = $matches[1]
            Write-Success "Found run ID in .nextflow.log: $runId"
            return $runId
        }
    }
    
    # Method 2: Check most recent Nextflow log in nextflow-logs/
    $logsDir = Join-Path $ExpDir "nextflow-logs"
    if (Test-Path $logsDir) {
        $latestLog = Get-ChildItem "$logsDir/nextflow-*.log" -ErrorAction SilentlyContinue | 
            Sort-Object LastWriteTime -Descending | 
            Select-Object -First 1
        
        if ($latestLog) {
            $content = Get-Content $latestLog.FullName -Raw
            if ($content -match "run_id=([a-zA-Z0-9_-]+)") {
                $runId = $matches[1]
                Write-Success "Found run ID in log file: $runId"
                return $runId
            }
        }
    }
    
    # Method 3: Check tower-launch.log (for Tower-launched runs)
    $towerLaunchLog = Join-Path $ExpDir "tower-launch.log"
    if (Test-Path $towerLaunchLog) {
        $content = Get-Content $towerLaunchLog -Raw
        if ($content -match "run_id=([a-zA-Z0-9_-]+)") {
            $runId = $matches[1]
            Write-Success "Found run ID in tower-launch.log: $runId"
            return $runId
        }
        
        # Alternative pattern for tw launch output
        if ($content -match "Run ID: ([a-zA-Z0-9_-]+)") {
            $runId = $matches[1]
            Write-Success "Found run ID in tower-launch.log: $runId"
            return $runId
        }
    }
    
    # Method 4: Check metadata.yaml for existing Tower run ID
    $metadataFile = Join-Path $ExpDir "metadata.yaml"
    if (Test-Path $metadataFile) {
        $content = Get-Content $metadataFile -Raw
        if ($content -match "^\s*tower_run_id:\s*[`"']?([a-zA-Z0-9_-]+)[`"']?" -and $matches[1] -ne "null") {
            $runId = $matches[1]
            Write-Success "Found run ID in metadata.yaml: $runId"
            return $runId
        }
    }
    
    Write-Warning "Could not detect Tower run ID automatically"
    return $null
}

# Fetch Tower metadata using tw CLI
function Get-TowerMetadata {
    param(
        [string]$RunId,
        [string]$Workspace,
        [string]$OutputFile
    )
    
    Write-Info "Fetching Tower metadata for run: $RunId"
    
    try {
        tw runs view $RunId --workspace=$Workspace --json > $OutputFile 2>&1
        Write-Success "Fetched Tower metadata"
        return $true
    } catch {
        Write-ErrorMsg "Failed to fetch Tower metadata for run: $RunId"
        return $false
    }
}

# Extract key information from Tower metadata
function Export-TowerSummary {
    param(
        [string]$MetadataFile,
        [string]$SummaryFile
    )
    
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
        Write-Warning "jq not available - skipping summary extraction"
        return $false
    }
    
    Write-Info "Extracting Tower summary..."
    
    $jqFilter = @'
{
    run_id: .id,
    run_name: .runName,
    workflow_id: .workflowId,
    status: .status,
    started: .start,
    completed: .complete,
    duration: .duration,
    succeeded: .stats.succeeded,
    failed: .stats.failed,
    cached: .stats.cached,
    ignored: .stats.ignored,
    total_tasks: .stats.processes,
    exit_status: .exitStatus,
    error_message: .errorMessage,
    project_name: .projectName,
    workspace: .workspace,
    compute_env: .computeEnv,
    nextflow_version: .nextflow.version,
    container_engine: .containerEngine,
    commit_id: .commitId,
    revision: .revision,
    session_id: .sessionId,
    command_line: .commandLine,
    config_files: .configFiles,
    params: .params
}
'@
    
    try {
        jq -r $jqFilter $MetadataFile > $SummaryFile 2>&1
        Write-Success "Created Tower summary"
        return $true
    } catch {
        Write-Warning "Failed to extract Tower summary"
        return $false
    }
}

# Update metadata.yaml with Tower information
function Update-MetadataYaml {
    param(
        [string]$ExpDir,
        [string]$RunId,
        [string]$Workspace,
        [string]$MetadataJsonFile
    )
    
    Write-Info "Updating metadata.yaml..."
    
    $metadataYaml = Join-Path $ExpDir "metadata.yaml"
    if (-not (Test-Path $metadataYaml)) {
        Write-Warning "metadata.yaml not found - skipping update"
        return $false
    }
    
    # Extract key fields
    $status = "unknown"
    $started = "unknown"
    $completed = "unknown"
    $duration = "unknown"
    
    if ((Get-Command jq -ErrorAction SilentlyContinue) -and (Test-Path $MetadataJsonFile)) {
        $status = jq -r '.status // "unknown"' $MetadataJsonFile
        $started = jq -r '.start // "unknown"' $MetadataJsonFile
        $completed = jq -r '.complete // "unknown"' $MetadataJsonFile
        $duration = jq -r '.duration // "unknown"' $MetadataJsonFile
    }
    
    $content = Get-Content $metadataYaml -Raw
    
    # Update YAML file (append if not exists, update if exists)
    if ($content -match "^tower:") {
        # Update existing tower section
        $content = $content -replace "^  tower_run_id:.*", "  tower_run_id: `"$RunId`""
        $content = $content -replace "^  tower_workspace:.*", "  tower_workspace: `"$Workspace`""
        $content = $content -replace "^  tower_url:.*", "  tower_url: `"https://tower.nf/orgs/workspace/watch/$RunId`""
        Set-Content -Path $metadataYaml -Value $content -NoNewline
    } else {
        # Append new tower section
        $towerSection = @"

tower:
  tower_run_id: "$RunId"
  tower_workspace: "$Workspace"
  tower_url: "https://tower.nf/orgs/workspace/watch/$RunId"
  status: "$status"
  started: "$started"
  completed: "$completed"
  duration: "$duration"
"@
        Add-Content -Path $metadataYaml -Value $towerSection
    }
    
    Write-Success "Updated metadata.yaml"
    return $true
}

# Update database with Tower information
function Update-Database {
    param(
        [string]$ExpDir,
        [string]$RunId,
        [string]$Workspace
    )
    
    Write-Info "Updating database..."
    
    # Extract experiment ID from directory name
    $expId = Split-Path $ExpDir -Leaf
    
    # Call Python script to update database
    $registerScript = Join-Path $ScriptDir "register-experiment.py"
    try {
        python3 $registerScript link-tower --id $expId --tower-run-id $RunId --workspace $Workspace 2>&1 | Out-Null
        Write-Success "Updated database"
        return $true
    } catch {
        Write-Warning "Failed to update database (experiment may not be registered)"
        return $false
    }
}

# Create Tower integration report
function New-IntegrationReport {
    param(
        [string]$ExpDir,
        [string]$RunId,
        [string]$Workspace
    )
    
    Write-Info "Creating integration report..."
    
    $reportFile = Join-Path $ExpDir "tower-integration-report.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $report = @"
# Tower Integration Report

**Generated:** $timestamp

## Tower Run Information

- **Run ID:** ``$RunId``
- **Workspace:** ``$Workspace``
- **Tower URL:** [View Run](https://tower.nf/orgs/workspace/watch/$RunId)

## Local Files

- **Full Metadata:** ``tower-metadata.json``
- **Summary:** ``tower-summary.json``
- **This Report:** ``tower-integration-report.md``

## Fetched Data

"@
    
    $summaryFile = Join-Path $ExpDir "tower-summary.json"
    if ((Test-Path $summaryFile) -and (Get-Command jq -ErrorAction SilentlyContinue)) {
        $statusInfo = jq -r '"Status:     " + .status' $summaryFile
        $startedInfo = jq -r '"Started:    " + .started' $summaryFile
        $completedInfo = jq -r '"Completed:  " + .completed' $summaryFile
        $durationInfo = jq -r '"Duration:   " + .duration' $summaryFile
        
        $succeededInfo = jq -r '"Succeeded:  " + (.succeeded|tostring)' $summaryFile
        $failedInfo = jq -r '"Failed:     " + (.failed|tostring)' $summaryFile
        $cachedInfo = jq -r '"Cached:     " + (.cached|tostring)' $summaryFile
        $totalInfo = jq -r '"Total:      " + (.total_tasks|tostring)' $summaryFile
        
        $computeInfo = jq -r '"Compute:    " + .compute_env' $summaryFile
        $nextflowInfo = jq -r '"Nextflow:   " + .nextflow_version' $summaryFile
        $containerInfo = jq -r '"Container:  " + .container_engine' $summaryFile
        
        $report += @"

### Run Status

``````
$statusInfo
$startedInfo
$completedInfo
$durationInfo
``````

### Task Statistics

``````
$succeededInfo
$failedInfo
$cachedInfo
$totalInfo
``````

### Environment

``````
$computeInfo
$nextflowInfo
$containerInfo
``````
"@
    }
    
    $report += @"


---

*Use ``tw runs view $RunId --workspace=$Workspace`` to fetch latest data*
"@
    
    Set-Content -Path $reportFile -Value $report
    Write-Success "Created integration report"
}

# Main execution
try {
    # Validate experiment directory
    if (-not (Test-Path $ExperimentDir)) {
        Write-ErrorMsg "Experiment directory not found: $ExperimentDir"
        exit 1
    }
    
    # Make path absolute
    $ExperimentDir = (Resolve-Path $ExperimentDir).Path
    
    Write-Host "🔗 Tower Integration" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Experiment: $(Split-Path $ExperimentDir -Leaf)"
    Write-Host "Workspace:  $Workspace"
    Write-Host ""
    
    # Check prerequisites
    Test-Prerequisites
    
    # Detect Tower run ID
    $runId = Get-TowerRunId -ExpDir $ExperimentDir
    
    if (-not $runId) {
        Write-ErrorMsg "Could not detect Tower run ID"
        Write-ErrorMsg "Ensure the experiment was run with -with-tower flag"
        Write-ErrorMsg "Or manually link with: just tower-link <exp_id> <tower_run_id>"
        exit 1
    }
    
    Write-Host ""
    Write-Host "Tower Run ID: $runId"
    Write-Host ""
    
    # Fetch metadata
    $metadataFile = Join-Path $ExperimentDir "tower-metadata.json"
    if (-not (Get-TowerMetadata -RunId $runId -Workspace $Workspace -OutputFile $metadataFile)) {
        exit 1
    }
    
    # Extract summary
    $summaryFile = Join-Path $ExperimentDir "tower-summary.json"
    $null = Export-TowerSummary -MetadataFile $metadataFile -SummaryFile $summaryFile
    
    # Update metadata.yaml
    $null = Update-MetadataYaml -ExpDir $ExperimentDir -RunId $runId -Workspace $Workspace -MetadataJsonFile $metadataFile
    
    # Update database
    $null = Update-Database -ExpDir $ExperimentDir -RunId $runId -Workspace $Workspace
    
    # Create report
    New-IntegrationReport -ExpDir $ExperimentDir -RunId $runId -Workspace $Workspace
    
    Write-Host ""
    Write-Success "Tower integration complete!"
    Write-Host ""
    Write-Host "📁 Files created:"
    Write-Host "   - tower-metadata.json"
    Write-Host "   - tower-summary.json"
    Write-Host "   - tower-integration-report.md"
    Write-Host ""
    Write-Host "🔗 View run at: https://tower.nf/orgs/$Workspace/watch/$runId"
    
} catch {
    Write-ErrorMsg "Error: $_"
    exit 1
}
