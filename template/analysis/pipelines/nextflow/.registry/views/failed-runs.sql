-- View: Failed Runs
-- Experiments that failed with error details

CREATE VIEW IF NOT EXISTS failed_runs AS
SELECT 
    e.id AS experiment_id,
    e.type,
    e.phase,
    e.created_at,
    e.tower_run_id,
    ex.execution_id,
    ex.started_at,
    ex.completed_at,
    ex.exit_code,
    ex.tasks_location,
    ex.work_dir
FROM experiments e
JOIN executions ex ON e.id = ex.experiment_id
WHERE e.status = 'failed'
ORDER BY ex.completed_at DESC;