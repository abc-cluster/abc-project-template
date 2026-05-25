# Academic Presentation System

Streamlined system for creating academic presentations with automated workflows and chronological organization. Optimized for rapid presentation development and event preparation.

## Directory Structure

```
presentation/
├── README.md                 # This documentation
├── justfile                  # Presentation automation commands
├── _quarto.yml               # Global Quarto configuration
├── _brand.yml                # Branding configuration
├── templates/                # Presentation templates
│   ├── academic/             # Academic conference presentations
│   ├── corporate/            # Business/industry presentations
│   ├── workshop/             # Workshop and training materials
│   ├── meeting/              # Meeting and progress reports
│   └── poster/               # Poster presentations
├── presentations/            # Chronologically organized presentations
│   ├── conferences/          # Conference presentations (YYYY-MM-VENUE)
│   │   ├── 2025-05-neurips/       # NeurIPS May 2025
│   │   ├── 2025-07-icml/          # ICML July 2025
│   │   └── 2025-12-aaai/          # AAAI December 2025
│   ├── workshops/            # Workshop presentations
│   │   ├── 2025-04-ml-workshop/   # ML Workshop April 2025
│   │   └── 2025-09-ai-tutorial/   # AI Tutorial September 2025
│   ├── meetings/             # Meeting presentations
│   │   ├── 2025-07-lab-meeting/   # Lab Meeting July 2025
│   │   └── 2025-08-progress/      # Progress Report August 2025
│   └── seminars/             # Seminar presentations
│       ├── 2025-06-department/    # Department Seminar June 2025
│       └── 2025-10-colloquium/    # Colloquium October 2025
├── assets/                   # Shared presentation assets
│   ├── figures/              # Research figures and plots
│   ├── tables/               # Data tables
│   └── graphics/             # Icons, logos, graphics
└── _output/                  # Generated presentations
    ├── html/                 # HTML/RevealJS presentations
    │   ├── draft/            # Draft versions
    │   └── final/            # Final versions
    ├── pdf/                  # PDF presentations
    │   ├── draft/
    │   └── final/
    └── pptx/                 # PowerPoint presentations
        ├── draft/
        └── final/
```

## Chronological Organization

Presentations are organized using the **YYYY-MM-VENUE** format:
- `2025-05-neurips` - NeurIPS 2025 presentation (May)
- `2025-07-lab-meeting` - Lab meeting presentation (July)
- `2025-09-ai-tutorial` - AI tutorial workshop (September)

## Presentation Templates

1. **Academic**: Research talks and conference presentations
2. **Corporate**: Business meetings and industry presentations  
3. **Workshop**: Interactive training and tutorial materials
4. **Meeting**: Lab meetings and progress reports
5. **Poster**: Academic poster presentations

## Automation with Just

The `justfile` provides comprehensive commands for managing presentations. Run from the `presentation/` directory.

## Quick Start

1. **Initialize the system** (first time only):
   ```bash
   just init
   ```

2. **Create a conference presentation** (specify year, month, venue):
   ```bash
   just create-conference neurips 2025 05 academic
   ```

3. **Create with automatic date** (uses current year/month):
   ```bash
   just create-auto-conference neurips academic
   ```

4. **Create workshop presentation**:
   ```bash
   just create-workshop ml-tutorial 2025 04 workshop
   ```

5. **Edit your presentation**: 
   ```bash
   # Edit: presentations/conferences/2025-05-neurips/neurips_presentation.qmd
   ```

6. **Render and preview**:
   ```bash
   just render neurips html          # Creates HTML version
   just preview neurips              # Live preview with reload
   just finalize neurips pdf         # Creates final PDF
   ```

## Example Workflow

Creating a presentation for NeurIPS 2025 (May conference):

```bash
# Create presentation with specific date
just create-conference neurips 2025 05 academic

# Or create with automatic date detection
just create-auto-conference neurips academic

# Edit your presentation:
# presentations/conferences/2025-05-neurips/neurips_presentation.qmd

# Preview while editing
just preview neurips

# Render different formats
just render neurips html              # HTML/RevealJS
just render neurips pdf               # PDF slides
just render neurips pptx              # PowerPoint

# Finalize for presentation
just finalize neurips html
```

## Available Commands

### Creating Presentations
- `just create-conference <venue> <year> <month> [template]` - Create conference presentation
- `just create-workshop <event> <year> <month> [template]` - Create workshop presentation
- `just create-meeting <topic> <year> <month> [template]` - Create meeting presentation
- `just create-seminar <venue> <year> <month> [template]` - Create seminar presentation
- `just create-auto-conference <venue> [template]` - Create with current date
- `just create-auto-workshop <event> [template]` - Create with current date

### Rendering and Preview
- `just render <venue> [format]` - Render presentation (html/pdf/pptx)
- `just preview <venue>` - Live preview with reload
- `just finalize <venue> [format]` - Create final version

### Management
- `just list` - List all presentations
- `just list-conferences` - List conference presentations
- `just list-workshops` - List workshop presentations
- `just list-upcoming` - List upcoming presentations
- `just status <venue>` - Show presentation status
- `just clean` - Clean generated files

## Integration with Research Workflow

Presentations in this system can be:
- Linked to abstracts and posters for the same venue
- Used for grant proposal presentations
- Adapted for different audiences (academic, industry, general)
- Archived with research outputs and publications

- **Global styles** are defined in `_quarto.yml`.
- **Branding** (colors, logos, fonts) is managed in `_brand.yml`.
- **Templates** can be customized in the `templates/` directory.

This system provides a robust and flexible way to manage your presentations, ensuring consistency and efficiency in your workflow. It is designed to be easily extensible to support additional templates and formats as needed.
