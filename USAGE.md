# `abc-project-template` — Usage Guide

A practical guide to scaffolding, growing, and running projects from
`abc-project-template`.

---

## 1. Install prerequisites (one-time)

| Tool | Why | Install |
|---|---|---|
| **Python 3.10+** | Runs `copier` and `garden.py` | https://www.python.org/downloads/ or `brew install python` |
| **`copier`** | Scaffolds projects from this template | `pipx install copier` |
| **`just`** | Task runner used by every recipe | `brew install just` / `cargo install just` / `apt install just` |
| **`pixi`** *(recommended)* | Project-level conda-style env management | `curl -fsSL https://pixi.sh/install.sh \| bash` |
| **`uv`** *(Python projects)* | Fast Python package install | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| **`dvc`** *(if data versioning)* | Data pipeline + versioning | `pipx install dvc` |
| **`quarto`** *(if writeup)* | Render manuscripts and dashboards | https://quarto.org/docs/get-started/ |

**Verify:**
```bash
python3 --version    # 3.10 or newer
copier --version
just --version
```

---

## 2. Scaffold a new project

```bash
copier copy --trust gh:abc-cluster/abc-project-template my-project
```

Copier will ask a series of questions:

| Question | Common answer |
|---|---|
| What is your project name? | `Penguins Study` |
| What is your project's short name? | `penguins-study` |
| Brief description | `Palmer penguins species classification` |
| Your name / email | (your details) |
| Project type | `Analysis Only (data science pipeline)` |
| Programming language | `Python`, `R`, or `Both` |
| Documentation format | `Quarto` (recommended) |
| Experiment tracking | `MLflow` / `Weights & Biases` / `None` |
| Data versioning | `true` / `false` |

The wizard scaffolds your project, then **automatically plants the components
matching your choices** (this is the Garden replant step — see §4 below).

```bash
cd my-project
just tour       # 5-line orientation
just doctor     # check tools needed for what's planted
```

---

## 3. Project structure

```
my-project/
├── notebooks/        exploratory work (00_scratch, stage_NN_*.qmd, ...)
├── data/             raw / intermediate / primary / reports
│   ├── 00_scratch/
│   ├── 01_raw/
│   ├── 02_intermediate/
│   ├── 03_primary/
│   └── 08_reporting/
├── src/              importable library code (Python package or R)
├── scripts/          operational scripts (CLI, batch jobs)
├── pipelines/        DVC + Nextflow + Snakemake (planted on demand)
├── tests/            test suite (pytest, R testthat)
├── writeup/
│   └── manuscript/   manuscript Quarto/RMarkdown source
├── config/           DB credentials, experiment-tracking config
├── tasks/            modular justfile recipes (one file per area)
└── .garden/          seed bank — dormant components
    ├── manifest.yaml
    ├── components/
    └── presets/
```

Plus root-level tool config: `pyproject.toml`, `pixi.toml`, `environment.yml`,
`renv.lock`, `dvc.yaml`, `.pre-commit-config.yaml`, etc.

---

## 4. The Garden — grow the project as you need

The template ships ~70 dormant **components** in `.garden/components/`. They
don't appear in your active project tree until you grow them.

### Browse what's available

```bash
just garden                 # planted vs dormant overview
just garden-list dormant    # all available components, grouped by category
just garden-show data:features    # what does this component contain?
```

Categories:
- `core:base` — README, .editorconfig (always planted)
- `data:*` — feature stages (features, model-input, models, model-output, logs, ...)
- `lang:*` — language scaffolds (julia, rust, go, ocaml, ...)
- `writeup:*` — formats (poster, grants, abstracts, presentation, blog, book, report)
- `infra:*` — infrastructure (terraform, juju, multipass, lxd, dagger, packer, ...)
- `pipelines:*` — workflow systems (nextflow, snakemake)
- `db:*` — database scaffolds (postgresql, sqlite, duckdb, dolt, xtdb, ...)
- `web:*` — web frameworks (pode, python, r)
- `build:*` — build systems (bazel)
- `shell:*`, `editor:*`, `tooling:*` — environment extras (fish, emacs, mise)
- `analysis:*` — visualization (dashboards)

### Plant components

```bash
# Single component
just grow writeup:poster

# Curated bundle
just grow preset:bioinformatics      # python + r + nextflow + writeup formats
just grow preset:ml-research         # data:* + dagger + tracking + writeup
just grow preset:academic-writing    # all writeup formats
just grow preset:full-academic       # the full original "Full Academic Project"
```

### Remove planted components

```bash
just prune writeup:poster                 # archive to .garden/dormant-history/
just prune writeup:poster --keep-files    # remove from manifest only; keep files
```

