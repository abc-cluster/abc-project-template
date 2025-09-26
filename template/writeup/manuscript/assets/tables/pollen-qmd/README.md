# Pollen-QMD: Enhanced Multi-Format Table Generator

A sophisticated system for generating clean QMD (Quarto Markdown) files from a single data source, supporting both Typst (PDF) and DOCX outputs with multiple table styles.

## 🚀 Quick Start

```bash
# Generate a Typst table with three-line style
./generate-enhanced.sh typst three-line my-table.qmd

# Generate a Typst table with bordered style  
./generate-enhanced.sh typst bordered my-table-bordered.qmd

# Generate a DOCX table (style parameter ignored)
./generate-enhanced.sh docx three-line my-table-docx.qmd

# Render the generated files
quarto render my-table.qmd --to typst        # Creates PDF
quarto render my-table-docx.qmd --to docx    # Creates DOCX
```

## 📁 Directory Structure

```
pollen-qmd/
├── README.md                     # This file
├── generate-enhanced.rkt         # Main Racket generator
├── generate-enhanced.sh          # Shell wrapper
├── data.csv                      # Sample data (CSV format)
├── data.json                     # Sample data (JSON format)  
├── data.yaml                     # Sample data (YAML format)
├── typst-templates/              # External Typst code templates
│   ├── page-setup.typ           # Page configuration
│   ├── table-imports.typ        # Three-line table style
│   └── table-imports-bordered.typ # Bordered table style
├── content-templates/            # External Markdown templates
│   └── table-1-heading.md      # Table title and description
├── examples/                     # Generated examples and demos
└── docs/                        # Additional documentation
```

## 🎯 Problem Solved

**Before**: Maintaining separate `table.qmd` (for Typst/PDF) and `table.docx.qmd` (for DOCX) files with duplicated content that could get out of sync.

**After**: Single source of truth → Generate format-specific QMD files → Render to both PDF and DOCX with consistent content.

## ✨ Key Features

### 🔧 **Multi-Format Data Input**
- **CSV**: Standard comma-separated values
- **JSON**: Structured data with metadata
- **YAML**: Human-readable configuration format

### 🎨 **Multiple Table Styles** (Typst only)
- **three-line**: Classic academic style with minimal horizontal lines
- **bordered**: Enhanced readability with borders and alternating row colors

### 🔀 **Format-Specific Output**
- **Typst**: Advanced code blocks with custom table functions
- **DOCX**: Standard Markdown tables for Word compatibility

### 🧩 **Modular Architecture**
- **External Templates**: Typst code separated from generation logic
- **Content Templates**: Reusable Markdown content
- **Clean Generation**: No regex post-processing needed

## 💻 Usage

### Command Line Interface

```bash
# Full command syntax
racket generate-enhanced.rkt --format FORMAT --style STYLE --output FILENAME

# Examples
racket generate-enhanced.rkt --format typst --style three-line --output table.qmd
racket generate-enhanced.rkt --format docx --output table-word.qmd
```

### Shell Wrapper (Recommended)

```bash
# Syntax: ./generate-enhanced.sh FORMAT STYLE [OUTPUT_FILE]
./generate-enhanced.sh typst three-line           # Auto-generates filename
./generate-enhanced.sh typst bordered custom.qmd  # Custom filename
./generate-enhanced.sh docx three-line            # Style ignored for DOCX
```

### Help and Options

```bash
./generate-enhanced.sh                 # Show usage help
racket generate-enhanced.rkt --help    # Show detailed options
```

## 📊 Data Formats

The system automatically detects and uses available data files in this priority order:

### 1. CSV Format (`data.csv`)
```csv
Theme,Feature
User-friendliness,Ease of download
User-friendliness,Explicit samplesheet
Maintainability,Extensibility
```

### 2. JSON Format (`data.json`)
```json
[
  {"Theme": "User-friendliness", "Feature": "Ease of download"},
  {"Theme": "User-friendliness", "Feature": "Explicit samplesheet"},
  {"Theme": "Maintainability", "Feature": "Extensibility"}
]
```

