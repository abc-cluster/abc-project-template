# Template Expansion Utilities
# Progressive enhancement commands for beginners

# Variables
copier_answers_file := ".copier-answers.yml"
template_source := "gh:abhi18av/template-analysis-and-writeup"

# Default recipe - show available expansion commands
default:
    @echo "🚀 Template Expansion Commands:"
    @just --list

# === PROJECT EXPANSION ===

# Show current project configuration
show-config:
    @echo "📋 Current Project Configuration:"
    @if [ -f "{{copier_answers_file}}" ]; then \
        echo ""; \
        cat "{{copier_answers_file}}"; \
    else \
        echo "❌ No copier answers file found. This might not be a template-generated project."; \
    fi

# Show available components that can be added
show-available:
    #!/usr/bin/env bash
    echo "🔧 Available Components to Add:"
    echo ""
    echo "📊 Analysis Components:"
    echo "  - data-versioning       : Add DVC for data version control"
    echo "  - data-validation       : Add Great Expectations & Pandera"
    echo "  - experiment-tracking   : Add MLflow/Weights & Biases/Neptune"
    echo "  - full-pipeline        : Add all analysis stages (scripts, packages, testing)"
    echo ""
    echo "📝 Writeup Components:"
    echo "  - academic-writing     : Add manuscript, presentations, grants"
    echo "  - publication-tools    : Add academic publication templates"
    echo "  - presentation-suite   : Add presentation management tools"
    echo ""
    echo "🛠 Infrastructure:"
    echo "  - ci-cd               : Add GitHub Actions & pre-commit hooks"
    echo "  - deployment          : Add Docker, cloud deployment templates"
    echo "  - advanced-vcs        : Add Jujutsu & Fossil version control"
    echo ""
    echo "🌍 Language Support:"
    echo "  - add-r               : Add R language support"
    echo "  - add-julia           : Add Julia language support"
    echo "  - multi-language      : Add both R and Python support"
    echo ""
    echo "Usage: just expand <component-name>"

# Generic expansion command
expand component:
    @echo "🔄 Expanding project with: {{component}}"
    @just _expand-{{component}} || echo "❌ Unknown component: {{component}}. Run 'just show-available' to see options."

# === ANALYSIS EXPANSIONS ===

# Add data versioning (DVC)
_expand-data-versioning:
    @echo "📊 Adding data versioning with DVC..."
    @just _update-config "data_versioning" "true"
    @echo "✅ Data versioning added. Run 'just setup' to install DVC."

# Add data validation frameworks
_expand-data-validation:
    @echo "🔍 Adding data validation frameworks..."
    @just _update-config "data_validation" "true"
    @echo "✅ Data validation added. Run 'just setup' to install validation frameworks."

# Add experiment tracking
_expand-experiment-tracking platform="MLflow":
    @echo "🧪 Adding experiment tracking with {{platform}}..."
    @just _update-config "experiment_tracking" "{{platform}}"
    @echo "✅ Experiment tracking added with {{platform}}."

# Add full analysis pipeline
_expand-full-pipeline:
    @echo "🔬 Adding full analysis pipeline..."
    @just _update-config "include_scripts" "true"
    @just _update-config "include_packages" "true"
    @just _update-config "include_testing" "true"
    @just _update-config "data_versioning" "true"
    @echo "✅ Full analysis pipeline added."

# === WRITEUP EXPANSIONS ===

# Add academic writing capabilities
_expand-academic-writing:
    @echo "📝 Adding academic writing capabilities..."
    @just _update-config "include_manuscript" "true"
    @just _update-config "include_presentations" "true"
    @just _update-config "include_grants" "true"
    @just _update-config "include_abstracts" "true"
    @just _update-config "documentation_format" "Quarto"
    @echo "✅ Academic writing capabilities added."

# Add publication templates
_expand-publication-tools:
    @echo "📄 Adding publication tools..."
    @just _update-config "include_publication_templates" "true"
    @just _update-config "documentation_format" "Quarto"
    @echo "✅ Publication tools added."

# Add presentation suite
_expand-presentation-suite:
    @echo "🎯 Adding presentation suite..."
    @just _update-config "include_presentations" "true"
    @just _update-config "include_posters" "true"
    @echo "✅ Presentation suite added."

# === INFRASTRUCTURE EXPANSIONS ===

# Add CI/CD and quality tools
_expand-ci-cd:
    @echo "⚙️ Adding CI/CD and quality tools..."
    @just _update-config "github_actions" "true"
    @just _update-config "pre_commit_hooks" "true"
    @echo "✅ CI/CD tools added. Run 'just git-setup' to configure pre-commit hooks."

# Add deployment capabilities
_expand-deployment:
    @echo "🚀 Adding deployment capabilities..."
    @just _update-config "include_deployment_templates" "true"
    @just _update-config "include_docker" "true"
    @just _update-config "include_cloud_deployment" "true"
    @echo "✅ Deployment capabilities added."

# Add advanced version control
_expand-advanced-vcs:
    @echo "📋 Adding advanced version control..."
    @just _update-config "include_jujutsu" "true"
    @just _update-config "include_fossil" "true"
    @just _update-config "use_hybrid_vcs" "true"
    @echo "✅ Advanced version control added."

# === LANGUAGE EXPANSIONS ===

