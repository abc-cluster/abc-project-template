---
sidebar_position: 6
title: Data stages
---

# Reference — Data stages

The `data/` directory uses a numbered-stage layout inspired by
[Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/)
and [Kedro](https://kedro.org/). Active root has the everyday-use stages;
specialty stages are dormant components.

## Active root (always present)

```
data/
├── 00_scratch/         # exploratory dumps, throwaway
├── 01_raw/             # original immutable data
│   ├── 011_external/   # downloaded from outside
│   ├── 012_internal/   # produced by your org
│   ├── 013_synthetic/  # generated for testing
│   └── 014_timestamped/ # versioned snapshots
├── 02_intermediate/    # cleaned, transformed
│   ├── 021_cleaned/
│   ├── 022_profiled/
│   ├── 023_extracted/
│   ├── 024_validated/
│   ├── 025_profiled/
│   └── 026_transformed/
├── 03_primary/         # canonical analysis-ready
│   ├── 031_quality_checked/
│   ├── 032_sampled/
│   ├── 033_versioned/
│   ├── 034_splits/
│   ├── 035_registered/
│   └── 036_versioned/
└── 08_reporting/       # outputs for reports
    ├── 081_tables/
    ├── 082_figures/
    ├── 083_dashboards/
    └── 084_presentations/
```

## Dormant components (grow as needed)

| Component | Active path | Substages |
|---|---|---|
| `data:features` | `data/features/` | `041_domain`, `042_statistical`, `043_interaction`, `044_scaled`, `045_dimensionality_reduced` |
| `data:model-input` | `data/model-input/` | `051_test`, `052_train`, `053_validation`, `054_production` |
| `data:models` | `data/models/` | `061_baseline`, `062_candidate`, `063_ensemble`, `064_optimized`, `065_production` |
| `data:model-output` | `data/model-output/` | `071_predictions`, `072_probabilities`, `073_evaluation`, `074_explanations`, `075_comparisons` |
| `data:logs` | `data/logs/` | `091_pipeline`, `092_training`, `093_metadata`, `094_lineage`, `095_experiment` |
| `data:backups` | `data/backups/` | `101_timestamped`, `102_versioned` |
| `data:benchmarks` | `data/benchmarks/` | `111_baseline_results`, `112_comparisons`, `113_standard` |
| `data:publications` | `data/publications/` | publication-ready figures and tables |
| `data:external-validation` | `data/external-validation/` | `131_cross_domain`, `132_cross_population`, `133_replication` |
| `data:collaboration` | `data/collaboration/` | `141_agreements`, `142_federated`, `143_shared` |
| `data:pipelines-stage` | `data/pipelines-stage/` | pipeline-internal data stage |

## Recommended flow

```
            ┌─────────────────────────────────────┐
            ▼                                     │
01_raw/  →  02_intermediate/  →  03_primary/  →  04_features/  →  05_model_input/
                                                         │
                                                         ▼
                                       06_models/  ← 04_features/
                                              │
                                              ▼
                                       07_model_output/  →  08_reporting/
```

## Naming conventions

- Numbered prefixes (`01_`, `02_`) preserve sort order
- Sub-numbered substages (`011_`, `012_`) — the first digit matches the stage
- Underscore-separated, lowercase

## What to commit

| Stage | Commit policy |
|---|---|
| `00_scratch/` | gitignored (in `data/.gitignore`) |
| `01_raw/` | DVC-tracked (committed `.dvc` files only) |
| `02_intermediate/` to `07_model_output/` | DVC-tracked |
| `08_reporting/082_figures/` | small enough → commit directly; large → DVC |
| `data/.gitkeep` files | committed, preserve the directory layout |

## Wiring into DVC

A typical `dvc.yaml`:

```yaml
stages:
  validate:
    cmd: python scripts/validate.py
    deps:
      - data/01_raw/011_external/raw.csv
      - scripts/validate.py
    outs:
      - data/02_intermediate/024_validated/

  clean:
    cmd: python scripts/clean.py
    deps:
      - data/02_intermediate/024_validated/
      - scripts/clean.py
    outs:
      - data/02_intermediate/021_cleaned/

  features:
    cmd: python scripts/feature_engineer.py
    deps:
      - data/02_intermediate/021_cleaned/
      - scripts/feature_engineer.py
    outs:
      - data/features/041_domain/

  model:
    cmd: python scripts/train.py
    deps:
      - data/features/041_domain/
      - scripts/train.py
    outs:
      - data/models/062_candidate/
    metrics:
      - data/model-output/073_evaluation/metrics.json
```

`just pipeline` runs `dvc repro` for the whole graph.

## Conventions

- One CSV / one experiment / one stage. Don't bundle multiple datasets in
  one file unless they're naturally linked.
- File names include the date or version: `penguins_2026-05-02.csv`.
- Each generated artifact has a `.dvc` (or git) record so it's reproducible.

## Working with large data

For datasets too large for DVC's local cache:

- Configure a DVC remote (S3, GCS, Azure)
- Use `data:cloud-sync` (with rclone, when planted)
- Or symlink from a shared storage path (NFS, ZFS, Lustre)
