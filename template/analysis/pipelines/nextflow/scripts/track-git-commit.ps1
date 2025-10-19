#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Track git repository state for experiment reproducibility

.DESCRIPTION
    Captures current git commit, branch, and diff to yaml file

.PARAMETER ExperimentDir
    Path to experiment directory

.PARAMETER UpdateDatabase
    Whether to update database with git info

.EXAMPLE
    ./track-git-commit.ps1 -ExperimentDir "experiments/development/runs/exp_001"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ExperimentDir,
    
    [Parameter(Mandatory=$false)]
    [switch]$UpdateDatabase
)

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BASE_DIR = Split-Path -Parent $SCRIPT_DIR
$GIT_INFO_FILE = Join-Path $ExperimentDir "git-info.yaml"

# Check if in git repository
$IsGitRepo = $false
try {
    git rev-parse --git-dir 2>$null | Out-Null
    $IsGitRepo = $true
} catch {
    Write-Warning "Not in a git repository"
}

if (-not $IsGitRepo) {
    # Create placeholder file
    @"
git:
  tracked: false
  reason: "Not in a git repository"
  captured_at: "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
"@ | Set-Content $GIT_INFO_FILE
    exit 0
}

# Gather git information
$GitCommit = git rev-parse HEAD 2>$null
$GitBranch = git rev-parse --abbrev-ref HEAD 2>$null
$GitRemote = git config --get remote.origin.url 2>$null
$GitStatus = git status --porcelain 2>$null
$IsDirty = $GitStatus.Length -gt 0

# Get commit info
$CommitSubject = git log -1 --pretty=format:'%s' 2>$null
$CommitAuthor = git log -1 --pretty=format:'%an' 2>$null
$CommitDate = git log -1 --pretty=format:'%ci' 2>$null

# Generate YAML
$YamlContent = @"
git:
  tracked: true
  commit: "$GitCommit"
  branch: "$GitBranch"
  remote: "$GitRemote"
  is_dirty: $($IsDirty.ToString().ToLower())
  commit_subject: "$CommitSubject"
  commit_author: "$CommitAuthor"
  commit_date: "$CommitDate"
  captured_at: "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
"@

if ($IsDirty) {
    $YamlContent += @"

  modified_files:
"@
    $GitStatus | ForEach-Object {
        $YamlContent += "`n    - `"$_`""
    }
}

# Save to file
$YamlContent | Set-Content $GIT_INFO_FILE

Write-Host "✅ Git info saved to: $GIT_INFO_FILE" -ForegroundColor Green

# Update database if requested
if ($UpdateDatabase) {
    $ExpId = Split-Path -Leaf $ExperimentDir
    $RegisterScript = Join-Path $SCRIPT_DIR "register-experiment.py"
    
    & python3 $RegisterScript update-git-info `
        --id $ExpId `
        --commit $GitCommit `
        --branch $GitBranch `
        --is-dirty:$IsDirty
    
    Write-Host "✅ Database updated with git info" -ForegroundColor Green
}
