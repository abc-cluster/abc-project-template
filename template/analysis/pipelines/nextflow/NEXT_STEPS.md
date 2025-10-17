# Nextflow Pipeline Lifecycle Management - Next Steps

## 🎉 Phase 1 Complete!

You now have a **solid foundation** for the Nextflow Pipeline Lifecycle Management System.

### ✅ What's Been Implemented

#### 1. **Complete Directory Structure**
```
template/analysis/pipelines/nextflow/
├── experiments/
│   ├── configs/               ✅ All configs created
│   │   ├── base.config
│   │   ├── development.config
│   │   ├── production.config
│   │   ├── profiles/
│   │   │   ├── local-local.config
│   │   │   ├── local-aws.config
│   │   │   ├── local-slurm.config
│   │   │   └── tower.config
│   │   └── params/
│   │       ├── default-params.yaml
│   │       ├── minimal-test.yaml
│   │       └── full-dataset.yaml
│   ├── templates/             ✅ 2/8 templates created
│   │   ├── metadata.yaml.template      ✅
│   │   ├── execution.yaml.template     ✅
│   │   └── (6 more needed)
│   ├── development/           ✅ Structure ready
│   ├── production/            ✅ Structure ready
│   └── planning/              ✅ Structure ready
├── chains/                    ✅ Structure ready
├── comparisons/               ✅ Structure ready
├── storage/                   ✅ Structure ready
├── .registry/                 ✅ Database infrastructure
│   ├── schemas/
│   │   └── schema.sql         ✅ Complete schema
│   └── views/
│       ├── active-experiments.sql  ✅
│       ├── failed-runs.sql         ✅
│       └── resume-chains.sql       ✅
├── docs/                      ⏳ Empty (needs documentation)
└── scripts/                   ⏳ Empty (needs all scripts)
```

#### 2. **Nextflow Configuration System**
- ✅ **Base config** with reports, tracing, Tower integration
- ✅ **Development config** - optimized for fast iteration
- ✅ **Production config** - optimized for scale and reliability
- ✅ **4 execution profiles**:
  - `local-local` - Local head + local tasks
  - `local-aws` - Local head + AWS Batch
  - `local-slurm` - Local head + SLURM cluster
  - `tower` - Tower-managed execution

#### 3. **Parameter Templates**
- ✅ `default-params.yaml` - Standard settings
- ✅ `minimal-test.yaml` - Quick smoke tests
- ✅ `full-dataset.yaml` - Production-scale runs

#### 4. **Database Infrastructure**
- ✅ Complete SQLite schema with 8 tables:
  - `experiments` - Main experiment tracking
  - `executions` - Run execution details
  - `chains` - Resume chain management
  - `chain_members` - Chain lineage
  - `results` - Metrics and outputs
  - `experiment_tags` - Tagging system
  - `storage_locations` - Multi-remote tracking
- ✅ 3 helpful views for common queries
- ✅ Indexes for performance
- ✅ Triggers for automatic timestamp updates

#### 5. **Experiment Templates (Partial)**
- ✅ `metadata.yaml.template` - Experiment metadata structure
- ✅ `execution.yaml.template` - Execution tracking structure

---

## 🚧 Phase 2: Core Scripts (Priority)

To make the system functional, implement these scripts next:

### 1. **scripts/register-experiment.py** (Highest Priority)
**Purpose**: Python CLI for database management

**Required Commands**:
```python
# Database initialization
register-experiment init-db

# Experiment management
register-experiment create --id <exp_id> --type development --scenario local-local
register-experiment update --id <exp_id> --status running
register-experiment list
register-experiment search --tag "optimization"

# Execution tracking
register-experiment add-execution --exp-id <exp_id> --exec-id <exec_id>
register-experiment update-execution --exec-id <exec_id> --status completed

# Tower linkage
register-experiment link-tower --exp-id <exp_id> --tower-run-id <run_id>

# Results tracking
register-experiment add-result --exp-id <exp_id> --name "alignment_rate" --value "95.7"
```

