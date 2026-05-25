# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Nextflow Experiments Management with Resume Support
# Enhanced experiment tracking for failed and resumed pipeline runs

# Variables
experiments_dir := justfile_directory()
templates_dir := experiments_dir + "/runs/templates"
runs_dir := experiments_dir + "/runs"
logs_dir := experiments_dir + "/logs"
reports_dir := experiments_dir + "/reports"
samplesheets_dir := experiments_dir + "/samplesheets/experiments"
configs_dir := experiments_dir + "/configs"
timestamp := `date +%Y%m%d_%H%M%S`
date := `date +%Y-%m-%d`
researcher := "researcher-name"

# Default recipe
default:
    @echo "🧪 Nextflow Experiments Management:"
    @just --list

# === Experiment Creation ===

# Create new experiment
nf-new-experiment name purpose="exploratory":
    #!/usr/bin/env bash
    exp_id="{{date}}_{{purpose}}_{{name}}_v1"
    exp_dir="{{runs_dir}}/$exp_id"
    
    echo "🧪 Creating new experiment: $exp_id"
    
    # Create experiment directory
    mkdir -p "$exp_dir"
    
    # Create experiment plan from template
    cp "{{templates_dir}}/experiment-plan.md" "$exp_dir/experiment-plan.md"
    sed -i.bak "s/{{experiment_id}}/$exp_id/g" "$exp_dir/experiment-plan.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$exp_dir/experiment-plan.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$exp_dir/experiment-plan.md"
    sed -i.bak "s/{{project}}/{{name}}/g" "$exp_dir/experiment-plan.md"
    rm "$exp_dir/experiment-plan.md.bak"
    
    # Create execution log template
    cp "{{templates_dir}}/execution-log.md" "$exp_dir/execution-log.md"
    sed -i.bak "s/{{experiment_id}}/$exp_id/g" "$exp_dir/execution-log.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$exp_dir/execution-log.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$exp_dir/execution-log.md"
    rm "$exp_dir/execution-log.md.bak"
    
    # Create default parameter file
    cat > "$exp_dir/params.yaml" << EOF
    # Experiment Parameters for $exp_id
    # Generated on {{date}}
    
    # Basic configuration
    input: "../data/01_raw/*.csv"
    output_dir: "../data/02_processed"
    
    # Pipeline specific parameters
    resume: false
    
    # Resources
    max_cpus: 4
    max_memory: "8.GB"
    max_time: "24.h"
    
    # Add your specific parameters here
    EOF
    
    # Create samplesheet template
    cat > "$exp_dir/samplesheet.csv" << EOF
    sample_id,fastq_1,fastq_2,condition
    sample1,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz,control
    sample2,/path/to/sample2_R1.fastq.gz,/path/to/sample2_R2.fastq.gz,treatment
    EOF
    
    echo "✅ Experiment created: $exp_dir"
    echo "📝 Edit experiment-plan.md to define objectives"
    echo "⚙️  Edit params.yaml to configure parameters"
    echo "📊 Edit samplesheet.csv to define samples"

# Create resumed experiment from failed one
nf-resume-experiment failed_experiment_id new_purpose="resume":
    #!/usr/bin/env bash
    failed_exp_dir="{{runs_dir}}/{{failed_experiment_id}}"
    
    if [ ! -d "$failed_exp_dir" ]; then
        echo "❌ Failed experiment directory not found: $failed_exp_dir"
        exit 1
    fi
    
    # Extract base name without version
    base_name=$(echo "{{failed_experiment_id}}" | sed 's/_v[0-9]*$//')
    resume_exp_id="${base_name}_{{new_purpose}}_v1"
    resume_exp_dir="{{runs_dir}}/$resume_exp_id"
    
    echo "🔄 Creating resumed experiment: $resume_exp_id"
    echo "📂 From failed experiment: {{failed_experiment_id}}"
    
    # Create resume experiment directory
    mkdir -p "$resume_exp_dir"
    
    # Copy and modify files from failed experiment
    cp "$failed_exp_dir/params.yaml" "$resume_exp_dir/params.yaml"
    cp "$failed_exp_dir/samplesheet.csv" "$resume_exp_dir/samplesheet.csv"
    
    # Enable resume in params
    sed -i.bak 's/resume: false/resume: true/g' "$resume_exp_dir/params.yaml"
    rm "$resume_exp_dir/params.yaml.bak"
    
    # Create experiment plan for resumed experiment
    cp "{{templates_dir}}/experiment-plan.md" "$resume_exp_dir/experiment-plan.md"
    sed -i.bak "s/{{experiment_id}}/$resume_exp_id/g" "$resume_exp_dir/experiment-plan.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$resume_exp_dir/experiment-plan.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$resume_exp_dir/experiment-plan.md"
    sed -i.bak "s/{{previous_experiment_id}}/{{failed_experiment_id}}/g" "$resume_exp_dir/experiment-plan.md"
    
    # Mark as resumed experiment
    sed -i.bak 's/- \[ \] New experiment/- [x] New experiment/g' "$resume_exp_dir/experiment-plan.md"
    sed -i.bak 's/- \[ \] Resumed experiment/- [x] Resumed experiment/g' "$resume_exp_dir/experiment-plan.md"
    
    rm "$resume_exp_dir/experiment-plan.md.bak"
    
    # Create execution log template
    cp "{{templates_dir}}/execution-log.md" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{experiment_id}}/$resume_exp_id/g" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{resumed_from}}/{{failed_experiment_id}}/g" "$resume_exp_dir/execution-log.md"
    rm "$resume_exp_dir/execution-log.md.bak"
    
    echo "✅ Resumed experiment created: $resume_exp_dir"
    echo "📝 Review and update experiment-plan.md"
    echo "⚙️  Review and update params.yaml"
    echo "🔄 Resume flag enabled in parameters"

