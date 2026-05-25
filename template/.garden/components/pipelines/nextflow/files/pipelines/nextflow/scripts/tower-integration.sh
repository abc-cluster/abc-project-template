#!/usr/bin/env bash
# Tower Integration Script
# Fetches Tower metadata and links it to local investigations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Default workspace
DEFAULT_WORKSPACE="${TOWER_WORKSPACE:-default}"

# Usage information
usage() {
    cat << EOF
Usage: $0 <investigation_dir> [workspace]

Fetch Tower metadata for a Nextflow investigation and link it locally.

Arguments:
    investigation_dir    Path to investigation directory
    workspace         Tower workspace (default: $DEFAULT_WORKSPACE)

Environment Variables:
    TOWER_WORKSPACE   Default Tower workspace
    TOWER_ACCESS_TOKEN Tower API token (required for tw CLI)

Examples:
    $0 investigations/development/runs/exp_20250117_1000
    $0 investigations/production/runs/exp_20250117_1500 my-workspace

Requirements:
    - Tower CLI (tw) must be installed: pipx install tower-cli
    - Tower access token must be configured: tw login

EOF
    exit 1
}

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

# Check prerequisites
check_prerequisites() {
    if ! command -v tw &> /dev/null; then
        log_error "Tower CLI (tw) not found"
        log_error "Install with: pipx install tower-cli"
        exit 1
    fi
    
    if ! tw info &> /dev/null; then
        log_error "Tower CLI not authenticated"
        log_error "Run: tw login"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_warning "jq not found - JSON parsing will be limited"
        log_warning "Install with: brew install jq"
    fi
}

# Detect Tower run ID from various sources
detect_tower_run_id() {
    local exp_dir="$1"
    local tower_run_id=""
    
    log_info "Detecting Tower run ID..."
    
    # Method 1: Check .nextflow.log for Tower run ID
    if [[ -f "$exp_dir/.nextflow.log" ]]; then
        tower_run_id=$(grep -oE "run_id=[a-zA-Z0-9_-]+" "$exp_dir/.nextflow.log" 2>/dev/null | head -1 | cut -d= -f2)
        if [[ -n "$tower_run_id" ]]; then
            log_success "Found run ID in .nextflow.log: $tower_run_id"
            echo "$tower_run_id"
            return 0
        fi
    fi
    
    # Method 2: Check most recent Nextflow log in nextflow-logs/
    if [[ -d "$exp_dir/nextflow-logs" ]]; then
        local latest_log=$(ls -t "$exp_dir/nextflow-logs"/nextflow-*.log 2>/dev/null | head -1)
        if [[ -n "$latest_log" && -f "$latest_log" ]]; then
            tower_run_id=$(grep -oE "run_id=[a-zA-Z0-9_-]+" "$latest_log" 2>/dev/null | head -1 | cut -d= -f2)
            if [[ -n "$tower_run_id" ]]; then
                log_success "Found run ID in log file: $tower_run_id"
                echo "$tower_run_id"
                return 0
            fi
        fi
    fi
    
    # Method 3: Check tower-launch.log (for Tower-launched runs)
    if [[ -f "$exp_dir/tower-launch.log" ]]; then
        tower_run_id=$(grep -oE "run_id=[a-zA-Z0-9_-]+" "$exp_dir/tower-launch.log" 2>/dev/null | head -1 | cut -d= -f2)
        if [[ -n "$tower_run_id" ]]; then
            log_success "Found run ID in tower-launch.log: $tower_run_id"
            echo "$tower_run_id"
            return 0
        fi
        
        # Alternative pattern for tw launch output
        tower_run_id=$(grep -oE "Run ID: [a-zA-Z0-9_-]+" "$exp_dir/tower-launch.log" 2>/dev/null | head -1 | awk '{print $3}')
        if [[ -n "$tower_run_id" ]]; then
            log_success "Found run ID in tower-launch.log: $tower_run_id"
            echo "$tower_run_id"
            return 0
        fi
    fi
    
    # Method 4: Check metadata.yaml for existing Tower run ID
    if [[ -f "$exp_dir/metadata.yaml" ]]; then
        tower_run_id=$(grep "^  tower_run_id:" "$exp_dir/metadata.yaml" 2>/dev/null | awk '{print $2}' | tr -d '"')
        if [[ -n "$tower_run_id" && "$tower_run_id" != "null" ]]; then
            log_success "Found run ID in metadata.yaml: $tower_run_id"
            echo "$tower_run_id"
            return 0
        fi
    fi
    
    log_warning "Could not detect Tower run ID automatically"
    return 1
}