# Add R support
_expand-add-r:
    @echo "📊 Adding R language support..."
    @just _update-config "programming_language" "Both"
    @echo "✅ R support added. Run 'just setup' to install R packages."

# Add Julia support
_expand-add-julia:
    @echo "🔢 Adding Julia language support..."
    @just _update-config "programming_language" "Both"
    @echo "✅ Multi-language support added including Julia."

# Add multi-language support
_expand-multi-language:
    @echo "🌍 Adding multi-language support..."
    @just _update-config "programming_language" "Both"
    @echo "✅ Multi-language support (Python + R) added."

# === UPGRADE TO FULL PROJECT ===

# Upgrade to full academic project
upgrade-to-full:
    @echo "🎓 Upgrading to Full Academic Project..."
    @just _update-config "project_type" "Full Academic Project (analysis + writeup)"
    @just _expand-academic-writing
    @just _expand-full-pipeline
    @just _expand-ci-cd
    @just _expand-publication-tools
    @just _update-config "data_versioning" "true"
    @just _update-config "experiment_tracking" "MLflow"
    @echo "✅ Upgraded to Full Academic Project! Run 'copier update' to apply changes."

# === UTILITY FUNCTIONS ===

# Update a configuration value in copier answers
_update-config key value:
    #!/usr/bin/env bash
    if [ ! -f "{{copier_answers_file}}" ]; then
        echo "❌ No copier answers file found."
        exit 1
    fi
    
    # Check if key exists and update it, or add it if it doesn't exist
    if grep -q "^{{key}}:" "{{copier_answers_file}}"; then
        # Key exists, update it
        sed -i.bak "s/^{{key}}:.*/{{key}}: {{value}}/" "{{copier_answers_file}}"
    else
        # Key doesn't exist, add it
        echo "{{key}}: {{value}}" >> "{{copier_answers_file}}"
    fi
    rm -f "{{copier_answers_file}}.bak"
    echo "  Updated {{key}} = {{value}}"

# Apply changes by running copier update
apply-changes:
    @echo "🔄 Applying template changes..."
    @if command -v copier >/dev/null 2>&1; then \
        copier update; \
    else \
        echo "❌ Copier not found. Install with: pip install copier"; \
        exit 1; \
    fi
    @echo "✅ Template updated successfully!"

# === GUIDED EXPANSION WORKFLOWS ===

# Interactive expansion wizard
wizard:
    #!/usr/bin/env bash
    echo "🧙 Project Expansion Wizard"
    echo "==========================="
    echo ""
    echo "This wizard will help you add components to your project."
    echo ""
    
    read -p "Add data versioning with DVC? (y/n): " add_dvc
    if [[ $add_dvc =~ ^[Yy]$ ]]; then
        just _expand-data-versioning
    fi
    
    read -p "Add experiment tracking? (y/n): " add_tracking
    if [[ $add_tracking =~ ^[Yy]$ ]]; then
        echo "Choose platform: 1) MLflow  2) Weights & Biases  3) Neptune"
        read -p "Selection (1-3): " platform
        case $platform in
            1) just _expand-experiment-tracking "MLflow" ;;
            2) just _expand-experiment-tracking "Weights & Biases" ;;
            3) just _expand-experiment-tracking "Neptune" ;;
        esac
    fi
    
    read -p "Add academic writing capabilities? (y/n): " add_writing
    if [[ $add_writing =~ ^[Yy]$ ]]; then
        just _expand-academic-writing
    fi
    
    read -p "Add CI/CD and quality tools? (y/n): " add_cicd
    if [[ $add_cicd =~ ^[Yy]$ ]]; then
        just _expand-ci-cd
    fi
    
    echo ""
    echo "🎉 Expansion complete! Run 'just apply-changes' to update your project."

# Show expansion recommendations based on current config
recommend:
    #!/usr/bin/env bash
    echo "💡 Recommended Next Steps:"
    echo ""
    
    if [ ! -f "{{copier_answers_file}}" ]; then
        echo "❌ No copier answers file found."
        exit 1
    fi
    
    # Check current state and make recommendations
    if ! grep -q "data_versioning: true" "{{copier_answers_file}}"; then
        echo "  📊 Consider adding data versioning: just expand data-versioning"
    fi
    
    if grep -q "experiment_tracking: None" "{{copier_answers_file}}"; then
        echo "  🧪 Consider adding experiment tracking: just expand experiment-tracking"
    fi
    
    if ! grep -q "github_actions: true" "{{copier_answers_file}}"; then
        echo "  ⚙️ Consider adding CI/CD: just expand ci-cd"
    fi
    
    if grep -q "programming_language: Python" "{{copier_answers_file}}" && ! grep -q "programming_language: Both" "{{copier_answers_file}}"; then
        echo "  🌍 Consider adding R support: just expand add-r"
    fi
    
    echo ""
    echo "  🎓 Or upgrade to full academic project: just upgrade-to-full"

# === RESET AND ROLLBACK ===

# Backup current configuration
backup-config:
    @cp "{{copier_answers_file}}" "{{copier_answers_file}}.backup"
    @echo "💾 Configuration backed up to {{copier_answers_file}}.backup"

# Restore from backup
restore-config:
    @if [ -f "{{copier_answers_file}}.backup" ]; then \
        cp "{{copier_answers_file}}.backup" "{{copier_answers_file}}"; \
        echo "🔄 Configuration restored from backup"; \
    else \
        echo "❌ No backup file found"; \
    fi
