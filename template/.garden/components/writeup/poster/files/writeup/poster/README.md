# Academic Conference Poster System

Streamlined system for creating academic conference posters with automated workflows and chronological organization. Optimized for rapid poster development and submission deadlines.

## Directory Structure

```
poster/
├── README.md                 # This documentation
├── justfile                  # Poster automation commands
├── templates/                # Poster templates
│   ├── standard/             # Standard academic poster layout
│   ├── landscape/            # Landscape format posters
│   └── specialized/          # Field-specific templates (bio, cs, physics, etc.)
├── conferences/              # Conference submissions (YYYY-MM-VENUE format)
│   ├── 2025-05-neurips/      # NeurIPS May 2025
│   ├── 2025-07-icml/         # ICML July 2025
│   ├── 2025-12-aaai/         # AAAI December 2025
│   └── archived/             # Archived completed posters
├── assets/                   # Shared poster assets
│   ├── figures/              # Research figures and plots
│   ├── logos/                # Institution and venue logos
│   ├── data/                 # Small datasets for plots
│   └── references/           # BibTeX files
└── _output/                  # Generated posters
    ├── drafts/               # Work-in-progress versions
    ├── reviews/              # Versions for internal review
    └── final/                # Submission-ready posters
```

## Chronological Organization

Conferences are organized using the **YYYY-MM-VENUE** format:
- `2025-05-neurips` - NeurIPS 2025 (May submission deadline)
- `2025-07-icml` - ICML 2025 (July submission deadline)
- `2025-12-aaai` - AAAI 2025 (December submission deadline)

This provides chronological sorting while maintaining venue context.

## Automation with Just

The `justfile` provides a comprehensive set of commands for managing your posters. Run from the `poster/` directory.

## Quick Start

1. **Initialize the system** (first time only):
   ```bash
   just init
   ```

2. **Create a conference poster** (specify year, month, venue):
   ```bash
   just create neurips 2025 05 standard
   ```

3. **Create with automatic date** (uses current year/month):
   ```bash
   just create-auto neurips standard
   ```

4. **Create for current year** (specify month):
   ```bash
   just create-now neurips standard  # Uses current year, July
   ```

5. **Edit your poster**: 
   ```bash
   # Edit: conferences/2025-05-neurips/neurips_poster.qmd
   ```

6. **Render and review**:
   ```bash
   just render neurips        # Creates draft
   just render-review neurips  # Creates review version
   just finalize neurips      # Creates final submission
   ```

## Example Workflow

Creating a poster for NeurIPS 2025 (May deadline):

```bash
# Create poster with specific date
just create neurips 2025 05 standard

# Or create with automatic date detection
just create-auto neurips standard

# Add your research content to:
# conferences/2025-05-neurips/neurips_poster.qmd

# Add figures to assets/figures/
just add-figure "my_results.png" "/path/to/my_results.png"

# Render for review
just render-review neurips

# Make final submission
just finalize neurips
```

## Available Commands

### Creating Posters
- `just create <venue> <year> <month> [template]` - Create poster with specific date
- `just create-auto <venue> [template]` - Create with current date
- `just create-now <venue> [template]` - Create with current year, July

### Rendering
- `just render <venue>` - Render draft version
- `just render-review <venue>` - Render review version  
- `just finalize <venue>` - Create final submission version

### Management
- `just list` - List all posters
- `just list-year <year>` - List posters for specific year
- `just list-upcoming` - List upcoming posters (current year+)
- `just info <venue>` - Show poster information
- `just archive <venue>` - Archive completed poster

# Create a professional poster
just create-professional business-poster
```

### Rendering Posters

```bash
# Render an academic poster to PDF
just render-poster academic research-poster format=pdf

# Render a conference poster to HTML
just render-poster conference conference-poster format=html

# Render to the 'final' output folder
just render-poster professional business-poster version=final
```

### Other Commands

```bash
# List all available commands
just

# List all posters
just list-posters

# List available templates
just list-templates

# Clone a poster to create a new version
just clone-poster original-poster new-poster academic

# Initialize a new poster project
just poster-init

# Clean draft output directories
just clean

# Clean all output directories
just clean-all

# Export a poster as PDF with timestamp
just export-pdf academic research-poster

# Create a differently sized version of an existing poster
just resize-poster academic research-poster size=42x30
```

## Customization

- **Logo**: Replace the default logo in `styles/logo.png` with your institution or organization logo.
- **Colors**: Adjust header, footer, and section title colors in the poster YAML frontmatter.
- **Fonts**: Customize fonts, sizes, and weights in the poster YAML frontmatter.
- **Columns**: Change the number of columns in the poster layout as needed.

## Workflow Integration

The poster system is designed to integrate with your existing workflow:

- **Version Control**: Each poster is stored in its own directory for easier version control.
- **Multiple Sizes**: Create different sized versions of the same poster for different venues.
- **Output Management**: Separate output directories for draft and final versions.
- **Templating**: Consistent structure and branding across all posters.

This system provides a robust and flexible way to manage your posters, ensuring consistency and efficiency in your poster creation workflow.
