---
sidebar_position: 4
title: justfile structure
---

# Reference — justfile structure

The top-level `justfile` is a thin dispatcher; each area's recipes live in
`tasks/<area>.just`.

## Top-level imports

```just
# Top-level justfile (consolidated layout)
import "tasks/_shell.just"          # shared SHELL_TYPE / SCRIPT_EXT / SHELL_CMD
import "tasks/_introspection.just"  # just tour / doctor / where
import "tasks/garden.just"          # seed-bank manager
import "tasks/expansion.just"       # adding components / scaling project

# Always-active areas
import "tasks/notebooks.just"
import "tasks/data.just"
import "tasks/scripts.just"
import "tasks/pipelines.just"
import "tasks/quality.just"

# Language and packaging
import "tasks/packages.just"
import "tasks/python.just"
import "tasks/r.just"

# Writeup
import "tasks/writeup.just"
import "tasks/manuscript.just"

# Conditional VCS extras
{% if include_jujutsu %}import "tasks/jj.just"{% endif %}
{% if include_jujutsu and include_fossil %}import "tasks/hybrid-vcs.just"{% endif %}

# >>> garden imports (managed by .garden/garden.py) >>>
# (each grown component appends import lines here)
# <<< garden imports <<<
```

## `tasks/_shell.just`

Defines:

```just
SHELL_TYPE := env_var_or_default('SHELL_TYPE',
  if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
```

These three variables are imported once and available to every other
`tasks/*.just` file.

## `tasks/_introspection.just`

Adds three discoverability commands: `just tour`, `just doctor`,
`just where <thing>`.

## `tasks/garden.just`

The Garden CLI dispatcher. Recipes:

```just
garden *args:                        # status
garden-list filter="all":            # list components
garden-show id:                      # show details
grow id:                             # plant
prune id *flags:                     # remove
replant *flags:                      # plant defaults_for_project_type[chosen]
```

All delegate to `python3 .garden/garden.py <subcmd> ...`.

## Per-area task files

| File | Purpose |
|---|---|
| `tasks/notebooks.just` | Notebook lifecycle (create / list / run) |
| `tasks/data.just` | Data acquisition, validation, profiling |
| `tasks/scripts.just` | Operational scripts |
| `tasks/pipelines.just` | DVC + pipeline orchestration |
| `tasks/python.just` | Python-specific recipes |
| `tasks/r.just` | R-specific recipes |
| `tasks/packages.just` | Package management |
| `tasks/writeup.just` | Top-level writeup recipes |
| `tasks/manuscript.just` | Manuscript build |
| `tasks/manuscript.pwsh.just` | PowerShell-specific manuscript variants |
| `tasks/pollen.just` | Pollen (Racket) document tooling |
| `tasks/quality.just` | Code quality checks |
| `tasks/expansion.just` | Project expansion / scaling |

Component-injected: when a component has `adds_imports`, those `import` lines
land in the managed garden block.

## Recipe conventions

### Cross-platform pairing

For recipes with significant shell logic, ship paired variants:

```just
# Default: auto-detect
data-validate name:
    {{SHELL_CMD}} scripts/data/validate.{{SCRIPT_EXT}} "{{name}}"

# Explicit bash
data-validate-bash name:
    bash scripts/data/validate.sh "{{name}}"

# Explicit PowerShell
data-validate-pwsh name:
    pwsh scripts/data/validate.ps1 "{{name}}"
```

### Trivial recipes

For one-liners, write inline:

```just
hello name:
    @echo "Hello {{name}}"
```

### Recipe with arguments

```just
new-eda name stage="02-exploration":
    bash scripts/notebooks/new-eda.sh "{{name}}" "{{stage}}"
```

### `[no-cd]` attribute

For recipes that should run from the user's CWD (not the justfile dir):

```just
[no-cd]
where thing:
    bash scripts/where.sh "{{thing}}"
```

## Top-level recipes (always present)

```just
default:
    @just --list

# update pre-commit file
pc-update:
    uvx pre-commit-update

# Run full pipeline with DVC
pipeline:
    dvc repro

# Visualize pipeline
pipeline-dag:
    dvc dag

# Setup development environment
setup: install
    uv run nbwipers install local
    uv run pre-commit install --install-hooks
```

(See the actual top-level `justfile.jinja` in the template for the full list.)
