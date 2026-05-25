# Documentation Structure

This documentation system supports multiple types of academic and technical content with a modular, scalable structure.

## Directory Structure

```
docs/
├── presentations/          # Academic and technical presentations
│   ├── academic-template/  # Main academic presentation
│   └── shared/            # Shared presentation resources
├── manuscript/            # Scientific manuscripts and papers
│   ├── src/              # Source manuscript files
│   ├── assets/           # Manuscript-specific assets
│   └── output/           # Generated manuscript outputs
├── website/              # Website content and documentation
│   ├── src/              # Website source files
│   ├── assets/           # Website assets
│   ├── walkthroughs/     # Step-by-step guides
│   ├── case-studies/     # Real-world examples
│   └── output/           # Generated website files
└── shared/               # Shared resources across all content
    ├── assets/           # Common images, logos, etc.
    ├── styles/           # Common CSS/SCSS files
    └── references/       # Shared bibliography files
```

## Content Types

### 📊 Presentations
- **Academic presentations** for conferences and seminars
- **Technical presentations** for workshops and training
- **Multiple format support**: HTML slides, PDF, PowerPoint
- **Shared styling** and assets for consistency

### 📝 Manuscripts
- **Scientific papers** and research articles
- **Technical reports** and documentation
- **Multiple formats**: PDF, HTML, Word
- **Citation management** and bibliography support

### 🌐 Website
- **Project documentation** and guides
- **Interactive walkthroughs** for complex processes
- **Case studies** with real-world examples
- **Static site generation** for easy deployment

## Getting Started

1. **Choose your content type** and navigate to the appropriate directory
2. **Read the specific README** in each directory for detailed instructions
3. **Use the provided templates** as starting points
4. **Leverage shared resources** for consistency across content types

## Tools and Technologies

- **Quarto**: Primary authoring system for all content types
- **Markdown/QMD**: Source format for writing
- **SCSS**: Styling and theming
- **BibTeX**: Citation management
- **Git**: Version control for all content

## Build and Deployment

Each content type has its own build process:

```bash
# Presentations
cd presentations/academic-template && quarto render

# Manuscripts  
cd manuscript && quarto render

# Website
cd website && quarto render
```

## Contributing

- Follow the established directory structure
- Use shared resources when possible
- Maintain consistent styling and formatting
- Update documentation when adding new content types
