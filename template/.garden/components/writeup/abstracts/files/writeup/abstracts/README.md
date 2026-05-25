# Academic Abstract Submission System

Streamlined system for creating and managing academic abstracts with automated workflows and chronological organization. Optimized for rapid abstract development and submission deadlines.

## Directory Structure

```
abstracts/
├── README.md                 # This documentation
├── abstracts.just           # Abstract automation commands
├── templates/               # Abstract templates
│   ├── conference_abstract.qmd    # Conference abstract template
│   ├── journal_abstract.qmd       # Journal abstract template
│   └── symposium_abstract.qmd     # Symposium/workshop template
├── submissions/             # Chronologically organized submissions
│   ├── conference/          # Conference submissions (YYYY-MM-VENUE format)
│   │   ├── 2025-05-neurips/      # NeurIPS May 2025
│   │   ├── 2025-07-icml/         # ICML July 2025
│   │   └── 2025-12-aaai/         # AAAI December 2025
│   ├── journal/             # Journal submissions
│   │   ├── 2025-06-nature/       # Nature June 2025
│   │   └── 2025-08-science/      # Science August 2025
│   └── symposium/           # Symposium/workshop submissions
│       ├── 2025-04-workshop/     # ML Workshop April 2025
│       └── 2025-09-symposium/    # AI Symposium September 2025
└── versions/                # Version control and tracking
    ├── drafts/              # Draft versions
    ├── reviews/             # Review feedback
    └── final/               # Final submitted versions
```

## Chronological Organization

Submissions are organized using the **YYYY-MM-VENUE** format:
- `2025-05-neurips` - NeurIPS 2025 (May submission deadline)
- `2025-06-nature` - Nature submission (June deadline)
- `2025-07-icml` - ICML 2025 (July submission deadline)

This provides chronological sorting while maintaining venue context.
## Abstract Templates

1. **Conference**: Standard academic conference abstracts (150-300 words)
2. **Journal**: Journal submission abstracts with structured format
3. **Symposium**: Workshop and symposium abstracts (100-250 words)

## Automation with Just

The `abstracts.just` file provides comprehensive commands for managing abstracts. Run from the `abstracts/` directory.

## Quick Start

1. **Initialize the system** (first time only):
   ```bash
   just init
   ```

2. **Create a conference abstract** (specify year, month, venue):
   ```bash
   just create-conference neurips 2025 05
   ```

3. **Create with automatic date** (uses current year/month):
   ```bash
   just create-auto-conference neurips
   ```

4. **Create journal submission**:
   ```bash
   just create-journal nature 2025 06
   ```

5. **Edit your abstract**: 
   ```bash
   # Edit: submissions/conference/2025-05-neurips/neurips_abstract.qmd
   ```

6. **Render and track**:
   ```bash
   just render neurips          # Creates draft version
   just finalize neurips        # Creates final submission
   just status neurips          # Shows submission status
   ```

## Example Workflow

Creating an abstract for NeurIPS 2025 (May deadline):

```bash
# Create abstract with specific date
just create-conference neurips 2025 05

# Or create with automatic date detection
just create-auto-conference neurips

# Edit your abstract:
# submissions/conference/2025-05-neurips/neurips_abstract.qmd

# Render for review
just render neurips

# Finalize for submission
just finalize neurips

# Track status
just status neurips
```

## Available Commands

### Creating Abstracts
- `just create-conference <venue> <year> <month>` - Create conference abstract
- `just create-journal <venue> <year> <month>` - Create journal abstract  
- `just create-symposium <venue> <year> <month>` - Create symposium abstract
- `just create-auto-conference <venue>` - Create with current date
- `just create-auto-journal <venue>` - Create with current date
- `just create-auto-symposium <venue>` - Create with current date

### Management
- `just list` - List all abstracts
- `just list-conference` - List conference abstracts
- `just list-journal` - List journal abstracts
- `just list-upcoming` - List upcoming deadlines
- `just status <venue>` - Show abstract status
- `just render <venue>` - Render draft version
- `just finalize <venue>` - Create final version

## Integration with Research Workflow

Abstracts in this system can be:
- Linked to poster and presentation development
- Referenced in grant applications as preliminary results
- Used to demonstrate research dissemination
- Tracked for impact metrics and citations