# === Experiment Execution ===

# Run experiment via Tower
nf-run-experiment experiment_id tower_workspace="default":
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{experiment_id}}"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Experiment directory not found: $exp_dir"
        exit 1
    fi
    
    echo "🚀 Running experiment: {{experiment_id}}"
    echo "🗂️  Workspace: {{tower_workspace}}"
    
    # Create log directory for this experiment
    log_dir="{{logs_dir}}/{{experiment_id}}"
    mkdir -p "$log_dir"
    
    # Run via Tower (adjust command based on your Tower setup)
    tower_run_id=$(tw launch data-pipeline.nf \
        --workspace={{tower_workspace}} \
        --params-file="$exp_dir/params.yaml" \
        --name="{{experiment_id}}" \
        --tag="experiment:{{experiment_id}}" \
        --tag="date:{{date}}" \
        --work-dir="s3://your-bucket/work/{{experiment_id}}" \
        --outdir="s3://your-bucket/results/{{experiment_id}}" \
        2>&1 | tee "$log_dir/tower-launch.log" | grep -o "Run ID: [0-9]*" | cut -d' ' -f3)
    
    echo "🆔 Tower Run ID: $tower_run_id"
    echo "$tower_run_id" > "$exp_dir/tower-run-id.txt"
    
    echo "📊 Monitor progress at: https://tower.nf/user/runs/$tower_run_id"
    echo "📝 Logs saved to: $log_dir"

# Resume experiment via Tower
nf-resume-run experiment_id tower_workspace="default":
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{experiment_id}}"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Experiment directory not found: $exp_dir"
        exit 1
    fi
    
    echo "🔄 Resuming experiment: {{experiment_id}}"
    echo "🗂️  Workspace: {{tower_workspace}}"
    
    # Create log directory for this experiment
    log_dir="{{logs_dir}}/{{experiment_id}}"
    mkdir -p "$log_dir"
    
    # Resume via Tower with resume flag
    tower_run_id=$(tw launch data-pipeline.nf \
        --workspace={{tower_workspace}} \
        --params-file="$exp_dir/params.yaml" \
        --name="{{experiment_id}}_resume" \
        --tag="experiment:{{experiment_id}}" \
        --tag="type:resume" \
        --tag="date:{{date}}" \
        --resume \
        --work-dir="s3://your-bucket/work/{{experiment_id}}" \
        --outdir="s3://your-bucket/results/{{experiment_id}}" \
        2>&1 | tee "$log_dir/tower-resume.log" | grep -o "Run ID: [0-9]*" | cut -d' ' -f3)
    
    echo "🆔 Tower Run ID: $tower_run_id"
    echo "$tower_run_id" > "$exp_dir/tower-resume-run-id.txt"
    
    echo "📊 Monitor progress at: https://tower.nf/user/runs/$tower_run_id"
    echo "📝 Logs saved to: $log_dir"

# === Experiment Monitoring ===

# Check experiment status
nf-status experiment_id:
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{experiment_id}}"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Experiment directory not found: $exp_dir"
        exit 1
    fi
    
    echo "📊 Experiment Status: {{experiment_id}}"
    echo "================================"
    
    # Check Tower run IDs
    if [ -f "$exp_dir/tower-run-id.txt" ]; then
        tower_id=$(cat "$exp_dir/tower-run-id.txt")
        echo "🆔 Tower Run ID: $tower_id"
        
        # Get status from Tower
        tw runs view "$tower_id" --workspace=default 2>/dev/null || echo "❌ Could not fetch Tower status"
    fi
    
    # Check for resume run
    if [ -f "$exp_dir/tower-resume-run-id.txt" ]; then
        resume_id=$(cat "$exp_dir/tower-resume-run-id.txt")
        echo "🔄 Tower Resume Run ID: $resume_id"
        
        # Get status from Tower
        tw runs view "$resume_id" --workspace=default 2>/dev/null || echo "❌ Could not fetch Tower resume status"
    fi

