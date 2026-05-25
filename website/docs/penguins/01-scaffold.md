---
sidebar_position: 2
title: 1. Scaffold the project
---

# Step 1 — Scaffold the project

We'll create a project named `penguins-study` configured for analysis +
writeup.

## Run copier

```bash
copier copy --trust gh:abc-cluster/abc-project-template penguins-study
```

Answer the prompts:

| Prompt | Value |
|---|---|
| What is your project name? | `Penguins Study` |
| What is your project's short name? | `penguins-study` |
| Brief description | `Palmer penguins species classification` |
| Your name / email | (your details) |
| **Project type** | `Full Academic Project (analysis + writeup)` |
| Programming language | `Python` |
| Documentation format | `Quarto` |
| Experiment tracking | `MLflow` |
| Data versioning | `true` |
| Include publication templates | `true` |
| Pre-commit hooks | `true` |

Copier will:
1. Render the template
2. Run cleanup tasks
3. Call `python3 .garden/garden.py replant` to plant the components for
   `Full Academic Project`

The replant output should look like:

```
Replanting 13 component(s) for project_type: Full Academic Project (analysis + writeup)
  ✓ core:base (2 files)
  ✓ data:features (6 files)
  ✓ data:model-input (5 files)
  ✓ data:model-output (6 files)
  ✓ data:models (6 files)
  ✓ data:logs (6 files)
  ✓ data:benchmarks (4 files)
  ✓ data:publications (1 files)
  ✓ writeup:presentation (...)
  ✓ writeup:abstracts (...)
  ✓ writeup:poster (...)
  ✓ infra:env-setup (...)
  ✓ pipelines:nextflow (...)
```

## Verify

```bash
cd penguins-study
just tour
```

You should see:

```
Project layout:
  notebooks/   exploratory work
  data/        raw / intermediate / primary / reports
  src/         library code (importable)
  scripts/     operational scripts
  pipelines/   DVC + Nextflow + Snakemake
  tests/       test suite
  writeup/     manuscripts (other formats: just grow writeup:<name>)
  config/      project configs
  .garden/     dormant components (just garden-list dormant)
```

## Setup the Python env

```bash
pixi install                  # if you have pixi
# OR
uv sync --all-groups          # if you have uv
```

This installs pandas, scikit-learn, palmerpenguins, matplotlib, jupyter, mlflow,
and dev dependencies (pytest, ruff, mypy).

## Initialize git

```bash
git init
git add .
git commit -m "scaffold: penguins-study from abc-project-template"
```

## What got planted

```bash
just garden
```

```
Planted components (13):
  ✓ core:base                      v1.0.0  (planted 2026-05-02)
  ✓ data:features                  v0.1.0
  ✓ data:model-input               v0.1.0
  ✓ data:models                    v0.1.0
  ✓ data:model-output              v0.1.0
  ✓ data:logs                      v0.1.0
  ✓ data:benchmarks                v0.1.0
  ✓ data:publications              v0.1.0
  ✓ writeup:presentation           v0.1.0
  ✓ writeup:abstracts              v0.1.0
  ✓ writeup:poster                 v0.1.0
  ✓ infra:env-setup                v0.1.0
  ✓ pipelines:nextflow             v0.1.0

Dormant components (~55):
  · data:backups                    Versioned and timestamped data backups
  · data:collaboration              Collaboration / shared data area
  ... (more)
```

[Next: Get the data →](./data)
