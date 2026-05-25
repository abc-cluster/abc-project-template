# Academic Template Presentation

This presentation showcases the integrated research template system for academic workflows.

## Files Structure

```
academic-template/
├── src/
│   └── template-presentation.qmd    # Main presentation source
├── assets/
│   ├── custom.scss                  # Custom styling
│   ├── references.bib               # Bibliography
│   └── .gitkeep                     # Placeholder for additional assets
└── output/                          # Generated presentation files
```

## Building the Presentation

### Prerequisites
- Quarto installed
- Modern web browser for HTML output

### Available Formats

```bash
# HTML slides (default)
quarto render src/template-presentation.qmd

# PDF slides
quarto render src/template-presentation.qmd --to beamer

# PowerPoint
quarto render src/template-presentation.qmd --to pptx

# All formats
quarto render src/template-presentation.qmd --to all
```

### Customization

1. **Content**: Edit `src/template-presentation.qmd`
2. **Styling**: Modify `assets/custom.scss`
3. **References**: Update `assets/references.bib`
4. **Assets**: Add images/logos to `assets/`

## Presentation Overview

This presentation covers:
- Academic research workflow challenges
- Integrated template solution
- Data architecture and management
- Multi-language development support
- Pipeline automation with Nextflow/Snakemake
- Quality assurance and reproducibility
- Real-world use cases and success stories

## Usage Tips

- Use speaker notes for detailed explanations
- Customize the color scheme in `custom.scss`
- Add your organization's logo to `assets/`
- Update contact information in the presentation
- Adapt content for your specific audience

## Output Location

Rendered presentations are saved to the `output/` directory automatically.
