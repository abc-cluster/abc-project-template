# 🔬 Comprehensive Data Science & Analysis Template

> **A production-ready template for end-to-end data science projects, from exploration to publication**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Copier](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/copier-org/copier/master/img/badge/badge-grayscale-inverted-border-orange.json)](https://github.com/copier-org/copier)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Just](https://img.shields.io/badge/task_runner-just-blue)](https://github.com/casey/just)
[![Quarto](https://img.shields.io/badge/documentation-Quarto-blue)](https://quarto.org/)

This is a comprehensive template built with [Copier](https://github.com/copier-org/copier) for creating professional data science projects that scale from exploration to publication. It provides a complete workflow covering data analysis, machine learning, academic writing, and deployment.

## 🚀 Quick Start (Beginner-Friendly)

```shell
# Create a minimal, beginner-friendly project (accepts all defaults)
copier copy --trust gh:abhi18av/template-analysis-and-writeup my-analysis-project
cd my-analysis-project

# Set up the development environment
just setup

# Start your first analysis
just notebooks new-eda "initial-exploration"

# See what you can add as you grow
just show-available
```

> 🌱 **New to data science?** You'll start with a simple project containing just notebooks and basic documentation. Add more features when you're ready!
>
> 💾 **Git ready**: A git repository is automatically initialized with your first commit, so you can start version control immediately!
>
> 🎓 **Experienced user?** Choose "Full Academic Project" during setup or run `just upgrade-to-full` later.

## ✨ Key Features

- 📊 **10-Stage Analysis Pipeline**: From data extraction to deployment
- 📝 **Comprehensive Academic Writing**: Complete ecosystem for research dissemination
- 🔄 **Reproducible Workflows**: DVC pipelines and environment management
- 🤖 **Multi-Language Support**: Python, R, Julia, Clojure, and more
- 🐳 **Infrastructure as Code**: Docker, Terraform, and VM provisioning
- 📈 **Experiment Tracking**: MLflow, Weights & Biases integration
- ✅ **Data Validation**: Great Expectations and Pandera frameworks
- 🔍 **Code Quality**: Pre-commit hooks, testing, and linting
- 📖 **Rich Documentation**: Quarto-based reports and documentation

### 🎯 Enhanced Academic Writing System

- **📄 Presentations**: Academic, corporate, and workshop templates with automation
- **📝 Abstracts**: Conference, journal, and symposium abstract management with tracking
- **💰 Grants**: NSF, NIH, DOE, and foundation proposal templates with deadlines
- **📋 Reports**: Technical, executive, project, and grant progress reports
- **🎨 Posters**: Academic, conference, and professional poster templates
- **⚡ Automation**: Just-based commands for creation, rendering, and management
- **🔄 Workflow**: Complete lifecycle from draft to publication with version control

## Features

### Project structure

It is assumed that most of the work will be done in Jupyter Notebooks.
However, the template also includes a python project, in which you can put functions and classes shared across notebooks.
The repository is set up to use [Pytest](https://docs.pytest.org/en/stable/) for unit testing this module code.

The template also includes a `data` directory whose contents will be ignored by git.
You can use this folder to store data that you do not commit.
You may also put a readme file in which you can document the source datasets you use and how to acquire them.

### [just](https://github.com/casey/just)

`just` is a command runner that allows you to easily to run project-specific commands.
In fact, you can use `just` to run all the setup commands listed below:

```shell
just setup
```

### [pre-commit](https://github.com/pre-commit/pre-commit)

pre-commit is a tool that runs checks on your files before you commit them with git, thereby helping ensure code quality.
Enable it with the following command:

```shell
pre-commit install --install-hooks
```

The configuration is stored in `.pre-commit-config.yaml`.

### Github Actions

You may optionally add a github workflow file which checks the following:

- uses ruff to check files are formatted and linted
- Runs unit tests and checks coverage
- Checks any markdown files are formatted with [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- Checks that all jupyter notebooks are clean

### [Typos](https://github.com/crate-ci/typos)

Typos checks for common typos in code, aiming for a low false positive rate.
The repository is configured not to use it for Jupyter notebook files, as it tends to find errors in cell outputs.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Key Features](#-key-features)
- [Project Structure](#-project-structure)
- [Workflow Overview](#-workflow-overview)
- [Technology Stack](#-technology-stack)
- [Getting Started](#-getting-started)
- [Usage Examples](#-usage-examples)
- [Configuration](#-configuration)
- [Contributing](#-contributing)
- [License](#-license)

## 📁 Project Structure

```
my-analysis-project/
├── analysis/                    # Main analysis directory
│   ├── notebooks/              # Organized analysis notebooks
│   │   ├── 00_scratch/         # Quick experiments
│   │   ├── 01-data/            # Data processing pipeline
│   │   ├── 02-exploration/     # Exploratory data analysis
│   │   ├── 03-analysis/        # Statistical analysis
│   │   ├── 04-feat_eng/        # Feature engineering
│   │   ├── 05-models/          # Model development
│   │   ├── 06-interpretation/  # Model interpretation
│   │   ├── 07-reports/         # Result summaries
│   │   ├── 08-deploy/          # Deployment preparation
│   │   ├── 09-governance/      # Model governance
│   │   └── 10-iteration/       # Continuous improvement
│   ├── scripts/                # Production scripts
│   ├── data/                   # Data pipeline structure
│   ├── tests/                  # Testing framework
│   └── infrastructure/         # Infrastructure as code
├── writeup/                    # Academic writing ecosystem
│   ├── manuscript/             # Journal articles & papers
│   ├── presentation/           # Conference presentations & slides
│   │   ├── templates/          # Academic, corporate, workshop templates
│   │   ├── presentations/      # Your presentation projects
│   │   └── _output/            # Rendered presentations (PDF/HTML)
│   ├── abstracts/              # Conference & journal abstracts
│   │   ├── templates/          # Abstract templates by type
│   │   ├── conference/         # Conference abstracts
│   │   ├── journal/            # Journal abstracts
│   │   ├── symposium/          # Workshop & symposium abstracts
│   │   └── tracking/           # Deadline & review tracking
│   ├── grants/                 # Grant applications & management
│   │   ├── templates/          # NSF, NIH, DOE, private foundation templates
│   │   ├── applications/       # Active, submitted, awarded grants
│   │   ├── assets/             # Supporting materials & budgets
│   │   └── tracking/           # Deadlines & progress tracking
│   ├── report/                 # Technical reports & documentation
│   │   ├── templates/          # Technical, executive, project, grant reports
│   │   ├── reports/            # Your report projects
│   │   └── _output/            # Rendered reports (PDF/HTML/DOCX)
│   ├── poster/                 # Academic & professional posters
│   │   ├── templates/          # Academic, conference, professional templates
│   │   ├── posters/            # Your poster projects
│   │   └── _output/            # Rendered posters (PDF/HTML)
│   └── blog/                   # Blog posts & informal writing
├── justfile                    # Task automation
├── pyproject.toml              # Python project configuration
└── README.md                   # Project documentation
```

## 🔄 Workflow Overview

### 1. Data Science Pipeline

```mermaid
flowchart TD
    A[Data Extraction] --> B[Data Cleaning]
    B --> C[Exploratory Analysis]
    C --> D[Feature Engineering]
    D --> E[Model Development]
    E --> F[Model Evaluation]
    F --> G[Deployment]
    G --> H[Monitoring]
```

### 2. Academic Workflow

```mermaid
flowchart LR
    A[Analysis] --> B[Results]
    B --> C[Manuscript]
    C --> D[Peer Review]
    D --> E[Publication]
    
    A --> F[Grant Proposal]
    F --> G[Funding]
    G --> A
```

## 🛠 Technology Stack

### Core Technologies
- **[Python](https://python.org/)**: Primary programming language
- **[R](https://r-project.org/)**: Statistical computing
- **[Quarto](https://quarto.org/)**: Scientific publishing
- **[Just](https://github.com/casey/just)**: Task automation
- **[uv](https://github.com/astral-sh/uv)**: Python package management

### Data & ML
- **[DVC](https://dvc.org/)**: Data version control
- **[MLflow](https://mlflow.org/)**: Experiment tracking
- **[Great Expectations](https://greatexpectations.io/)**: Data validation
- **[Pandera](https://pandera.readthedocs.io/)**: Data validation framework

### Infrastructure
- **[Docker](https://docker.com/)**: Containerization
- **[Terraform](https://terraform.io/)**: Infrastructure as code
- **[Multipass](https://multipass.run/)**: VM management

### Quality & Testing
- **[Ruff](https://github.com/astral-sh/ruff)**: Python linting and formatting
- **[pre-commit](https://pre-commit.com/)**: Git hooks
- **[pytest](https://pytest.org/)**: Testing framework

## 🎯 Getting Started

### Prerequisites

- Python 3.11+
- [Copier](https://copier.readthedocs.io/)
- [Just](https://just.systems/)
- [Git](https://git-scm.com/)

### Installation

1. **Install Copier**:
   ```shell
   pip install copier
   ```

2. **Install Just** (choose your platform):
   ```shell
   # macOS
   brew install just
   
   # Linux (cargo)
   cargo install just
   
   # Or download from releases
   ```

3. **Generate Project**:
   ```shell
   copier copy gh:abhi18av/template-analysis-and-writeup my-project
   cd my-project
   ```

4. **Initialize Environment**:
   ```shell
   just setup
   ```

## 💡 Usage Examples

### Creating Experiments

```shell
# Create EDA notebook
just notebooks new-eda "customer-segmentation"

# Create modeling experiment
just notebooks new-model "random-forest" --stage="05-models" --type="advanced"

# Create custom experiment
just notebooks new-experiment "hypothesis-test" "03-analysis/031_hypothesis_testing"
```

### Running Analysis

```shell
# Run specific notebook
just notebooks run "02-exploration/eda_20241201_customer-segmentation.qmd"

# Run entire stage
just notebooks run-stage "05-models"

# Execute DVC pipeline
just analysis pipeline
```

### Managing Experiments

```shell
# List all notebooks
just notebooks list

# Search experiments
just notebooks search "machine learning"

# Generate experiment report
just notebooks report "customer-segmentation"
```

### Academic Writing

```shell
# Manuscript writing
just writeup manuscript-new "customer-analysis-paper"
just writeup manuscript-render

# Presentations and slides
cd writeup/presentation
just create-academic "research-talk"
just render-presentation "research-talk" format=revealjs

# Abstract management
cd writeup/abstracts
just new-conference "conference-abstract" "ICML-2024"
just list-submitted

# Grant applications
cd writeup/grants
just new-nsf "data-science-grant"
just deadlines

# Reports and documentation
cd writeup/report
just create-technical "analysis-report"
just render-report "analysis-report" format=pdf

# Poster creation
cd writeup/poster
just create-academic "conference-poster"
just render-poster academic "conference-poster"
```

### Infrastructure Management

```shell
# Create development VM
just infrastructure vm-create

# Deploy to cloud
just infrastructure deploy-cloud

# Monitor resources
just infrastructure status
```

## ⚙️ Configuration

### Project Configuration

The template uses several configuration files:

- `copier.yml`: Template configuration
- `pyproject.toml`: Python project settings
- `justfile`: Task automation
- `dvc.yaml`: Data pipeline definition
- `.pre-commit-config.yaml`: Code quality hooks

### Environment Variables

Create a `.env` file for sensitive configuration:

```shell
# Experiment tracking
MLFLOW_TRACKING_URI=https://your-mlflow-server.com
WANDB_API_KEY=your-wandb-key

# Cloud credentials
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret

# Database connections
DATABASE_URL=postgresql://user:pass@localhost:5432/db
```

### Customization Options

When generating a project, you can customize:

- Programming languages (Python, R, both)
- Experiment tracking platform
- Documentation format
- Deployment options
- Infrastructure components

## 🔧 Advanced Features

### Multi-Language Support

The template supports multiple programming languages with consistent structure:

```shell
# Python analysis
just notebooks new-experiment "python-analysis" "02-exploration" --lang=python

# R analysis  
just notebooks new-experiment "r-analysis" "02-exploration" --lang=r

# Julia analysis
just notebooks new-experiment "julia-analysis" "02-exploration" --lang=julia
```

### Data Validation

Integrated data validation with multiple frameworks:

```python
# Use Great Expectations
from analysis.validation import create_expectation_suite
suite = create_expectation_suite(df, "customer_data")

# Use Pandera schemas
from analysis.validation import validate_dataframe
validated_df = validate_dataframe(df, "customer_schema")
```

### Experiment Tracking

Automatic experiment logging:

```python
# MLflow integration
import mlflow
with mlflow.start_run():
    mlflow.log_param("model_type", "random_forest")
    mlflow.log_metric("accuracy", 0.95)
    mlflow.sklearn.log_model(model, "model")
```

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```shell
# Clone the template repository
git clone https://github.com/abhi18av/template-analysis-and-writeup.git
cd template-analysis-and-writeup

# Test the template
copier copy . test-project
cd test-project
just setup
```

### Testing

```shell
# Run template tests
pytest tests/

# Test with copier-template-tester
ctt test
```

## 📚 Resources

- [Documentation](https://github.com/abhi18av/template-analysis-and-writeup/wiki)
- [Examples](https://github.com/abhi18av/template-analysis-and-writeup/tree/main/examples)
- [Best Practices](https://github.com/abhi18av/template-analysis-and-writeup/wiki/best-practices)
- [Troubleshooting](https://github.com/abhi18av/template-analysis-and-writeup/wiki/troubleshooting)

## 🏆 Acknowledgments

- [Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/)
- [Kedro](https://kedro.readthedocs.io/)
- [DVC](https://dvc.org/)
- [MLflow](https://mlflow.org/)
- [Quarto](https://quarto.org/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the data science community**

Test with [Copier](https://github.com/copier-org/copier) and [copier-template-tester](https://github.com/KyleKing/copier-template-tester).
