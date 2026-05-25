# Snakemake Execution Log

## Experiment Information
- **Experiment ID**: `{{experiment_id}}`
- **Date**: `{{date}}`
- **Researcher**: `{{researcher}}`
- **Attempt Number**: `{{attempt_number}}`
- **Resumed From**: `{{resumed_from}}` (if applicable)

## Execution Details
### Workflow Information
- **Snakefile**: `{{snakefile_path}}`
- **Config File**: `{{config_file}}`
- **Working Directory**: `{{working_directory}}`
- **Profile**: `{{execution_profile}}`
- **Snakemake Version**: `{{snakemake_version}}`

### Command Line
```bash
{{command_line}}
```

### Execution Timeline
- **Start Time**: `{{start_time}}`
- **End Time**: `{{end_time}}`
- **Duration**: `{{duration}}`
- **Status**: `{{status}}`

### Resource Allocation
- **Max Jobs**: `{{max_jobs}}`
- **Local Cores**: `{{local_cores}}`
- **Total CPU Hours**: `{{total_cpu_hours}}`
- **Peak Memory Usage**: `{{peak_memory}}`
- **Disk Usage**: `{{disk_usage}}`

## Resume Information (if applicable)
### Previous Attempt
- **Previous Attempt ID**: `{{previous_attempt_id}}`
- **Previous Status**: `{{previous_status}}`
- **Failure Reason**: `{{failure_reason}}`
- **Failed Rules**: `{{failed_rules}}`

### Resume Strategy
- **Resume Method**: `{{resume_method}}`
- **Resume Command**: `{{resume_command}}`
- **Files Reused**: `{{files_reused}}`
- **Rules Rerun**: `{{rules_rerun}}`

### Changes Made
- **Configuration Changes**: `{{config_changes}}`
- **Resource Adjustments**: `{{resource_adjustments}}`
- **Code Modifications**: `{{code_modifications}}`

## Rule Execution Summary
| Rule | Status | Jobs | Duration | CPU Time | Memory | Exit Codes |
|------|--------|------|----------|----------|---------|------------|
| {{rule_1}} | {{status_1}} | {{jobs_1}} | {{duration_1}} | {{cpu_1}} | {{memory_1}} | {{exit_1}} |
| {{rule_2}} | {{status_2}} | {{jobs_2}} | {{duration_2}} | {{cpu_2}} | {{memory_2}} | {{exit_2}} |

## Job Statistics
### Successful Jobs
- **Total Successful**: `{{successful_jobs}}`
- **Average Runtime**: `{{avg_runtime}}`
- **Total CPU Time**: `{{total_cpu_time}}`

### Failed Jobs
- **Total Failed**: `{{failed_jobs}}`
- **Failure Reasons**: `{{failure_reasons}}`
- **Retry Attempts**: `{{retry_attempts}}`

### Resource Usage
- **CPU Efficiency**: `{{cpu_efficiency}}`
- **Memory Efficiency**: `{{memory_efficiency}}`
- **I/O Statistics**: `{{io_statistics}}`

## Environment Information
### Execution Environment
- **Platform**: `{{platform}}`
- **Hostname**: `{{hostname}}`
- **User**: `{{user}}`
- **Working Directory**: `{{workdir}}`

### Software Versions
- **Python**: `{{python_version}}`
- **Snakemake**: `{{snakemake_version}}`
- **Conda**: `{{conda_version}}`
- **Git Commit**: `{{git_commit}}`

### Conda Environments
| Environment | Location | Packages |
|-------------|----------|----------|
| {{env_1}} | {{loc_1}} | {{pkg_1}} |
| {{env_2}} | {{loc_2}} | {{pkg_2}} |

## Output Files
### Primary Outputs
- `{{primary_output_1}}`
- `{{primary_output_2}}`
- `{{primary_output_3}}`

### Intermediate Files
- `{{intermediate_1}}`
- `{{intermediate_2}}`
- `{{intermediate_3}}`

### Reports Generated
- **HTML Report**: `{{html_report}}`
- **DAG Visualization**: `{{dag_file}}`
- **Rule Graph**: `{{rule_graph}}`
- **Filegraph**: `{{file_graph}}`

## Errors and Warnings
### Critical Errors
```
{{critical_errors}}
```

### Warnings
```
{{warnings}}
```

### Job Failures
| Job | Rule | Error Code | Error Message | Retry Count |
|-----|------|------------|---------------|-------------|
| {{job_1}} | {{rule_1}} | {{code_1}} | {{message_1}} | {{retry_1}} |
| {{job_2}} | {{rule_2}} | {{code_2}} | {{message_2}} | {{retry_2}} |

## Performance Analysis
### Bottlenecks Identified
- {{bottleneck_1}}
- {{bottleneck_2}}

### Resource Utilization
- **CPU Utilization**: {{cpu_utilization}}%
- **Memory Utilization**: {{memory_utilization}}%
- **Storage I/O**: {{storage_io}}

### Optimization Opportunities
- {{optimization_1}}
- {{optimization_2}}

## Cluster Information (if applicable)
### Job Scheduler
- **Scheduler**: `{{scheduler}}`
- **Cluster**: `{{cluster_name}}`
- **Partition/Queue**: `{{partition}}`

### Submitted Jobs
- **Total Jobs Submitted**: `{{total_submitted}}`
- **Queue Wait Time**: `{{queue_wait_time}}`
- **Average Job Duration**: `{{avg_job_duration}}`

### Resource Requests vs Usage
| Resource | Requested | Used | Efficiency |
|----------|-----------|------|------------|
| CPU | {{cpu_req}} | {{cpu_used}} | {{cpu_eff}}% |
| Memory | {{mem_req}} | {{mem_used}} | {{mem_eff}}% |
| Time | {{time_req}} | {{time_used}} | {{time_eff}}% |

## Troubleshooting Notes
### Issues Encountered
- {{issue_1}}
- {{issue_2}}

### Solutions Applied
- {{solution_1}}
- {{solution_2}}

### Manual Interventions
- {{intervention_1}}
- {{intervention_2}}

## Data Integrity Checks
### Input Validation
- [ ] All input files present
- [ ] Sample sheet validated
- [ ] Reference files verified

### Output Validation
- [ ] All expected outputs generated
- [ ] File sizes reasonable
- [ ] Checksums verified (if applicable)

### Quality Control
- [ ] QC metrics within expected ranges
- [ ] No obvious data corruption
- [ ] Results consistent with expectations

## Lessons Learned
### What Worked Well
- {{success_1}}
- {{success_2}}

### Areas for Improvement
- {{improvement_1}}
- {{improvement_2}}

### Recommendations for Future Runs
- {{recommendation_1}}
- {{recommendation_2}}

## Next Steps
- [ ] {{next_step_1}}
- [ ] {{next_step_2}}
- [ ] {{next_step_3}}

## Follow-up Actions
### Immediate Actions
- [ ] Archive successful outputs
- [ ] Clean up temporary files
- [ ] Update documentation

### Future Improvements
- [ ] Optimize resource allocation
- [ ] Update workflow based on lessons learned
- [ ] Improve error handling

## Sign-off
- **Execution Completed By**: `{{completed_by}}`
- **Reviewed By**: `{{reviewed_by}}`
- **Date Reviewed**: `{{review_date}}`
- **Status**: `{{final_status}}`
