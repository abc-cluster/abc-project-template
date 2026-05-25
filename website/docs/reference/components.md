---
sidebar_position: 2
title: Components
---

# Reference — Components

The seed bank ships ~70 components organized by category. This page lists
them all with descriptions.

## Categories

| Category | Count | Purpose |
|---|---|---|
| `core:` | 1 | Always-planted essentials |
| `data:` | 11 | Data pipeline stages |
| `db:` | 8 | Database scaffolds |
| `lang:` | 16 | Language-specific scaffolds |
| `writeup:` | 7 | Academic writing formats |
| `infra:` | 15 | Infrastructure subsystems |
| `pipelines:` | 2 | Workflow systems |
| `web:` | 3 | Web framework scaffolds |
| `build:` | 1 | Build systems |
| `shell:` | 1 | Shell environments |
| `editor:` | 1 | Editor configs |
| `tooling:` | 1 | Task runners / version managers |
| `analysis:` | 1 | Analysis-specific (dashboards) |

## `core:`

| Component | Description |
|---|---|
| `core:base` | Minimal essentials: README + .editorconfig |

## `data:`

| Component | Active path | Substages |
|---|---|---|
| `data:features` | `data/features/` | domain, statistical, interaction, scaled, dim-reduced |
| `data:model-input` | `data/model-input/` | test, train, validation, production |
| `data:models` | `data/models/` | baseline, candidate, ensemble, optimized, production |
| `data:model-output` | `data/model-output/` | predictions, probabilities, evaluation, explanations, comparisons |
| `data:logs` | `data/logs/` | pipeline, training, metadata, lineage, experiment |
| `data:backups` | `data/backups/` | timestamped, versioned |
| `data:benchmarks` | `data/benchmarks/` | baseline, comparisons, standard |
| `data:publications` | `data/publications/` | figures and tables for publication |
| `data:external-validation` | `data/external-validation/` | cross-domain, cross-population, replication |
| `data:collaboration` | `data/collaboration/` | agreements, federated, shared |
| `data:pipelines-stage` | `data/pipelines-stage/` | pipeline-internal data stage |

## `db:`

