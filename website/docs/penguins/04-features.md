---
sidebar_position: 5
title: 4. Engineer features
---

# Step 4 — Feature engineering

We have `data:features` planted (it auto-planted as part of Full Academic
Project). Use the standard substages.

## Standard feature substages

The `data:features` component creates these subdirs:

```
data/features/
├── 041_domain/             # domain-knowledge features (e.g. ratios)
├── 042_statistical/        # statistical features (mean, std, ...)
├── 043_interaction/        # interaction terms
├── 044_scaled/             # scaled / standardized
└── 045_dimensionality_reduced/  # PCA / UMAP / ...
```

For penguins, we'll use only `041_domain/` and `044_scaled/`.

## Domain features

Bill length / depth ratio is a classic species discriminator. Create
`scripts/feature_engineer.py`:

```python
"""Engineer features for the Penguins dataset."""
from pathlib import Path
import pandas as pd

CLEAN = Path("data/02_intermediate/021_cleaned/penguins_clean.csv")
DOMAIN = Path("data/features/041_domain/penguins_features_domain.csv")

df = pd.read_csv(CLEAN)

# Domain features
df["bill_ratio"] = df["bill_length_mm"] / df["bill_depth_mm"]
df["body_density_proxy"] = df["body_mass_g"] / df["flipper_length_mm"]

DOMAIN.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(DOMAIN, index=False)
print(f"Wrote {DOMAIN}")
```

Run:

```bash
python scripts/feature_engineer.py
```

## Scaled features

```python
# scripts/scale_features.py
from pathlib import Path
import pandas as pd
from sklearn.preprocessing import StandardScaler

DOMAIN = Path("data/features/041_domain/penguins_features_domain.csv")
SCALED = Path("data/features/044_scaled/penguins_features_scaled.csv")

df = pd.read_csv(DOMAIN)
numeric_cols = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm",
                "body_mass_g", "bill_ratio", "body_density_proxy"]

scaler = StandardScaler()
df[numeric_cols] = scaler.fit_transform(df[numeric_cols])

SCALED.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(SCALED, index=False)
print(f"Wrote {SCALED}")
```

```bash
python scripts/scale_features.py
```

## Wire into DVC

Add a `dvc.yaml` stage:

```yaml
# dvc.yaml
stages:
  features:
    cmd: |
      python scripts/feature_engineer.py
      python scripts/scale_features.py
    deps:
      - data/02_intermediate/021_cleaned/penguins_clean.csv
      - scripts/feature_engineer.py
      - scripts/scale_features.py
    outs:
      - data/features/041_domain/penguins_features_domain.csv
      - data/features/044_scaled/penguins_features_scaled.csv
```

```bash
dvc repro features
git add scripts/ dvc.yaml dvc.lock data/features/041_domain/.gitignore data/features/044_scaled/.gitignore
git commit -m "features: add domain + scaled features for penguins"
```

## Train/val/test split

Split into `data/05_model_input/`:

The `data:model-input` component already provides:
```
data/model-input/
├── 051_test/
├── 052_train/
├── 053_validation/
└── 054_production/
```

```python
# scripts/split_data.py
from pathlib import Path
import pandas as pd
from sklearn.model_selection import train_test_split

SCALED = Path("data/features/044_scaled/penguins_features_scaled.csv")
TRAIN = Path("data/model-input/052_train/penguins_train.csv")
VAL   = Path("data/model-input/053_validation/penguins_val.csv")
TEST  = Path("data/model-input/051_test/penguins_test.csv")

df = pd.read_csv(SCALED)
y = df["species"]
X = df.drop(columns=["species"])

X_trv, X_test, y_trv, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
X_tr, X_val, y_tr, y_val = train_test_split(X_trv, y_trv, test_size=0.2, random_state=42, stratify=y_trv)

for path, X_, y_ in [(TRAIN, X_tr, y_tr), (VAL, X_val, y_val), (TEST, X_test, y_test)]:
    path.parent.mkdir(parents=True, exist_ok=True)
    pd.concat([X_, y_], axis=1).to_csv(path, index=False)
    print(f"Wrote {path}: {len(X_)} rows")
```

```bash
python scripts/split_data.py
```

[Next: Train a model →](./model)
