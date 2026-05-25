# Nextflow Pipeline Lifecycle - Quick Start

## 🚀 Quick Commands

### Essential Commands

```bash
# Initialize system (first time only)
just setup

# Create new investigation
just n "investigation-name" "What you're testing"

# List investigations
just l

# View investigation details
just v <investigation_id>

# Show statistics
just s
```

### Investigation Execution

```bash
# Run locally
just run-local <investigation_id>

# Run on AWS Batch
just run-aws <investigation_id>

# Launch via Tower
just run-tower <investigation_id>

# Resume failed run
just resume <investigation_id>
```

### Monitoring

```bash
# Check status
just status <investigation_id>

# View summary
just summary <investigation_id>

# Show results
just show-results <investigation_id>

# Open investigation folder
just open <investigation_id>
```

### Tower Integration

```bash
# Fetch Tower metadata
just fetch-tower <investigation_id>

# Monitor Tower run
just monitor-tower <tower_run_id>

# Link Tower run manually
just tower-link <investigation_id> <tower_run_id>
```

### Organization

```bash
# Archive completed investigation
just archive <investigation_id>

# Search by tag
just search-tag <tag_name>

# Direct database query
just query "SELECT * FROM investigations"
```

## 📋 Workflow Examples

### Development Workflow

```bash
# 1. Create development investigation
just n "test-new-params" "Testing parameter set A vs B"

# 2. Edit configuration
cd investigations/development/active/test-new-params
vim params.yaml

# 3. Run
cd ../../../..  # back to root
just run-local <investigation_id>

# 4. Check results
just show-results <investigation_id>
```

### Production Workflow

```bash
# 1. Create production investigation
just prod-new "full-analysis" "dataset-v2.0" "Complete genome analysis"

# 2. Configure
cd investigations/production/runs/<investigation_id>
vim params.yaml
vim samplesheet.csv

# 3. Run on AWS
cd ../../../../..
just run-aws <investigation_id>

# 4. Monitor via Tower
just monitor-tower <tower_run_id>

# 5. Archive when complete
just archive <investigation_id>
```

### Tower-First Workflow

```bash
# 1. Create investigation
just n "tower-run" "Running via Tower platform"

# 2. Launch via Tower
just run-tower <investigation_id>

# 3. Fetch results later
just fetch-tower <investigation_id>
```

## 🎯 Aliases

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `just n` | `just dev-new` | Create new development investigation |
| `just r` | `just run-local` | Run investigation locally |
| `just l` | `just list-all` | List all investigations |
| `just s` | `just stats` | Show statistics |
| `just v` | `just view` | View investigation details |

## 📁 Directory Structure

```
investigations/
├── development/
│   ├── runs/                  # Timestamped investigation directories
│   ├── active/                # Symlinks to current investigations
│   └── archive/               # Archived investigations
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

### Investigation Files
- `metadata.yaml` - Core investigation metadata
- `params.yaml` - Pipeline parameters
- `execution.yaml` - Execution configuration
- `samplesheet.csv` - Sample configuration
- `investigation-plan.md` - Planning document
- `execution-log.md` - Execution notes

### System Files
- `.registry/investigations.db` - SQLite database
- `.registry/schemas/schema.sql` - Database schema
- `scripts/` - Management scripts
- `justfile` - Command definitions

## 💡 Tips

### Finding Investigations
```bash
# Use short investigation names for easy typing
just n "exp1" "..."
just n "exp2" "..."

# Active symlinks make navigation easier
cd investigations/development/active/exp1

# List recent investigations
just l | tail -5
```

### Parameter Management
```bash
# Use templates for common configs
investigations/configs/params-templates/
├── default-params.yaml
├── full-dataset.yaml
├── quick-test.yaml
└── production.yaml

# Copy and modify
cp investigations/configs/params-templates/production.yaml \
   investigations/production/runs/<exp_id>/params.yaml
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
# Find failed investigations
just query "SELECT * FROM failed_runs"

# Recent completed investigations
just query "SELECT id, status, created_at FROM investigations WHERE status='completed' ORDER BY created_at DESC LIMIT 5"

# Investigations by researcher
just query "SELECT id, purpose, created_at FROM investigations WHERE researcher='abhi'"
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "No justfile found" | `cd` to nextflow directory |
| "Database not initialized" | Run `just setup` |
| "Investigation not found" | Check ID with `just l` |
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
