# Experiment: 20251017_1151_deve-test-workflow

## Quick Info

- **Type**: development
- **Scenario**: local-local
- **Created**: 2025-10-17 11:51:51
- **Researcher**: abhi
- **Status**: planned

## Purpose

Testing the complete experiment lifecycle

## Git State

- **Branch**: 
- **Commit**: 
- **Dirty**: false

## Tower

- **Run ID**: 
- **Workspace**: default
- **URL**: 

## Key Results

*To be filled after execution*

## Files

- `metadata.yaml` - Experiment metadata
- `execution.yaml` - Execution details
- `params.yaml` - Pipeline parameters
- `experiment-plan.md` - Pre-run planning
- `execution-log.md` - Post-run notes
- `results-manifest.yaml` - Result file locations
- `git-info.yaml` - Git repository state
- `tower-info.yaml` - Tower metadata

## Directories

- `nextflow-logs/` - Nextflow .nextflow.log files
- `reports/` - Execution reports (timeline, trace, report)
- `reports/tower/` - Reports downloaded from Tower

## Quick Commands

```bash
# View experiment status
just status 20251017_1151_deve-test-workflow

# Fetch Tower metadata
just fetch-tower 20251017_1151_deve-test-workflow

# Sync results
just sync-results 20251017_1151_deve-test-workflow

# View in database
just query "SELECT * FROM experiments WHERE id='20251017_1151_deve-test-workflow'"
```

## Notes

*Add your notes here*