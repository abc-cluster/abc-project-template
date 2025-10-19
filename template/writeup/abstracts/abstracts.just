# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Academic Abstract Submission System
# Streamlined automation for academic abstract creation and management

# Set shell
set shell := ["zsh", "-c"]

# Variables
abstracts_dir := justfile_directory()
templates_dir := abstracts_dir + "/templates"
submissions_dir := abstracts_dir + "/submissions"
versions_dir := abstracts_dir + "/versions"

# Default recipe - show available commands
default:
    @echo "Academic Abstract Submission System"
    @echo "==================================="
    @just --list

# === Setup and Initialization ===

# Initialize complete abstract system
init: create-dirs
    @echo "✅ Abstract system initialized successfully!"

# Create directory structure
create-dirs:
    #!/usr/bin/env zsh
    mkdir -p submissions/{conference,journal,symposium}
    mkdir -p versions/{drafts,reviews,final}
    echo "📁 Directory structure created"

# === Abstract Creation ===

# Create new conference abstract with YYYY-MM-VENUE format
create-conference venue year month:
    #!/usr/bin/env zsh
    submission_dir="submissions/conference/{{year}}-{{month}}-{{venue}}"
    mkdir -p "$submission_dir"
    
    # Copy template and customize
    cp "templates/conference_abstract.qmd" "$submission_dir/{{venue}}_abstract.qmd"
    
    echo "✅ Created conference abstract for {{venue}} ({{year}}-{{month}})"
    echo "📝 Edit: $submission_dir/{{venue}}_abstract.qmd"

# Create journal abstract
create-journal venue year month:
    #!/usr/bin/env zsh
    submission_dir="submissions/journal/{{year}}-{{month}}-{{venue}}"
    mkdir -p "$submission_dir"
    
    # Copy template and customize
    cp "templates/journal_abstract.qmd" "$submission_dir/{{venue}}_abstract.qmd"
    
    echo "✅ Created journal abstract for {{venue}} ({{year}}-{{month}})"
    echo "📝 Edit: $submission_dir/{{venue}}_abstract.qmd"

# Create symposium abstract
create-symposium venue year month:
    #!/usr/bin/env zsh
    submission_dir="submissions/symposium/{{year}}-{{month}}-{{venue}}"
    mkdir -p "$submission_dir"
    
    # Copy template and customize
    cp "templates/symposium_abstract.qmd" "$submission_dir/{{venue}}_abstract.qmd"
    
    echo "✅ Created symposium abstract for {{venue}} ({{year}}-{{month}})"
    echo "📝 Edit: $submission_dir/{{venue}}_abstract.qmd"

# Create with automatic date detection
create-auto-conference venue:
    #!/usr/bin/env zsh
    current_year=$(date +"%Y")
    current_month=$(date +"%m")
    submission_dir="submissions/conference/${current_year}-${current_month}-{{venue}}"
    mkdir -p "$submission_dir"
    
    cp "templates/conference_abstract.qmd" "$submission_dir/{{venue}}_abstract.qmd"
    
    echo "✅ Created conference abstract for {{venue}} (${current_year}-${current_month})"
    echo "📝 Edit: $submission_dir/{{venue}}_abstract.qmd"

# Create auto journal
create-auto-journal venue:
    #!/usr/bin/env zsh
    current_year=$(date +"%Y")
    current_month=$(date +"%m")
    submission_dir="submissions/journal/${current_year}-${current_month}-{{venue}}"
    mkdir -p "$submission_dir"
    
    cp "templates/journal_abstract.qmd" "$submission_dir/{{venue}}_abstract.qmd"
    
    echo "✅ Created journal abstract for {{venue}} (${current_year}-${current_month})"
    echo "📝 Edit: $submission_dir/{{venue}}_abstract.qmd"

# Create auto symposium
create-auto-symposium venue:
    #!/usr/bin/env zsh
    current_year=$(date +"%Y")
    current_month=$(date +"%m")
    submission_dir="submissions/symposium/${current_year}-${current_month}-{{venue}}"
    mkdir -p "$submission_dir"
    
    cp "templates/symposium_abstract.qmd" "$submission_dir/{{venue}}_abstract.qmd"
    
    echo "✅ Created symposium abstract for {{venue}} (${current_year}-${current_month})"
    echo "📝 Edit: $submission_dir/{{venue}}_abstract.qmd"

# === Rendering and Output ===

