# Execution Log

## Experiment Information
- **Experiment ID**: `{{experiment_id}}`
- **Date**: `{{date}}`
- **Researcher**: `{{researcher}}`
- **Resumed From**: `{{resumed_from}}` (if applicable)

## Execution Details
### Tower Information
- **Tower Run ID**: `{{tower_run_id}}`
- **Tower URL**: `{{tower_url}}`
- **Workspace**: `{{tower_workspace}}`
- **Compute Environment**: `{{compute_environment}}`

### Pipeline Configuration
- **Pipeline**: `{{pipeline_name}}`
- **Version**: `{{pipeline_version}}`
- **Revision**: `{{revision}}`
- **Profile**: `{{execution_profile}}`
- **Resume**: `{{resume_flag}}`

### Execution Timeline
- **Start Time**: `{{start_time}}`
- **End Time**: `{{end_time}}`
- **Duration**: `{{duration}}`
- **Status**: `{{status}}`

### Resource Usage
- **CPU Hours**: `{{cpu_hours}}`
- **Memory Peak**: `{{memory_peak}}`
- **Storage Used**: `{{storage_used}}`
- **Cost**: `{{cost}}`

## Resume Information (if applicable)
### Previous Run
- **Previous Run ID**: `{{previous_run_id}}`
- **Previous Status**: `{{previous_status}}`
- **Failure Point**: `{{failure_point}}`
- **Failure Message**: 
```
{{failure_message}}
```

### Resume Strategy
- **Resume Method**: `{{resume_method}}`
- **Cached Processes**: `{{cached_processes}}`
- **Rerun Processes**: `{{rerun_processes}}`

## Process Status
| Process | Status | Duration | CPU | Memory | Exit Code |
|---------|--------|----------|-----|---------|-----------|
| {{process_1}} | {{status_1}} | {{duration_1}} | {{cpu_1}} | {{memory_1}} | {{exit_code_1}} |
| {{process_2}} | {{status_2}} | {{duration_2}} | {{cpu_2}} | {{memory_2}} | {{exit_code_2}} |

## Output Files
### Generated Files
- `{{output_file_1}}`
- `{{output_file_2}}`
- `{{output_file_3}}`

### Reports
- **Execution Report**: `{{execution_report}}`
- **Timeline Report**: `{{timeline_report}}`
- **Trace Report**: `{{trace_report}}`

## Errors and Warnings
### Errors
```
{{errors}}
```

### Warnings
```
{{warnings}}
```

## Notes
{{execution_notes}}

## Next Steps
- [ ] {{next_step_1}}
- [ ] {{next_step_2}}
- [ ] {{next_step_3}}

## Follow-up Actions
- [ ] Review failed processes
- [ ] Optimize resource allocation
- [ ] Update pipeline parameters
- [ ] Schedule rerun/resume
