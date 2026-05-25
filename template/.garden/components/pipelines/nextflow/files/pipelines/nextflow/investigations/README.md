# Nextflow Investigations Documentation

This directory contains investigation tracking and documentation for Nextflow pipeline runs.

## Directory Structure

```
nextflow/
├── investigations/
│   ├── README.md                    # This file
│   ├── samplesheets/               # Input samplesheets for different investigations
│   │   ├── templates/
│   │   └── investigations/
│   ├── configs/                    # Parameter configurations for investigations
│   │   ├── base.config
│   │   ├── development.config
│   │   └── production.config
│   ├── runs/                       # Individual investigation run documentation
│   │   ├── YYYY-MM-DD_investigation-name/
│   │   └── templates/
│   ├── logs/                       # Pipeline execution logs
│   └── reports/                    # Generated reports and summaries
├── profiles/                       # Nextflow execution profiles
└── tower/                         # Tower-specific configurations
```

## Investigation Workflow

### 1. Pre-Investigation Setup
1. Create samplesheet in `samplesheets/investigations/`
2. Configure parameters in `configs/`
3. Document investigation plan in `runs/YYYY-MM-DD_investigation-name/`

### 2. Execution
- Run via Tower with proper investigation tags
- Monitor progress through Tower dashboard
- Collect execution reports

### 3. Post-Execution Analysis
- Generate summary reports
- Document results and conclusions
- Archive successful configurations

## Naming Conventions

### Investigation Names
Format: `YYYY-MM-DD_[purpose]_[dataset]_[version]`

Examples:
- `2024-07-03_exploratory_cancer-samples_v1`
- `2024-07-03_production_batch-001_v2`

### Tower Run Names
Format: `[project]_[investigation-name]_[run-number]`

Examples:
- `cancer-study_exploratory_cancer-samples_run001`
- `data-processing_production_batch-001_run003`

## Documentation Requirements

Each investigation run should include:
1. **Investigation Plan** (`investigation-plan.md`)
2. **Parameter Configuration** (`params.yaml`)
3. **Samplesheet** (`samplesheet.csv`)
4. **Execution Log** (`execution-log.md`)
5. **Results Summary** (`results-summary.md`)

## Investigation Resumption

If an investigation fails and needs to be resumed, follow these steps:

### 1. Identify Failure Point
- Examine logs in `logs/` to determine the failure step.
- Review output files in `runs/YYYY-MM-DD_investigation-name/` for completeness.

### 2. Update Configuration
- Adjust parameters in the corresponding `runs/YYYY-MM-DD_investigation-name/params.yaml` if necessary.

### 3. Resume Investigation
- Use a new investigation name but reference the previous run for context.
- Ensure `resume` flag is used if supported by the pipeline.

### 4. Document Resumption
- Create a new entry in the `runs/` with linkage to the original investigation.

Example:
```bash
# Resume investigation
just nf-resume-investigation "2024-07-03_exploratory_cancer-samples_resume_v1"
```

## Best Practices

1. **Version Control**: Tag all configurations and samplesheets
2. **Documentation**: Document hypothesis, methodology, and results
3. **Reproducibility**: Ensure all parameters are captured
4. **Archival**: Archive successful investigations for future reference
5. **Tower Integration**: Use consistent tags and naming in Tower

## Quick Start

```bash
# Create new investigation
just nf-new-investigation "exploratory_cancer-samples"

# Run investigation
just nf-run-investigation "2024-07-03_exploratory_cancer-samples_v1"

# Generate report
just nf-report-investigation "2024-07-03_exploratory_cancer-samples_v1"
```

## Tools Integration

- **Tower**: Centralized monitoring and execution
- **Just**: Local automation and investigation management
- **Git**: Version control for configurations
- **Org-mode**: Structured documentation and reports