# Render abstract to draft (finds by venue name)
render venue format="pdf":
    #!/usr/bin/env zsh
    # Find abstract file by venue name in submissions
    abstract_file=$(find submissions -name "{{venue}}_abstract.qmd" | head -1)
    if [[ -f "$abstract_file" ]]; then
        venue_dir=$(basename $(dirname "$abstract_file"))
        mkdir -p "versions/drafts/$venue_dir"
        quarto render "$abstract_file" --to {{format}} --output-dir "versions/drafts/$venue_dir"
        echo "✅ Rendered {{venue}} abstract to versions/drafts/$venue_dir/"
    else
        echo "❌ Abstract file not found for venue: {{venue}}"
        echo "Available abstracts:"
        find submissions -name "*_abstract.qmd" | sed 's|.*/||' | sed 's|_abstract.qmd||'
    fi

# Create final submission version
finalize venue format="pdf":
    #!/usr/bin/env zsh
    abstract_file=$(find submissions -name "{{venue}}_abstract.qmd" | head -1)
    if [[ -f "$abstract_file" ]]; then
        venue_dir=$(basename $(dirname "$abstract_file"))
        timestamp=$(date +"%Y%m%d_%H%M%S")
        mkdir -p "versions/final/$venue_dir"
        quarto render "$abstract_file" --to {{format}} --output-dir "versions/final/$venue_dir"
        
        # Create timestamped copy
        cp "versions/final/$venue_dir/{{venue}}_abstract.{{format}}" \
           "versions/final/$venue_dir/{{venue}}_final_${timestamp}.{{format}}"
        
        echo "✅ Final version created: versions/final/$venue_dir/"
    else
        echo "❌ Abstract file not found for venue: {{venue}}"
    fi

# === Listing and Information ===

# List all abstracts
list:
    #!/usr/bin/env zsh
    echo "Abstract Submissions:"
    echo "===================="
    find submissions -name "*_abstract.qmd" -exec echo "📄 {}" \; | sort

# List by submission type
list-conference:
    #!/usr/bin/env zsh
    echo "Conference Abstracts:"
    echo "===================="
    find submissions/conference -name "*_abstract.qmd" -exec echo "📄 {}" \; | sort

list-journal:
    #!/usr/bin/env zsh
    echo "Journal Abstracts:"
    echo "=================="
    find submissions/journal -name "*_abstract.qmd" -exec echo "📄 {}" \; | sort

list-symposium:
    #!/usr/bin/env zsh
    echo "Symposium Abstracts:"
    echo "==================="
    find submissions/symposium -name "*_abstract.qmd" -exec echo "📄 {}" \; | sort

# List by year
list-year year:
    #!/usr/bin/env zsh
    echo "Abstracts for {{year}}:"
    echo "======================"
    find submissions -name "{{year}}-*" -type d | sort

# List upcoming (current year and later)
list-upcoming:
    #!/usr/bin/env zsh
    current_year=$(date +"%Y")
    echo "Upcoming Abstracts (${current_year}+):"
    echo "======================================"
    find submissions -name "${current_year}-*" -o -name "$((current_year + 1))-*" | sort

# Show abstract status and info
status venue:
    #!/usr/bin/env zsh
    abstract_file=$(find submissions -name "{{venue}}_abstract.qmd" | head -1)
    if [[ -f "$abstract_file" ]]; then
        venue_dir=$(basename $(dirname "$abstract_file"))
        submission_type=$(basename $(dirname $(dirname "$abstract_file")))
        
        echo "Abstract: {{venue}}"
        echo "Type: $submission_type"
        echo "Submission: $venue_dir"
        echo "File: $abstract_file"
        echo "Size: $(wc -l < "$abstract_file") lines"
        echo "Word count: $(wc -w < "$abstract_file") words"
        echo "Modified: $(stat -f %Sm "$abstract_file")"
        
        # Check for rendered versions
        if [[ -d "versions/drafts/$venue_dir" ]]; then
            echo "Draft: ✅ Available in versions/drafts/$venue_dir/"
        fi
        if [[ -d "versions/final/$venue_dir" ]]; then
            echo "Final: ✅ Available in versions/final/$venue_dir/"
        fi
    else
        echo "❌ Abstract not found: {{venue}}"
    fi
            dest_dir="{{symposium_dir}}/accepted/"
            ;;
        *)
            echo "Error: Invalid abstract type. Use 'conference', 'journal', or 'symposium'"
            exit 1
            ;;
    esac
    
    if [ -d "$source_dir" ]; then
        mv "$source_dir" "$dest_dir"
        echo "Moved {{abstract_name}} to accepted {{abstract_type}} abstracts"
    else
        echo "Error: {{abstract_name}} not found in submitted {{abstract_type}} abstracts"
    fi