### 3. YAML Format (`data.yaml`)
```yaml
- Theme: User-friendliness
  Feature: Ease of download
- Theme: User-friendliness  
  Feature: Explicit samplesheet
- Theme: Maintainability
  Feature: Extensibility
```

## 🎨 Table Styles

### Three-Line Style
Classic academic table appearance:
- Horizontal lines at top, after header, and bottom
- Clean, minimal design
- Ideal for academic papers

### Bordered Style  
Enhanced readability:
- Full borders around all cells
- Alternating row colors (light gray)
- Better for presentations and reports

## 🏗️ Architecture

### Data Flow
```
Data File → Racket Generator → External Templates → Clean QMD → Quarto → PDF/DOCX
```

### Template System
- **Typst Templates**: Contain table styling definitions and page setup
- **Content Templates**: Markdown content like headings and descriptions  
- **Runtime Assembly**: Generator combines templates with data at generation time

### Output Quality
- ✅ **Clean QMD**: No artifacts or extra characters
- ✅ **Format-Specific**: Optimal markup for each output format
- ✅ **Consistent**: Identical content across PDF and DOCX
- ✅ **No Post-Processing**: Direct generation without regex cleanup

## 🛠️ Requirements

- **Racket**: Version 8.0+ with standard libraries
- **Quarto**: For rendering QMD to PDF/DOCX
- **Typst**: Automatically handled by Quarto for PDF generation

### Required Racket Packages
All packages are part of standard Racket installation:
- `racket/base`
- `racket/cmdline` 
- `racket/string`
- `racket/list`
- `json`
- `yaml`
- `csv-reading`

## 🚦 Getting Started

1. **Verify Requirements**
   ```bash
   racket --version    # Should show 8.0+
   quarto --version    # Should show recent version
   ```

2. **Test the System**
   ```bash
   cd pollen-qmd
   ./generate-enhanced.sh typst three-line test.qmd
   quarto render test.qmd --to typst
   ```

3. **Customize Your Data**
   - Edit `data.csv` (or create `data.json`/`data.yaml`)
   - Modify `content-templates/table-1-heading.md` for your table title
   - Generate your tables!

## 📈 Examples

See the `examples/` directory for:
- Generated QMD files showing different styles
- Rendered PDF and DOCX outputs  
- Demonstration scripts
- Before/after comparisons

## 🔧 Customization

### Adding New Table Styles

1. Create a new template file: `typst-templates/table-imports-mystyle.typ`
2. Define your table styling:
   ```typst
   #let mystyle-table = tablem.with(
     render: (columns: auto, ..args) => {
       table(
         columns: columns,
         // Your custom styling here
         ..args,
       )
     }
   )
   ```
3. Update the style mapping in `generate-enhanced.rkt`
4. Use with: `--style mystyle`

### Modifying Content Templates

Edit files in `content-templates/` to change:
- Table headings and descriptions
- Additional Markdown content
- Cross-references and captions

### Data Structure Changes

The generator expects data with "Theme" and "Feature" columns by default. To customize:
1. Modify the data processing functions in `generate-enhanced.rkt`
2. Update the table generation logic for your column names
3. Adjust templates if needed

## 🎓 Academic Publishing Workflow

This system is designed for academic publishing where you need:

1. **PDF Version**: High-quality typeset tables via Typst
2. **DOCX Version**: Word-compatible tables for collaborative editing
3. **Consistency**: Identical content across both formats
4. **Version Control**: All components tracked in Git
5. **Automation**: Regenerate tables when data changes

## 📝 License

This system is provided as an example implementation. Feel free to adapt and modify for your specific needs.

## 🤝 Contributing

To extend or improve this system:
1. Add new table styles in `typst-templates/`
2. Create additional data format handlers
3. Enhance the template system
4. Add validation and error checking
5. Improve documentation and examples

---

*This system transforms the challenge of maintaining duplicate table files into an elegant, automated workflow suitable for professional academic publishing.*