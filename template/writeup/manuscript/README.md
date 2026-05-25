# Types of manuscripts

# Manuscript Structure

```
manuscript/
├── src/                      # Source files
│   ├── index.qmd            # Main manuscript file
│   ├── abstract.qmd         # Abstract
│   ├── introduction.qmd     # Introduction
│   ├── methods.qmd          # Methods
│   ├── results.qmd          # Results
│   ├── discussion.qmd       # Discussion
│   └── references.bib       # Bibliography
│
├── assets/                   # Manuscript-specific assets
│   ├── figures/             # Figures used in manuscript
│   ├── tables/              # Tables used in manuscript
│   └── supplementary/       # Supplementary materials
│
├── output/                   # Generated outputs
│   ├── pdf/                 # PDF versions
│   │   ├── draft/          # Draft versions
│   │   └── final/          # Final versions
│   ├── docx/               # Word versions
│   │   ├── draft/          # Draft versions
│   │   └── final/          # Final versions
│   └── html/               # HTML versions
│
├── reviews/                  # Review-related files
│   ├── feedback/            # Reviewer feedback
│   ├── responses/           # Response to reviewers
│   └── revisions/           # Revision history
│
├── submissions/             # Submission packages
│   ├── journal-name/        # Journal-specific submissions
│   └── preprint/            # Preprint submissions
│
├── _quarto.yml             # Quarto configuration
└── .gitignore              # Git ignore rules
```

## Directory Purposes

### src/
- Contains all source Quarto files
- Modular structure for better organization
- Each section in its own file for easier collaboration
- References file for bibliography

### assets/
- Manuscript-specific assets
- Organized by type (figures, tables, supplementary)
- Keeps source files separate from generated content

### output/
- All generated outputs organized by format
- Separate draft and final versions
- Easy to track different versions

### reviews/
- Centralized location for review-related files
- Tracks feedback and responses
- Maintains revision history

### submissions/
- Organized by target journal/preprint
- Contains complete submission packages
- Easy to track different submissions

## Best Practices

1. **Version Control**
   - Keep source files in version control
   - Ignore generated outputs
   - Use meaningful commit messages

2. **File Naming**
   - Use consistent naming conventions
   - Include version numbers in filenames
   - Use descriptive names

3. **Backup**
   - Regular backups of source files
   - Archive important versions
   - Use cloud storage for large files

4. **Collaboration**
   - Clear file organization
   - Document changes
   - Track feedback and responses