# Move abstract to presented status
present abstract_type abstract_name:
    #!/usr/bin/env bash
    case "{{abstract_type}}" in
        "conference")
            source_dir="{{conference_dir}}/accepted/{{abstract_name}}"
            dest_dir="{{conference_dir}}/presented/"
            ;;
        "journal")
            source_dir="{{journal_dir}}/accepted/{{abstract_name}}"
            dest_dir="{{journal_dir}}/presented/"
            ;;
        "symposium")
            source_dir="{{symposium_dir}}/accepted/{{abstract_name}}"
            dest_dir="{{symposium_dir}}/presented/"
            ;;
        *)
            echo "Error: Invalid abstract type. Use 'conference', 'journal', or 'symposium'"
            exit 1
            ;;
    esac
    
    if [ -d "$source_dir" ]; then
        mv "$source_dir" "$dest_dir"
        echo "Moved {{abstract_name}} to presented {{abstract_type}} abstracts"
    else
        echo "Error: {{abstract_name}} not found in accepted {{abstract_type}} abstracts"
    fi

# Compile abstract to PDF
compile abstract_type abstract_name:
    #!/usr/bin/env bash
    # Try to find the abstract in any status folder
    abstract_found=false
    for status in submitted accepted presented; do
        case "{{abstract_type}}" in
            "conference")
                abstract_dir="{{conference_dir}}/$status/{{abstract_name}}"
                ;;
            "journal")
                abstract_dir="{{journal_dir}}/$status/{{abstract_name}}"
                ;;
            "symposium")
                abstract_dir="{{symposium_dir}}/$status/{{abstract_name}}"
                ;;
        esac
        
        if [ -d "$abstract_dir" ]; then
            cd "$abstract_dir"
            for qmd_file in *.qmd; do
                if [ -f "$qmd_file" ]; then
                    echo "Compiling $qmd_file..."
                    quarto render "$qmd_file"
                    abstract_found=true
                fi
            done
            break
        fi
    done
    
    if [ "$abstract_found" = false ]; then
        echo "Error: {{abstract_name}} not found in {{abstract_type}} abstracts"
    fi

# Check upcoming deadlines
deadlines:
    @echo "Checking upcoming abstract deadlines..."
    @grep -E "Due:|Deadline:" "{{tracking_dir}}/deadlines.md" | head -10

# Show abstract statistics
stats:
    #!/usr/bin/env bash
    echo "Abstract Submission Statistics:"
    echo "==============================="
    
    # Count abstracts by type and status
    for type in conference journal symposium; do
        echo ""
        echo "$type abstracts:"
        case "$type" in
            "conference") base_dir="{{conference_dir}}" ;;
            "journal") base_dir="{{journal_dir}}" ;;
            "symposium") base_dir="{{symposium_dir}}" ;;
        esac
        
        submitted=$(find "$base_dir/submitted" -maxdepth 1 -type d ! -path "*/submitted" | wc -l)
        accepted=$(find "$base_dir/accepted" -maxdepth 1 -type d ! -path "*/accepted" | wc -l)
        presented=$(find "$base_dir/presented" -maxdepth 1 -type d ! -path "*/presented" | wc -l)
        
        echo "  Submitted: $submitted"
        echo "  Accepted: $accepted"
        echo "  Presented: $presented"
        
        if [ $submitted -gt 0 ] && [ $accepted -gt 0 ]; then
            acceptance_rate=$(echo "scale=1; $accepted * 100 / $submitted" | bc -l)
            echo "  Acceptance rate: $acceptance_rate%"
        fi
    done

# Word count for abstract
wordcount abstract_type abstract_name:
    #!/usr/bin/env bash
    # Try to find the abstract in any status folder
    for status in submitted accepted presented; do
        case "{{abstract_type}}" in
            "conference")
                abstract_dir="{{conference_dir}}/$status/{{abstract_name}}"
                ;;
            "journal")
                abstract_dir="{{journal_dir}}/$status/{{abstract_name}}"
                ;;
            "symposium")
                abstract_dir="{{symposium_dir}}/$status/{{abstract_name}}"
                ;;
        esac
        
        if [ -d "$abstract_dir" ]; then
            cd "$abstract_dir"
            for qmd_file in *.qmd; do
                if [ -f "$qmd_file" ]; then
                    echo "Word count for $qmd_file:"
                    # Count words in abstract section only
                    sed -n '/^# Abstract/,/^---/p' "$qmd_file" | wc -w
                fi
            done
            exit 0
        fi
    done
    echo "Error: {{abstract_name}} not found in {{abstract_type}} abstracts"

