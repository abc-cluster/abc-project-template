# Nextflow Pipeline Lifecycle Management
# Comprehensive experiment tracking across development and production

# Use bash for all commands (fish-compatible via Just)
set shell := ["bash", "-euo", "pipefail", "-c"]

# Global variables
NF_FILE := "hello-pipeline.nf"
BASE_DIR := justfile_directory()
EXPTS_DIR := BASE_DIR + "/experiments"
SCRIPTS_DIR := BASE_DIR + "/scripts"
CONFIGS_DIR := BASE_DIR + "/experiments/configs"
REGISTRY_DB := BASE_DIR + "/.registry/experiments.db"
DEFAULT_WORKSPACE := env_var_or_default("TOWER_WORKSPACE", "default")

# Default recipe - show available commands
default:
    @echo "🧬 Nextflow Pipeline Lifecycle Management"
    @echo "=========================================="
    @echo ""
    @just --list

# ═══════════════════════════════════════════════════════════
# SETUP & INITIALIZATION
# ═══════════════════════════════════════════════════════════

# Initialize the lifecycle management system
setup:
    #!/usr/bin/env bash
    echo "🔨 Setting up Nextflow Pipeline Lifecycle Management..."
    
    # Create directory structure
    mkdir -p "{{EXPTS_DIR}}"/{development,production,planning}/{runs,active,archive}
    mkdir -p "{{EXPTS_DIR}}/results/comparative"
    mkdir -p "{{BASE_DIR}}"/{chains,comparisons,storage/manifests,docs}
    
    # Initialize database
    python3 "{{SCRIPTS_DIR}}/register-experiment.py" init-db
    
    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Configure Tower CLI: tw login"
    echo "  2. Create your first experiment: just dev-new \"my-experiment\" \"Purpose\""

# Clean up work directories older than specified days
clean-work days="30":
    #!/usr/bin/env bash
    echo "🧹 Cleaning work directories older than {{days}} days..."
    find "{{BASE_DIR}}/work" -type d -mtime +{{days}} -exec rm -rf {} + 2>/dev/null || true
    echo "✅ Cleanup complete"

# ═══════════════════════════════════════════════════════════
# EXPERIMENT CREATION
# ═══════════════════════════════════════════════════════════

# Create new development experiment
dev-new name purpose="" params="default-params":
    @bash "{{SCRIPTS_DIR}}/init-experiment.sh" \
        --type development \
        --name "{{name}}" \
        --purpose "{{purpose}}" \
        --scenario local-local \
        --params-template "{{params}}"

# Create new production experiment
prod-new name dataset="" purpose="" params="full-dataset":
    @bash "{{SCRIPTS_DIR}}/init-experiment.sh" \
        --type production \
        --name "{{name}}" \
        --purpose "{{purpose}}" \
        --dataset "{{dataset}}" \
        --scenario local-local \
        --params-template "{{params}}"

# Create planning-only experiment (no execution)
plan-new name purpose="":
    @bash "{{SCRIPTS_DIR}}/init-experiment.sh" \
        --type planning \
        --name "{{name}}" \
        --purpose "{{purpose}}" \
        --scenario planning-only

# Create experiment for AWS execution
dev-new-aws name purpose="" params="default-params":
    @bash "{{SCRIPTS_DIR}}/init-experiment.sh" \
        --type development \
        --name "{{name}}" \
        --purpose "{{purpose}}" \
        --scenario local-remote \
        --params-template "{{params}}"

# ═══════════════════════════════════════════════════════════
# EXPERIMENT EXECUTION
# ═══════════════════════════════════════════════════════════

# Run experiment locally (local head + local tasks)
run-local experiment_id:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    echo "🚀 Running experiment locally: {{experiment_id}}"
    echo "📁 Directory: $EXP_DIR"
    
    cd "$EXP_DIR"
    
    # Update status to running
    python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
        --id "{{experiment_id}}" \
        --status running
    
    # Run Nextflow with Tower monitoring
    nextflow run "{{BASE_DIR}}/{{NF_FILE}}" \
        -profile local-local \
        -params-file params.yaml \
        -with-tower \
        -work-dir "./work" \
        -with-report "reports/report.html" \
        -with-timeline "reports/timeline.html" \
        -with-trace "reports/trace.txt" \
        2>&1 | tee "nextflow-logs/nextflow-$(date +%Y%m%d_%H%M%S).log"
    
    EXIT_CODE=${PIPESTATUS[0]}
    
    # Update status based on exit code
    if [[ $EXIT_CODE -eq 0 ]]; then
        python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
            --id "{{experiment_id}}" \
            --status completed
        echo "✅ Experiment completed successfully"
    else
        python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
            --id "{{experiment_id}}" \
            --status failed
        echo "❌ Experiment failed with exit code: $EXIT_CODE"
    fi
    
    # Fetch Tower metadata if available
    if command -v tw &> /dev/null; then
        echo "📡 Fetching Tower metadata..."
        bash "{{SCRIPTS_DIR}}/tower-integration.sh" "$EXP_DIR" || true
    fi