**Implementation Template**:
```python
#!/usr/bin/env python3
"""Experiment registry management CLI"""
import sqlite3
import sys
from pathlib import Path
from datetime import datetime
import yaml
import json

DB_PATH = Path(__file__).parent.parent / ".registry/experiments.db"
SCHEMA_PATH = Path(__file__).parent.parent / ".registry/schemas/schema.sql"

def init_db():
    """Initialize database with schema"""
    conn = sqlite3.connect(DB_PATH)
    with open(SCHEMA_PATH) as f:
        conn.executescript(f.read())
    # Apply views
    views_dir = SCHEMA_PATH.parent.parent / "views"
    for view_file in views_dir.glob("*.sql"):
        with open(view_file) as f:
            conn.executescript(f.read())
    conn.close()
    print(f"✅ Database initialized: {DB_PATH}")

def create_experiment(exp_id, exp_type, scenario, **kwargs):
    """Register new experiment"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO experiments (id, type, phase, scenario, status, created_at)
        VALUES (?, ?, ?, ?, 'planned', CURRENT_TIMESTAMP)
    """, (exp_id, exp_type, kwargs.get('phase', 'pipeline-development'), scenario))
    conn.commit()
    conn.close()
    print(f"✅ Experiment registered: {exp_id}")

# Add more commands here...

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: register-experiment.py <command> [args]")
        sys.exit(1)
    
    command = sys.argv[1]
    if command == "init-db":
        init_db()
    # Add command dispatch...
```

### 2. **scripts/init-experiment.sh** (High Priority)
**Purpose**: Create new experiment directories and initialize files

**Key Features**:
- Generate experiment ID: `YYYYMMDD_HHMM_<type>-<name>`
- Create experiment directory structure
- Copy and populate templates
- Call `track-git-commit.sh` to capture git state
- Register in database via `register-experiment.py`
- Create symlink in `active/` directory

**Skeleton**:
```bash
#!/usr/bin/env bash
set -euo pipefail

# Parse arguments
TYPE="" NAME="" SCENARIO="local-local" PARAMS="default-params"
while [[ $# -gt 0 ]]; do
    case $1 in
        --type) TYPE="$2"; shift 2 ;;
        --name) NAME="$2"; shift 2 ;;
        --scenario) SCENARIO="$2"; shift 2 ;;
        --params-template) PARAMS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Validate inputs
if [[ -z "$TYPE" ]] || [[ -z "$NAME" ]]; then
    echo "Error: --type and --name are required"
    exit 1
fi

# Generate experiment ID
TIMESTAMP=$(date +%Y%m%d_%H%M)
EXP_ID="${TIMESTAMP}_${TYPE}-${NAME}"

# Create experiment directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXP_DIR="${BASE_DIR}/experiments/${TYPE}/runs/${EXP_ID}"
mkdir -p "${EXP_DIR}"/{nextflow-logs,reports/tower}

# Copy templates and substitute placeholders
cp "${BASE_DIR}/experiments/templates/metadata.yaml.template" "${EXP_DIR}/metadata.yaml"
sed -i "s/{{EXPERIMENT_ID}}/${EXP_ID}/g" "${EXP_DIR}/metadata.yaml"
# ... more substitutions ...

# Copy parameter template
cp "${BASE_DIR}/experiments/configs/params/${PARAMS}.yaml" "${EXP_DIR}/params.yaml"

# Track git commit
"${BASE_DIR}/scripts/track-git-commit.sh" "${EXP_DIR}"

# Register in database
python3 "${BASE_DIR}/scripts/register-experiment.py" create \
    --id "${EXP_ID}" \
    --type "${TYPE}" \
    --scenario "${SCENARIO}"

# Create symlink
ln -sf "${EXP_DIR}" "${BASE_DIR}/experiments/${TYPE}/active/${NAME}"

echo "✅ Experiment created: ${EXP_ID}"
echo "📁 Location: ${EXP_DIR}"
```

### 3. **scripts/track-git-commit.sh** (High Priority)
**Purpose**: Capture git repository state

**Key Features**:
- Detect git repository root
- Capture current branch, commit hash, commit message
- Detect dirty state (uncommitted changes)
- Write `git-info.yaml`
- Update `execution.yaml` git section

### 4. **scripts/tower-integration.sh** (Medium Priority)
**Purpose**: Universal Tower metadata fetching

**Key Features**:
- Detect Tower run ID from `.nextflow.log`
- Fetch metadata via `tw --output=json runs view`
- Download reports via `tw runs download`
- Write `tower-info.yaml`
- Update database with Tower metadata

---

## 📋 Phase 3: Justfile and Documentation

### 1. **pipeline-lifecycle.just**
Create the main automation layer with these essential commands:

```just
# Setup and initialization
setup:
    @mkdir -p experiments/{development,production,planning}/{runs,active,archive}
    @python3 scripts/register-experiment.py init-db

# Experiment creation
dev-new name purpose="testing":
    @scripts/init-experiment.sh --type development --name "{{name}}" --scenario local-local

# Experiment execution
run-local experiment_id:
    #!/usr/bin/env bash
    exp_dir="experiments/*/runs/{{experiment_id}}"
    cd "$exp_dir"
    nextflow run ../../data-pipeline.nf \
        -profile local-local \
        -params-file params.yaml \
        -with-tower \
        -work-dir "./work" \
        -with-report "reports/report.html" \
        -with-timeline "reports/timeline.html" \
        -with-trace "reports/trace.txt"
    
    # Fetch Tower metadata
    ../../scripts/tower-integration.sh "$exp_dir"

# Experiment queries
list-all:
    @sqlite3 .registry/experiments.db "SELECT id, type, status FROM experiments ORDER BY created_at DESC;"

list-active:
    @sqlite3 .registry/experiments.db "SELECT * FROM active_experiments;"

# Status check
status experiment_id:
    @python3 scripts/register-experiment.py view --id "{{experiment_id}}"
```

### 2. **docs/README.md**
Quick start documentation with:
- Overview of the system
- Four execution scenarios explained
- Quick start commands
- Common workflows
- Troubleshooting guide

---

## 🔧 Complete Template Files (Remaining 6)

Create these template files in `experiments/templates/`:

### 1. `experiment-plan.md.template`
Markdown template for experiment planning

### 2. `execution-log.md.template`
Markdown template for logging run details

### 3. `results-manifest.yaml.template`
YAML template for tracking result file locations

### 4. `git-info.yaml.template`
YAML template for git state

### 5. `tower-info.yaml.template`
YAML template for Tower metadata

### 6. `README.md.template`
Per-experiment README with quick summary

---

## 🎯 Recommended Implementation Order

1. **Week 1** (Core functionality):
   - [ ] Create remaining 6 template files
   - [ ] Implement `register-experiment.py` (init-db, create, list commands)
   - [ ] Implement `init-experiment.sh` (basic version)
   - [ ] Create `pipeline-lifecycle.just` (setup, dev-new, list commands)
   - [ ] Test: Create experiment, verify DB registration

2. **Week 2** (Execution):
   - [ ] Implement `track-git-commit.sh`
   - [ ] Add `run-local` recipe to justfile
   - [ ] Test: Run local experiment, verify all metadata captured
   - [ ] Implement `tower-integration.sh` (basic version)
   - [ ] Test: Fetch Tower metadata after run

3. **Week 3** (Extended features):
   - [ ] Add remaining justfile recipes (run-aws, run-tower, resume)
   - [ ] Implement storage management (`sync-results.sh`, policies)
   - [ ] Create comparison and lineage scripts
   - [ ] Write comprehensive documentation

4. **Week 4** (Polish and testing):
   - [ ] Implement utility scripts (check-status, validate, dashboard)
   - [ ] End-to-end testing across all 4 scenarios
   - [ ] Fix bugs and edge cases
   - [ ] Complete documentation with examples

---

## 🚀 Quick Start for Next Session

To continue implementation, start with:

```bash
cd /Users/abhi/projects/template-analysis-and-writeup/template/analysis/pipelines/nextflow

# 1. Create remaining templates
# 2. Create scripts/register-experiment.py with init-db command
# 3. Test database initialization:
python3 scripts/register-experiment.py init-db

# 4. Create basic scripts/init-experiment.sh
# 5. Create pipeline-lifecycle.just with setup and dev-new recipes
# 6. Test experiment creation:
just setup
just dev-new test-first "initial test"

# 7. Verify experiment was created and registered:
just list-all
```

---

## 📚 Reference

### Key File Locations
- **Database**: `.registry/experiments.db`
- **Schema**: `.registry/schemas/schema.sql`
- **Templates**: `experiments/templates/*.template`
- **Configs**: `experiments/configs/`
- **Scripts**: `scripts/`
- **Justfile**: `pipeline-lifecycle.just`

### Important Concepts
- **Experiment ID Format**: `YYYYMMDD_HHMM_<type>-<name>`
- **Four Scenarios**: local-local, local-remote, tower, planning-only
- **Three Phases**: development, production, planning
- **Tower Integration**: Always enabled via `-with-tower` for executed runs

---

## ✅ Success Criteria

You'll know the system is working when:
1. ✅ Database initializes successfully
2. ✅ New experiments can be created with one command
3. ✅ Experiments are registered in database
4. ✅ Git state is captured automatically
5. ✅ Nextflow runs complete with all metadata
6. ✅ Tower data is fetched and stored locally
7. ✅ All experiments can be queried via SQL/justfile

Good luck with the implementation! 🎉