# === Experiment Analysis ===

# Generate experiment report
nf-report experiment_id:
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{experiment_id}}"
    report_file="{{reports_dir}}/{{experiment_id}}_report.md"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Experiment directory not found: $exp_dir"
        exit 1
    fi
    
    echo "📊 Generating report for: {{experiment_id}}"
    
    # Create reports directory
    mkdir -p "{{reports_dir}}"
    
    # Generate comprehensive report
    cat > "$report_file" << EOF
    # Experiment Report: {{experiment_id}}
    
    Generated: $(date)
    
    ## Experiment Overview
    $(cat "$exp_dir/experiment-plan.md")
    
    ## Execution Log
    $(cat "$exp_dir/execution-log.md")
    
    ## Parameters Used
    \`\`\`yaml
    $(cat "$exp_dir/params.yaml")
    \`\`\`
    
    ## Samplesheet
    \`\`\`csv
    $(cat "$exp_dir/samplesheet.csv")
    \`\`\`
    
    ## Tower Information
    EOF
    
    # Add Tower run information if available
    if [ -f "$exp_dir/tower-run-id.txt" ]; then
        tower_id=$(cat "$exp_dir/tower-run-id.txt")
        echo "- **Tower Run ID**: $tower_id" >> "$report_file"
        echo "- **Tower URL**: https://tower.nf/user/runs/$tower_id" >> "$report_file"
    fi
    
    if [ -f "$exp_dir/tower-resume-run-id.txt" ]; then
        resume_id=$(cat "$exp_dir/tower-resume-run-id.txt")
        echo "- **Tower Resume Run ID**: $resume_id" >> "$report_file"
        echo "- **Tower Resume URL**: https://tower.nf/user/runs/$resume_id" >> "$report_file"
    fi
    
    echo "✅ Report generated: $report_file"

# === Experiment Management ===

# List all experiments
nf-list-experiments:
    @echo "🧪 All Experiments:"
    @find {{runs_dir}} -name "20*" -type d | sort | while read exp_dir; do \
        exp_id=$(basename "$exp_dir"); \
        if [ -f "$exp_dir/tower-run-id.txt" ]; then \
            tower_id=$(cat "$exp_dir/tower-run-id.txt"); \
            echo "  📊 $exp_id (Tower: $tower_id)"; \
        else \
            echo "  📊 $exp_id"; \
        fi; \
    done

# List failed experiments
nf-list-failed:
    @echo "❌ Failed Experiments:"
    @find {{runs_dir}} -name "20*" -type d | sort | while read exp_dir; do \
        exp_id=$(basename "$exp_dir"); \
        if [ -f "$exp_dir/tower-run-id.txt" ]; then \
            tower_id=$(cat "$exp_dir/tower-run-id.txt"); \
            # Check if experiment failed (you might need to adjust this logic)
            if tw runs view "$tower_id" --workspace=default 2>/dev/null | grep -q "FAILED"; then \
                echo "  ❌ $exp_id (Tower: $tower_id)"; \
            fi; \
        fi; \
    done

# Archive completed experiment
nf-archive experiment_id:
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{experiment_id}}"
    archive_dir="{{runs_dir}}/archived"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Experiment directory not found: $exp_dir"
        exit 1
    fi
    
    mkdir -p "$archive_dir"
    
    echo "📦 Archiving experiment: {{experiment_id}}"
    mv "$exp_dir" "$archive_dir/"
    
    echo "✅ Experiment archived to: $archive_dir/{{experiment_id}}"

# === Setup and Cleanup ===

# Setup experiment directories
nf-setup:
    @mkdir -p {{runs_dir}} {{logs_dir}} {{reports_dir}} {{samplesheets_dir}} {{configs_dir}}
    @mkdir -p {{runs_dir}}/templates {{runs_dir}}/archived
    @mkdir -p {{samplesheets_dir}}
    @echo "✅ Experiment directories created"

# Clean up temporary files
nf-cleanup:
    @find {{runs_dir}} -name "*.bak" -delete
    @find {{logs_dir}} -name "*.tmp" -delete
    @echo "🧹 Cleanup completed"

# Show experiment statistics
nf-stats:
    #!/usr/bin/env bash
    echo "📊 Experiment Statistics:"
    echo "========================"
    
    total_exp=$(find {{runs_dir}} -name "20*" -type d | wc -l)
    archived_exp=$(find {{runs_dir}}/archived -name "20*" -type d 2>/dev/null | wc -l)
    active_exp=$((total_exp - archived_exp))
    
    echo "Total experiments: $total_exp"
    echo "Active experiments: $active_exp"
    echo "Archived experiments: $archived_exp"
    
    echo ""
    echo "Recent experiments (last 7 days):"
    find {{runs_dir}} -name "20*" -type d -mtime -7 | sort | while read exp_dir; do
        exp_id=$(basename "$exp_dir")
        echo "  📊 $exp_id"
    done
