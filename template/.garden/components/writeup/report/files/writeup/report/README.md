# Report Management System

This directory provides a structured and automated system for creating, managing, and rendering different types of reports. It supports multiple templates (technical, executive, project, grant) and output formats, and includes a `justfile` for automating common tasks.

## Directory Structure

```
report/
├── README.md                 # This file
├── _quarto.yml               # Global quarto configuration
├── justfile                  # Automation tasks
├── templates/                # Report templates
│   ├── technical/            # Technical reports
│   ├── executive/            # Executive summaries
│   ├── project/              # Project reports
│   └── grant/                # Grant progress reports
├── reports/                  # Your reports
│   ├── technical-report-1/   # Example technical report
│   └── executive-summary-1/  # Example executive summary
├── styles/                   # CSS styles for HTML reports
│   └── executive-summary.css # Styling for executive summaries
└── _output/                  # Rendered reports
    ├── html/
    │   ├── draft/
    │   └── final/
    ├── pdf/
    │   ├── draft/
    │   └── final/
    └── docx/
        ├── draft/
        └── final/
```

## Available Templates

The report system includes several specialized templates:

1. **Technical Report**: Comprehensive template for detailed technical analysis and findings.
2. **Executive Summary**: Concise, business-oriented summary with key findings and recommendations.
3. **Project Report**: Progress tracking, status updates, and next steps for project management.
4. **Grant Progress Report**: Structured reporting for grant-funded projects with objectives and milestones.

## Automation with Just

The `justfile` provides a comprehensive set of commands for managing your reports. Run from the `report/` directory.

### Creating New Reports

```bash
# Create a new technical report
just create-technical analysis-report

# Create an executive summary
just create-executive quarterly-summary

# Create a project report
just create-project project-status

# Create a grant progress report
just create-grant nsf-annual-report
```

### Rendering Reports

```bash
# Render a report to PDF (default)
just render-report analysis-report format=pdf

# Render a report to HTML
just render-report quarterly-summary format=html

# Render to the 'final' output folder
just render-report project-status version=final

# Batch render all reports
just batch-render format=pdf
```

### Other Commands

```bash
# List all available commands
just

# List all reports
just list-reports

# List available templates
just list-templates

# Clone a report to create a new version
just clone-report q1-report q2-report

# Initialize a new report project
just report-init

# Clean draft output directories
just clean

# Clean all output directories
just clean-all

# Export a report as PDF with timestamp
just export-pdf analysis-report
```

## Customization

- **Global styles** are defined in `_quarto.yml`.
- **Template-specific styles** are available in the `styles/` directory.
- **Templates** can be modified in the `templates/` directory to match your organization's requirements.

## Workflow Integration

The report system is designed to integrate with your existing workflow:

- **Version Control**: Each report is stored in its own directory for easier version control.
- **Collaboration**: Multiple authors can work on different reports simultaneously.
- **Output Management**: Separate output directories for draft and final versions.
- **Batch Processing**: Commands for processing multiple reports at once.

This system provides a robust and flexible way to manage your reports, ensuring consistency and efficiency in your reporting workflow.
