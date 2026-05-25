# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Nextflow Investigations Management with Resume Support
# Enhanced investigation tracking for failed and resumed pipeline runs

# Variables
investigations_dir := justfile_directory()
templates_dir := investigations_dir + "/runs/templates"
runs_dir := investigations_dir + "/runs"
logs_dir := investigations_dir + "/logs"
reports_dir := investigations_dir + "/reports"
samplesheets_dir := investigations_dir + "/samplesheets/investigations"
configs_dir := investigations_dir + "/configs"
timestamp := `date +%Y%m%d_%H%M%S`
date := `date +%Y-%m-%d`
researcher := "researcher-name"

# Default recipe
default:
    @echo "🧪 Nextflow Investigations Management:"
    @just --list

# === Investigation Creation ===

# Create new investigation
nf-new-investigation name purpose="exploratory":
    #!/usr/bin/env bash
    exp_id="{{date}}_{{purpose}}_{{name}}_v1"
    exp_dir="{{runs_dir}}/$exp_id"
    
    echo "🧪 Creating new investigation: $exp_id"
    
    # Create investigation directory
    mkdir -p "$exp_dir"
    
    # Create investigation plan from template
    cp "{{templates_dir}}/investigation-plan.md" "$exp_dir/investigation-plan.md"
    sed -i.bak "s/{{investigation_id}}/$exp_id/g" "$exp_dir/investigation-plan.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$exp_dir/investigation-plan.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$exp_dir/investigation-plan.md"
    sed -i.bak "s/{{project}}/{{name}}/g" "$exp_dir/investigation-plan.md"
    rm "$exp_dir/investigation-plan.md.bak"
    
    # Create execution log template
    cp "{{templates_dir}}/execution-log.md" "$exp_dir/execution-log.md"
    sed -i.bak "s/{{investigation_id}}/$exp_id/g" "$exp_dir/execution-log.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$exp_dir/execution-log.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$exp_dir/execution-log.md"
    rm "$exp_dir/execution-log.md.bak"
    
    # Create default parameter file
    cat > "$exp_dir/params.yaml" << EOF
    # Investigation Parameters for $exp_id
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
    
    echo "✅ Investigation created: $exp_dir"
    echo "📝 Edit investigation-plan.md to define objectives"
    echo "⚙️  Edit params.yaml to configure parameters"
    echo "📊 Edit samplesheet.csv to define samples"

# Create resumed investigation from failed one
nf-resume-investigation failed_investigation_id new_purpose="resume":
    #!/usr/bin/env bash
    failed_exp_dir="{{runs_dir}}/{{failed_investigation_id}}"
    
    if [ ! -d "$failed_exp_dir" ]; then
        echo "❌ Failed investigation directory not found: $failed_exp_dir"
        exit 1
    fi
    
    # Extract base name without version
    base_name=$(echo "{{failed_investigation_id}}" | sed 's/_v[0-9]*$//')
    resume_exp_id="${base_name}_{{new_purpose}}_v1"
    resume_exp_dir="{{runs_dir}}/$resume_exp_id"
    
    echo "🔄 Creating resumed investigation: $resume_exp_id"
    echo "📂 From failed investigation: {{failed_investigation_id}}"
    
    # Create resume investigation directory
    mkdir -p "$resume_exp_dir"
    
    # Copy and modify files from failed investigation
    cp "$failed_exp_dir/params.yaml" "$resume_exp_dir/params.yaml"
    cp "$failed_exp_dir/samplesheet.csv" "$resume_exp_dir/samplesheet.csv"
    
    # Enable resume in params
    sed -i.bak 's/resume: false/resume: true/g' "$resume_exp_dir/params.yaml"
    rm "$resume_exp_dir/params.yaml.bak"
    
    # Create investigation plan for resumed investigation
    cp "{{templates_dir}}/investigation-plan.md" "$resume_exp_dir/investigation-plan.md"
    sed -i.bak "s/{{investigation_id}}/$resume_exp_id/g" "$resume_exp_dir/investigation-plan.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$resume_exp_dir/investigation-plan.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$resume_exp_dir/investigation-plan.md"
    sed -i.bak "s/{{previous_investigation_id}}/{{failed_investigation_id}}/g" "$resume_exp_dir/investigation-plan.md"
    
    # Mark as resumed investigation
    sed -i.bak 's/- \[ \] New investigation/- [x] New investigation/g' "$resume_exp_dir/investigation-plan.md"
    sed -i.bak 's/- \[ \] Resumed investigation/- [x] Resumed investigation/g' "$resume_exp_dir/investigation-plan.md"
    
    rm "$resume_exp_dir/investigation-plan.md.bak"
    
    # Create execution log template
    cp "{{templates_dir}}/execution-log.md" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{investigation_id}}/$resume_exp_id/g" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{date}}/{{date}}/g" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{researcher}}/{{researcher}}/g" "$resume_exp_dir/execution-log.md"
    sed -i.bak "s/{{resumed_from}}/{{failed_investigation_id}}/g" "$resume_exp_dir/execution-log.md"
    rm "$resume_exp_dir/execution-log.md.bak"
    
    echo "✅ Resumed investigation created: $resume_exp_dir"
    echo "📝 Review and update investigation-plan.md"
    echo "⚙️  Review and update params.yaml"
    echo "🔄 Resume flag enabled in parameters"

