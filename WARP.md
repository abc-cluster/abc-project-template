# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Copier template repository for creating comprehensive data science and academic research projects. It generates project structures that include analysis pipelines, academic writing workflows, and infrastructure management. The template supports multi-language development (Python, R, Julia, Clojure) and provides automation through Just task runner.

**🌱 Beginner-Friendly Design**: The template now defaults to a "Minimal Starter" configuration that creates simple, approachable projects. Users can progressively add more components as they become comfortable, preventing overwhelming beginners with complex setups.

**💾 Automatic Git Initialization**: Every generated project automatically initializes a git repository with an initial commit containing project metadata, so users can start version control immediately.

## Development Commands

### Template Testing and Development
```bash
# Test the template with copier-template-tester
ctt run
# Or using the script
./ctt-test-template.sh

# Test template generation manually
copier copy . test-project
cd test-project
just setup
```

### Template Validation
```bash
# Run pre-commit hooks on template files
pre-commit run --all-files

# Check template syntax
copier copy --dry-run . test-output
```

## Architecture Overview

### Core Template Structure

The template uses **Copier** as the templating engine with Jinja2 templating. Key architectural components:

1. **Template Configuration**: `copier.yml` defines template variables and conditional logic
2. **Generated Project Structure**: Templates generate different project types based on user selections
3. **Multi-Language Support**: Supports Python, R, Julia, and Clojure environments
4. **Modular Components**: Users can select specific components (analysis, writeup, infrastructure)

### Template Types and Components

The template generates different project structures based on `project_type`:
- **Full Academic Project**: Analysis + writeup + infrastructure
- **Analysis Only**: Data science pipeline focused
- **Manuscript Only**: Academic writing focused  
- **Package Development**: Software library creation
- **Custom**: Manual component selection

### Key Generated Directories

**Analysis Pipeline** (`analysis/`):
- `notebooks/`: 10-stage structured workflow (00-scratch to 10-iteration)
- `scripts/`: Production Python/R/shell scripts
- `data/`: 8-level data pipeline (01_raw to 08_reporting)
- `packages/`: Local package development
- `infrastructure/`: Docker, cloud deployment, VMs

**Academic Writing** (`writeup/`):
- `manuscript/`: Journal articles with Quarto
- `presentation/`: Conference presentations (RevealJS, PowerPoint)
- `grants/`: NSF, NIH, DOE proposal management
- `abstracts/`: Conference submission tracking
- `reports/`: Technical documentation
- `posters/`: Academic poster creation

### Automation System

**Just-based Task Runner**: The template generates extensive Just recipes for automation:

- **Notebook Management**: Create, run, validate, and track experiments
- **Environment Setup**: UV/Conda environment management
- **Quality Assurance**: Pre-commit hooks, testing, linting
- **Document Generation**: Multi-format rendering (PDF, HTML, PPTX)
- **Infrastructure**: VM creation, Docker builds, cloud deployment

### Version Control Integration

The template includes hybrid version control:
- **Git**: Primary version control with GitHub Actions
- **Jujutsu** (optional): Enhanced academic workflows
- **Fossil** (optional): Self-contained manuscript archives

## Working with Generated Projects

### Initial Setup Commands
```bash
# In generated project
just setup                    # Full environment setup
just install                  # Install dependencies only
just git-setup               # Pre-commit hooks and nbwipers
```

### Analysis Workflow
```bash
# Create notebooks
just notebooks new-eda "dataset-analysis"
just notebooks new-model "random-forest" --stage="05-models"

# Run analysis
just notebooks run "path/to/notebook.qmd"
just notebooks run-stage "02-exploration"
just analysis pipeline       # Run DVC pipeline
```

### Academic Writing
```bash
# Manuscript workflow
cd writeup/manuscript
just manuscript-new "paper-title"
just manuscript-render

# Presentations  
cd writeup/presentation
just presentation-new "talk-name" --template="revealjs"
just presentation-render "talk-name"

# Reports and grants
cd writeup/report
just report-new "technical-report"
cd writeup/grants  
just grant-new-nsf "proposal-name"
```

### Progressive Enhancement (Beginner-Friendly)
```bash
# See what components can be added to project
just show-available

# Get personalized recommendations
just recommend

# Interactive wizard for guided expansion
just wizard

# Add specific components
just expand data-versioning
just expand experiment-tracking
just expand academic-writing
just expand ci-cd

# Apply changes to project
just apply-changes

# Upgrade minimal project to full academic project
just upgrade-to-full
```

### Testing and Quality
```bash
just test-cov                 # Run tests with coverage
just clean                    # Clean generated files
uv run pre-commit run --all-files  # Code quality checks
```

## Template Development Guidelines

### Template Testing with copier-template-tester

```bash
# Run all test scenarios
ctt run

# Using the convenience script
./ctt-test-template.sh

# Test specific configurations from ctt.toml
ctt run --config=full-academic
ctt run --config=minimal-starter
ctt run --config=maximum-everything
```

### Adding New Features

1. **Template Variables**: Add to `copier.yml` with proper validation and conditional logic
2. **File Templates**: Use Jinja2 templating in `.jinja` files
3. **Just Recipes**: Add automation commands to appropriate `.just` files
4. **Testing**: Add comprehensive test cases to `ctt.toml` for new features
5. **Documentation**: Update template documentation in generated README.md.jinja

### Template File Organization

- **Root Level**: Core project files (pyproject.toml.jinja, justfile.jinja)
- **Conditional Directories**: Use `{% if condition %}` for optional components
- **Shared Templates**: Common templates in `template/` with Jinja2 variables
- **Module Organization**: Separate Just files for different functional areas
- **Template Structure**: `template/` contains all template files, `_subdirectory: template` in copier.yml

