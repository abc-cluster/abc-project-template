# `.garden/` — the seed bank

This directory holds the **dormant** parts of the project template. Files here
are not active in your project until you "grow" them.

## Concept

Your project starts minimal: a few directories you actually use. The rest of
the template's content (50+ data stages, 17 language scaffolds, infra subsystems,
writeup formats, etc.) lives here in the seed bank. When you need a capability,
you grow it — files move from `.garden/components/<name>/` into the active tree
and the relevant `import` lines are added to the justfile.

## Commands

```bash
just garden                     # show planted vs dormant
just grow <component>           # plant a component
just prune <component>          # archive a planted component back to dormant
just garden show <component>    # what does a component contain?
just grow preset:<name>         # plant a curated bundle
```

## Structure

```
.garden/
├── README.md              ← this file
├── manifest.yaml          ← what's planted, when, with what version
├── components/            ← the seeds (one dir per component)
│   ├── data/
│   │   ├── features/
│   │   │   ├── component.yaml      ← metadata
│   │   │   ├── files/              ← what gets copied to active tree
│   │   │   └── post-grow.sh        ← optional: runs after planting
│   │   └── ...
│   ├── lang/
│   ├── writeup/
│   ├── infra/
│   ├── pipelines/
│   └── ...
└── presets/               ← named bundles
    ├── bioinformatics.yaml
    ├── ml-research.yaml
    └── academic-writing.yaml
```

## Component manifest format

Each component has `.garden/components/<name>/component.yaml`:

```yaml
id: data:features
description: Feature engineering stage (transforms, scaling, encoding)
status: stable           # stable | experimental | shell-incomplete
version: 1.0.0
depends:
  - data:primary         # auto-grown if not present
files:
  - analysis/data/04_feature/.gitkeep
  - analysis/data/04_feature/041_domain/.gitkeep
  ...
recipes:                 # justfile recipes added to the active project
  - data::feature-engineer
  - data::feature-validate
adds_imports:            # justfile import lines added on grow
  - tasks/data-features.just
post_grow_hint: |
  Created analysis/data/04_feature/. Try `just data list-stages`.
```

## Why a seed bank instead of one big template

The original template emitted 800+ files at scaffold time and tried to clean up
"unused" parts via post-render tasks. That cleanup was buggy — every project
ended up with the same minimal output regardless of choices.

The Garden approach inverts the model: emit only what's planted; nothing to
clean up. Adding capability is explicit (`just grow <thing>`), undoable
(`just prune <thing>`), and discoverable (`just garden`).

## Updating the seed bank

When `abc-project-template` upstream releases new components:

```bash
just garden update    # pulls new versions of seeds into .garden/
```

This ONLY touches dormant components. Planted components are not modified
without explicit consent (you'll be prompted per-component).
