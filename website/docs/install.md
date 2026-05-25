---
sidebar_position: 2
title: Install prerequisites
---

# Install prerequisites

You need `python3`, `copier`, and `just`. Everything else is optional and
installed via project envs (pixi/uv) once you've scaffolded.

## Required

### Python 3.10+

Used by `copier` and `garden.py`.

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

<Tabs groupId="os">
<TabItem value="macos" label="macOS">

```bash
brew install python
```

</TabItem>
<TabItem value="linux" label="Linux">

Most distros have it pre-installed. If not:

```bash
sudo apt install python3 python3-pip   # Debian/Ubuntu
sudo dnf install python3                # Fedora
```

</TabItem>
<TabItem value="windows" label="Windows">

Download from [python.org](https://www.python.org/downloads/) or:

```powershell
winget install Python.Python.3.12
```

</TabItem>
</Tabs>

Verify:
```bash
python3 --version    # Python 3.10 or newer
```

### `copier`

The scaffolding engine.

```bash
pipx install copier
```

(`pipx` install: `brew install pipx` / `sudo apt install pipx` / `python -m pip install --user pipx`)

### `just`

Task runner for every recipe in the project.

<Tabs groupId="os">
<TabItem value="macos" label="macOS">

```bash
brew install just
```

</TabItem>
<TabItem value="linux" label="Linux">

```bash
cargo install just                          # via Cargo
sudo snap install --edge --classic just     # Snap
# or download the binary from https://github.com/casey/just/releases
```

</TabItem>
<TabItem value="windows" label="Windows">

```powershell
scoop install just
# or
choco install just
```

</TabItem>
</Tabs>

## Recommended

| Tool | Why | Install |
|---|---|---|
| **`pixi`** | Conda-style env per project | `curl -fsSL https://pixi.sh/install.sh \| bash` |
| **`uv`** | Fast Python package install | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| **`dvc`** | Data versioning / pipelines | `pipx install dvc` |
| **`quarto`** | Render manuscripts and dashboards | https://quarto.org/docs/get-started/ |
| **`pre-commit`** | Code quality gates | `pipx install pre-commit` |

## Optional, depending on what you grow

| Component | Tool needed |
|---|---|
| `pipelines:nextflow` | [Nextflow](https://www.nextflow.io/) |
| `pipelines:snakemake` | [Snakemake](https://snakemake.github.io/) |
| `infra:terraform` | [Terraform](https://www.terraform.io/) |
| `infra:dagger` | [Dagger](https://dagger.io/) |
| `infra:lxd` | LXD |
| `infra:multipass` | [Multipass](https://multipass.run/) |
| `db:duckdb` | [DuckDB](https://duckdb.org/) |
| `lang:rust` | Rust toolchain |
| `lang:julia` | Julia |

`just doctor` (run inside a scaffolded project) tells you which tools are
needed for currently planted components.

## Verify everything

```bash
python3 --version
copier --version
just --version
```

If all three respond, you're ready. [Create your first project →](./first-project)