# Run experiment with AWS Batch (local head + remote tasks)
run-aws experiment_id:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    echo "🚀 Running experiment on AWS Batch: {{experiment_id}}"
    
    cd "$EXP_DIR"
    
    python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
        --id "{{experiment_id}}" \
        --status running
    
    nextflow run "{{BASE_DIR}}/{{NF_FILE}}" \
        -profile local-aws \
        -params-file params.yaml \
        -with-tower \
        -work-dir "s3://your-bucket/work/{{experiment_id}}" \
        -bucket-dir "s3://your-bucket/scratch" \
        -with-report "reports/report.html" \
        -with-timeline "reports/timeline.html" \
        -with-trace "reports/trace.txt" \
        2>&1 | tee "nextflow-logs/nextflow-$(date +%Y%m%d_%H%M%S).log"
    
    EXIT_CODE=${PIPESTATUS[0]}
    
    if [[ $EXIT_CODE -eq 0 ]]; then
        python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
            --id "{{experiment_id}}" \
            --status completed
    else
        python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
            --id "{{experiment_id}}" \
            --status failed
    fi

# Launch experiment via Tower
run-tower experiment_id workspace=DEFAULT_WORKSPACE:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    echo "🚀 Launching experiment via Tower: {{experiment_id}}"
    echo "🗂️  Workspace: {{workspace}}"
    
    cd "$EXP_DIR"
    
    python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
        --id "{{experiment_id}}" \
        --status running
    
    # Launch via Tower CLI
    tw launch "{{BASE_DIR}}/{{NF_FILE}}" \
        --workspace="{{workspace}}" \
        --params-file="params.yaml" \
        --name="{{experiment_id}}" \
        --config="{{CONFIGS_DIR}}/profiles/tower.config" \
        --work-dir="s3://your-bucket/work/{{experiment_id}}" \
        --outdir="s3://your-bucket/results/{{experiment_id}}" \
        | tee tower-launch.log
    
    echo ""
    echo "📊 Monitor at: https://tower.nf"
    echo "📥 Fetch metadata later with: just fetch-tower {{experiment_id}}"

# Resume failed experiment with -resume flag
resume experiment_id:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    echo "🔄 Resuming experiment: {{experiment_id}}"
    
    cd "$EXP_DIR"
    
    nextflow run "{{BASE_DIR}}/{{NF_FILE}}" \
        -profile local-local \
        -params-file params.yaml \
        -with-tower \
        -resume \
        -work-dir "./work" \
        -with-report "reports/report-resume-$(date +%Y%m%d_%H%M%S).html" \
        -with-timeline "reports/timeline-resume-$(date +%Y%m%d_%H%M%S).html" \
        -with-trace "reports/trace-resume-$(date +%Y%m%d_%H%M%S).txt"

# ═══════════════════════════════════════════════════════════
# EXPERIMENT QUERIES
# ═══════════════════════════════════════════════════════════

# List all experiments
list-all:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" list

# List active (non-archived) experiments
list-active:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" list --status planned,running,completed,failed

# List failed experiments
list-failed:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" list --status failed

# List experiments by type
list-dev:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" list --type development

# List experiments by type
list-prod:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" list --type production

# Search experiments by tag
search-tag tag:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" search-tag --tag "{{tag}}"

# View detailed experiment information
view experiment_id:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" view --id "{{experiment_id}}"

# ═══════════════════════════════════════════════════════════
# MONITORING & STATUS
# ═══════════════════════════════════════════════════════════

# Check experiment status
status experiment_id:
    #!/usr/bin/env bash
    echo "📊 Experiment Status"
    echo "===================="
    python3 "{{SCRIPTS_DIR}}/register-experiment.py" view --id "{{experiment_id}}" | head -20