| Component | Tool |
|---|---|
| `db:postgresql` | PostgreSQL scaffolding |
| `db:sqlite` | SQLite scaffolding |
| `db:duckdb` | [DuckDB](https://duckdb.org/) scaffolding |
| `db:dolt` | [Dolt](https://www.dolthub.com/) (git-like SQL DB) |
| `db:xtdb` | [XTDB](https://xtdb.com/) bitemporal DB |
| `db:datalevin` | Datalevin |
| `db:immudb` | [immudb](https://immudb.io/) immutable DB |
| `db:irmin` | [Irmin](https://irmin.org/) git-compatible store |

## `lang:`

| Component | Status |
|---|---|
| `lang:c` | experimental |
| `lang:cli` | CLI tool scaffolding |
| `lang:clojure` | experimental |
| `lang:csharp` | experimental |
| `lang:distribution` | multi-language packaging |
| `lang:fsharp` | experimental |
| `lang:go` | experimental |
| `lang:groovy` | experimental |
| `lang:java` | experimental |
| `lang:julia` | experimental |
| `lang:ocaml` | experimental |
| `lang:powershell` | experimental |
| `lang:rust` | experimental |
| `lang:validation` | cross-language validation |
| `lang:zig` | experimental |

(`lang:python` and `lang:r` stay in active root — they're the primary
languages for most users.)

## `writeup:`

| Component | What it provides |
|---|---|
| `writeup:abstracts` | Conference and journal abstract templates |
| `writeup:blog` | Quarto blog with research log |
| `writeup:book` | Book-length manuscript scaffolding |
| `writeup:grants` | NSF / NIH / DOE / ERC grant proposal templates |
| `writeup:poster` | Academic + professional poster templates |
| `writeup:presentation` | Beamer / Reveal.js / Quarto presentation templates |
| `writeup:report` | Technical + executive report templates |

(`writeup/manuscript/` stays in active root — most projects need it.)

## `infra:`

Core subsystems:

| Component | Tool |
|---|---|
| `infra:lxd` | LXD containers |
| `infra:multipass` | [Multipass](https://multipass.run/) VMs |
| `infra:juju` | [Juju](https://juju.is/) charms (Nomad+Docker, JupyterHub) |
| `infra:waypoint` | [Waypoint](https://www.waypointproject.io/) deployments |
| `infra:dagger` | [Dagger](https://dagger.io/) CI/CD |
| `infra:packer` | [Packer](https://www.packer.io/) image builds |
| `infra:terraform` | Terraform configs (microk8s, multipass, OCI) |
| `infra:env-setup` | Cross-platform environment setup (Java, etc.) |
| `infra:cloud-scripts` | Cloud automation scripts (bash + pwsh + python) |

Underscore-prefixed (orchestrator metadata, may be consolidated):

- `infra:_orchestrator-templates`
- `infra:_just-orchestrator`
- `infra:_envs-orchestrator`
- `infra:virtualization-readme`
- `infra:orchestration-readme`
- `infra:automation-readme`

## `pipelines:`

| Component | Tool |
|---|---|
| `pipelines:nextflow` | Nextflow pipeline scaffolding (with Tower integration) |
| `pipelines:snakemake` | Snakemake pipeline scaffolding (with cluster profiles) |

## `web:`

| Component | Framework |
|---|---|
| `web:pode` | [Pode](https://pode.readthedocs.io/) (PowerShell) |
| `web:python` | Flask / FastAPI |
| `web:r` | Shiny / Plumber |

## `build:` / `shell:` / `editor:` / `tooling:` / `analysis:`

| Component | What |
|---|---|
| `build:bazel` | Bazel build system files |
| `shell:fish` | Fish aliases, completions, starship prompt |
| `editor:emacs` | Emacs project setup |
| `tooling:mise` | mise task runner config |
| `analysis:dashboards` | Quarto dashboards (Observable, Shiny) |

## Authoring a new component

To create a new component:

```
.garden/components/<category>/<name>/
├── component.yaml         # metadata (see below)
├── files/                 # what gets copied to active tree on grow
│   └── ...
├── post-grow.sh           # optional lifecycle hook
└── post-prune.sh          # optional lifecycle hook
```

Minimal `component.yaml`:

```yaml
id: "myorg:my-component"
description: "What this component provides"
status: "experimental"     # or stable / shell-incomplete
version: "0.1.0"
files:
  - path/relative/to/active/root.txt
adds_imports:              # optional
  - tasks/my-component.just
post_grow_hint: |          # optional
  Created path/. Try `just my-recipe`.
```

Test it:

```bash
just garden-show myorg:my-component   # verify metadata loads
just grow myorg:my-component
just prune myorg:my-component
```

## Curated bundles (presets)

Defined in `.garden/manifest.yaml:presets`:

```yaml
presets:
  bioinformatics:
    description: "Pixi + R + Nextflow + workbench"
    components:
      - core:base
      - lang:r
      - data:features
      - data:benchmarks
      - data:publications
      - pipelines:nextflow
      - infra:env-setup
      - writeup:presentation
      - writeup:abstracts

  ml-research:
    description: "ML pipeline with experiment tracking"
    components:
      - core:base
      - data:features
      - data:model-input
      - data:model-output
      - data:models
      - data:logs
      - data:benchmarks
      - infra:dagger
      - infra:env-setup
      - writeup:presentation

  academic-writing:
    description: "Manuscript + grants + presentations + posters"
    components:
      - core:base
      - writeup:presentation
      - writeup:abstracts
      - writeup:poster
      - writeup:grants

  full-academic:
    description: "Replicates the original Full Academic Project preset"
    components: [...]
```

Plant one with `just grow preset:<name>`.
