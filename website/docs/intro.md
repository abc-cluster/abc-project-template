---
sidebar_position: 1
title: Introduction
---

# Welcome to `abc-project-template`

`abc-project-template` is a [Copier](https://copier.readthedocs.io/) template
for scaffolding data science / bioinformatics / academic-research projects.

It's designed around a **Garden model**: most capabilities are dormant when
you scaffold, and you grow them on demand. This keeps new projects focused
while preserving the full spectrum of tooling for when you need it.

## Who is this for

- **Data scientists** doing exploratory analysis with notebooks and pipelines
- **Bioinformaticians** running Nextflow / Snakemake workflows
- **Academic researchers** writing manuscripts, posters, grants alongside code
- **Lab teams** that need a consistent project layout across multiple projects
- **Anyone** who's bounced between [Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/),
  [Kedro](https://kedro.org/), and rolling-their-own and wanted something more flexible

## Design principles

1. **Everything is reachable, but nothing is forced.** The full template ships
   in the `.garden/` seed bank. Active root is minimal until you grow.
2. **Tools obey the tools' conventions.** `data/` at root for DVC,
   `pyproject.toml` at root for uv, `tests/` at root for pytest. No
   custom wrappers around well-known patterns.
3. **Every recipe is testable.** A 54-scenario CTT safety net gates every
   change to ensure no capability is lost during refactors.
4. **Cross-platform first.** Recipes work on Linux, macOS, Windows. Paired
   `xyz` (auto), `xyz-pwsh` (PowerShell), `xyz-bash` (bash) recipes when needed.

## Five-minute tour

```bash
# 1. Scaffold
copier copy --trust gh:abc-cluster/abc-project-template my-project
cd my-project

# 2. Get oriented
just tour

# 3. Browse what's available
just garden-list dormant

# 4. Plant what you need
just grow data:features
just grow writeup:poster
just grow preset:ml-research

# 5. Use it
just notebooks new-eda "first-pass"
just pipeline
just manuscript-render
```

## Next steps

- [Install prerequisites](./install) — copier, just, python, optional tools
- [Create your first project](./first-project) — 10-minute walkthrough
- [Learn the Garden model](./garden-overview) — concepts in 5 minutes
- [Walk the penguins tutorial](/docs/penguins/overview) — end-to-end use case
- [Reference docs](/docs/reference/garden) — feature-by-feature
