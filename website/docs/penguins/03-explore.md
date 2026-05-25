---
sidebar_position: 4
title: 3. Explore the data
---

# Step 3 — Exploratory data analysis

Create an EDA notebook scaffolded from the template's experiment template:

```bash
just notebooks new-eda "penguins-overview"
```

This creates `notebooks/02-exploration/eda/<timestamp>_eda_penguins-overview.qmd`
with a pre-filled experiment ID, date, and stage metadata.

## Open it

```bash
quarto preview notebooks/02-exploration/eda/*_eda_penguins-overview.qmd
```

Or open in Jupyter / Positron / VS Code with the Jupyter extension.

## Suggested EDA cells

```python
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

penguins = pd.read_csv("data/01_raw/011_external/penguins.csv")

# Drop rows with missing species/measurements
clean = penguins.dropna(subset=["species", "bill_length_mm", "bill_depth_mm",
                                "flipper_length_mm", "body_mass_g"])

clean.shape
# (333, 8) — dropped 11 rows with missing key fields
```

```python
# Counts per species
clean["species"].value_counts()

# Adelie       146
# Gentoo       119
# Chinstrap     68
```

```python
# Pairplot — classic exploratory visualization
sns.pairplot(clean, hue="species",
             vars=["bill_length_mm", "bill_depth_mm",
                   "flipper_length_mm", "body_mass_g"])
plt.savefig("data/08_reporting/082_figures/penguins_pairplot.png", dpi=150,
            bbox_inches="tight")
plt.show()
```

```python
# Box plot per species
fig, axes = plt.subplots(2, 2, figsize=(10, 8))
for ax, col in zip(axes.flat, ["bill_length_mm", "bill_depth_mm",
                                "flipper_length_mm", "body_mass_g"]):
    sns.boxplot(data=clean, x="species", y=col, ax=ax)
fig.suptitle("Measurements by species")
fig.tight_layout()
fig.savefig("data/08_reporting/082_figures/penguins_boxplots.png", dpi=150)
```

## Save the cleaned data

```python
clean.to_csv("data/02_intermediate/021_cleaned/penguins_clean.csv", index=False)
```

## Track with DVC

```bash
dvc add data/02_intermediate/021_cleaned/penguins_clean.csv
git add data/02_intermediate/021_cleaned/penguins_clean.csv.dvc
git commit -m "eda: drop missing-key rows, save cleaned"
```

## Insights from EDA

After looking at the plots:

- **Gentoo** is clearly separable on `flipper_length_mm` and `body_mass_g`
  (much larger than the other two species).
- **Adelie** vs **Chinstrap** is harder — they overlap heavily on body size.
  But **bill_length_mm** separates them well: Adelie bills are shorter (~39mm)
  vs Chinstrap (~49mm).
- **bill_depth_mm** vs **bill_length_mm** plot shows a clean cluster structure.

These observations guide the feature engineering step.

[Next: Engineer features →](./features)
