# Enhanced Multi-Output Writeup Template

A comprehensive Quarto-based publishing system for generating multiple output formats from shared content sources. This template supports academic manuscripts, books, reports, presentations, posters, and digital content with audience-specific adaptations.

## 📁 Directory Structure

```
writeup/
├── outputs/                    # Generated output files organized by type
│   ├── manuscripts/           # Academic papers and articles
│   │   ├── main-paper/       # Primary research manuscript
│   │   ├── short-paper/      # Conference short papers
│   │   └── preprint/         # Preprint versions
│   ├── books/                # Book-length publications
│   │   ├── full-book/        # Complete book manuscript
│   │   └── chapters/         # Individual chapters
│   ├── reports/              # Technical and policy reports
│   │   ├── technical/        # Detailed technical reports
│   │   ├── executive/        # Executive summaries
│   │   └── policy/           # Policy briefs
│   ├── presentations/        # Slide presentations
│   │   ├── conference/       # Academic conference talks
│   │   ├── workshop/         # Workshop presentations
│   │   └── public/           # Public talks
│   ├── posters/              # Research posters
│   │   ├── conference/       # Academic conference posters
│   │   └── public/           # Public engagement posters
│   └── digital/              # Digital-first content
│       ├── blog/             # Blog posts
│       ├── social/           # Social media content
│       └── interactive/      # Interactive content
├── shared-content/           # Reusable content components
│   ├── core-content/         # Main research content
│   │   ├── abstracts/        # Different length abstracts
│   │   ├── sections/         # Individual paper sections
│   │   ├── appendices/       # Supplementary materials
│   │   └── citations/        # Citation styles and bibliography
│   ├── audience-adaptations/ # Content adapted for different audiences
│   │   ├── academic/         # Academic audience versions
│   │   ├── popular/          # General audience versions
│   │   ├── policy/           # Policy maker versions
│   │   └── technical/        # Technical audience versions
│   └── _variables.yml        # Shared variables and metadata
├── assets/                   # Static assets and media
│   ├── figures/              # Charts, graphs, diagrams
│   ├── tables/               # Data tables and summaries
│   ├── images/               # Photos and illustrations
│   ├── data/                 # Raw and processed datasets
│   └── media/                # Audio, video, and interactive media
├── workflows/                # Automation and CI/CD
│   ├── render/               # Rendering workflows
│   ├── validation/           # Content validation scripts
│   └── deployment/           # Publishing and deployment
├── templates/                # Template files for new outputs
│   ├── manuscript/           # Academic paper templates
│   ├── presentation/         # Slide deck templates
│   ├── poster/               # Poster templates
│   └── report/               # Report templates
├── writeup.just             # Task runner commands
└── README.md                # This file
```

## 🚀 Quick Start

### Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (latest version)
- [Just](https://github.com/casey/just) task runner
- R or Python (depending on your analysis needs)

### Installation

1. Clone or copy this template structure
2. Install dependencies:
   ```bash
   # Install Quarto (if not already installed)
   # Visit: https://quarto.org/docs/get-started/

   # Install Just task runner
   brew install just  # macOS
   # or follow instructions at: https://github.com/casey/just#installation
   ```

### Basic Usage

1. **Configure your project variables** in `shared-content/_variables.yml`
2. **Add your content** to the appropriate sections in `shared-content/core-content/`
3. **Generate outputs** using Just commands:

```bash
# Render all outputs
just render-all

# Render specific output types
just render-manuscripts
just render-reports
just render-presentations

# Create new documents from templates
just new-manuscript "my-new-paper"
just new-presentation "conference-talk"
just new-poster "research-poster"

# Preview outputs
just preview-main-manuscript
just preview-reports
```

## 📝 Content Management

### Shared Variables

Edit `shared-content/_variables.yml` to define project-wide variables that can be used across all outputs:

```yaml
project:
  title: "Your Research Title"
  subtitle: "Detailed Investigation"
  
study:
  key-finding: "Your main discovery"
  participants: "Study population description"
  method-brief: "Research methodology summary"
  
authors:
  - name: "Your Name"
    affiliation: "Your Institution"
```

### Content Sections

- **Core Content** (`shared-content/core-content/`): Main research content that can be included in multiple outputs
- **Audience Adaptations** (`shared-content/audience-adaptations/`): Content rewritten for specific audiences
- **Assets** (`assets/`): Figures, tables, data, and media files

### Including Content

Use Quarto includes in your output files:

```markdown
{{< include ../../shared-content/core-content/sections/_introduction.qmd >}}

{{< include ../../shared-content/audience-adaptations/popular/_popular-version.qmd >}}
```

## 🔧 Task Runner Commands

The `writeup.just` file provides comprehensive automation:

### Rendering Commands
```bash
just render-all              # Render all output types
just render-manuscripts      # Render all manuscripts
just render-books           # Render all books
just render-reports         # Render all reports
just render-presentations   # Render all presentations
just render-posters         # Render all posters
just render-digital         # Render digital content
```

### Template Creation
```bash
just new-manuscript NAME     # Create new manuscript
just new-presentation NAME   # Create new presentation
just new-poster NAME         # Create new poster
just new-report NAME         # Create new report
```

### Asset Management
```bash
just sync-assets            # Sync assets across outputs
just validate-refs          # Check cross-references
just update-bibliography    # Update citations
```

### Maintenance
```bash
just clean                  # Remove generated files
just clean-all              # Deep clean all outputs
just sync-shared-content    # Sync shared content
just package-outputs        # Create distribution packages
```

## 📚 Output Types

### Manuscripts
Academic papers with standard structure (Abstract, Introduction, Methods, Results, Discussion, Conclusions). Supports PDF, HTML, and DOCX formats.

### Books
Long-form publications with chapters, cross-references, and comprehensive bibliographies.

### Reports
Technical reports, executive summaries, and policy briefs with professional formatting.

### Presentations
Slide decks for conferences, workshops, and public talks using reveal.js.

### Posters
Research posters for academic conferences and public engagement events.

### Digital Content
Blog posts, social media content, and interactive materials optimized for online consumption.

### Technical Protocols
Structured protocols for technical audiences including:
- **Experimental Protocols**: Step-by-step laboratory and research procedures
- **API Documentation**: Comprehensive endpoint specifications and examples
- **System Architecture**: Technical specifications and deployment guides
- **Configuration Management**: Environment setup and maintenance procedures
- **Testing Protocols**: Unit, integration, and load testing frameworks
- **Troubleshooting Guides**: Diagnostic procedures and emergency contacts

## 🎯 Audience Adaptations

Content can be adapted for different audiences:

- **Academic**: Formal scientific language, detailed methodology, comprehensive citations
- **Popular**: Accessible language, engaging examples, minimal jargon  
- **Policy**: Action-oriented, clear recommendations, executive summaries
- **Technical**: Detailed implementation, code examples, technical specifications, protocols, and operational procedures

## 🔄 Workflow Integration

The template supports automated workflows for:

- **Content Validation**: Check for broken references, missing figures, citation errors
- **Cross-Format Consistency**: Ensure content stays synchronized across outputs
- **Asset Management**: Automatically sync figures and tables across formats
- **Publishing**: Generate distribution-ready packages for different platforms

## 🤝 Contributing

To extend this template:

1. Add new output types in the `outputs/` directory
2. Create corresponding templates in `templates/`
3. Update `writeup.just` with new commands
4. Add audience adaptations as needed

## 📄 License

This template structure is provided as-is for academic and research use. Adapt as needed for your projects.

## 📞 Support

For issues with:
- **Quarto**: Visit [Quarto documentation](https://quarto.org/docs/)
- **Just**: See [Just command runner docs](https://github.com/casey/just)
- **Template structure**: Create an issue in your project repository

---

**Happy writing and publishing!** 🎉