# Update tracking files
update-tracking abstract_type abstract_name status:
    #!/usr/bin/env bash
    echo "Updating tracking for {{abstract_name}}..."
    # This is a placeholder for more sophisticated tracking updates
    # Could integrate with calendar systems, notification systems, etc.
    echo "Abstract: {{abstract_name}}"
    echo "Type: {{abstract_type}}"  
    echo "Status: {{status}}"
    echo "Date: $(date)"
    echo ""

# Clean up empty directories
clean:
    @echo "Cleaning up empty directories..."
    @find "{{abstracts_dir}}" -type d -empty -not -path "*/.*" -delete
    @echo "Done"

# Initialize abstracts workspace
init:
    #!/usr/bin/env bash
    echo "Initializing abstracts workspace..."
    
    # Ensure all directories exist
    mkdir -p "{{conference_dir}}"/{submitted,accepted,presented}
    mkdir -p "{{journal_dir}}"/{submitted,accepted,presented}
    mkdir -p "{{symposium_dir}}"/{submitted,accepted,presented}
    mkdir -p "{{tracking_dir}}"
    
    echo "Abstracts workspace initialized!"
    echo "Use 'just new-conference <name> <conference>' to create your first conference abstract"
    echo "Use 'just new-journal <name> <journal>' to create your first journal abstract"
    echo "Use 'just new-symposium <name> <event>' to create your first symposium abstract"

# === Word Count and Analysis ===

# Check word count for an abstract
wordcount venue:
    #!/usr/bin/env zsh
    abstract_file=$(find submissions -name "{{venue}}_abstract.qmd" | head -1)
    if [[ -f "$abstract_file" ]]; then
        word_count=$(wc -w < "$abstract_file")
        echo "Word count for {{venue}}: $word_count words"
        
        # Provide guidance based on submission type
        submission_type=$(basename $(dirname $(dirname "$abstract_file")))
        case "$submission_type" in
            "conference")
                echo "Conference abstracts typically: 150-300 words"
                ;;
            "journal")
                echo "Journal abstracts typically: 200-350 words"
                ;;
            "symposium")
                echo "Symposium abstracts typically: 100-250 words"
                ;;
        esac
    else
        echo "❌ Abstract file not found for venue: {{venue}}"
    fi

# === Archive Management ===

# Archive completed abstract
archive venue:
    #!/usr/bin/env zsh
    timestamp=$(date +"%Y%m%d")
    abstract_file=$(find submissions -name "{{venue}}_abstract.qmd" | head -1)
    if [[ -f "$abstract_file" ]]; then
        abstract_dir=$(dirname "$abstract_file")
        venue_dir=$(basename "$abstract_dir")
        submission_type=$(basename $(dirname "$abstract_dir"))
        mkdir -p "submissions/archived"
        tar -czf "submissions/archived/${submission_type}_${venue_dir}_${timestamp}.tar.gz" "$abstract_dir"
        echo "📦 Archived: submissions/archived/${submission_type}_${venue_dir}_${timestamp}.tar.gz"
    else
        echo "❌ Abstract not found: {{venue}}"
    fi

# === Cleanup ===

# Clean draft versions
clean-drafts:
    rm -rf versions/drafts/*
    echo "🧹 Cleaned draft versions"

# Clean all versions
clean-all:
    rm -rf versions/{drafts,reviews,final}/*
    echo "🧹 Cleaned all versions"

# === Quick Commands ===

# Quick render of current working abstract (assumes you're in a submission folder)
quick-render:
    #!/usr/bin/env zsh
    if [[ -f *_abstract.qmd ]]; then
        abstract_file=$(ls *_abstract.qmd | head -1)
        venue_name=$(basename "$abstract_file" _abstract.qmd)
        venue_dir=$(basename "$PWD")
        mkdir -p "../../../versions/drafts/quick"
        quarto render "$abstract_file" --to pdf --output-dir "../../../versions/drafts/quick"
        echo "✅ Quick render complete: versions/drafts/quick/"
    else
        echo "❌ No abstract file found in current directory"
    fi
