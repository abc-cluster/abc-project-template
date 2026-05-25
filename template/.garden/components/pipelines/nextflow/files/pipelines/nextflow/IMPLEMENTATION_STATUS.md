# Nextflow Pipeline Lifecycle Management - Implementation Status

## ✅ Completed (Phase 1)

### Directory Structure
- ✅ Created complete directory scaffold
- ✅ Added .gitkeep files for empty directories
- ✅ Organized into investigations/{development,production,planning}
- ✅ Created chains/, comparisons/, storage/, .registry/, docs/, scripts/

### Nextflow Configurations
- ✅ `investigations/configs/base.config` - Base configuration with reports, tracing
- ✅ `investigations/configs/development.config` - Dev-optimized settings
- ✅ `investigations/configs/production.config` - Production-scale settings
- ✅ `investigations/configs/profiles/local-local.config` - Local execution profile
- ✅ `investigations/configs/profiles/local-aws.config` - AWS Batch profile
- ✅ `investigations/configs/profiles/local-slurm.config` - SLURM cluster profile
- ✅ `investigations/configs/profiles/tower.config` - Tower-managed execution

### Parameter Templates
- ✅ `investigations/configs/params/default-params.yaml` - Standard parameters
- ✅ `investigations/configs/params/minimal-test.yaml` - Quick smoke test params
- ✅ `investigations/configs/params/full-dataset.yaml` - Production dataset params

### Investigation Templates
- ✅ `investigations/templates/metadata.yaml.template` - Investigation metadata structure
- ✅ `investigations/templates/execution.yaml.template` - Execution details structure
- 🚧 Need: investigation-plan.md.template, execution-log.md.template
- 🚧 Need: results-manifest.yaml.template, git-info.yaml.template
- 🚧 Need: tower-info.yaml.template, README.md.template

## 🚧 In Progress (Phase 2)

### Database Schema
- 🚧 `.registry/schemas/schema.sql` - SQLite schema
- 🚧 `.registry/views/*.sql` - Helper views

### Core Scripts
- 🚧 `scripts/register-investigation.py` - Database management CLI
- 🚧 `scripts/init-investigation.sh` - Create new investigations
- 🚧 `scripts/track-git-commit.sh` - Git state snapshot
- 🚧 `scripts/tower-integration.sh` - Universal Tower linkage

### Automation Layer
- 🚧 `pipeline-lifecycle.just` - Main justfile with all commands

## ⏳ Pending (Phase 3)

### Additional Scripts
- ⏳ `scripts/sync-results.sh` - Rclone-based result syncing
- ⏳ `scripts/generate-lineage.py` - Resume chain tracking
- ⏳ `scripts/create-comparison.py` - Cross-investigation analysis
- ⏳ `scripts/check-status.py` - Investigation health check
- ⏳ `scripts/validate-investigation.py` - Structural validation
- ⏳ `scripts/import-tower-runs.py` - Bulk Tower import
- ⏳ `scripts/generate-dashboard.py` - Statistics dashboard

### Storage Management
- ⏳ `storage/rclone-remotes.yaml` - Remote storage definitions
- ⏳ `storage/storage-policy.yaml` - Category-based storage policies

### Documentation
- ⏳ `docs/README.md` - Quick start guide
- ⏳ `docs/execution-scenarios.md` - Scenario-specific workflows
- ⏳ `docs/resume-strategy.md` - Chain management guide
- ⏳ `docs/comparison-guide.md` - Comparison workflows

## Next Immediate Steps

1. **Create SQLite schema** (.registry/schemas/schema.sql)
2. **Implement register-investigation.py** (basic version)
3. **Create init-investigation.sh** (investigation creation)
4. **Build pipeline-lifecycle.just** (automation layer)
5. **Write core documentation** (docs/README.md)

## Testing Strategy

Once core components are ready:
1. Run `just setup` to initialize database
2. Create test investigation: `just dev-new test-smoke "sanity check"`
3. Execute locally: `just run-local <investigation_id>`
4. Validate structure: `just validate <investigation_id>`
5. Test Tower integration: `just fetch-tower <investigation_id>`

## File Locations

```
template/analysis/pipelines/nextflow/
├── investigations/
│   ├── configs/           ✅ DONE
│   ├── templates/         ✅ Partial (2/8 files)
│   ├── development/       ✅ Structure ready
│   ├── production/        ✅ Structure ready
│   └── planning/          ✅ Structure ready
├── chains/                ✅ Structure ready
├── comparisons/           ✅ Structure ready
├── storage/               ✅ Structure ready
├── .registry/             ✅ Structure ready
├── docs/                  ⏳ Empty
├── scripts/               ⏳ Empty
└── pipeline-lifecycle.just ⏳ Not created
```

## Dependencies

### Required CLIs
- `nextflow` - Pipeline execution
- `tw` (tower-cli) - Tower integration
- `jq` - JSON processing
- `git` - Version control
- `python3.11+` - Script execution
- `rclone` - Remote storage sync

### Optional CLIs
- `yq` - YAML processing (fallback to Python)
- `mermaid-cli` - Lineage diagram generation
- `quarto` - Comparison report rendering
- `graphviz` - Graph visualization

### Python Packages
- `pyyaml` - YAML handling
- `typer` or `click` - CLI framework
- `rich` (optional) - Pretty output
- `sqlite-utils` (optional) - DB utilities

## Current Priority: Core Functionality

Focusing on getting a minimal working system that supports:
- ✅ Scenario (i): Local head + local tasks
- 🚧 Investigation creation and tracking
- 🚧 Tower integration
- ⏳ Basic result management

Extended features (resume chains, comparisons, dashboards) will be implemented after core is stable.
