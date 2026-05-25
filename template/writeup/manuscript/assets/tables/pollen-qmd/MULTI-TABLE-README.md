# Multi-Table QMD Generator System

A scalable system for generating academic tables from multiple data sources, each with their own configuration, data, templates, and metadata.

## 🚀 Quick Start

```bash
# List available tables
./generate-tables.sh list

# Generate a specific table
./generate-tables.sh generate table-1 -f typst

# Create a new table
./generate-tables.sh create table-4
```

## 📁 Directory Structure

```
pollen-qmd/
├── generate-multi-table-simple.rkt    # Core generator (working version)
├── generate-tables.sh                 # Shell wrapper with table management
├── tables/                           # Multi-table structure
│   ├── shared/                       # Shared templates
│   │   ├── typst-templates/          # Shared Typst functions
│   │   └── content-templates/        # Shared content templates
│   ├── table-1/                      # Individual table directory
│   │   ├── metadata/
│   │   │   └── config.yaml           # Table configuration
│   │   ├── data/
│   │   │   └── features.json         # Table data
│   │   └── templates/
│   │       ├── typst/                # Custom Typst templates
│   │       └── content/              # Custom content templates
│   ├── table-2/                      # Performance metrics table
│   └── table-3/                      # Dataset summary table
└── examples/                         # Generated examples
```

## 🎯 Key Features

### ✨ **Multi-Table Support**
- Each table has its own configuration, data, and templates
- Independent generation and management
- Shared template inheritance with table-specific overrides

### 📊 **Multiple Data Formats**
- **JSON**: Structured data with rich metadata
- **CSV**: Simple comma-separated values
- **YAML**: Human-readable configuration format

### 🎨 **Flexible Styling**
- **three-line**: Classic academic table style
- **bordered**: Enhanced readability with borders and colors
- **custom**: Table-specific custom styles (e.g., performance-table)

### 🔧 **Configuration-Driven**
- YAML metadata files control table behavior
- Column definitions with types and display names
- Output format preferences and styling options
- Academic metadata for citations and captions

## 📋 Table Configuration Schema

Each table's `metadata/config.yaml` follows this structure:

```yaml
---
table_id: table-1
title: "Your Table Title"
description: "Description of the table"

# Data Configuration
data:
  source_file: "data.json"    # Data file in table's data/ directory
  format: "json"              # json, csv, or yaml
  columns:
    - name: "column1"         # Column identifier for data access
      display_name: "Column 1" # Display name in table header
      type: "string"          # Data type (string, numeric, integer)
      description: "..."      # Column description

# Template Configuration
templates:
  typst:
    custom_imports: null      # Custom Typst template file (or null)
    custom_functions: null    # Custom function name (or null)
  content:
    heading: "heading.md"     # Content template filename

# Style and Output
styles:
  default: "three-line"       # Default style
  available: ["three-line", "bordered"]

output:
  filename_prefix: "my-table"
  formats:
    typst:
      enabled: true
      styles: ["three-line", "bordered"]
    docx:
      enabled: true

# Academic Publishing
academic:
  label: "tbl-my-table"
  caption: "Table caption for academic papers"
  short_caption: "Short caption"
  placement: "here"
```

## 🛠️ Usage

### Command Line Interface

```bash
# Using Racket directly
racket generate-multi-table-simple.rkt --table table-1 --format typst --style three-line

# Using shell wrapper (recommended)
./generate-tables.sh generate table-1 -f typst -s bordered
```

### Table Management

```bash
# List all available tables
./generate-tables.sh list

# Create new table template
./generate-tables.sh create new-table

# Generate specific table
./generate-tables.sh generate table-1

# Generate with options
./generate-tables.sh generate table-2 -f docx -o custom-filename.qmd
```

## 📊 Example Tables

### Table 1: Software Features
- **Data**: JSON format with theme/feature pairs
- **Style**: Three-line academic style
- **Content**: MTB-seq software feature analysis

### Table 2: Performance Metrics
- **Data**: CSV format with numeric performance data
- **Style**: Bordered with custom performance-table function
- **Content**: Benchmark comparison results

### Table 3: Dataset Summary
- **Data**: YAML format with dataset metadata
- **Style**: Clean three-line for academic papers
- **Content**: Genomic dataset overview

## 🔄 Workflow

1. **Create Table Structure**: Use `./generate-tables.sh create table-id`
2. **Configure Metadata**: Edit `tables/table-id/metadata/config.yaml`
3. **Add Data**: Place data file in `tables/table-id/data/`
4. **Customize Templates**: Add custom templates in `tables/table-id/templates/`
5. **Generate Output**: Use `./generate-tables.sh generate table-id`
6. **Render**: Use Quarto to render QMD to PDF/DOCX

## 🎨 Template System

### Shared Templates
Located in `tables/shared/` - used by default for all tables:
- `typst-templates/page-setup.typ`: Page configuration
- `typst-templates/table-imports.typ`: Three-line table functions
- `typst-templates/table-imports-bordered.typ`: Bordered table functions

### Table-Specific Templates
Located in `tables/table-id/templates/` - override shared templates:
- `typst/custom-imports.typ`: Custom Typst functions
- `content/heading.md`: Custom table heading and description

### Template Precedence
1. Table-specific templates (highest priority)
2. Shared templates
3. Built-in defaults

## 🔧 Extensibility

### Adding New Tables
```bash
./generate-tables.sh create my-new-table
# Edit the generated config.yaml and data files
# Generate: ./generate-tables.sh generate my-new-table
```

### Custom Typst Functions
Create `tables/table-id/templates/typst/custom-imports.typ`:
```typst
#let my-custom-table(content) = {
  // Your custom Typst table function
  table(
    // Custom styling
    ..content
  )
}
```

### New Data Formats
Extend the generator by adding support for new formats in the data loading section.

## 📈 Benefits

1. **Scalability**: Add new tables without affecting existing ones
2. **Maintainability**: Each table's configuration is self-contained
3. **Consistency**: Shared templates ensure consistent styling
4. **Flexibility**: Table-specific overrides when needed
5. **Automation**: Batch generation and scripted workflows
6. **Academic Publishing**: Built-in support for labels, captions, and citations

## 🚦 Status

- ✅ **Multi-table architecture implemented**
- ✅ **Configuration-driven table generation**
- ✅ **JSON, CSV, YAML data format support**
- ✅ **Template inheritance system**
- ✅ **Shell wrapper for table management**
- ✅ **Academic metadata support**
- ✅ **Typst and DOCX output formats**
- ⚠️ **Some minor data rendering issues in complex tables**

This system provides a robust foundation for managing multiple academic tables with different data sources, formats, and styling requirements, making it ideal for research publications and complex document workflows.