# === Investigation Execution ===

# Run investigation via Tower
nf-run-investigation investigation_id tower_workspace="default":
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{investigation_id}}"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Investigation directory not found: $exp_dir"
        exit 1
    fi
    
    echo "🚀 Running investigation: {{investigation_id}}"
    echo "🗂️  Workspace: {{tower_workspace}}"
    
    # Create log directory for this investigation
    log_dir="{{logs_dir}}/{{investigation_id}}"
    mkdir -p "$log_dir"
    
    # Run via Tower (adjust command based on your Tower setup)
    tower_run_id=$(tw launch data-pipeline.nf \
        --workspace={{tower_workspace}} \
        --params-file="$exp_dir/params.yaml" \
        --name="{{investigation_id}}" \
        --tag="investigation:{{investigation_id}}" \
        --tag="date:{{date}}" \
        --work-dir="s3://your-bucket/work/{{investigation_id}}" \
        --outdir="s3://your-bucket/results/{{investigation_id}}" \
        2>&1 | tee "$log_dir/tower-launch.log" | grep -o "Run ID: [0-9]*" | cut -d' ' -f3)
    
    echo "🆔 Tower Run ID: $tower_run_id"
    echo "$tower_run_id" > "$exp_dir/tower-run-id.txt"
    
    echo "📊 Monitor progress at: https://tower.nf/user/runs/$tower_run_id"
    echo "📝 Logs saved to: $log_dir"

# Resume investigation via Tower
nf-resume-run investigation_id tower_workspace="default":
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{investigation_id}}"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Investigation directory not found: $exp_dir"
        exit 1
    fi
    
    echo "🔄 Resuming investigation: {{investigation_id}}"
    echo "🗂️  Workspace: {{tower_workspace}}"
    
    # Create log directory for this investigation
    log_dir="{{logs_dir}}/{{investigation_id}}"
    mkdir -p "$log_dir"
    
    # Resume via Tower with resume flag
    tower_run_id=$(tw launch data-pipeline.nf \
        --workspace={{tower_workspace}} \
        --params-file="$exp_dir/params.yaml" \
        --name="{{investigation_id}}_resume" \
        --tag="investigation:{{investigation_id}}" \
        --tag="type:resume" \
        --tag="date:{{date}}" \
        --resume \
        --work-dir="s3://your-bucket/work/{{investigation_id}}" \
        --outdir="s3://your-bucket/results/{{investigation_id}}" \
        2>&1 | tee "$log_dir/tower-resume.log" | grep -o "Run ID: [0-9]*" | cut -d' ' -f3)
    
    echo "🆔 Tower Run ID: $tower_run_id"
    echo "$tower_run_id" > "$exp_dir/tower-resume-run-id.txt"
    
    echo "📊 Monitor progress at: https://tower.nf/user/runs/$tower_run_id"
    echo "📝 Logs saved to: $log_dir"

# === Investigation Monitoring ===