### Key Template Variables

Important variables from `copier.yml`:
- `project_type`: Determines overall project structure (Minimal Starter, Full Academic Project, etc.)
- `include_analysis`/`include_writeup`/`include_infrastructure`: Main component toggles
- `programming_language`: Python/R/Both language selection
- `experiment_tracking`: MLflow/Weights & Biases/Neptune integration
- `documentation_format`: Jupyter Notebooks/Quarto/RMarkdown/Markdown
- `data_versioning`/`data_validation`: Data pipeline components
- `github_actions`/`pre_commit_hooks`: CI/CD configuration

### Multi-Language Support Architecture

The template handles multiple programming languages through:
- **Conditional Dependencies**: Language-specific packages in pyproject.toml.jinja
- **Environment Management**: UV for Python, renv for R, separate environments
- **Notebook Templates**: Language-specific Quarto templates
- **Script Organization**: Separate directories for each language in analysis/scripts/
- **Testing Frameworks**: pytest for Python, testthat for R

## Testing Strategy

### Template Testing
The repository uses `copier-template-tester` with comprehensive configurations in `ctt.toml`:

#### Core Test Scenarios
- **full-academic**: Complete academic project with analysis + writeup + infrastructure
- **analysis-only**: Data science pipeline focused project
- **manuscript-only**: Academic writing focused project
- **package-dev**: Software/library development project
- **minimal-starter**: Beginner-friendly minimal setup

#### Progressive Enhancement Tests
- **progressive-minimal-tracking**: Minimal project + experiment tracking
- **progressive-minimal-writeup**: Minimal project + writing tools
- **progressive-full-upgrade**: Complete feature upgrade scenario

#### Language and Documentation Tests
- **docs-markdown**: Markdown documentation format
- **docs-rmarkdown**: R-focused with RMarkdown
- **package-dev-r**: R package development
- **package-dev-multilang**: Multi-language package

#### Infrastructure and CI/CD Tests
- **infra-docker-only**: Docker containerization only
- **infra-cloud**: Cloud deployment focused
- **infra-virtualization**: VM-based development
- **ci-gha-only**: GitHub Actions only
- **ci-precommit-only**: Pre-commit hooks only

#### Experiment Tracking Variants
- **tracking-wandb**: Weights & Biases with Python
- **tracking-neptune-r**: Neptune with R

#### Edge Cases and Stress Tests
- **absolutely-minimal**: Bare minimum configuration
- **maximum-everything**: All features enabled (stress test)

#### Version Control Tests
- **vcs-jujutsu**: Jujutsu version control
- **vcs-fossil**: Fossil version control
- **vcs-hybrid**: Both Jujutsu and Fossil

### Generated Project Testing
Generated projects include testing infrastructure:
- **Python**: pytest with coverage reporting
- **R**: testthat framework integration  
- **Data Validation**: Great Expectations and Pandera integration
- **Notebook Testing**: nbwipers for clean notebook commits

## Infrastructure and Deployment

### Environment Management
- **UV**: Primary Python package manager with lock files
- **Pixi**: Multi-language conda environment management
- **mise**: Runtime version management

### Containerization
- **Docker**: Multi-stage builds with development and production targets
- **Development Containers**: VS Code devcontainer integration

### Cloud Integration
- **AWS/GCP/Azure**: Cloud deployment templates
- **Multipass**: Local VM development environments
- **GitHub Actions**: CI/CD pipeline automation

## Common Patterns and Conventions

### File Naming
- **Notebooks**: `YYYYMMDD_HHMM_stage_description.qmd` format
- **Experiments**: Timestamped with descriptive names
- **Scripts**: Organized by language and function

### Directory Structure Conventions
- **Analysis**: 10-stage numbered pipeline (00-10)
- **Data**: 8-level processing pipeline (01_raw to 08_reporting)
- **Writing**: Document type separation (manuscript, presentation, reports)

### Documentation Standards
- **Quarto**: Primary documentation format with multi-output rendering
- **Academic Citations**: BibTeX integration with cross-referencing
- **API Documentation**: Sphinx for Python, roxygen2 for R packages

## Quality Assurance and Contributing

### Code Quality Tools
The template and generated projects enforce quality through:
- **pre-commit hooks**: Configured in `.pre-commit-config.yaml`
  - `trailing-whitespace`, `end-of-file-fixer`, `check-yaml`
  - `typos` for spell checking
  - `markdownlint-cli2` for markdown formatting
  - `bibtex-tidy` for bibliography formatting
- **UV**: Fast Python package management with lock files
- **nbwipers**: Clean notebook commits without outputs

### Template Development Workflow
1. **Local Testing**: Use `copier copy . test-project` for manual testing
2. **Comprehensive Testing**: Run `ctt run` for all test scenarios
3. **Quality Checks**: Run `pre-commit run --all-files` before commits
4. **Documentation**: Update README.md, WARP.md, and CONTRIBUTING.md as needed
5. **Feature Testing**: Add new test scenarios to `ctt.toml` for new features

### Contributing Guidelines
Key points from CONTRIBUTING.md:
- **Conventional Commits**: Use `feat`, `fix`, `docs`, `test`, etc.
- **Branch Naming**: `feature/`, `fix/`, `docs/`, `refactor/` prefixes
- **Testing Requirements**: All changes must pass template generation and project setup
- **Documentation**: Update relevant documentation for new features
- **Review Process**: Automated checks + maintainer review within 1-2 weeks

### Development Prerequisites
- Python 3.11+
- Copier, Just, Git
- pre-commit for quality checks
- pytest for testing

This template repository enables creating sophisticated research projects with professional-grade automation, multi-language support, and comprehensive academic writing workflows.
