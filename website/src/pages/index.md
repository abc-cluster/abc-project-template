---
title: abc-project-template
hide_table_of_contents: false
---

# abc-project-template

A grow-as-you-need template for **data science**, **bioinformatics**, and
**academic research** projects. Aligned to the
[abc-cluster](https://abc-cluster.io) design language.

```bash
copier copy --trust gh:abc-cluster/abc-project-template my-project
cd my-project
just tour
```

## What you get

- A **flat, navigable project structure** — no `analysis/` wrapper; top-level
  `notebooks/`, `data/`, `src/`, `pipelines/`, `tests/`, `writeup/`
- **70+ dormant components** in `.garden/` — grow only what you need
- **Curated bundles** (`just grow preset:bioinformatics`) for common workflows
- **Cross-platform** recipes (bash + PowerShell pairing)
- **CI-gated safety net** — every change verified against 54 scenarios

## Three ways in

|  | Where to start |
|---|---|
| **New here?** | The [getting-started guide](/docs/intro) — 5 minutes to a running project |
| **Want a worked example?** | The [penguins study](/docs/penguins/overview) — scaffold, EDA, model, manuscript |
| **Looking up a feature?** | The [reference docs](/docs/reference/garden) — Garden, components, CLI, justfile |

## The Garden model

A typical research template ships ~800 files. Most users use ~50 of them.
Existing templates either **bloat** new projects or break trying to clean up.

`abc-project-template` inverts the model: **everything ships**, but most of
it is dormant in `.garden/`. The user grows what they need.

```bash
just garden                       # planted vs dormant overview
just garden-list dormant          # browse 70+ available components
just grow data:features           # plant feature-engineering stage
just grow preset:ml-research      # plant a curated bundle
just prune writeup:poster         # archive back to dormant
```

## Quick reference

| Task | Command |
|---|---|
| Scaffold | `copier copy --trust gh:abc-cluster/abc-project-template my-project` |
| Orientation | `just tour` |
| Health check | `just doctor` |
| Find a path | `just where features` |
| Browse components | `just garden-list dormant` |
| Plant | `just grow <component>` |
| Plant a bundle | `just grow preset:<name>` |
| Remove | `just prune <component>` |
| Replant defaults | `just replant` |

[Get started →](/docs/intro)
