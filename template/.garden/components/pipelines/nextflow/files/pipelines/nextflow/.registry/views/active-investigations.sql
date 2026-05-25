-- View: Active Investigations
-- Non-archived investigations with latest status

CREATE VIEW IF NOT EXISTS active_investigations AS
SELECT 
    e.id,
    e.type,
    e.phase,
    e.scenario,
    e.status,
    e.created_at,
    e.git_branch,
    e.git_commit,
    e.tower_run_id,
    e.chain_id,
    e.project_name,
    e.purpose,
    ex.started_at,
    ex.duration_seconds,
    ex.total_cpu_hours,
    ex.estimated_cost_usd
FROM investigations e
LEFT JOIN executions ex ON e.id = ex.investigation_id
WHERE e.status != 'archived'
ORDER BY e.created_at DESC;