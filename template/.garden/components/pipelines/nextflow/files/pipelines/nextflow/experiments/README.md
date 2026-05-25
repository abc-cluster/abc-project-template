# Nextflow Experiments Documentation

This directory contains experiment tracking and documentation for Nextflow pipeline runs.

## Directory Structure

```
nextflow/
├── experiments/
│   ├── README.md                    # This file
│   ├── samplesheets/               # Input samplesheets for different experiments
│   │   ├── templates/
│   │   └── experiments/
│   ├── configs/                    # Parameter configurations for experiments
│   │   ├── base.config
│   │   ├── development.config
│   │   └── production.config
│   ├── runs/                       # Individual experiment run documentation
│   │   ├── YYYY-MM-DD_experiment-name/
│   │   └── templates/
│   ├── logs/                       # Pipeline execution logs
│   └── reports/                    # Generated reports and summaries
├── profiles/                       # Nextflow execution profiles
└── tower/                         # Tower-specific configurations
```

## Experiment Workflow

### 1. Pre-Experiment Setup
1. Create samplesheet in `samplesheets/experiments/`
2. Configure parameters in `configs/`
3. Document experiment plan in `runs/YYYY-MM-DD_experiment-name/`

### 2. Execution
- Run via Tower with proper experiment tags
- Monitor progress through Tower dashboard
- Collect execution reports

### 3. Post-Execution Analysis
- Generate summary reports
- Document results and conclusions
- Archive successful configurations

## Naming Conventions

### Experiment Names
Format: `YYYY-MM-DD_[purpose]_[dataset]_[version]`

Examples:
- `2024-07-03_exploratory_cancer-samples_v1`
- `2024-07-03_production_batch-001_v2`

### Tower Run Names
Format: `[project]_[experiment-name]_[run-number]`

Examples:
- `cancer-study_exploratory_cancer-samples_run001`
- `data-processing_production_batch-001_run003`

## Documentation Requirements

Each experiment run should include:
1. **Experiment Plan** (`experiment-plan.md`)
2. **Parameter Configuration** (`params.yaml`)
3. **Samplesheet** (`samplesheet.csv`)
4. **Execution Log** (`execution-log.md`)
5. **Results Summary** (`results-summary.md`)

## Experiment Resumption

If an experiment fails and needs to be resumed, follow these steps:

### 1. Identify Failure Point
- Examine logs in `logs/` to determine the failure step.
- Review output files in `runs/YYYY-MM-DD_experiment-name/` for completeness.

### 2. Update Configuration
- Adjust parameters in the corresponding `runs/YYYY-MM-DD_experiment-name/params.yaml` if necessary.

### 3. Resume Experiment
- Use a new experiment name but reference the previous run for context.
- Ensure `resume` flag is used if supported by the pipeline.

### 4. Document Resumption
- Create a new entry in the `runs/` with linkage to the original experiment.

Example:
```bash
# Resume experiment
just nf-resume-experiment "2024-07-03_exploratory_cancer-samples_resume_v1"
```

## Best Practices

1. **Version Control**: Tag all configurations and samplesheets
2. **Documentation**: Document hypothesis, methodology, and results
3. **Reproducibility**: Ensure all parameters are captured
4. **Archival**: Archive successful experiments for future reference
5. **Tower Integration**: Use consistent tags and naming in Tower

## Quick Start

```bash
# Create new experiment
just nf-new-experiment "exploratory_cancer-samples"

# Run experiment
just nf-run-experiment "2024-07-03_exploratory_cancer-samples_v1"

# Generate report
just nf-report-experiment "2024-07-03_exploratory_cancer-samples_v1"
```

## Tools Integration

- **Tower**: Centralized monitoring and execution
- **Just**: Local automation and experiment management
- **Git**: Version control for configurations
- **Org-mode**: Structured documentation and reports
