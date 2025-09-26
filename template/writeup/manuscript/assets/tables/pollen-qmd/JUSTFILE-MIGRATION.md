# Shell Script to Justfile Migration

## Overview

The shell scripts in this project have been converted to a comprehensive `justfile` for improved usability, discoverability, and maintainability.

## Migration Summary

### Original Shell Scripts → Justfile Recipes

| Original Script | Justfile Recipe(s) | Description |
|----------------|-------------------|-------------|
| `./quick-start.sh` | `just quick-start` | Complete system test and demo |
| `./generate-enhanced.sh` | `just generate FORMAT STYLE [OUTPUT]` | Generate specific table format |
| `./generate-tables.sh` | `just tables-*` commands | Multi-table operations |
| `./demo-multi-table.sh` | `just examples`, `just table-1` | Generate examples and demos |
| `examples/generate-all-examples.sh` | `just examples` | Generate all example variations |

### Key Benefits of the Migration

1. **Better Discoverability**: `just --list` shows all available commands
2. **Built-in Help**: `just help` provides comprehensive usage information
3. **Parameter Handling**: Clean, typed parameters instead of positional arguments
4. **Dependency Management**: `just check-deps` validates system requirements
5. **Consistent Interface**: All operations follow the same command pattern
6. **Error Handling**: Better error reporting and validation

## Quick Start

### Installation
Make sure you have `just` installed:
```bash
# macOS
brew install just

# Or see: https://github.com/casey/just#installation
```

### Basic Usage

```bash
# Show all available commands
just --list

# Get detailed help
just help

# Check dependencies
just check-deps

# Run complete system test (replaces ./quick-start.sh)
just quick-start

# Generate tables (replaces ./generate-enhanced.sh)
just generate typst three-line my-table.qmd
just generate docx three-line my-docx-table.qmd

# Generate all table-1 variations
just table-1

# Render QMD files to final outputs
just render table-1-*.qmd

# Clean up generated files
just clean table-1-*
```

## Command Categories

### 🚀 Quick Start & Testing
- `just quick-start` - Complete system test (replaces `./quick-start.sh`)
- `just check-deps` - Check system dependencies
- `just examples` - Generate all example variations

### 📊 Table Generation
- `just generate FORMAT STYLE [OUTPUT]` - Generate specific table
- `just table-1` - Generate all table-1 variations
- `just docx [OUTPUT]` - Generate DOCX format table
- `just typst-three-line [OUTPUT]` - Generate Typst three-line table
- `just typst-bordered [OUTPUT]` - Generate Typst bordered table

### 📄 Rendering
- `just render [PATTERN]` - Render QMD files to final outputs
- `just render-docx [PATTERN]` - Render to DOCX only
- `just render-pdf [PATTERN]` - Render to PDF only

### 🗂️ Multi-Table Operations
- `just tables-list` - List available tables
- `just tables-generate TABLE` - Generate specific table by ID
- `just tables-batch` - Generate all tables
- `just tables-create TABLE` - Create new table template

### 🧹 Maintenance
- `just clean [PATTERN]` - Clean generated files
- `just clean-all` - Clean everything
- `just info` - Show system information

## Migration Guide

### For Existing Shell Script Users

#### Instead of:
```bash
./quick-start.sh
```
#### Use:
```bash
just quick-start
```

#### Instead of:
```bash
./generate-enhanced.sh typst three-line my-table.qmd
```
#### Use:
```bash
just generate typst three-line my-table.qmd
```

#### Instead of:
```bash
./generate-tables.sh list
./generate-tables.sh generate table-1
```
#### Use:
```bash
just tables-list
just tables-generate table-1
```

### Workflow Examples

#### Complete Workflow (old vs new)

**Old way:**
```bash
./quick-start.sh
./generate-enhanced.sh typst three-line table-1.qmd
./generate-enhanced.sh docx three-line table-1-docx.qmd
quarto render table-1.qmd --to typst
quarto render table-1-docx.qmd --to docx
```

**New way:**
```bash
just quick-start
just table-1                    # Generates all variations
just render table-1-*           # Renders all variations
```

#### Custom Table Generation

**Old way:**
```bash
./generate-enhanced.sh typst bordered custom-table.qmd
quarto render custom-table.qmd --to typst
```

**New way:**
```bash
just generate typst bordered custom-table.qmd
just render custom-table.qmd
```

## Advanced Features

### Pattern-based Operations
```bash
# Render all tables matching a pattern
just render "examples/table-*.qmd"

# Clean specific patterns
just clean "table-1-*"
```

### System Information
```bash
# Check system status
just info

# Verify dependencies
just check-deps
```

## Compatibility

- **Shell Scripts**: The original shell scripts remain functional and are not removed
- **Commands**: All original functionality is preserved in the Justfile
- **Dependencies**: Same system requirements (Racket, Quarto, Typst)
- **Outputs**: Identical output files are generated

## Next Steps

1. **Try it out**: Run `just quick-start` to test the system
2. **Learn**: Use `just help` to explore all available commands
3. **Migrate**: Gradually replace shell script usage with `just` commands
4. **Customize**: Modify the `justfile` for your specific needs

The Justfile provides a modern, maintainable interface while preserving all the functionality of the original shell scripts.