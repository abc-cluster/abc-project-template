# Snakemake Experiment Plan

## Basic Information
- **Experiment ID**: `{{experiment_id}}`
- **Date**: `{{date}}`
- **Researcher**: `{{researcher}}`
- **Project**: `{{project}}`

## Experiment Type
- [ ] New experiment
- [ ] Resumed experiment
- [ ] Replication experiment
- [ ] Parameter optimization

## Previous Experiment (if resumed)
- **Previous Experiment ID**: `{{previous_experiment_id}}`
- **Failure Point**: `{{failure_point}}`
- **Failed Rules**: `{{failed_rules}}`
- **Failure Reason**: `{{failure_reason}}`
- **Resume Strategy**: `{{resume_strategy}}`
- **Resume Command**: `{{resume_command}}`

## Objective
**Primary Goal**: 
{{objective}}

**Secondary Goals**:
- {{secondary_goal_1}}
- {{secondary_goal_2}}

## Hypothesis
{{hypothesis}}

## Methodology
### Data Sources
- **Sample Sheet**: `{{sample_sheet_path}}`
- **Input Data**: `{{input_data}}`
- **Reference Files**: `{{reference_files}}`
- **External Databases**: `{{external_databases}}`

### Workflow Configuration
- **Snakefile**: `{{snakefile_path}}`
- **Config File**: `{{config_file_path}}`
- **Profile**: `{{execution_profile}}`
- **Environment**: `{{conda_env}}`

### Key Parameters
```yaml
{{key_parameters}}
```

### Rules Overview
| Rule Name | Purpose | Resources | Expected Runtime |
|-----------|---------|-----------|------------------|
| {{rule_1}} | {{purpose_1}} | {{resources_1}} | {{runtime_1}} |
| {{rule_2}} | {{purpose_2}} | {{resources_2}} | {{runtime_2}} |

## Expected Outputs
### Primary Outputs
- {{output_1}}
- {{output_2}}

### Intermediate Files
- {{intermediate_1}}
- {{intermediate_2}}

### Reports and Visualizations
- {{report_1}}
- {{report_2}}

## Success Criteria
- [ ] {{success_criterion_1}}
- [ ] {{success_criterion_2}}
- [ ] All target files generated
- [ ] Quality control metrics met
- [ ] No failed jobs in final run

## Risk Assessment
### Potential Failure Points
- **Compute Resources**: {{compute_risk}}
- **Data Dependencies**: {{data_risk}}
- **Memory Requirements**: {{memory_risk}}
- **Time Constraints**: {{time_risk}}

### Mitigation Strategies
- **Resource Allocation**: {{resource_mitigation}}
- **Checkpointing**: {{checkpoint_strategy}}
- **Retry Logic**: {{retry_strategy}}
- **Fallback Plans**: {{fallback_plans}}

## Resource Requirements
### Compute Resources
- **CPU Cores**: {{cpu_requirements}}
- **Memory**: {{memory_requirements}}
- **Storage**: {{storage_requirements}}
- **Estimated Runtime**: {{estimated_runtime}}

### Software Dependencies
- **Conda Environments**: {{conda_environments}}
- **Containers**: {{containers}}
- **External Tools**: {{external_tools}}

## Execution Environment
### Local Execution
- **Cores Available**: {{local_cores}}
- **Memory Available**: {{local_memory}}

### Cluster Execution
- **Cluster**: {{cluster_name}}
- **Queue/Partition**: {{queue_partition}}
- **Max Jobs**: {{max_jobs}}
- **Job Scheduler**: {{job_scheduler}}

### Cloud Execution
- **Cloud Provider**: {{cloud_provider}}
- **Instance Types**: {{instance_types}}
- **Storage Backend**: {{storage_backend}}

## Quality Control
### Input Validation
- [ ] Sample sheet format check
- [ ] Input file existence verification
- [ ] Reference file integrity

### Process Monitoring
- [ ] Resource usage tracking
- [ ] Intermediate file validation
- [ ] Error log monitoring

### Output Validation
- [ ] Output file completeness
- [ ] Quality metrics evaluation
- [ ] Result consistency checks

## Reproducibility
### Version Control
- **Workflow Version**: {{workflow_version}}
- **Git Commit**: {{git_commit}}
- **Snakemake Version**: {{snakemake_version}}

### Environment Specification
- **Conda Lock Files**: {{conda_locks}}
- **Container Images**: {{container_images}}
- **System Information**: {{system_info}}

## Documentation Plan
### During Execution
- [ ] Monitor resource usage
- [ ] Track intermediate results
- [ ] Document any manual interventions

### Post-Execution
- [ ] Generate workflow report
- [ ] Document lessons learned
- [ ] Archive successful configuration
- [ ] Update best practices

## Resume Planning
### Checkpoint Strategy
- **Natural Checkpoints**: {{natural_checkpoints}}
- **Manual Checkpoints**: {{manual_checkpoints}}
- **Resume Points**: {{resume_points}}

### Resume Commands
```bash
# Standard resume
{{standard_resume_command}}

# Force rerun from specific rule
{{force_rerun_command}}

# Resume with modified config
{{modified_config_resume}}
```

## Notes
{{additional_notes}}

## Approval
- [ ] Reviewed by supervisor
- [ ] Resource allocation approved
- [ ] Ethics clearance (if required)
- [ ] Data usage permissions verified