# Fetch Tower metadata using tw CLI
fetch_tower_metadata() {
    local run_id="$1"
    local workspace="$2"
    local output_file="$3"
    
    log_info "Fetching Tower metadata for run: $run_id"
    
    # Fetch run details
    if tw runs view "$run_id" --workspace="$workspace" --json > "$output_file" 2>/dev/null; then
        log_success "Fetched Tower metadata"
        return 0
    else
        log_error "Failed to fetch Tower metadata for run: $run_id"
        return 1
    fi
}

# Extract key information from Tower metadata
extract_tower_summary() {
    local metadata_file="$1"
    local summary_file="$2"
    
    if ! command -v jq &> /dev/null; then
        log_warning "jq not available - skipping summary extraction"
        return 1
    fi
    
    log_info "Extracting Tower summary..."
    
    jq -r '
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
    ' "$metadata_file" > "$summary_file" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        log_success "Created Tower summary"
        return 0
    else
        log_warning "Failed to extract Tower summary"
        return 1
    fi
}

# Update metadata.yaml with Tower information
update_metadata_yaml() {
    local exp_dir="$1"
    local run_id="$2"
    local workspace="$3"
    local metadata_file="$exp_dir/tower-metadata.json"
    
    log_info "Updating metadata.yaml..."
    
    if [[ ! -f "$exp_dir/metadata.yaml" ]]; then
        log_warning "metadata.yaml not found - skipping update"
        return 1
    fi
    
    # Extract key fields
    local status=""
    local started=""
    local completed=""
    local duration=""
    
    if command -v jq &> /dev/null && [[ -f "$metadata_file" ]]; then
        status=$(jq -r '.status // "unknown"' "$metadata_file")
        started=$(jq -r '.start // "unknown"' "$metadata_file")
        completed=$(jq -r '.complete // "unknown"' "$metadata_file")
        duration=$(jq -r '.duration // "unknown"' "$metadata_file")
    fi
    
    # Update YAML file (append if not exists, update if exists)
    if grep -q "^tower:" "$exp_dir/metadata.yaml"; then
        # Update existing tower section
        sed -i.bak "s|^  tower_run_id:.*|  tower_run_id: \"$run_id\"|" "$exp_dir/metadata.yaml"
        sed -i.bak "s|^  tower_workspace:.*|  tower_workspace: \"$workspace\"|" "$exp_dir/metadata.yaml"
        sed -i.bak "s|^  tower_url:.*|  tower_url: \"https://tower.nf/orgs/workspace/watch/$run_id\"|" "$exp_dir/metadata.yaml"
        rm -f "$exp_dir/metadata.yaml.bak"
    else
        # Append new tower section
        cat >> "$exp_dir/metadata.yaml" << EOF

tower:
  tower_run_id: "$run_id"
  tower_workspace: "$workspace"
  tower_url: "https://tower.nf/orgs/workspace/watch/$run_id"
  status: "$status"
  started: "$started"
  completed: "$completed"
  duration: "$duration"
EOF
    fi
    
    log_success "Updated metadata.yaml"
}

# Update database with Tower information
update_database() {
    local exp_dir="$1"
    local run_id="$2"
    local workspace="$3"
    
    log_info "Updating database..."
    
    # Extract investigation ID from directory name
    local exp_id=$(basename "$exp_dir")
    
    # Call Python script to update database
    if python3 "$SCRIPT_DIR/register-investigation.py" link-tower \
        --id "$exp_id" \
        --tower-run-id "$run_id" \
        --workspace "$workspace" 2>/dev/null; then
        log_success "Updated database"
        return 0
    else
        log_warning "Failed to update database (investigation may not be registered)"
        return 1
    fi
}

