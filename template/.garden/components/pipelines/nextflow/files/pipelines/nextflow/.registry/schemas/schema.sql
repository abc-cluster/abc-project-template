-- Nextflow Pipeline Lifecycle Management Database Schema
-- SQLite database for tracking experiments, executions, and lineage

-- Main experiments table
CREATE TABLE IF NOT EXISTS experiments (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL CHECK(type IN ('development', 'production', 'planning')),
    phase TEXT NOT NULL CHECK(phase IN ('pipeline-development', 'production-analysis')),
    scenario TEXT NOT NULL CHECK(scenario IN ('local-local', 'local-remote', 'tower', 'planning-only')),
    status TEXT NOT NULL CHECK(status IN ('planned', 'running', 'completed', 'failed', 'cancelled', 'archived')),
    
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Git information
    git_commit TEXT,
    git_branch TEXT,
    is_dirty INTEGER DEFAULT 0,
    
    -- Tower information
    tower_run_id TEXT,
    workspace TEXT,
    
    -- Chain tracking
    chain_id TEXT,
    run_number INTEGER,
    parent_experiment_id TEXT,
    
    -- Project context
    project_name TEXT,
    dataset TEXT,
    purpose TEXT,
    researcher TEXT,
    
    -- Metadata
    tags TEXT,  -- JSON array of tags
    notes TEXT,
    
    FOREIGN KEY (chain_id) REFERENCES chains(chain_id),
    FOREIGN KEY (parent_experiment_id) REFERENCES experiments(id)
);

-- Execution details table
CREATE TABLE IF NOT EXISTS executions (
    execution_id TEXT PRIMARY KEY,
    experiment_id TEXT NOT NULL,
    
    started_at DATETIME,
    completed_at DATETIME,
    duration_seconds INTEGER,
    
    status TEXT NOT NULL CHECK(status IN ('planned', 'running', 'completed', 'failed', 'cancelled')),
    exit_code INTEGER,
    
    -- Environment
    head_location TEXT,
    tasks_location TEXT,
    profile TEXT,
    work_dir TEXT,
    
    -- Nextflow
    nextflow_version TEXT,
    command TEXT,
    config_files TEXT,  -- JSON array
    
    -- Resume information
    resume INTEGER DEFAULT 0,
    parent_execution_id TEXT,
    cached_tasks INTEGER DEFAULT 0,
    rerun_tasks INTEGER DEFAULT 0,
    
    -- Resources
    total_cpus INTEGER,
    peak_memory_gb REAL,
    total_cpu_hours REAL,
    estimated_cost_usd REAL,
    
    -- Tower
    tower_run_id TEXT,
    tower_compute_env TEXT,
    
    FOREIGN KEY (experiment_id) REFERENCES experiments(id),
    FOREIGN KEY (parent_execution_id) REFERENCES executions(execution_id)
);

-- Chains (resume/lineage tracking)
CREATE TABLE IF NOT EXISTS chains (
    chain_id TEXT PRIMARY KEY,
    chain_name TEXT NOT NULL,
    purpose TEXT,
    phase TEXT CHECK(phase IN ('development', 'production')),
    status TEXT CHECK(status IN ('active', 'completed', 'abandoned')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Chain members (experiments in a chain)
CREATE TABLE IF NOT EXISTS chain_members (
    chain_id TEXT NOT NULL,
    experiment_id TEXT NOT NULL,
    execution_id TEXT,
    run_number INTEGER NOT NULL,
    
    -- Track changes between runs
    git_commit_before TEXT,
    git_commit_after TEXT,
    param_changes TEXT,  -- JSON object of changes
    result_changes TEXT,  -- JSON object of metric changes
    
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (chain_id, run_number),
    FOREIGN KEY (chain_id) REFERENCES chains(chain_id),
    FOREIGN KEY (experiment_id) REFERENCES experiments(id),
    FOREIGN KEY (execution_id) REFERENCES executions(execution_id)
);

-- Results and metrics
CREATE TABLE IF NOT EXISTS results (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    experiment_id TEXT NOT NULL,
    execution_id TEXT,
    
    name TEXT NOT NULL,
    value TEXT,
    unit TEXT,
    category TEXT,  -- qc, summary, performance, etc.
    file TEXT,
    
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (experiment_id) REFERENCES experiments(id),
    FOREIGN KEY (execution_id) REFERENCES executions(execution_id)
);

-- Experiment tags (many-to-many)
CREATE TABLE IF NOT EXISTS experiment_tags (
    experiment_id TEXT NOT NULL,
    tag TEXT NOT NULL,
    PRIMARY KEY (experiment_id, tag),
    FOREIGN KEY (experiment_id) REFERENCES experiments(id)
);

-- Storage tracking
CREATE TABLE IF NOT EXISTS storage_locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    experiment_id TEXT NOT NULL,
    execution_id TEXT,
    
    category TEXT NOT NULL,  -- qc_reports, alignments, summary_stats, etc.
    remote_location TEXT,
    local_location TEXT,
    
    size_bytes INTEGER,
    synced INTEGER DEFAULT 0,
    last_sync_at DATETIME,
    
    FOREIGN KEY (experiment_id) REFERENCES experiments(id),
    FOREIGN KEY (execution_id) REFERENCES executions(execution_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_experiments_type ON experiments(type);
CREATE INDEX IF NOT EXISTS idx_experiments_status ON experiments(status);
CREATE INDEX IF NOT EXISTS idx_experiments_created ON experiments(created_at);
CREATE INDEX IF NOT EXISTS idx_experiments_chain ON experiments(chain_id);
CREATE INDEX IF NOT EXISTS idx_experiments_tower ON experiments(tower_run_id);

CREATE INDEX IF NOT EXISTS idx_executions_experiment ON executions(experiment_id);
CREATE INDEX IF NOT EXISTS idx_executions_status ON executions(status);
CREATE INDEX IF NOT EXISTS idx_executions_started ON executions(started_at);

CREATE INDEX IF NOT EXISTS idx_chain_members_chain ON chain_members(chain_id);
CREATE INDEX IF NOT EXISTS idx_chain_members_experiment ON chain_members(experiment_id);

CREATE INDEX IF NOT EXISTS idx_results_experiment ON results(experiment_id);
CREATE INDEX IF NOT EXISTS idx_results_category ON results(category);

CREATE INDEX IF NOT EXISTS idx_tags_experiment ON experiment_tags(experiment_id);
CREATE INDEX IF NOT EXISTS idx_tags_tag ON experiment_tags(tag);

CREATE INDEX IF NOT EXISTS idx_storage_experiment ON storage_locations(experiment_id);
CREATE INDEX IF NOT EXISTS idx_storage_category ON storage_locations(category);

-- Triggers to update timestamps
CREATE TRIGGER IF NOT EXISTS update_experiments_timestamp 
AFTER UPDATE ON experiments
BEGIN
    UPDATE experiments SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Views for common queries (created separately in views/ directory)
