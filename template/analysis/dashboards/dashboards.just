# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Enhanced Dashboard Management with Just
# Comprehensive automation for research dashboards

# Variables
dashboards_dir := justfile_directory()
templates_dir := dashboards_dir + "/templates"
date := `date +%Y%m%d`
timestamp := `date +%Y%m%d_%H%M%S`

# Default recipe
default:
    @echo "📊 Dashboard Management Commands:"
    @just --list

# === Dashboard Creation ===

# Create new research results dashboard
new-research name:
    #!/usr/bin/env bash
    dashboard_id="{{timestamp}}_research_{{name}}"
    template_file="{{templates_dir}}/research-results-template.qmd"
    target_file="${dashboard_id}.qmd"
    
    if [ -f "$template_file" ]; then
        cp "$template_file" "$target_file"
        # Replace template variables
        sed -i.bak "s/{{DASHBOARD_ID}}/$dashboard_id/g" "$target_file"
        sed -i.bak "s/{{PROJECT_NAME}}/{{name}}/g" "$target_file"
        sed -i.bak "s/{{DATE}}/{{date}}/g" "$target_file"
        rm "$target_file.bak"
        echo "📊 Created research dashboard: $target_file"
    else
        echo "❌ Template not found: $template_file"
        echo "📝 Creating basic research dashboard..."
        cat > "$target_file" << EOF
---
title: "Research Results: {{name}}"
format: dashboard
server: shiny
---

# Research Overview
Add your research methodology and objectives here.

# Results
Add your key findings and visualizations here.

# Statistical Analysis
Add statistical tests and significance analysis here.

# Conclusions
Summarize your conclusions and next steps here.
EOF
        echo "📊 Created basic research dashboard: $target_file"
    fi

# Create new model performance dashboard
new-model-performance name:
    #!/usr/bin/env bash
    dashboard_id="{{timestamp}}_model_{{name}}"
    template_file="{{templates_dir}}/model-performance-template.qmd"
    target_file="${dashboard_id}.qmd"
    
    if [ -f "$template_file" ]; then
        cp "$template_file" "$target_file"
        sed -i.bak "s/{{DASHBOARD_ID}}/$dashboard_id/g" "$target_file"
        sed -i.bak "s/{{MODEL_NAME}}/{{name}}/g" "$target_file"
        sed -i.bak "s/{{DATE}}/{{date}}/g" "$target_file"
        rm "$target_file.bak"
        echo "🤖 Created model performance dashboard: $target_file"
    else
        echo "❌ Template not found: $template_file"
        echo "📝 Creating basic model dashboard..."
        cat > "$target_file" << EOF
---
title: "Model Performance: {{name}}"
format: dashboard
server: shiny
---

# Model Overview
Add model architecture and configuration here.

# Performance Metrics
Add accuracy, precision, recall, F1-score visualizations here.

# Feature Importance
Add feature importance plots and analysis here.

# Validation Results
Add cross-validation and test set results here.
EOF
        echo "🤖 Created basic model dashboard: $target_file"
    fi

# Create experimental comparison dashboard
new-comparison name:
    #!/usr/bin/env bash
    dashboard_id="{{timestamp}}_comparison_{{name}}"
    target_file="${dashboard_id}.qmd"
    
    cat > "$target_file" << EOF
---
title: "Experimental Comparison: {{name}}"
format: dashboard
---

# Experimental Setup
Describe the experimental conditions and parameters being compared.

# Results Comparison
Side-by-side comparison of experimental results.

# Statistical Significance
Statistical tests comparing experimental conditions.

# Recommendations
Based on the comparison, provide recommendations for next steps.
EOF
    echo "⚖️ Created comparison dashboard: $target_file"

# === Dashboard Management ===

# List all dashboards
list:
    @echo "📋 All Dashboards:"
    @find . -name "*.qmd" | grep -E "(dashboard|research|model|comparison)" | sort

# Build specific dashboard
build dashboard:
    @echo "🔨 Building dashboard: {{dashboard}}"
    @if [ -f "{{dashboard}}" ]; then \
        quarto render "{{dashboard}}"; \
    else \
        echo "❌ Dashboard not found: {{dashboard}}"; \
    fi

# Build all dashboards
build-all:
    @echo "🔨 Building all dashboards..."
    @find . -name "*.qmd" -exec quarto render {} \;

# Preview dashboard
preview dashboard:
    @echo "👀 Previewing dashboard: {{dashboard}}"
    @if [ -f "{{dashboard}}" ]; then \
        quarto preview "{{dashboard}}" --port 4200; \
    else \
        echo "❌ Dashboard not found: {{dashboard}}"; \
    fi

# === Validation and Quality ===

# Validate dashboard format
validate dashboard:
    @echo "✅ Validating dashboard: {{dashboard}}"
    @quarto check "{{dashboard}}"

# === Deployment ===

# Deploy dashboard to GitHub Pages
deploy-github dashboard:
    @echo "🚀 Deploying to GitHub Pages: {{dashboard}}"
    @quarto publish gh-pages "{{dashboard}}"

# Deploy to Quarto Pub
deploy-pub dashboard:
    @echo "🚀 Deploying to Quarto Pub: {{dashboard}}"
    @quarto publish quarto-pub "{{dashboard}}"

# === Utilities ===

# Clean dashboard outputs
clean:
    @echo "🧹 Cleaning dashboard outputs..."
    @find . -name "*_files" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "*.html" -not -name "index.html" -delete 2>/dev/null || true

# Create dashboard templates directory
setup-templates:
    @mkdir -p {{templates_dir}}
    @echo "📁 Created templates directory: {{templates_dir}}"
