# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Academic Presentation System
# Streamlined automation for academic presentation creation and management

# Set shell
set shell := ["zsh", "-c"]

# Variables
presentation_dir := justfile_directory()
templates_dir := presentation_dir + "/templates"
presentations_dir := presentation_dir + "/presentations"
assets_dir := presentation_dir + "/assets"
output_dir := presentation_dir + "/_output"

# Default recipe - show available commands
default:
    @echo "Academic Presentation System"
    @echo "============================"
    @just --list

# === Setup and Initialization ===

# Initialize complete presentation system
init: create-dirs
    @echo "✅ Presentation system initialized successfully!"

# Create directory structure
create-dirs:
    #!/usr/bin/env zsh
    mkdir -p presentations/{conferences,workshops,meetings,seminars}
    mkdir -p assets/{figures,tables,graphics}
    mkdir -p _output/{html,pdf,pptx}/{draft,final}
    echo "📁 Directory structure created"

# === Presentation Creation ===

# Create new conference presentation with YYYY-MM-VENUE format
create-conference venue year month template="academic":
    #!/usr/bin/env zsh
    presentation_dir="presentations/conferences/{{year}}-{{month}}-{{venue}}"
    mkdir -p "$presentation_dir"

    # Select template
    template_file="templates/{{template}}/{{template}}_template.qmd"
    if [[ ! -f "$template_file" ]]; then
        template_file="templates/academic/academic_template.qmd"
    fi

    # Copy template and customize
    cp "$template_file" "$presentation_dir/{{venue}}_presentation.qmd"

    echo "✅ Created conference presentation for {{venue}} ({{year}}-{{month}})"
    echo "📝 Edit: $presentation_dir/{{venue}}_presentation.qmd"

# Create workshop presentation
create-workshop event year month template="workshop":
    #!/usr/bin/env zsh
    presentation_dir="presentations/workshops/{{year}}-{{month}}-{{event}}"
    mkdir -p "$presentation_dir"

    template_file="templates/{{template}}/{{template}}_template.qmd"
    if [[ ! -f "$template_file" ]]; then
        template_file="templates/workshop/workshop_template.qmd"
    fi

    cp "$template_file" "$presentation_dir/{{event}}_presentation.qmd"

    echo "✅ Created workshop presentation for {{event}} ({{year}}-{{month}})"
    echo "📝 Edit: $presentation_dir/{{event}}_presentation.qmd"

# Create meeting presentation
create-meeting topic year month template="meeting":
    #!/usr/bin/env zsh
    presentation_dir="presentations/meetings/{{year}}-{{month}}-{{topic}}"
    mkdir -p "$presentation_dir"

    template_file="templates/{{template}}/meeting-progress-summary.qmd"
    if [[ ! -f "$template_file" ]]; then
        template_file="templates/academic/academic_template.qmd"
    fi

    cp "$template_file" "$presentation_dir/{{topic}}_presentation.qmd"

    echo "✅ Created meeting presentation for {{topic}} ({{year}}-{{month}})"
    echo "📝 Edit: $presentation_dir/{{topic}}_presentation.qmd"

# Create seminar presentation
create-seminar venue year month template="academic":
    #!/usr/bin/env zsh
    presentation_dir="presentations/seminars/{{year}}-{{month}}-{{venue}}"
    mkdir -p "$presentation_dir"

    template_file="templates/{{template}}/{{template}}_template.qmd"
    if [[ ! -f "$template_file" ]]; then
        template_file="templates/academic/academic_template.qmd"
    fi

    cp "$template_file" "$presentation_dir/{{venue}}_presentation.qmd"

    echo "✅ Created seminar presentation for {{venue}} ({{year}}-{{month}})"
    echo "📝 Edit: $presentation_dir/{{venue}}_presentation.qmd"

# Create with automatic date detection
create-auto-conference venue template="academic":
    #!/usr/bin/env zsh
    current_year=$(date +"%Y")
    current_month=$(date +"%m")
    presentation_dir="presentations/conferences/${current_year}-${current_month}-{{venue}}"
    mkdir -p "$presentation_dir"

    template_file="templates/{{template}}/{{template}}_template.qmd"
    if [[ ! -f "$template_file" ]]; then
        template_file="templates/academic/academic_template.qmd"
    fi

    cp "$template_file" "$presentation_dir/{{venue}}_presentation.qmd"

    echo "✅ Created conference presentation for {{venue}} (${current_year}-${current_month})"
    echo "📝 Edit: $presentation_dir/{{venue}}_presentation.qmd"

# Create auto workshop
create-auto-workshop event template="workshop":
    #!/usr/bin/env zsh
    current_year=$(date +"%Y")
    current_month=$(date +"%m")
    presentation_dir="presentations/workshops/${current_year}-${current_month}-{{event}}"
    mkdir -p "$presentation_dir"

    template_file="templates/{{template}}/{{template}}_template.qmd"
    if [[ ! -f "$template_file" ]]; then
        template_file="templates/workshop/workshop_template.qmd"
    fi

    cp "$template_file" "$presentation_dir/{{event}}_presentation.qmd"

    echo "✅ Created workshop presentation for {{event}} (${current_year}-${current_month})"
    echo "📝 Edit: $presentation_dir/{{event}}_presentation.qmd"

# === Rendering Presentations ===

render-presentation name format="revealjs" version="draft": # Render a specific presentation
    #!/usr/bin/env bash
    if [ -f "presentations/{{name}}/{{name}}.qmd" ]; then
        mkdir -p "_output/{{format}}/{{version}}/{{name}}"
        quarto render "presentations/{{name}}/{{name}}.qmd" --to {{format}} --output-dir "_output/{{format}}/{{version}}/{{name}}"
        echo "Rendered {{name}} to _output/{{format}}/{{version}}/{{name}}"
    else
        echo "Error: Presentation {{name}} not found"
    fi

render-poster name format="pdf" version="draft": # Render a specific poster
    #!/usr/bin/env bash
    if [ -f "presentations/posters/{{name}}/{{name}}.qmd" ]; then
        mkdir -p "_output/posters/{{format}}/{{version}}/{{name}}"
        quarto render "presentations/posters/{{name}}/{{name}}.qmd" --to {{format}} --output-dir "_output/posters/{{format}}/{{version}}/{{name}}"
        echo "Rendered poster {{name}} to _output/posters/{{format}}/{{version}}/{{name}}"
    else
        echo "Error: Poster {{name}} not found"
    fi

# === Utility Functions ===

list-presentations: # List all presentations
    @echo "Available presentations:"
    @find presentations -name "*.qmd" | sort

list-posters: # List all posters
    @echo "Available posters:"
    @find presentations/posters -name "*.qmd" | sort

clone-presentation source target: # Clone a presentation to create a new version
    #!/usr/bin/env bash
    if [ -f "presentations/{{source}}/{{source}}.qmd" ]; then
        mkdir -p "presentations/{{target}}"
        cp -r "presentations/{{source}}/"* "presentations/{{target}}/"
        if [ -f "presentations/{{target}}/{{source}}.qmd" ]; then
            mv "presentations/{{target}}/{{source}}.qmd" "presentations/{{target}}/{{target}}.qmd"
        fi
        echo "Cloned {{source}} to {{target}}"
    else
        echo "Error: Source presentation {{source}} not found"
    fi
