# Technical Architecture

This document explains the internal architecture of the Pollen-QMD system for developers and advanced users.

## System Overview

```
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌─────────────┐
│ Data Files  │───▶│ Racket Generator │───▶│ External        │───▶│ Clean QMD   │
│ CSV/JSON/   │    │ (generate-       │    │ Templates       │    │ Files       │
│ YAML        │    │  enhanced.rkt)   │    │                 │    │             │
└─────────────┘    └──────────────────┘    └─────────────────┘    └─────────────┘
                            │                        │                      │
                            ▼                        ▼                      ▼
                   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐
                   │ Command Line    │    │ Typst Templates │    │ Quarto      │
                   │ Interface       │    │ Content Tmpl.   │    │ Rendering   │
                   └─────────────────┘    └─────────────────┘    └─────────────┘
```

## Core Components

### 1. Data Layer

**Purpose**: Flexible data input supporting multiple formats

**Files**:
- `data.csv` - Primary CSV data source
- `data.json` - Structured JSON alternative  
- `data.yaml` - Human-readable YAML format

**Implementation**:
```racket
(define (load-data-file)
  (cond
    [(file-exists? "data.csv") (load-csv-data "data.csv")]
    [(file-exists? "data.json") (load-json-data "data.json")]
    [(file-exists? "data.yaml") (load-yaml-data "data.yaml")]
    [else (error "No data file found")]))
```

### 2. Template System

**Purpose**: Modular, external template management

**Template Types**:
- **Typst Templates** (`typst-templates/*.typ`): Table styling and page setup
- **Content Templates** (`content-templates/*.md`): Reusable Markdown content

**Loading Mechanism**:
```racket
(define (load-template file-path)
  (if (file-exists? file-path)
      (file->string file-path)
      (error "Template not found: " file-path)))
```

### 3. Generator Core

**File**: `generate-enhanced.rkt`

**Key Functions**:

#### Data Processing
```racket
(define (process-csv-data rows)
  (map (lambda (row)
         (hash 'theme (first row)
               'feature (second row)))
       rows))
```

#### Format-Specific Generation
```racket
(define (generate-typst-content data style)
  (string-append
    (load-template "typst-templates/page-setup.typ")
    (load-template (format "typst-templates/table-imports-~a.typ" style))
    (format-typst-table data)))

(define (generate-docx-content data)
  (string-append
    (load-template "content-templates/table-1-heading.md")
    (format-markdown-table data)))
```

### 4. Command Line Interface

**Shell Wrapper**: `generate-enhanced.sh`
- User-friendly interface
- Parameter validation
- Error handling
- Usage help

**Racket CLI**: Direct command-line parsing in Racket
```racket
(command-line
 #:program "generate-enhanced.rkt"
 #:once-each
 [("--format" "-f") format-str "Output format (typst/docx)" ...]
 [("--style" "-s") style-str "Table style (three-line/bordered)" ...]
 [("--output" "-o") output-file "Output filename" ...])
```

## Data Flow

### 1. Initialization
```
User Command → Shell Wrapper → Racket Script → Command Line Parser
```

### 2. Data Loading
```
Check data.csv → Check data.json → Check data.yaml → Load & Parse
```

### 3. Template Resolution
```
Determine Format → Load Base Templates → Load Style-Specific Templates
```

### 4. Content Generation
```
Process Data → Apply Templates → Generate Format-Specific Markup → Write QMD
```

## Style System

### Style Definition Architecture

Each style is defined as a separate Typst template:

**File**: `typst-templates/table-imports-STYLE.typ`
```typst
#import "@preview/tablem:0.2.0": tablem

#let STYLE-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      // Style-specific configuration
      ..args,
    )
  }
)
```

### Style Registration

In `generate-enhanced.rkt`:
```racket
(define style-templates
  (hash "three-line" "table-imports.typ"
        "bordered" "table-imports-bordered.typ"))
```

## Output Generation

### Typst Output Structure
```markdown
---
YAML Frontmatter (format configuration)
---

Typst Page Setup Block

Markdown Content (heading)

Typst Template Import Block

Typst Table Data Block
```

### DOCX Output Structure  
```markdown
---
YAML Frontmatter (format configuration)
---

Markdown Content (heading)

Markdown Table (standard format)
```

## Error Handling

### Data Validation
- Check for required data files
- Validate CSV/JSON/YAML structure
- Ensure required columns exist

### Template Validation
- Verify template files exist
- Check style parameter validity
- Validate template syntax

### Output Validation
- Ensure output directory exists
- Check file write permissions
- Validate generated QMD syntax

## Extension Points

### Adding New Data Formats

1. Add loader function:
   ```racket
   (define (load-xml-data file-path)
     ;; XML parsing logic
     )
   ```

2. Update data loading logic:
   ```racket
   (define (load-data-file)
     (cond
       ;; existing formats...
       [(file-exists? "data.xml") (load-xml-data "data.xml")]
       ;; ...
       ))
   ```

### Adding New Table Styles

1. Create template file: `typst-templates/table-imports-mystyle.typ`
2. Define table function in template
3. Register in style mapping:
   ```racket
   (define style-templates
     (hash ;; existing styles...
           "mystyle" "table-imports-mystyle.typ"))
   ```

### Adding New Output Formats

1. Add format-specific generation function:
   ```racket
   (define (generate-latex-content data)
     ;; LaTeX table generation
     )
   ```

2. Update main generation logic:
   ```racket
   (cond
     [(equal? output-fmt "typst") (generate-typst-content ...)]
     [(equal? output-fmt "docx") (generate-docx-content ...)]
     [(equal? output-fmt "latex") (generate-latex-content ...)])
   ```

## Performance Considerations

### Template Caching
Templates are loaded once per generation. For batch processing, consider implementing template caching:

```racket
(define template-cache (make-hash))

(define (cached-load-template file-path)
  (hash-ref template-cache file-path
    (lambda () 
      (let ([content (file->string file-path)])
        (hash-set! template-cache file-path content)
        content))))
```

### Memory Usage
- CSV data is loaded into memory completely
- Large datasets may require streaming processing
- Template files are typically small and cacheable

## Testing Strategy

### Unit Tests
- Data loading functions
- Template processing
- Format-specific generation
- Command-line parsing

### Integration Tests  
- End-to-end generation workflows
- Template + data combinations
- Quarto rendering validation

### Validation Tests
- QMD syntax validation
- Typst compilation testing
- DOCX generation verification

## Security Considerations

### Input Validation
- CSV injection prevention
- Path traversal protection in template loading
- Output file path validation

### Template Safety
- Templates are loaded from controlled locations
- No dynamic code execution in templates
- Input sanitization for table content

## Debugging

### Debug Mode
Add debug output by setting environment variable:
```bash
export POLLEN_QMD_DEBUG=1
./generate-enhanced.sh typst three-line debug.qmd
```

### Common Issues
1. **Template Not Found**: Check file paths and permissions
2. **Data Parse Error**: Validate CSV/JSON/YAML syntax
3. **Style Not Recognized**: Verify style name matches template file
4. **Quarto Render Failure**: Check QMD syntax and Typst code

This architecture provides a robust, extensible foundation for multi-format table generation while maintaining clean separation of concerns and easy maintainability.