# Show experiment summary
summary experiment_id:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    echo "📊 Experiment Summary: {{experiment_id}}"
    echo "=========================================="
    echo ""
    
    if [[ -f "$EXP_DIR/README.md" ]]; then
        cat "$EXP_DIR/README.md"
    else
        echo "No README.md found"
    fi

# ═══════════════════════════════════════════════════════════
# TOWER INTEGRATION
# ═══════════════════════════════════════════════════════════

# Fetch Tower metadata for completed experiment
fetch-tower experiment_id workspace=DEFAULT_WORKSPACE:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    echo "📡 Fetching Tower metadata for: {{experiment_id}}"
    
    if command -v tw &> /dev/null; then
        bash "{{SCRIPTS_DIR}}/tower-integration.sh" "$EXP_DIR" "{{workspace}}"
    else
        echo "❌ Tower CLI (tw) not found. Install with: pipx install tower-cli"
        exit 1
    fi

# Monitor Tower run in real-time
monitor-tower tower_run_id workspace=DEFAULT_WORKSPACE:
    @echo "👀 Monitoring Tower run: {{tower_run_id}}"
    @tw runs view "{{tower_run_id}}" --workspace="{{workspace}}" --follow

# Check Tower run status
tower-status tower_run_id workspace=DEFAULT_WORKSPACE:
    @tw runs view "{{tower_run_id}}" --workspace="{{workspace}}"

# List Tower runs in workspace
tower-list workspace=DEFAULT_WORKSPACE:
    @echo "📋 Tower runs in workspace: {{workspace}}"
    @tw runs list --workspace="{{workspace}}"

# Link Tower run to experiment (retrospective)
tower-link experiment_id tower_run_id workspace=DEFAULT_WORKSPACE:
    @python3 "{{SCRIPTS_DIR}}/register-experiment.py" link-tower \
        --id "{{experiment_id}}" \
        --tower-run-id "{{tower_run_id}}" \
        --workspace "{{workspace}}"

# ═══════════════════════════════════════════════════════════
# RESULTS MANAGEMENT
# ═══════════════════════════════════════════════════════════

# Show results manifest for experiment
show-results experiment_id:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    if [[ -f "$EXP_DIR/results-manifest.yaml" ]]; then
        cat "$EXP_DIR/results-manifest.yaml"
    else
        echo "No results manifest found"
    fi

# Open experiment directory
open experiment_id:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    open "$EXP_DIR"

# ═══════════════════════════════════════════════════════════
# UTILITIES
# ═══════════════════════════════════════════════════════════

# Archive completed experiment
archive experiment_id:
    #!/usr/bin/env bash
    EXP_DIR=$(find "{{EXPTS_DIR}}/*/runs" -name "{{experiment_id}}" -type d | head -1)
    
    if [[ -z "$EXP_DIR" ]]; then
        echo "❌ Experiment not found: {{experiment_id}}"
        exit 1
    fi
    
    EXP_TYPE=$(basename "$(dirname "$(dirname "$EXP_DIR")")")
    ARCHIVE_DIR="{{EXPTS_DIR}}/${EXP_TYPE}/archive"
    
    echo "📦 Archiving experiment: {{experiment_id}}"
    mkdir -p "$ARCHIVE_DIR"
    mv "$EXP_DIR" "$ARCHIVE_DIR/"
    
    python3 "{{SCRIPTS_DIR}}/register-experiment.py" update-status \
        --id "{{experiment_id}}" \
        --status archived
    
    echo "✅ Archived to: ${ARCHIVE_DIR}/{{experiment_id}}"

# Run database query
query sql:
    @sqlite3 "{{REGISTRY_DB}}" "{{sql}}"

# Show experiment statistics
stats:
    #!/usr/bin/env bash
    echo "📊 Experiment Statistics"
    echo "========================"
    echo ""
    
    TOTAL=$(sqlite3 "{{REGISTRY_DB}}" "SELECT COUNT(*) FROM experiments")
    DEV=$(sqlite3 "{{REGISTRY_DB}}" "SELECT COUNT(*) FROM experiments WHERE type='development'")
    PROD=$(sqlite3 "{{REGISTRY_DB}}" "SELECT COUNT(*) FROM experiments WHERE type='production'")
    FAILED=$(sqlite3 "{{REGISTRY_DB}}" "SELECT COUNT(*) FROM experiments WHERE status='failed'")
    COMPLETED=$(sqlite3 "{{REGISTRY_DB}}" "SELECT COUNT(*) FROM experiments WHERE status='completed'")
    RUNNING=$(sqlite3 "{{REGISTRY_DB}}" "SELECT COUNT(*) FROM experiments WHERE status='running'")
    
    echo "Total experiments:     $TOTAL"
    echo "Development:           $DEV"
    echo "Production:            $PROD"
    echo "Running:               $RUNNING"
    echo "Completed:             $COMPLETED"
    echo "Failed:                $FAILED"
    echo ""
    
    echo "Recent experiments (last 5):"
    sqlite3 "{{REGISTRY_DB}}" "SELECT id, status, created_at FROM experiments ORDER BY created_at DESC LIMIT 5" | \
        while IFS='|' read -r id status created; do
            echo "  $id | $status | $created"
        done