# Create Tower integration report
create_integration_report() {
    local exp_dir="$1"
    local run_id="$2"
    local workspace="$3"
    local report_file="$exp_dir/tower-integration-report.md"
    
    log_info "Creating integration report..."
    
    cat > "$report_file" << EOF
# Tower Integration Report

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

## Tower Run Information

- **Run ID:** \`$run_id\`
- **Workspace:** \`$workspace\`
- **Tower URL:** [View Run](https://tower.nf/orgs/workspace/watch/$run_id)

## Local Files

- **Full Metadata:** \`tower-metadata.json\`
- **Summary:** \`tower-summary.json\`
- **This Report:** \`tower-integration-report.md\`

## Fetched Data

EOF
    
    if [[ -f "$exp_dir/tower-summary.json" ]] && command -v jq &> /dev/null; then
        cat >> "$report_file" << EOF
### Run Status

\`\`\`
$(jq -r '"Status:     " + .status' "$exp_dir/tower-summary.json")
$(jq -r '"Started:    " + .started' "$exp_dir/tower-summary.json")
$(jq -r '"Completed:  " + .completed' "$exp_dir/tower-summary.json")
$(jq -r '"Duration:   " + .duration' "$exp_dir/tower-summary.json")
\`\`\`

### Task Statistics

\`\`\`
$(jq -r '"Succeeded:  " + (.succeeded|tostring)' "$exp_dir/tower-summary.json")
$(jq -r '"Failed:     " + (.failed|tostring)' "$exp_dir/tower-summary.json")
$(jq -r '"Cached:     " + (.cached|tostring)' "$exp_dir/tower-summary.json")
$(jq -r '"Total:      " + (.total_tasks|tostring)' "$exp_dir/tower-summary.json")
\`\`\`

### Environment

\`\`\`
$(jq -r '"Compute:    " + .compute_env' "$exp_dir/tower-summary.json")
$(jq -r '"Nextflow:   " + .nextflow_version' "$exp_dir/tower-summary.json")
$(jq -r '"Container:  " + .container_engine' "$exp_dir/tower-summary.json")
\`\`\`
EOF
    fi
    
    cat >> "$report_file" << EOF

---

*Use \`tw runs view $run_id --workspace=$workspace\` to fetch latest data*
EOF
    
    log_success "Created integration report"
}

# Main function
main() {
    local exp_dir="${1:-}"
    local workspace="${2:-$DEFAULT_WORKSPACE}"
    
    # Validate arguments
    if [[ -z "$exp_dir" ]]; then
        usage
    fi
    
    if [[ ! -d "$exp_dir" ]]; then
        log_error "Investigation directory not found: $exp_dir"
        exit 1
    fi
    
    # Make path absolute
    exp_dir=$(cd "$exp_dir" && pwd)
    
    echo "🔗 Tower Integration"
    echo "===================="
    echo ""
    echo "Investigation: $(basename "$exp_dir")"
    echo "Workspace:  $workspace"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Detect Tower run ID
    local run_id=$(detect_tower_run_id "$exp_dir")
    
    if [[ -z "$run_id" ]]; then
        log_error "Could not detect Tower run ID"
        log_error "Ensure the investigation was run with -with-tower flag"
        log_error "Or manually link with: just tower-link <exp_id> <tower_run_id>"
        exit 1
    fi
    
    echo ""
    echo "Tower Run ID: $run_id"
    echo ""
    
    # Fetch metadata
    local metadata_file="$exp_dir/tower-metadata.json"
    if ! fetch_tower_metadata "$run_id" "$workspace" "$metadata_file"; then
        exit 1
    fi
    
    # Extract summary
    local summary_file="$exp_dir/tower-summary.json"
    extract_tower_summary "$metadata_file" "$summary_file" || true
    
    # Update metadata.yaml
    update_metadata_yaml "$exp_dir" "$run_id" "$workspace" || true
    
    # Update database
    update_database "$exp_dir" "$run_id" "$workspace" || true
    
    # Create report
    create_integration_report "$exp_dir" "$run_id" "$workspace"
    
    echo ""
    log_success "Tower integration complete!"
    echo ""
    echo "📁 Files created:"
    echo "   - tower-metadata.json"
    echo "   - tower-summary.json"
    echo "   - tower-integration-report.md"
    echo ""
    echo "🔗 View run at: https://tower.nf/orgs/$workspace/watch/$run_id"
}

# Run main function
main "$@"
