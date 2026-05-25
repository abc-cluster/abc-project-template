# `abc-project-template`

> A grow-as-you-need template for data science, bioinformatics, and academic-research projects.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Copier](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/copier-org/copier/master/img/badge/badge-grayscale-inverted-border-orange.json)](https://github.com/copier-org/copier)
[![Just](https://img.shields.io/badge/task_runner-just-blue)](https://github.com/casey/just)

`abc-project-template` is a [Copier](https://copier.readthedocs.io/) template
built around a **Garden model**: most capabilities are dormant when you scaffold,
and you grow them on demand. This keeps new projects focused while preserving
the full spectrum of tooling for when you need it.

## Quick start

```bash
copier copy --trust gh:abc-cluster/abc-project-template my-project
cd my-project
just tour       # 5-line orientation
just doctor     # check tools
```

## What you get

- ✅ A **flat, navigable project structure** — no `analysis/` wrapper; top-level
  `notebooks/`, `data/`, `src/`, `pipelines/`, `tests/`, `writeup/`
- ✅ **70+ dormant components** in `.garden/` — grow only what you need
- ✅ **Curated bundles** (`just grow preset:bioinformatics`) for common workflows
- ✅ **Cross-platform** recipes (bash + PowerShell pairing where it matters)
- ✅ **CI-gated safety net** — every change verified against 54 CTT scenarios

## The Garden model

```bash
just garden                       # what's planted vs dormant
just garden-list dormant          # browse 70+ available components
just grow data:features           # plant a component
just grow preset:bioinformatics   # plant a curated bundle
just prune <component>            # archive back to dormant
just replant                      # apply project_type defaults
```

The full template ships in every project, but most of it sleeps in `.garden/`
until you wake it. Adding capability is one command. Removing it is one
command. The active root stays small until you decide otherwise.

## Documentation

- 📖 **[USAGE.md](./USAGE.md)** — comprehensive user guide
- 🌐 **[Documentation site](https://abhi18av.github.io/abc-project-template/)** — Docusaurus, with:
  - [Get-started guide](https://abhi18av.github.io/abc-project-template/docs/intro)
  - [Penguins tutorial](https://abhi18av.github.io/abc-project-template/docs/penguins/00-overview)
    (end-to-end walkthrough: scaffold → EDA → features → model → manuscript)
  - [Reference docs](https://abhi18av.github.io/abc-project-template/docs/reference/garden)
    (Garden, components, CLI, justfile, copier options, ...)

## Project structure (flat)

```
my-project/
├── notebooks/        exploratory work
├── data/             raw / intermediate / primary / reports
├── src/              importable library code
├── scripts/          operational scripts
├── pipelines/        DVC + Nextflow + Snakemake
├── tests/            test suite
├── writeup/
│   └── manuscript/   active by default; other formats via `just grow writeup:*`
├── config/           project-level configs
├── tasks/            modular justfile recipes (one file per area)
└── .garden/          seed bank — dormant components
```

Plus standard tool config at root: `pyproject.toml`, `pixi.toml`,
`environment.yml`, `dvc.yaml`, `.pre-commit-config.yaml`, etc.

## Project types (preset bundles at scaffold)

| Choice | Auto-plants |
|---|---|
| Minimal Starter | `core:base` only |
| Full Academic Project | core + 12 data/writeup/infra/pipeline components |
| Analysis Only | core + 6 data: + infra:env-setup |
| Manuscript Only | core + 5 writeup formats |
| Package Development | core + build:bazel + infra:env-setup |
| Custom | core only — user grows the rest |

Plus named presets (plant after scaffold via `just grow preset:<name>`):
`bioinformatics`, `ml-research`, `academic-writing`, `full-academic`.

## Prerequisites

- Python 3.10+
- [`copier`](https://copier.readthedocs.io/) (`pipx install copier`)
- [`just`](https://just.systems/) (`brew install just` / `cargo install just`)
- Optional: `pixi`, `uv`, `dvc`, `quarto`

See [USAGE.md §1](./USAGE.md#1-install-prerequisites-one-time) for full install instructions.

## For contributors

- [`tests/`](./tests/) — CTT safety net + phase docs
- [`copier.yml`](./copier.yml) — scaffold question definitions
- [`template/`](./template/) — the actual template files
- [`template/.garden/`](./template/.garden/) — seed bank (component definitions)
- [`tests/PHASE-*-COMPLETE.md`](./tests/) — per-phase implementation history
- [`tests/FUTURE-GO-PORT.md`](./tests/FUTURE-GO-PORT.md) — long-term plan to
  rewrite `garden.py` as a Go binary
- [`website/`](./website/) — Docusaurus documentation site source

## Acknowledgements

This template grew out of earlier personal scaffolding work (`analyze-and-publish-template`)
and was substantially rebuilt through iterative AI-assisted development across multiple
design phases. The Garden model, seed-bank architecture, and cross-platform tooling
represent a significant departure from that starting point, but the original project
provided the initial structure and direction.

The template draws on the broader ecosystem of community tools that make this kind of
work possible: [Copier](https://github.com/copier-org/copier) for template management,
[Just](https://github.com/casey/just) as the task runner backbone,
[Quarto](https://quarto.org) for reproducible manuscripts,
[Pixi](https://pixi.sh) for environment management,
[DVC](https://dvc.org) for data versioning,
[Nextflow](https://www.nextflow.io) and [nf-core](https://nf-co.re) for pipeline
conventions, and [nf-nomad](https://github.com/nextflow-io/nf-nomad) as the
executor. We are grateful to the authors and maintainers of all these projects.

## License

MIT — see [LICENSE](./LICENSE).
