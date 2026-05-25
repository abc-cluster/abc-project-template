---
sidebar_position: 3
title: 2. Get the data
---

# Step 2 — Acquire the data

The Palmer Penguins dataset is published on PyPI as `palmerpenguins` and on
[GitHub](https://github.com/allisonhorst/palmerpenguins/tree/main/inst/extdata)
as a CSV.

## Option A — From the Python package

```bash
just data download-external \
    https://raw.githubusercontent.com/allisonhorst/palmerpenguins/main/inst/extdata/penguins.csv \
    penguins
```

The `data download-external` recipe (from the `data:features` component):

1. Downloads the URL to `data/01_raw/011_external/penguins_<date>.csv`
2. Computes a sha256 checksum
3. Records metadata in `data/01_raw/011_external/.metadata/penguins.yaml`

## Option B — In a Python script

```python
# scripts/load_penguins.py
from pathlib import Path
import pandas as pd

URL = "https://raw.githubusercontent.com/allisonhorst/palmerpenguins/main/inst/extdata/penguins.csv"
DEST = Path("data/01_raw/011_external/penguins.csv")
DEST.parent.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(URL)
df.to_csv(DEST, index=False)
print(f"Saved {len(df)} rows to {DEST}")
```

```bash
python scripts/load_penguins.py
```

## Verify

```bash
just data validate-dataset data/01_raw/011_external/penguins.csv
```

You should see:

```
🔍 Validating dataset: data/01_raw/011_external/penguins.csv
  Rows:        344
  Columns:     8
  Missing:     19 cells across 4 columns
  Dtypes:      species(O), island(O), bill_length_mm(F), bill_depth_mm(F),
               flipper_length_mm(F), body_mass_g(F), sex(O), year(I)
  ✓ valid CSV
```

Profile it:

```bash
just data profile-dataset data/01_raw/011_external/penguins.csv
```

This generates a [`ydata-profiling`](https://docs.profiling.ydata.ai/) report
to `data/02_intermediate/022_profiled/penguins_profile.html`.

## Track with DVC

Since you enabled `data_versioning`, track the raw file:

```bash
dvc add data/01_raw/011_external/penguins.csv
git add data/01_raw/011_external/penguins.csv.dvc data/01_raw/011_external/.gitignore
git commit -m "data: track Palmer Penguins raw CSV"
```

DVC stores the actual file outside git (in `.dvc/cache/`); only the small `.dvc`
metadata file is committed.

## Inspect

```bash
head -5 data/01_raw/011_external/penguins.csv
```

```csv
species,island,bill_length_mm,bill_depth_mm,flipper_length_mm,body_mass_g,sex,year
Adelie,Torgersen,39.1,18.7,181,3750,male,2007
Adelie,Torgersen,39.5,17.4,186,3800,female,2007
Adelie,Torgersen,40.3,18,195,3250,female,2007
Adelie,Torgersen,,,,,,2007
```

[Next: Explore →](./explore)
