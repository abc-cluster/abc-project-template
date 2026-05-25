# Enhanced Notebook Management with Just
# Comprehensive automation for data science notebooks

# Variables
notebooks_dir := justfile_directory()
experiment_template := notebooks_dir + "/experiment_template.qmd"
date := `date +%Y%m%d`
timestamp := `date +%Y%m%d_%H%M%S`
EXPERIMENTS_LOG := "experiments_log.md"

# Default recipe
default:
    @echo "📓 Notebook Management Commands:"
    @just --list

# === Notebook Creation ===

# Create new EDA notebook
new-eda name stage="02-exploration":
    #!/usr/bin/env bash
    exp_id="{{timestamp}}_eda_{{name}}"
    target_dir="{{stage}}/eda"
    mkdir -p "$target_dir"
    
    # Copy and customize template
    if [ -f "{{experiment_template}}" ]; then
        cp "{{experiment_template}}" "$target_dir/${exp_id}.qmd"
        # Replace template variables (using portable sed)
        sed -i.bak "s/{{EXPERIMENT_ID}}/$exp_id/g" "$target_dir/${exp_id}.qmd"
        sed -i.bak "s/{{SUBSTAGE}}/EDA for {{name}}/g" "$target_dir/${exp_id}.qmd"
        sed -i.bak "s/{{DATE}}/{{date}}/g" "$target_dir/${exp_id}.qmd"
        rm "$target_dir/${exp_id}.qmd.bak"
        echo "📊 Created EDA notebook: $target_dir/${exp_id}.qmd"
    else
        echo "❌ Template file not found: {{experiment_template}}"
    fi

# Create new modeling experiment
new-model name stage="05-models" model_type="baseline":
    #!/usr/bin/env bash
    exp_id="{{timestamp}}_model_{{model_type}}_{{name}}"
    target_dir="{{stage}}/051_{{model_type}}_models"
    mkdir -p "$target_dir"
    
    if [ -f "{{experiment_template}}" ]; then
        cp "{{experiment_template}}" "$target_dir/${exp_id}.qmd"
        sed -i.bak "s/{{EXPERIMENT_ID}}/$exp_id/g" "$target_dir/${exp_id}.qmd"
        sed -i.bak "s/{{SUBSTAGE}}/{{model_type}} modeling for {{name}}/g" "$target_dir/${exp_id}.qmd"
        sed -i.bak "s/{{DATE}}/{{date}}/g" "$target_dir/${exp_id}.qmd"
        rm "$target_dir/${exp_id}.qmd.bak"
        echo "🤖 Created modeling notebook: $target_dir/${exp_id}.qmd"
    else
        echo "❌ Template file not found: {{experiment_template}}"
    fi

# Create custom experiment notebook (legacy support)
new-experiment substage desc:
    #!/usr/bin/env bash
    ts={{timestamp}}
    folder="{{substage}}/experiments/${ts}_{{desc}}"
    mkdir -p "$folder"
    
    if [ -f "{{experiment_template}}" ]; then
        cp "{{experiment_template}}" "$folder/experiment.qmd"
        
        # Create experiment metadata if template exists
        if [ -f "experiment_template.md" ]; then
            cp "experiment_template.md" "$folder/experiment.md"
            sed -i.bak "s/{{EXPERIMENT_ID}}/${ts}_{{desc}}/g" "$folder/experiment.md"
            sed -i.bak "s/{{SUBSTAGE}}/{{substage}}/g" "$folder/experiment.md"
            sed -i.bak "s/{{AUTHOR}}/abhi18av/g" "$folder/experiment.md"
            sed -i.bak "s/{{DATE}}/$ts/g" "$folder/experiment.md"
            rm "$folder/experiment.md.bak"
        fi
        
        echo "🧪 Experiment initialized at $folder"
    else
        echo "❌ Template file not found: {{experiment_template}}"
    fi

# === Notebook Management ===

# List all notebooks
list:
    @echo "📋 All Notebooks:"
    @find . -name "*.qmd" -o -name "*.ipynb" | sort

# List notebooks by stage
list-stage stage:
    @echo "📋 Notebooks in {{stage}}:"
    @find "{{stage}}" -name "*.qmd" -o -name "*.ipynb" 2>/dev/null | sort || echo "No notebooks found in {{stage}}"

# List recent notebooks (last 7 days)
list-recent:
    @echo "📋 Recent Notebooks (last 7 days):"
    @find . -name "*.qmd" -o -name "*.ipynb" -mtime -7 | sort

# Search notebooks by content
search query:
    @echo "🔍 Searching for: {{query}}"
    @grep -r "{{query}}" --include="*.qmd" --include="*.ipynb" . | head -20

# === Notebook Execution ===

# Run specific notebook
run notebook:
    @echo "▶️ Running notebook: {{notebook}}"
    @if [ -f "{{notebook}}" ]; then \
        quarto render "{{notebook}}"; \
    else \
        echo "❌ Notebook not found: {{notebook}}"; \
    fi

# Run all notebooks in a stage
run-stage stage:
    @echo "▶️ Running all notebooks in: {{stage}}"
    @if [ -d "{{stage}}" ]; then \
        find "{{stage}}" -name "*.qmd" -exec quarto render {} \;; \
    else \
        echo "❌ Stage directory not found: {{stage}}"; \
    fi

