import "manuscript/manuscript.just"


# === Enhanced Multi-Output Tasks ===

# Clean all generated files
clean-all:
    rm -rf */_book
    rm -rf */_site
    rm -rf */*_files
    rm -rf */_output
    rm -rf outputs/*/_book
    rm -rf outputs/*/_site
    rm -rf outputs/*/*_files
    rm -rf outputs/*/_output

# Render all manuscript variants to PDF
render-manuscripts:
    @echo "Rendering all manuscript variants..."
    quarto render outputs/manuscripts/*/index.qmd --to pdf

# Render all book formats to PDF
render-books:
    @echo "Rendering all book formats..."
    quarto render outputs/books/*/index.qmd --to pdf

# Render all report types to PDF
render-reports:
    @echo "Rendering all report types..."
    quarto render outputs/reports/*/index.qmd --to pdf

# Render all presentations
render-presentations:
    @echo "Rendering all presentations..."
    quarto render outputs/presentations/*/index.qmd --to pdf

# Render all posters
render-posters:
    @echo "Rendering all posters..."
    quarto render outputs/posters/*/index.qmd --to pdf

# Render all digital outputs
render-digital:
    @echo "Rendering all digital outputs..."
    quarto render outputs/digital/*/index.qmd --format all

# Multi-format batch rendering
batch-render-all:
    @just render-manuscripts
    @just render-books
    @just render-reports
    @just render-presentations
    @just render-posters
    @just render-digital

# === Poster Tasks ===
[working-directory: 'poster']
poster-new name="new-poster" template="default": # Create a new poster
    @mkdir -p {{name}}
    quarto create presentation --template {{template}} {{name}}/index.qmd

poster-render name: # Render poster to PDF
    quarto render {{name}}/index.qmd --to pdf

poster-preview name: # Preview poster with live reload
    quarto preview {{name}}/index.qmd

poster-clean name: # Clean poster generated files
    rm -rf {{name}}/_book
    rm -rf {{name}}/index_files

# === Presentation Tasks ===
[working-directory: 'presentation']
presentation-new name="new-presentation" template="revealjs": # Create new presentation
    @mkdir -p {{name}}
    quarto create presentation --template {{template}} {{name}}/index.qmd

presentation-render name format="revealjs": # Render presentation
    quarto render {{name}}/index.qmd --to {{format}}

presentation-preview name: # Preview presentation with live reload
    quarto preview {{name}}/index.qmd

presentation-clean name: # Clean presentation generated files
    rm -rf {{name}}/_book
    rm -rf {{name}}/index_files

presentation-pdf name: # Export presentation to PDF
    quarto render {{name}}/index.qmd --to pdf

presentation-pptx name: # Export presentation to PowerPoint
    quarto render {{name}}/index.qmd --to pptx

# === Report Tasks ===
[working-directory: 'report']
report-new name="new-report" template="default": # Create new report
    @mkdir -p {{name}}
    quarto create document --template {{template}} {{name}}/index.qmd

report-render name: # Render report
    quarto render {{name}}/index.qmd

report-preview name: # Preview report with live reload
    quarto preview {{name}}/index.qmd

report-clean name: # Clean report generated files
    rm -rf {{name}}/_book
    rm -rf {{name}}/index_files

report-pdf name: # Export report to PDF
    quarto render {{name}}/index.qmd --to pdf

report-word name: # Export report to Word
    quarto render {{name}}/index.qmd --to docx

report-html name: # Export report to HTML
    quarto render {{name}}/index.qmd --to html

# === Asset Management ===
[working-directory: 'assets-figtables']
figures-sync: # Sync figures with version control
    git add figures/
    git commit -m "Update figures" || true

tables-sync: # Sync tables with version control
    git add tables/
    git commit -m "Update tables" || true

# === Bibliography Management ===
[working-directory: '..']
bib-update: # Update bibliography
    quarto tools citeproc

bib-check: # Check bibliography for issues
    quarto tools citeproc --check

# === Export and Archive ===
# Export all documents to PDF
export-all:
    quarto render */index.qmd --to pdf
    quarto render outputs/*/index.qmd --to pdf

# Create backup of all documents
archive-all:
    tar -czf writeup-backup-$(date +%Y%m%d).tar.gz poster/ presentation/ report/ manuscript/
    tar -czf outputs-backup-$(date +%Y%m%d).tar.gz outputs/


# === Multi-output Management ===

# Cross-output content synchronization
sync-content:
    @echo "Synchronizing shared content across formats..."
    cp shared-content/core-content/* outputs/manuscripts/
    cp shared-content/_variables.yml outputs/manuscripts/
    cp shared-content/core-content/* outputs/books/
    cp shared-content/_variables.yml outputs/books/
    cp shared-content/core-content/* outputs/reports/
    cp shared-content/_variables.yml outputs/reports/
    cp shared-content/core-content/* outputs/presentations/
    cp shared-content/_variables.yml outputs/presentations/
    cp shared-content/core-content/* outputs/posters/
    cp shared-content/_variables.yml outputs/posters/

# Cross-reference validation
validate-cross-references:
    @echo "Validating cross-references in documents..."
    quarto check references outputs/*/index.qmd

# Package outputs for distribution
package-for-distribution:
    @echo "Packaging outputs for distribution..."
    tar -czf distribution-package-$(date +%Y%m%d).tar.gz outputs/
