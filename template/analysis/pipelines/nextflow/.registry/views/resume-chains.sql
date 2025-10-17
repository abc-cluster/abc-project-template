-- View: Resume Chains
-- Flattened view of chains with member details

CREATE VIEW IF NOT EXISTS resume_chains AS
SELECT 
    c.chain_id,
    c.chain_name,
    c.purpose,
    c.phase,
    c.status AS chain_status,
    cm.run_number,
    cm.experiment_id,
    e.status AS experiment_status,
    e.created_at,
    cm.git_commit_before,
    cm.git_commit_after,
    cm.param_changes,
    cm.result_changes,
    ex.duration_seconds,
    ex.cached_tasks,
    ex.rerun_tasks
FROM chains c
JOIN chain_members cm ON c.chain_id = cm.chain_id
JOIN experiments e ON cm.experiment_id = e.id
LEFT JOIN executions ex ON cm.execution_id = ex.execution_id
ORDER BY c.chain_id, cm.run_number;