### Replant after pulling teammate's changes

```bash
git pull
just replant      # re-materialize anything new in defaults_for_project_type
```

---

## 5. Common workflows

### Exploratory data analysis (notebooks)

```bash
just notebooks new-eda "exploratory-name"  # creates timestamped notebook
just notebooks list-recent                  # last 7 days of notebooks
just notebooks search "sklearn"             # search notebook contents
```

### Data validation + profiling (with `data:features` planted)

```bash
just data download-external https://example.com/data.csv mydata
just data validate-dataset path/to/data.csv
just data profile-dataset path/to/data.csv
just data quality-report path/to/data.csv
```

### Pipeline execution

```bash
just pipeline               # dvc repro (whole pipeline)
just pipeline-dag           # visualize pipeline graph
just pipeline-clean         # remove intermediate outputs
```

If you grew `pipelines:nextflow`:

```bash
just data nextflow-set-pipeline my-pipeline
just data nextflow-run-experiment exp-1 mydata
```

### Manuscript build

```bash
just manuscript-render                   # build manuscript PDF/HTML
just manuscript-watch                    # auto-rebuild on save
just writeup export-all                  # export everything to PDF
```

### Cross-platform recipes

Recipes that need a shell ship in two flavors:

```bash
just data validate-dataset       # uses bash on Unix, pwsh on Windows
just data validate-dataset-pwsh  # explicit PowerShell
just data validate-dataset-bash  # explicit bash (works on Win via WSL/Git Bash)
```

---

## 6. Pinning and updating the template

The project remembers which template version it came from in
`.copier-answers.yml`. To update later:

```bash
copier update                 # pulls latest template, asks about changes
just garden update            # also pull new components into seed bank (dormant only)
```

Planted components are NOT modified without explicit per-component consent.

---

## 7. Sharing a project setup with collaborators

The `.garden/manifest.yaml` is version-controlled. When a collaborator clones:

```bash
git clone <repo>
cd <repo>
just setup       # install deps via uv / pixi
just replant     # materialize the same planted components
just doctor      # verify everything's installed
```

---

## 8. Troubleshooting

### `python3: command not found`

You need Python 3.10+ on PATH. If using pyenv/asdf, ensure the right version
is active in this directory.

### `garden replant` fails with YAML error

Open `.garden/manifest.yaml` and verify syntax. The Python parser handles a
strict subset — see `.garden/garden.py` for limits. If stuck, reset:

```bash
git checkout -- .garden/manifest.yaml
just replant
```

### Recipe not found

Check planting state — many recipes come from components:

```bash
just garden                            # what's planted?
just garden-list dormant               # what's available?
just grow <component>                  # plant the component you need
```

### Want to nuke and restart

```bash
git status                             # ensure your changes are committed
just prune <every-component>           # archive each planted component
just replant                           # back to the project_type defaults
```

---

## 9. Anatomy of a component

Every component lives in `.garden/components/<category>/<name>/`:

```
.garden/components/data/features/
├── component.yaml          # metadata: id, description, files, depends, hint
└── files/                  # mirrors landing locations in active tree
    └── data/
        └── features/
            ├── .gitkeep
            ├── 041_domain/.gitkeep
            ├── 042_statistical/.gitkeep
            └── ...
```

When you `just grow data:features`:
1. Files copy from `files/` to active tree at the same relative path
2. Any `adds_imports` get appended to the top-level justfile
3. The `post-grow.sh` hook runs (if present)
4. Manifest updates with the planted entry

---

## 10. CLI reference (quick)

```
copier copy --trust gh:abc-cluster/abc-project-template <DIR>    # scaffold
copier update                                                 # pull latest template

just                                  # list all available recipes
just tour                             # 5-line orientation
just doctor                           # tool check
just where <thing>                    # find where X lives
just garden                           # planted vs dormant
just garden-list [planted|dormant]    # detailed listing
just garden-show <id>                 # component details
just grow <id>                        # plant component
just grow preset:<name>               # plant curated bundle
just prune <id> [--keep-files]        # archive planted component
just replant                          # plant defaults_for_project_type[chosen]
```

---

## 11. Going further

- **Architecture deep-dive:** [`docs/architecture/`](docs/architecture/) (in scaffolded projects)
- **Component authoring:** see any `.garden/components/<x>/component.yaml`
- **Template customization:** clone `abc-project-template`, edit, push to your fork, scaffold from it
- **Documentation site:** https://abhi18av.github.io/abc-project-template (Docusaurus, includes tutorials)

---

## License

See [LICENSE](LICENSE).
