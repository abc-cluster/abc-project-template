# Walkthroughs

This folder contains step-by-step guides for using the research templates effectively.

## Structure

Each walkthrough should be self-contained and include:
- **Introduction**: Brief overview of what the walkthrough covers
- **Prerequisites**: Required tools, knowledge, or setup
- **Step-by-step instructions**: Clear, numbered steps with code examples
- **Expected outcomes**: What users should see at each step
- **Troubleshooting**: Common issues and solutions
- **Next steps**: Links to related walkthroughs or advanced topics

## Walkthrough Templates

### Basic Usage
- Getting started with templates
- Setting up development environment
- Creating your first project

### Advanced Workflows
- Multi-language development
- Pipeline automation
- Data analysis workflows
- Publication-ready outputs

### Specialized Topics
- Container deployment
- Cloud computing integration
- Collaborative development
- Quality assurance practices

## Writing Guidelines

1. **Be clear and concise**: Use simple language and short sentences
2. **Include code examples**: Show exact commands and expected outputs
3. **Use screenshots**: Visual aids help clarify complex steps
4. **Test thoroughly**: Ensure all steps work as described
5. **Keep updated**: Regular review and updates for accuracy

## File Naming Convention

- Use kebab-case: `getting-started-guide.qmd`
- Include difficulty level: `beginner-setup.qmd`, `advanced-pipeline.qmd`
- Be descriptive: `rust-package-development.qmd`

## Example Walkthroughs

- `getting-started.qmd`: Basic template setup and usage
- `rust-development.qmd`: Rust package development workflow
- `data-analysis-pipeline.qmd`: End-to-end data analysis
- `publication-workflow.qmd`: From code to publication

## Building Walkthroughs

```bash
# Single walkthrough
quarto render getting-started.qmd

# All walkthroughs
quarto render

# With specific format
quarto render getting-started.qmd --to html
```

## Integration with Main Site

Walkthroughs are integrated into the main website navigation and can be cross-referenced with case studies and other documentation.