# Show help for specific command
help-command command:
    @just --show "{{command}}"

# Show version information
version:
    @echo "Nextflow Pipeline Lifecycle Management"
    @echo "Version: 2.0.0 (Phase 2)"
    @echo ""
    @echo "Dependencies:"
    @nextflow -version 2>/dev/null || echo "  nextflow: not installed"
    @tw --version 2>/dev/null || echo "  tw (tower-cli): not installed"
    @python3 --version 2>/dev/null || echo "  python3: not installed"
    @sqlite3 --version 2>/dev/null || echo "  sqlite3: not installed"

# ═══════════════════════════════════════════════════════════
# PHASE 2: ADVANCED FEATURES
# ═══════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════
# COMPARISON & ANALYSIS
# ═══════════════════════════════════════════════════════════

# Compare multiple experiments
compare output_name="" *exp_ids:
    @python3 "{{SCRIPTS_DIR}}/compare-experiments.py" compare {{exp_ids}} {{if output_name != "" { "--output " + output_name } else { "" } }}

# List saved comparisons
list-comparisons:
    @python3 "{{SCRIPTS_DIR}}/compare-experiments.py" list

# View comparison report
view-comparison name:
    @python3 "{{SCRIPTS_DIR}}/compare-experiments.py" view "{{name}}"

# ═══════════════════════════════════════════════════════════
# CHAIN TRACKING
# ═══════════════════════════════════════════════════════════

# Create/update resume chain
chain-create original resumed run_number="2":
    @python3 "{{SCRIPTS_DIR}}/track-chains.py" create "{{original}}" "{{resumed}}" --run-number {{run_number}}

# Show experiment's chain
chain-show experiment_id:
    @python3 "{{SCRIPTS_DIR}}/track-chains.py" show "{{experiment_id}}"

# List all chains
chain-list:
    @python3 "{{SCRIPTS_DIR}}/track-chains.py" list

# Visualize chain diagram
chain-visualize chain_id:
    @python3 "{{SCRIPTS_DIR}}/track-chains.py" visualize "{{chain_id}}"

# Generate chain report
chain-report chain_id:
    @python3 "{{SCRIPTS_DIR}}/track-chains.py" report "{{chain_id}}"

# Analyze chain
chain-analyze chain_id:
    @python3 "{{SCRIPTS_DIR}}/track-chains.py" analyze "{{chain_id}}"

# ═══════════════════════════════════════════════════════════
# DASHBOARD & REPORTING
# ═══════════════════════════════════════════════════════════

# Generate experiment dashboard
dashboard format="markdown":
    @python3 "{{SCRIPTS_DIR}}/generate-dashboard.py" --format "{{format}}"

# View latest dashboard
view-dashboard:
    @cat "{{BASE_DIR}}/docs/dashboard_latest.md"

# ═══════════════════════════════════════════════════════════
# BATCH OPERATIONS
# ═══════════════════════════════════════════════════════════

# Bulk status update
batch-update-status status *exp_ids:
    @python3 "{{SCRIPTS_DIR}}/batch-operations.py" update-status "{{status}}" {{exp_ids}}

# Bulk add tags
batch-add-tags tags *exp_ids:
    @python3 "{{SCRIPTS_DIR}}/batch-operations.py" add-tags --tags {{tags}} {{exp_ids}}

# Bulk archive
batch-archive *exp_ids:
    @python3 "{{SCRIPTS_DIR}}/batch-operations.py" archive {{exp_ids}}

# Find experiments by criteria
batch-find status="" exp_type="" tag="":
    @python3 "{{SCRIPTS_DIR}}/batch-operations.py" find {{if status != "" { "--status " + status } else { "" } }} {{if exp_type != "" { "--type " + exp_type } else { "" } }} {{if tag != "" { "--tag " + tag } else { "" } }}
