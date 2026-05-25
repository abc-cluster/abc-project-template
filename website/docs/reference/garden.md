---
sidebar_position: 1
title: Garden CLI
---

# Reference — Garden CLI

`.garden/garden.py` is a Python 3.10+ stdlib-only CLI that manages dormant
components. Invoked via `just` recipes.

## Subcommands

### `garden status`

```bash
just garden                  # default; same as garden status
python3 .garden/garden.py status
```

Prints planted vs dormant overview:

```
Template: gh:abc-cluster/abc-project-template @ 0.2.0

Planted components (3):
  ✓ core:base                      v1.0.0  (planted 2026-05-02)
  ✓ data:features                  v0.1.0
  ✓ writeup:poster                 v0.1.0

Dormant components (~65):
  · data:models                     Model artifacts ...
  ... and 64 more — `just garden-list dormant`
```

### `garden list [filter]`

```bash
just garden-list                  # all
just garden-list planted          # planted only
just garden-list dormant          # dormant only
```

### `garden show <id>`

```bash
just garden-show data:features
```

Prints metadata for a single component (id, description, status, version,
files, deps, recipes, post-grow hint).

### `grow <id>`

```bash
just grow data:features
just grow preset:bioinformatics
```

Plants a component (or all in a preset). Resolves `depends:` recursively
so dependencies are planted first.

Steps:
1. Copy files from `.garden/components/<id>/files/` to active tree
2. Add `import` lines to top-level justfile (managed block)
3. Run `post-grow.sh` if present
4. Append entry to `.garden/manifest.yaml:planted`

### `prune <id> [--keep-files]`

```bash
just prune writeup:poster
just prune writeup:poster --keep-files
```

Removes a planted component. Default behavior:
1. Archive a copy under `.garden/dormant-history/<id>_<timestamp>/`
2. Remove files from active tree (cleaning empty parent dirs)
3. Remove import lines from justfile
4. Run `post-prune.sh` if present
5. Remove from manifest's `planted` list

`--keep-files` skips step 2 (useful when you've put work into the files and
want to detach from the seed but keep your content).

### `replant`

```bash
just replant
just replant --verbose
```

Used by:
- copier `_tasks` after scaffolding (auto-fires)
- collaborators after `git pull` to re-materialize a teammate's setup

Reads `project_type` from `.copier-answers.yml`, then plants all components
listed in `.garden/manifest.yaml:defaults_for_project_type[<chosen>]`.
Idempotent — skips already-planted components.

## On-disk format

### `.garden/manifest.yaml`

```yaml
template_version: "0.2.0"
template_source: "gh:abc-cluster/abc-project-template"

planted:
  - id: "core:base"
    version: "1.0.0"
    planted_at: "2026-05-02"
  - id: "data:features"
    version: "0.1.0"
    planted_at: "2026-05-02"
    locally_modified: true       # set if user edited files vs seed

defaults_for_project_type:
  "Analysis Only (data science pipeline)":
    - core:base
    - data:features
    - data:model-input
    - ...

presets:
  bioinformatics:
    description: "..."
    components: [...]
```

### `.garden/components/<category>/<name>/component.yaml`

```yaml
id: "<category>:<name>"
description: "..."
status: "experimental"           # experimental | stable | shell-incomplete
version: "0.1.0"
depends: []                      # other component IDs to plant first
files:                           # files in the seed; order doesn't matter
  - relative/path/from/active/root/file.ext
  - ...
adds_imports:                    # justfile import lines to add on grow
  - tasks/<area>.just
post_grow_hint: |                # printed after `just grow`
  Optional message describing what was added.
```

### `.garden/components/<id>/files/`

The directory tree mirrors the active tree paths. When `grow` is called,
files are copied with the same relative path.

Example: a component with `files/tasks/data-features.just` lands at
`<project-root>/tasks/data-features.just`.

## Environment variables

| Variable | Effect |
|---|---|
| `GARDEN_DIR` | (planned) override default `.garden/` location |

## Exit codes

- `0` — success
- `1` — error (missing component, malformed manifest, planting conflict)

## Implementation notes

- Pure Python 3.10+ stdlib; no `pyyaml` dependency
- Hand-rolled minimal YAML parser handles the strict subset used here
  (top-level scalars, lists, lists of dicts, block scalars, comments)
- For full YAML, swap to `pyyaml` behind a try/except import — see
  [`tests/FUTURE-GO-PORT.md`](https://github.com/abc-cluster/abc-project-template/blob/main/tests/FUTURE-GO-PORT.md)
  for the long-term plan to replace with a Go binary
