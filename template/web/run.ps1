#Requires -Version 7.0
<#
.SYNOPSIS
    Run the web application locally

.DESCRIPTION
    Installs required packages and starts the FastAPI development server
    
.EXAMPLE
    .\run.ps1

.NOTES
    - Installs fastapi[all] and h2o packages
    - Runs uvicorn server on 0.0.0.0:8080 with hot reload
    - Test endpoint with: curl -X POST -H "Content-Type: application/json" -d '{"feature1": 1.0, "feature2": 2.0}' http://localhost:8080/predict
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Web Application Setup..." -ForegroundColor Cyan
Write-Host ""

# LOCAL execution
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
pip install "fastapi[all]" h2o

Write-Host ""
Write-Host "🌐 Starting uvicorn server..." -ForegroundColor Green
Write-Host "   Host: 0.0.0.0"
Write-Host "   Port: 8080"
Write-Host "   Hot Reload: Enabled"
Write-Host ""

# Start uvicorn with reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080

# Note: The curl command below is for reference - won't execute while server is running
# curl -X POST -H "Content-Type: application/json" `
#   -d '{"feature1": 1.0, "feature2": 2.0}' `
#   "$(waypoint url)/predict"
