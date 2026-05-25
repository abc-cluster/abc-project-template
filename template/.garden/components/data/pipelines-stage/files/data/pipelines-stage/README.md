# Pipeline Management System

Organized workflow execution with both Nextflow and Snakemake support for a single research project.

## Directory Structure

```
15_pipelines/
├── 151_nextflow/           # Nextflow pipeline management
│   ├── pipelines/          # Pipeline definitions
│   ├── experiments/        # Experiment results
│   │   ├── by_analysis/    # Organized by analysis type (RECOMMENDED)
│   │   ├── by_dataset/     # Organized by input dataset
│   │   └── archive/        # Archived completed analyses
│   ├── shared/             # Shared resources
│   │   ├── configs/        # Reusable configurations
│   │   ├── containers/     # Container definitions
│   │   └── references/     # Reference data
│   └── .pipeline_name      # Current active pipeline name
├── 152_snakemake/          # Snakemake workflow management
│   ├── workflows/          # Workflow definitions
│   ├── experiments/        # Experiment results
│   │   ├── by_analysis/    # Organized by analysis type
│   │   ├── by_dataset/     # Organized by input dataset
│   │   └── archive/        # Archived completed analyses
│   ├── shared/             # Shared resources
│   │   ├── configs/        # Cluster profiles and configs
│   │   ├── environments/   # Conda environment files
│   │   └── resources/      # Scripts and reference files
│   └── .workflow_name      # Current active workflow name
└── README.md               # This file
```

## Available Systems

### 🧬 Nextflow (151_nextflow/)
- **Use Case**: Complex multi-step pipelines, cloud computing, containerized workflows
- **Strengths**: Excellent for distributed computing, strong container support, robust caching
- **Best For**: Genomics pipelines, large-scale data processing, cloud deployment

### 🐍 Snakemake (152_snakemake/)
- **Use Case**: Python-based workflows, conda environments, rule-based processing
- **Strengths**: Python integration, automatic dependency resolution, conda environments
- **Best For**: Python-heavy analyses, bioinformatics, reproducible research environments

## Quick Start

### Nextflow Workflows

```bash
# Create and set pipeline
just data::nextflow-create-pipeline rna_analysis
just data::nextflow-set-pipeline rna_analysis

# Run analysis
just data::nextflow-run-experiment differential_expression dataset_001

# View results
just data::nextflow-list-analyses
just data::nextflow-analysis-results differential_expression

# Publish results
just data::nextflow-publish-analysis differential_expression 20250704 primary
```

### Snakemake Workflows (Coming Soon)

```bash
# Create and set workflow
just data::snakemake-create-workflow variant_calling
just data::snakemake-set-workflow variant_calling

# Run analysis
just data::snakemake-run-analysis genotyping sample_cohort_1

# View results
just data::snakemake-list-analyses
just data::snakemake-analysis-results genotyping
```

## When to Use Which System

### Choose Nextflow When:
- You need to run on multiple computing environments (local, cluster, cloud)
- Your pipeline involves multiple programming languages
- You want strong container/Docker support
- You need robust caching and resume capabilities
- Your pipeline will scale to very large datasets

### Choose Snakemake When:
- Your analysis is primarily Python-based
- You want tight integration with conda environments
- You prefer rule-based workflow definition
- You need automatic dependency tracking
- Your team is more familiar with Python ecosystems

## Integration with Data Pipeline

Both systems automatically integrate with the existing data structure:

1. **Raw Data Input**: Reads from `01_raw/` directories
2. **Intermediate Processing**: Uses appropriate intermediate directories
3. **Final Results**: Publishes to `03_primary/`, `08_reporting/`, etc.
4. **Quality Control**: Integrates with existing validation tools

## Publishing Destinations

- **`primary`** → `03_primary/033_versioned/` - For further analysis
- **`reporting`** → `08_reporting/` - For visualization and reports  
- **`publication`** → `12_publications/datasets/` - For paper preparation

## Organization Strategy

### By Analysis (Recommended)
Organize by the type of analysis being performed:
```
experiments/by_analysis/
├── differential_expression/
├── pathway_analysis/
├── quality_control/
└── variant_calling/
```

### By Dataset
Useful when running multiple analyses on the same datasets:
```
experiments/by_dataset/
├── cohort_primary/
├── cohort_validation/
└── public_reference/
```

## Available Commands

### Nextflow Commands
- `nextflow-set-pipeline <name>` - Set current active pipeline
- `nextflow-get-pipeline` - Show current pipeline name
- `nextflow-run-experiment <analysis> <dataset>` - Run with current pipeline
- `nextflow-run-with-pipeline <pipeline> <analysis> <dataset>` - Run specific pipeline
- `nextflow-list-analyses` - List all analyses
- `nextflow-analysis-results <analysis>` - View analysis results
- `nextflow-publish-analysis <analysis> <run_id> <dest>` - Publish results
- `nextflow-clean-work <analysis> [days]` - Clean old work directories
- `nextflow-create-pipeline <name>` - Create new pipeline template

### Snakemake Commands (Planned)
- `snakemake-set-workflow <name>` - Set current active workflow
- `snakemake-get-workflow` - Show current workflow name
- `snakemake-run-analysis <analysis> <dataset>` - Run with current workflow
- `snakemake-list-analyses` - List all analyses
- `snakemake-analysis-results <analysis>` - View analysis results
- `snakemake-publish-analysis <analysis> <run_id> <dest>` - Publish results
- `snakemake-create-workflow <name>` - Create new workflow template

## Best Practices

### Workflow Organization
- Use descriptive names for analyses and datasets
- Document parameter choices and configurations
- Archive completed analyses regularly
- Use version control for workflow definitions

### Resource Management
- Monitor resource usage in reports
- Clean work directories regularly to save disk space
- Use appropriate computing profiles for your environment

### Reproducibility
- Pin software versions in containers/environments
- Document all parameter files
- Provide execution metadata for each run
- Use consistent naming conventions

This dual-pipeline system provides flexibility to choose the best tool for each specific analysis while maintaining consistent data organization and automation! 🚀
