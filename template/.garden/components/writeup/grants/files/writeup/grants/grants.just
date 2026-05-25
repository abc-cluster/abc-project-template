# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Grant Management Automation
# Use with just (https://github.com/casey/just)

# Set default shell
set shell := ["bash", "-c"]

# Variables
grants_dir := justfile_directory()
templates_dir := grants_dir + "/templates"
applications_dir := grants_dir + "/applications"
assets_dir := grants_dir + "/assets"

# Default recipe
default:
    @echo "Available grant management commands:"
    @just --list

# Create new grant application from template
new-application template_type agency_name project_name:
    #!/usr/bin/env bash
    mkdir -p "{{applications_dir}}/active/{{project_name}}"
    cp -r "{{templates_dir}}/{{template_type}}/{{agency_name}}"/* "{{applications_dir}}/active/{{project_name}}/"
    echo "Created new grant application: {{project_name}}"
    echo "Location: {{applications_dir}}/active/{{project_name}}"

# Create NSF grant application
new-nsf project_name:
    @just new-application federal nsf {{project_name}}

# Create NIH grant application  
new-nih project_name:
    @just new-application federal nih {{project_name}}

# Create private foundation grant application
new-foundation project_name:
    @just new-application private foundation {{project_name}}

# List all active applications
list-active:
    @echo "Active grant applications:"
    @ls -la "{{applications_dir}}/active" 2>/dev/null || echo "No active applications found"

# List all submitted applications
list-submitted:
    @echo "Submitted grant applications:"
    @ls -la "{{applications_dir}}/submitted" 2>/dev/null || echo "No submitted applications found"

# List all awarded grants
list-awarded:
    @echo "Awarded grants:"
    @ls -la "{{applications_dir}}/awarded" 2>/dev/null || echo "No awarded grants found"

# Move application to submitted
submit project_name:
    #!/usr/bin/env bash
    if [ -d "{{applications_dir}}/active/{{project_name}}" ]; then
        mv "{{applications_dir}}/active/{{project_name}}" "{{applications_dir}}/submitted/"
        echo "Moved {{project_name}} to submitted applications"
    else
        echo "Error: {{project_name}} not found in active applications"
    fi

# Move application to awarded
award project_name:
    #!/usr/bin/env bash
    if [ -d "{{applications_dir}}/submitted/{{project_name}}" ]; then
        mv "{{applications_dir}}/submitted/{{project_name}}" "{{applications_dir}}/awarded/"
        echo "Moved {{project_name}} to awarded grants"
    else
        echo "Error: {{project_name}} not found in submitted applications"
    fi

# Generate budget template
budget project_name:
    #!/usr/bin/env bash
    if [ -d "{{applications_dir}}/active/{{project_name}}" ]; then
        cp "{{assets_dir}}/budgets/budget_template.xlsx" "{{applications_dir}}/active/{{project_name}}/budget.xlsx"
        echo "Created budget template for {{project_name}}"
    else
        echo "Error: {{project_name}} not found in active applications"
    fi

# Generate data management plan
dmp project_name:
    #!/usr/bin/env bash
    if [ -d "{{applications_dir}}/active/{{project_name}}" ]; then
        cp "{{assets_dir}}/appendices/data_management_plan.qmd" "{{applications_dir}}/active/{{project_name}}/"
        echo "Created data management plan for {{project_name}}"
    else
        echo "Error: {{project_name}} not found in active applications"
    fi

# Compile grant proposal to PDF
compile project_name file="":
    #!/usr/bin/env bash
    cd "{{applications_dir}}/active/{{project_name}}"
    if [ -z "{{file}}" ]; then
        # Find and compile all .qmd files
        for qmd_file in *.qmd; do
            if [ -f "$qmd_file" ]; then
                echo "Compiling $qmd_file..."
                quarto render "$qmd_file"
            fi
        done
    else
        if [ -f "{{file}}" ]; then
            echo "Compiling {{file}}..."
            quarto render "{{file}}"
        else
            echo "Error: {{file}} not found"
        fi
    fi

# Check grant deadlines (requires updating tracker file)
deadlines:
    @echo "Checking upcoming grant deadlines..."
    @grep -E "Due:|Deadline:" "{{grants_dir}}/tracking/deadlines/grant_tracker.md" | head -10

# Create backup of applications
backup:
    #!/usr/bin/env bash
    backup_dir="{{grants_dir}}/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    cp -r "{{applications_dir}}" "$backup_dir/"
    echo "Backup created: $backup_dir"

# Validate grant application structure
validate project_name:
    #!/usr/bin/env bash
    project_dir="{{applications_dir}}/active/{{project_name}}"
    if [ ! -d "$project_dir" ]; then
        echo "Error: {{project_name}} not found in active applications"
        exit 1
    fi
    
    echo "Validating {{project_name}}..."
    
    # Check for common files
    files=("*.qmd" "*.md" "budget*" "*references*")
    for pattern in "${files[@]}"; do
        if ls "$project_dir"/$pattern 1> /dev/null 2>&1; then
            echo "✓ Found $pattern"
        else
            echo "⚠ Missing $pattern"
        fi
    done

# Show grant statistics
stats:
    #!/usr/bin/env bash
    echo "Grant Application Statistics:"
    echo "=============================="
    
    active_count=$(ls -1 "{{applications_dir}}/active" 2>/dev/null | wc -l)
    submitted_count=$(ls -1 "{{applications_dir}}/submitted" 2>/dev/null | wc -l)
    awarded_count=$(ls -1 "{{applications_dir}}/awarded" 2>/dev/null | wc -l)
    
    echo "Active applications: $active_count"
    echo "Submitted applications: $submitted_count"
    echo "Awarded grants: $awarded_count"
    echo ""
    
    if [ $submitted_count -gt 0 ] && [ $awarded_count -gt 0 ]; then
        success_rate=$(echo "scale=1; $awarded_count * 100 / $submitted_count" | bc -l)
        echo "Success rate: $success_rate%"
    fi

# Clean up empty directories
clean:
    @echo "Cleaning up empty directories..."
    @find "{{grants_dir}}" -type d -empty -not -path "*/.*" -delete
    @echo "Done"

# Initialize a new grants workspace
init:
    #!/usr/bin/env bash
    echo "Initializing grants workspace..."
    
    # Ensure all directories exist
    mkdir -p "{{applications_dir}}"/{active,submitted,awarded}
    mkdir -p "{{assets_dir}}"/{budgets,figures,appendices,references}
    mkdir -p "{{grants_dir}}/tracking"/{deadlines,reviews,reports}
    
    echo "Grants workspace initialized!"
    echo "Use 'just new-nsf <project_name>' to create your first NSF proposal"
    echo "Use 'just new-nih <project_name>' to create your first NIH proposal"
