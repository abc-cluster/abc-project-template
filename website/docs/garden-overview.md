---
sidebar_position: 4
title: The Garden model
---

# The Garden model

`abc-project-template` ships with a **seed bank** — a hidden directory
(`.garden/components/`) containing dormant capabilities you can grow into your
project on demand.

## Why a seed bank

A typical research template has a hard tradeoff:

- **Comprehensive templates** ship hundreds of files. New projects feel bloated.
  Cleanup logic runs after rendering and is fragile (we found such a bug:
  cleanup over-aggressively deleted user-enabled directories).
- **Minimal templates** ship few files. When you need an extra capability —
  a poster, a Nextflow pipeline, a database scaffold — you have to look
  somewhere else and integrate manually.

The Garden model gets both:

- The full template **ships** with every project, but **dormant** in `.garden/`.
- Active root has only what's planted (typically 5-15 components).
- Adding capability is one command: `just grow <component>`.
- Removing capability is one command: `just prune <component>`.
- Curated bundles plant several at once: `just grow preset:bioinformatics`.

## Anatomy

A component lives at `.garden/components/<category>/<name>/`:

```
.garden/components/data/features/
├── component.yaml          # metadata
└── files/                  # mirrors landing locations in active tree
    └── data/
        └── features/
            ├── .gitkeep
            ├── 041_domain/.gitkeep
            ├── 042_statistical/.gitkeep
            └── ...
```

`component.yaml`:

```yaml
id: "data:features"
description: "Feature engineering data stage"
status: "experimental"
version: "0.1.0"
depends: []                # other components to plant first
files:
  - data/features/.gitkeep
  - data/features/041_domain/.gitkeep
  - ...
adds_imports:              # justfile import lines to add on grow
  - tasks/data-features.just
post_grow_hint: |
  Created data/features/ with subdirs.
```

When you run `just grow data:features`:

1. Files in `.garden/components/data/features/files/` are copied to active tree
2. `import "tasks/data-features.just"` is added to the top-level `justfile`
3. The `post-grow.sh` hook (if present) runs
4. Manifest updates: `planted` list gets a new entry

## What's in the seed bank

| Category | Examples |
|---|---|
| `core:` | base (always planted) |
| `data:` | features, model-input, models, model-output, logs, backups, benchmarks, publications, ... |
| `lang:` | python, r, julia, rust, go, c, csharp, fsharp, clojure, groovy, java, ocaml, powershell, ... |
| `writeup:` | poster, grants, abstracts, presentation, blog, book, report |
| `infra:` | terraform, juju, multipass, lxd, dagger, packer, waypoint, env-setup, cloud-scripts |
| `pipelines:` | nextflow, snakemake |
| `db:` | postgresql, sqlite, duckdb, dolt, xtdb, datalevin, immudb, irmin |
| `web:` | pode, python (Flask/FastAPI), r (Shiny/Plumber) |
| `build:` | bazel |
| `shell:` | fish |
| `editor:` | emacs |
| `tooling:` | mise |
| `analysis:` | dashboards (Quarto Observable / Shiny) |

`just garden-list dormant` shows everything available with descriptions.

## Presets

A preset is a named bundle:

```yaml
# in .garden/manifest.yaml
presets:
  bioinformatics:
    description: "Pixi + R + Nextflow + Nomad workbench"
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
```

`just grow preset:bioinformatics` plants all components in order, resolving
dependencies along the way.

Built-in presets: `bioinformatics`, `ml-research`, `academic-writing`,
`full-academic`.

## Auto-planting at scaffold time

When `copier copy` finishes, it runs `garden.py replant` automatically.
Replant looks at:

- `.copier-answers.yml` (records the chosen `project_type`)
- `.garden/manifest.yaml`'s `defaults_for_project_type` table

```yaml
defaults_for_project_type:
  "Analysis Only (data science pipeline)":
    - core:base
    - data:features
    - data:model-input
    - data:model-output
    - data:models
    - data:logs
    - infra:env-setup
```

So the user gets a tailored project right after scaffolding — no manual
"now grow these 7 things" step.

## Lifecycle

```
copier copy ...               (renders template + auto-replants)
    │
    ▼
just garden                   (status check)
    │
    ▼
just grow data:features       (manual additions)
just grow preset:ml-research
    │
    ▼
... do your work ...
    │
    ▼
just prune writeup:poster     (removed something you no longer need)
    │
    ▼
git commit                    (manifest tracks state)
    │
    ▼
[teammate clones]
just replant                  (re-materialize from manifest)
```

## Pulling new components from upstream

When `abc-project-template` upstream releases new components:

```bash
just garden update    # pulls new component versions into .garden/
```

This **only touches dormant components**. Planted components are not modified
without explicit per-component consent.

## Read more

- [Reference: Garden](../docs/reference/garden) — full CLI surface
- [Reference: components](../docs/reference/components) — how to author new ones
- [Penguins tutorial](/docs/penguins/overview) — see Garden in action
