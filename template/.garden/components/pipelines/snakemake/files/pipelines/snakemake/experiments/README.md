# Snakemake Experiments Documentation

This directory contains experiment tracking and documentation for Snakemake pipeline runs with comprehensive resume and failure handling capabilities.

## Directory Structure

```
snakemake/
├── experiments/
│   ├── README.md                    # This file
│   ├── config/                     # Configuration files for different experiments
│   │   ├── base.yaml
│   │   ├── development.yaml
│   │   └── production.yaml
│   ├── profiles/                   # Snakemake execution profiles
│   │   ├── local/
│   │   ├── cluster/
│   │   └── cloud/
│   ├── runs/                       # Individual experiment run documentation
│   │   ├── YYYY-MM-DD_experiment-name/
│   │   └── templates/
│   ├── logs/                       # Pipeline execution logs
│   ├── reports/                    # Generated reports and summaries
│   ├── rules/                      # Modular Snakemake rules
│   └── workflows/                  # Complete workflow definitions
├── Snakefile                      # Main Snakemake workflow
└── config.yaml                    # Default configuration
```

## Experiment Workflow

### 1. Pre-Experiment Setup
1. Create configuration in `config/experiments/`
2. Define samples in `samples.tsv`
3. Document experiment plan in `runs/YYYY-MM-DD_experiment-name/`

### 2. Execution
- Run with specific config and profile
- Monitor progress through logs and reports
- Handle failures with automatic resume capability

### 3. Post-Execution Analysis
- Generate comprehensive reports
- Document results and conclusions
- Archive successful configurations

## Naming Conventions

### Experiment Names
Format: `YYYY-MM-DD_[purpose]_[dataset]_[version]`

Examples:
- `2024-07-03_exploratory_rna-seq_v1`
- `2024-07-03_production_batch-processing_v2`

### Run Names
Format: `[project]_[experiment-name]_[attempt]`

Examples:
- `genomics_exploratory_rna-seq_attempt001`
- `proteomics_production_batch-processing_attempt002`

## Experiment Resumption

Snakemake provides excellent built-in resume capabilities. When an experiment fails:

### 1. Automatic Resume
- Snakemake automatically detects completed files
- Only re-runs failed or incomplete steps
- Preserves all successfully completed work

### 2. Manual Resume Strategies
- **Checkpoint Resume**: Use `--rerun-incomplete` to retry failed jobs
- **Forced Resume**: Use `--forcerun` to rerun specific rules
- **Clean Resume**: Remove problematic outputs and restart

### 3. Resume Documentation
- Track resume attempts in experiment logs
- Document failure points and resolution strategies
- Maintain lineage from original to resumed experiments

Example Resume Commands:
```bash
# Resume from last checkpoint
snakemake --rerun-incomplete --profile profiles/cluster

# Force rerun specific rule
snakemake --forcerun rule_name --profile profiles/cluster

# Resume with different configuration
snakemake --configfile config/experiments/experiment_resume_v1.yaml
```

## Documentation Requirements

Each experiment run should include:
1. **Experiment Plan** (`experiment-plan.md`)
2. **Configuration File** (`config.yaml`)
3. **Sample Sheet** (`samples.tsv`)
4. **Execution Log** (`execution-log.md`)
5. **Results Summary** (`results-summary.md`)
6. **Resume Log** (`resume-log.md`) - if applicable

## Best Practices

1. **Modular Design**: Use rule files for reusable components
2. **Configuration Management**: Separate configs for different experiment types
3. **Resource Management**: Define appropriate resources for each rule
4. **Checkpoint Strategy**: Use checkpoints for complex dependencies
5. **Resume Planning**: Design workflows to be resume-friendly
6. **Documentation**: Maintain detailed logs of all attempts

## Quick Start

```bash
# Setup experiment infrastructure
just smk-setup

# Create new experiment
just smk-new-experiment "rna-seq-analysis" "exploratory"

# Run experiment
just smk-run-experiment "2024-07-03_exploratory_rna-seq_v1" "cluster"

# Resume failed experiment
just smk-resume-experiment "2024-07-03_exploratory_rna-seq_v1" "incomplete"

# Generate comprehensive report
just smk-report-experiment "2024-07-03_exploratory_rna-seq_v1"
```

## Tools Integration

- **Snakemake**: Core workflow management with built-in resume
- **Conda/Mamba**: Environment management per rule
- **Singularity/Docker**: Containerized execution
- **Cluster Integration**: SLURM, PBS, SGE support
- **Cloud Execution**: AWS, GCP, Azure backends
- **Just**: Local automation and experiment management
- **Git**: Version control for workflows and configs

## Resume Strategies by Failure Type

### Compute Failures
- **Node failure**: `--rerun-incomplete` resumes automatically
- **Memory issues**: Adjust resources and `--forcerun` specific rules
- **Timeout**: Increase time limits and resume

### Data Failures
- **Missing input**: Fix data paths and `--rerun-incomplete`
- **Corrupted output**: Remove bad files and `--forcerun`
- **Permission issues**: Fix permissions and resume

### Code Failures
- **Bug fixes**: Update code and `--rerun-incomplete`
- **Parameter changes**: New config file and resume
- **Rule changes**: `--forcerun` affected rules

## Monitoring and Debugging

### Real-time Monitoring
```bash
# Watch log output
tail -f logs/experiment-name/snakemake.log

# Monitor cluster jobs
squeue -u $USER

# Check rule status
snakemake --summary
```

### Debugging Failed Jobs
```bash
# Detailed error information
snakemake --detailed-summary

# Debug specific rule
snakemake --debug rule_name

# Dry run to check workflow
snakemake --dry-run
```