# Check investigation status
nf-status investigation_id:
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{investigation_id}}"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Investigation directory not found: $exp_dir"
        exit 1
    fi
    
    echo "📊 Investigation Status: {{investigation_id}}"
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

# === Investigation Analysis ===

# Generate investigation report
nf-report investigation_id:
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{investigation_id}}"
    report_file="{{reports_dir}}/{{investigation_id}}_report.md"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Investigation directory not found: $exp_dir"
        exit 1
    fi
    
    echo "📊 Generating report for: {{investigation_id}}"
    
    # Create reports directory
    mkdir -p "{{reports_dir}}"
    
    # Generate comprehensive report
    cat > "$report_file" << EOF
    # Investigation Report: {{investigation_id}}
    
    Generated: $(date)
    
    ## Investigation Overview
    $(cat "$exp_dir/investigation-plan.md")
    
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

# === Investigation Management ===

# List all investigations
nf-list-investigations:
    @echo "🧪 All Investigations:"
    @find {{runs_dir}} -name "20*" -type d | sort | while read exp_dir; do \
        exp_id=$(basename "$exp_dir"); \
        if [ -f "$exp_dir/tower-run-id.txt" ]; then \
            tower_id=$(cat "$exp_dir/tower-run-id.txt"); \
            echo "  📊 $exp_id (Tower: $tower_id)"; \
        else \
            echo "  📊 $exp_id"; \
        fi; \
    done

# List failed investigations
nf-list-failed:
    @echo "❌ Failed Investigations:"
    @find {{runs_dir}} -name "20*" -type d | sort | while read exp_dir; do \
        exp_id=$(basename "$exp_dir"); \
        if [ -f "$exp_dir/tower-run-id.txt" ]; then \
            tower_id=$(cat "$exp_dir/tower-run-id.txt"); \
            # Check if investigation failed (you might need to adjust this logic)
            if tw runs view "$tower_id" --workspace=default 2>/dev/null | grep -q "FAILED"; then \
                echo "  ❌ $exp_id (Tower: $tower_id)"; \
            fi; \
        fi; \
    done

# Archive completed investigation
nf-archive investigation_id:
    #!/usr/bin/env bash
    exp_dir="{{runs_dir}}/{{investigation_id}}"
    archive_dir="{{runs_dir}}/archived"
    
    if [ ! -d "$exp_dir" ]; then
        echo "❌ Investigation directory not found: $exp_dir"
        exit 1
    fi
    
    mkdir -p "$archive_dir"
    
    echo "📦 Archiving investigation: {{investigation_id}}"
    mv "$exp_dir" "$archive_dir/"
    
    echo "✅ Investigation archived to: $archive_dir/{{investigation_id}}"

# === Setup and Cleanup ===

# Setup investigation directories
nf-setup:
    @mkdir -p {{runs_dir}} {{logs_dir}} {{reports_dir}} {{samplesheets_dir}} {{configs_dir}}
    @mkdir -p {{runs_dir}}/templates {{runs_dir}}/archived
    @mkdir -p {{samplesheets_dir}}
    @echo "✅ Investigation directories created"

# Clean up temporary files
nf-cleanup:
    @find {{runs_dir}} -name "*.bak" -delete
    @find {{logs_dir}} -name "*.tmp" -delete
    @echo "🧹 Cleanup completed"

# Show investigation statistics
nf-stats:
    #!/usr/bin/env bash
    echo "📊 Investigation Statistics:"
    echo "========================"
    
    total_exp=$(find {{runs_dir}} -name "20*" -type d | wc -l)
    archived_exp=$(find {{runs_dir}}/archived -name "20*" -type d 2>/dev/null | wc -l)
    active_exp=$((total_exp - archived_exp))
    
    echo "Total investigations: $total_exp"
    echo "Active investigations: $active_exp"
    echo "Archived investigations: $archived_exp"
    
    echo ""
    echo "Recent investigations (last 7 days):"
    find {{runs_dir}} -name "20*" -type d -mtime -7 | sort | while read exp_dir; do
        exp_id=$(basename "$exp_dir")
        echo "  📊 $exp_id"
    done
