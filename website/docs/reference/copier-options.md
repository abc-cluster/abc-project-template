---
sidebar_position: 5
title: copier options
---

# Reference — copier scaffolding options

When you run `copier copy --trust gh:abc-cluster/abc-project-template <DIR>`,
the wizard asks the questions in `copier.yml`. This page lists every option.

## Basic

| Question | Type | Default | Notes |
|---|---|---|---|
| `project_name` | str | (required) | Human-readable name |
| `short_name` | str | (required) | Used in filenames; lowercase + dashes |
| `description` | str | "A comprehensive ..." | One-line description |
| `author_name` | str | "Your Name" | |
| `author_email` | str | "your.email@example.com" | |

## Project type

| Choice | What it plants |
|---|---|
| `Minimal Starter (notebooks + basic writeup)` | core:base only |
| `Full Academic Project (analysis + writeup)` | core:base + 12 components (data + writeup + infra + pipelines) |
| `Analysis Only (data science pipeline)` | core:base + 6 data:* + infra:env-setup |
| `Manuscript Only (writing and publications)` | core:base + 5 writeup:* |
| `Package Development (software/library)` | core:base + build:bazel + infra:env-setup |
| `Custom (choose components manually)` | core:base only — user grows the rest |

Default: `Minimal Starter`.

## Programming language

| Choice | Effect |
|---|---|
| `Python` | Removes R-specific files (renv.lock, DESCRIPTION, .Rprofile) |
| `R` | Removes Python-specific files (uv.lock, .python-version) |
| `Both` | Keeps both |

Default: `Python`.

When `Python` or `Both`, also asks:

| Question | Default |
|---|---|
| `python_version` | `3.11` |

## Documentation format

| Choice |
|---|
| `Markdown` |
| `Jupyter Notebooks` |
| `Quarto` |
| `RMarkdown` |

Default: `Jupyter Notebooks`.

## Optional features

| Question | Type | Default | Effect |
|---|---|---|---|
| `experiment_tracking` | str | `None` | Install MLflow / W&B / Neptune config |
| `data_versioning` | bool | `false` | Include DVC + dvc.yaml |
| `data_validation` | bool | `false` | Include validation frameworks |
| `include_publication_templates` | bool | `false` | Extra publication formats |
| `github_actions` | bool | `false` | Add `.github/workflows/` |
| `pre_commit_hooks` | bool | `false` | Configure pre-commit + nbwipers |
| `include_deployment_templates` | bool | `false` | Docker, FastAPI, etc. |

## Custom mode questions

These appear only when `project_type == 'Custom'`:

| Question | Default |
|---|---|
| `include_analysis` | `true` |
| `include_writeup` | `true` |
| `include_infrastructure` | `true` |
| `include_misc` | `true` |
| `include_notebooks` | `true` |
| `include_scripts` | `true` |
| `include_data_pipeline` | `true` |
| `include_testing` | `true` |
| `include_packages` | `true` |
| `include_manuscript` | `true` |
| `include_presentations` | `true` |
| `include_grants` | `true` |
| `include_abstracts` | `true` |
| `include_posters` | `true` |
| `include_reports` | `true` |
| `include_blog` | `true` |
| `include_docker` | `true` |
| `include_cloud_deployment` | `true` |
| `include_virtualization` | `true` |
| `include_automation` | `true` |

## VCS extensions

| Question | Default |
|---|---|
| `include_jujutsu` | `false` |
| `include_fossil` | `false` |
| `use_hybrid_vcs` | `false` (only when both above are true) |

## Auto-computed

| Variable | How |
|---|---|
| `module_name` | derived from `short_name` (lowercased, dashes → underscores) |

## Non-interactive scaffolding

```bash
copier copy --trust --defaults gh:abc-cluster/abc-project-template my-proj
```

`--defaults` accepts every default. Override individual answers:

```bash
copier copy --trust --defaults \
    --data 'project_name=Penguins Study' \
    --data 'short_name=penguins-study' \
    --data 'project_type=Full Academic Project (analysis + writeup)' \
    --data 'programming_language=Python' \
    gh:abc-cluster/abc-project-template penguins-study
```

CI-friendly: pipe answers from a file.

## Updating an existing project

```bash
cd my-existing-project
copier update                  # interactive merge with new template version
copier update --skip-answered  # use existing answers, ask only new ones
```

## Customizing the template

Fork the template, edit, push to your fork:

```bash
copier copy --trust gh:YOUR_FORK/abc-project-template my-proj
```

Or use a local path:

```bash
copier copy --trust /path/to/local/abc-project-template my-proj
```
