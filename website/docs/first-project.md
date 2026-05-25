---
sidebar_position: 3
title: Your first project
---

# Your first project

A 10-minute walkthrough from `copier copy` to running recipes.

## 1. Scaffold

```bash
copier copy --trust gh:abc-cluster/abc-project-template my-first-project
```

Copier asks ~10 questions. Reasonable defaults:

| Question | Answer |
|---|---|
| Project name | `My First Project` |
| Short name | `my-first-project` |
| Description | (your description) |
| Author / email | (your info) |
| **Project type** | `Analysis Only (data science pipeline)` |
| Programming language | `Python` |
| Documentation format | `Quarto` |
| Experiment tracking | `None` |
| Data versioning | `false` |

After the wizard, copier:
1. Renders the template into `my-first-project/`
2. Runs cleanup tasks for tool-specific files (DVC, R-only, etc.)
3. Calls `python3 .garden/garden.py replant` to plant the components for
   `Analysis Only` (core:base + 5 data: components + infra:env-setup)

## 2. Look around

```bash
cd my-first-project
ls
```

You'll see roughly:

```
README.md
.editorconfig         .gitignore        .pre-commit-config.yaml
pyproject.toml        pixi.toml         environment.yml
justfile
notebooks/            data/             src/
scripts/              pipelines/        tests/
config/               writeup/          tasks/
.garden/              # seed bank for grow/prune
```

`just tour` gives you a 5-line orientation:

```bash
just tour
```

## 3. Setup environment

```bash
just setup        # installs Python deps via uv + pre-commit hooks
```

## 4. Try a recipe

```bash
just notebooks new-eda "exploration"
# Creates notebooks/02-exploration/eda/<timestamp>_eda_exploration.qmd

just data validate-dataset path/to/data.csv
# (with data:features planted, validates against schema)
```

## 5. Browse the Garden

```bash
just garden                  # planted vs dormant
just garden-list dormant     # all available components
```

You'll see ~60 dormant components organized by category.

## 6. Grow what you need

Want a poster?

```bash
just grow writeup:poster
ls writeup/poster/
```

Want a Nextflow pipeline?

```bash
just grow pipelines:nextflow
ls pipelines/nextflow/
```

Want a curated bundle for ML research?

```bash
just grow preset:ml-research
# Plants: data:features + data:model-input + data:model-output +
#         data:models + data:logs + infra:dagger + writeup:presentation
```

## 7. When you're done

```bash
just garden                  # what's planted now?
git add .
git commit -m "scaffold: initial project"
```

The `.garden/manifest.yaml` records what you planted — collaborators can
clone and run `just replant` to materialize the same setup.

## Next steps

- [Learn the Garden model →](./garden-overview)
- [Walk the penguins tutorial →](/docs/penguins/overview) (end-to-end use case)
- [Reference docs →](/docs/reference/garden)