# Run EDA notebooks
eda:
    @echo "📊 Running EDA notebooks..."
    {% if programming_language == "Python" or programming_language == "Both" %}
    @find . -path "*/02-exploration/*" -name "*.ipynb" -exec jupyter nbconvert --execute {} --to html \;
    {% endif %}
    {% if programming_language == "R" or programming_language == "Both" %}
    @find . -path "*/02-exploration/*" -name "*.Rmd" -exec Rscript -e "rmarkdown::render('{}')" \;
    {% endif %}

# === Validation and Quality ===

# Validate notebook format
validate notebook:
    @echo "✅ Validating: {{notebook}}"
    @if [[ "{{notebook}}" == *.qmd ]]; then \
        quarto check "{{notebook}}"; \
    elif [[ "{{notebook}}" == *.ipynb ]]; then \
        python -m nbformat.validator "{{notebook}}" 2>/dev/null || echo "⚠️ nbformat validator not available"; \
    fi

# Clean notebook outputs
clean notebook:
    @echo "🧹 Cleaning: {{notebook}}"
    @if [[ "{{notebook}}" == *.ipynb ]]; then \
        jupyter nbconvert --clear-output --inplace "{{notebook}}" 2>/dev/null || echo "⚠️ jupyter nbconvert not available"; \
    fi

# Clean all notebook outputs in stage
clean-stage stage:
    @echo "🧹 Cleaning all notebooks in: {{stage}}"
    @find "{{stage}}" -name "*.ipynb" -exec jupyter nbconvert --clear-output --inplace {} \; 2>/dev/null || echo "⚠️ jupyter nbconvert not available"

# === Environment and Dependencies ===

# Start Jupyter Lab
jupyter:
    @echo "🚀 Starting Jupyter Lab..."
    @jupyter lab --ip=0.0.0.0 --port=8888 --no-browser || echo "❌ Jupyter Lab not available"

# === Experiment Tracking ===

# Update experiment history
update-history substage desc result:
    #!/usr/bin/env bash
    ts={{timestamp}}
    id="${ts}_{{desc}}"
    echo "| $id | {{substage}} | abhi18av | $ts | {{desc}} | {{result}} |" >> {{EXPERIMENTS_LOG}}
    echo "📝 Updated experiment history with $id"

# Initialize log file header
init-history:
    #!/usr/bin/env bash
    if [ ! -f {{EXPERIMENTS_LOG}} ]; then
        echo '| Experiment ID | Stage | Author | Date/Time (UTC) | Description | Key Result/Metric |' >> {{EXPERIMENTS_LOG}}
        echo '|---------------|-------|--------|-----------------|-------------|-------------------|' >> {{EXPERIMENTS_LOG}}
        echo "📄 Initialized experiment log at {{EXPERIMENTS_LOG}}"
    else
        echo "📄 Experiment log already exists."
    fi

# === Script Extraction ===

# Extract Python scripts from notebooks
extract-python:
    @echo "🐍 Extracting Python scripts..."
    @mkdir -p ../scripts/python
    @find . -name '*.ipynb' -exec jupyter nbconvert --to script {} --output-dir=../scripts/python \; 2>/dev/null || echo "⚠️ jupyter nbconvert not available"
    @find . -name '*.qmd' -exec quarto extract {} --to ../scripts/python \; 2>/dev/null || echo "⚠️ quarto extract not available"

# Extract R scripts from notebooks
extract-r:
    @echo "📊 Extracting R scripts..."
    @mkdir -p ../scripts/r
    @find . -name '*.Rmd' -exec Rscript -e "knitr::purl('{}', output='../scripts/r/')" \; 2>/dev/null || echo "⚠️ R/knitr not available"

# Extract all scripts
extract-all: extract-python extract-r

# === Analytics and Reporting ===

# Generate notebook statistics
stats:
    #!/usr/bin/env bash
    echo "📊 Notebook Statistics:"
    echo "======================"
    total_qmd=$(find . -name "*.qmd" | wc -l)
    total_ipynb=$(find . -name "*.ipynb" | wc -l)
    total_notebooks=$((total_qmd + total_ipynb))
    
    echo "Total notebooks: $total_notebooks"
    echo "Quarto documents: $total_qmd"
    echo "Jupyter notebooks: $total_ipynb"
    echo ""
    echo "By stage:"
    for stage in 00_scratch 01-data 02-exploration 03-analysis 04-feat_eng 05-models 06-interpretation 07-reports 08-deploy 09-governance 10-iteration; do
        if [ -d "$stage" ]; then
            count=$(find "$stage" -name "*.qmd" -o -name "*.ipynb" | wc -l)
            echo "  $stage: $count notebooks"
        fi
    done

# === Backup and Archive ===

# Backup all notebooks
backup:
    #!/usr/bin/env bash
    backup_dir="backups/notebooks_{{timestamp}}"
    mkdir -p "$backup_dir"
    
    # Copy all notebooks
    find . -name "*.qmd" -o -name "*.ipynb" | while read notebook; do
        target_dir="$backup_dir/$(dirname "$notebook")"
        mkdir -p "$target_dir"
        cp "$notebook" "$target_dir/"
    done
    
    echo "💾 Notebooks backed up to: $backup_dir"

# Archive completed experiments
archive stage:
    #!/usr/bin/env bash
    archive_dir="archive/{{stage}}_{{timestamp}}"
    mkdir -p "$archive_dir"
    
    if [ -d "{{stage}}" ]; then
        cp -r "{{stage}}" "$archive_dir/"
        echo "📦 Stage {{stage}} archived to: $archive_dir"
    else
        echo "❌ Stage {{stage}} not found"
    fi
