# Investigation: 20251017_1145_deve-test-pipeline

## Quick Info

- **Type**: development
- **Scenario**: local-local
- **Created**: 2025-10-17 11:45:03
- **Researcher**: abhi
- **Status**: planned

## Purpose

Test investigation creation workflow

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

- `metadata.yaml` - Investigation metadata
- `execution.yaml` - Execution details
- `params.yaml` - Pipeline parameters
- `investigation-plan.md` - Pre-run planning
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
# View investigation status
just status 20251017_1145_deve-test-pipeline

# Fetch Tower metadata
just fetch-tower 20251017_1145_deve-test-pipeline

# Sync results
just sync-results 20251017_1145_deve-test-pipeline

# View in database
just query "SELECT * FROM investigations WHERE id='20251017_1145_deve-test-pipeline'"
```

## Notes

*Add your notes here*