# Nextflow Pipeline Lifecycle - Quick Start

## 🚀 Quick Commands

### Essential Commands

```bash
# Initialize system (first time only)
just setup

# Create new experiment
just n "experiment-name" "What you're testing"

# List experiments
just l

# View experiment details
just v <experiment_id>

# Show statistics
just s
```

### Experiment Execution

```bash
# Run locally
just run-local <experiment_id>

# Run on AWS Batch
just run-aws <experiment_id>

# Launch via Tower
just run-tower <experiment_id>

# Resume failed run
just resume <experiment_id>
```

### Monitoring

```bash
# Check status
just status <experiment_id>

# View summary
just summary <experiment_id>

# Show results
just show-results <experiment_id>

# Open experiment folder
just open <experiment_id>
```

### Tower Integration

```bash
# Fetch Tower metadata
just fetch-tower <experiment_id>

# Monitor Tower run
just monitor-tower <tower_run_id>

# Link Tower run manually
just tower-link <experiment_id> <tower_run_id>
```

### Organization

```bash
# Archive completed experiment
just archive <experiment_id>

# Search by tag
just search-tag <tag_name>

# Direct database query
just query "SELECT * FROM experiments"
```

## 📋 Workflow Examples

### Development Workflow

```bash
# 1. Create development experiment
just n "test-new-params" "Testing parameter set A vs B"

# 2. Edit configuration
cd experiments/development/active/test-new-params
vim params.yaml

# 3. Run
cd ../../../..  # back to root
just run-local <experiment_id>

# 4. Check results
just show-results <experiment_id>
```

### Production Workflow

```bash
# 1. Create production experiment
just prod-new "full-analysis" "dataset-v2.0" "Complete genome analysis"

# 2. Configure
cd experiments/production/runs/<experiment_id>
vim params.yaml
vim samplesheet.csv

# 3. Run on AWS
cd ../../../../..
just run-aws <experiment_id>

# 4. Monitor via Tower
just monitor-tower <tower_run_id>

# 5. Archive when complete
just archive <experiment_id>
```

### Tower-First Workflow

```bash
# 1. Create experiment
just n "tower-run" "Running via Tower platform"

# 2. Launch via Tower
just run-tower <experiment_id>

# 3. Fetch results later
just fetch-tower <experiment_id>
```

## 🎯 Aliases

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `just n` | `just dev-new` | Create new development experiment |
| `just r` | `just run-local` | Run experiment locally |
| `just l` | `just list-all` | List all experiments |
| `just s` | `just stats` | Show statistics |
| `just v` | `just view` | View experiment details |

## 📁 Directory Structure

```
experiments/
├── development/
│   ├── runs/                  # Timestamped experiment directories
│   ├── active/                # Symlinks to current experiments
│   └── archive/               # Archived experiments
├── production/
│   ├── runs/
│   ├── active/
│   └── archive/
├── planning/
│   ├── runs/
│   └── active/
├── configs/
│   ├── base/                  # Base configurations
│   ├── profiles/              # Execution profiles
│   └── params-templates/      # Parameter templates
└── results/
    └── comparative/           # Comparison reports
```

## 🔧 Configuration Files

### Experiment Files
- `metadata.yaml` - Core experiment metadata
- `params.yaml` - Pipeline parameters
- `execution.yaml` - Execution configuration
- `samplesheet.csv` - Sample configuration
- `experiment-plan.md` - Planning document
- `execution-log.md` - Execution notes

### System Files
- `.registry/experiments.db` - SQLite database
- `.registry/schemas/schema.sql` - Database schema
- `scripts/` - Management scripts
- `justfile` - Command definitions

## 💡 Tips

### Finding Experiments
```bash
# Use short experiment names for easy typing
just n "exp1" "..."
just n "exp2" "..."

# Active symlinks make navigation easier
cd experiments/development/active/exp1

# List recent experiments
just l | tail -5
```

### Parameter Management
```bash
# Use templates for common configs
experiments/configs/params-templates/
├── default-params.yaml
├── full-dataset.yaml
├── quick-test.yaml
└── production.yaml

# Copy and modify
cp experiments/configs/params-templates/production.yaml \
   experiments/production/runs/<exp_id>/params.yaml
```

### Tower Integration
```bash
# Set default workspace
export TOWER_WORKSPACE="my-team-workspace"

# Install dependencies
brew install jq                    # JSON parsing
pipx install tower-cli             # Tower CLI
tw login                          # Authenticate
```

### Database Queries
```bash
# Find failed experiments
just query "SELECT * FROM failed_runs"

# Recent completed experiments
just query "SELECT id, status, created_at FROM experiments WHERE status='completed' ORDER BY created_at DESC LIMIT 5"

# Experiments by researcher
just query "SELECT id, purpose, created_at FROM experiments WHERE researcher='abhi'"
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "No justfile found" | `cd` to nextflow directory |
| "Database not initialized" | Run `just setup` |
| "Experiment not found" | Check ID with `just l` |
| "Tower CLI not found" | `pipx install tower-cli` |
| "Git tracking failed" | Non-blocking, safe to ignore |
| S3 errors | Update bucket paths in justfile |

## 📚 Documentation

- `README.md` - Full documentation
- `TESTING.md` - Testing guide and status
- `ARCHITECTURE.md` - System architecture
- `QUICKSTART.md` - This file

## 🔗 Links

- [Nextflow Documentation](https://www.nextflow.io/docs/latest/)
- [Tower Documentation](https://help.tower.nf/)
- [Tower CLI](https://github.com/seqeralabs/tower-cli)

---

**Quick Help:** Run `just` or `just --list` to see all commands
