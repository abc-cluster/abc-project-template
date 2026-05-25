---
sidebar_position: 8
title: 7. Publish
---

# Step 7 — Publish your work

You've got a working analysis, model, and manuscript. Now turn it into
sharable artifacts.

## Generate a poster (optional — already planted)

`writeup:poster` was planted in §1. Customize:

```bash
ls writeup/poster/
# academic-template/  professional-template/
```

Pick a template, edit `writeup/poster/academic-template/src/poster.qmd`,
and render:

```bash
just writeup poster-render academic-template
```

## Generate a presentation (optional — already planted)

`writeup:presentation` was planted in §1.

```bash
ls writeup/presentation/
# academic-template/  beamer-template/  reveal-template/
```

Edit your chosen template and render:

```bash
just writeup presentation-render academic-template
```

## Create a conference abstract

`writeup:abstracts` was planted in §1.

```bash
ls writeup/abstracts/
just writeup abstract-new "neurips-2026"
# Creates writeup/abstracts/neurips-2026/abstract.qmd
```

## Cite the dataset properly

Follow the [`palmerpenguins` citation guidance](https://allisonhorst.github.io/palmerpenguins/#citation):

```text
Horst AM, Hill AP, Gorman KB (2020). palmerpenguins: Palmer Archipelago
(Antarctica) penguin data. R package version 0.1.0.
https://allisonhorst.github.io/palmerpenguins/
```

## Bundle for sharing

```bash
# Render everything
just writeup export-all

# Outputs land in:
ls writeup/manuscript/_manuscript/    # HTML + PDF manuscript
ls writeup/poster/academic-template/_output/
ls writeup/presentation/academic-template/_output/
```

## Share via DVC remote

If you've configured a DVC remote (S3, GCS, Azure):

```bash
dvc push
git push
```

Collaborators clone + `dvc pull` to get the data; everything else is
reproducible from `dvc.yaml`.

## Add a GitHub Actions workflow

Want CI to render the manuscript on every push?

```yaml
# .github/workflows/manuscript.yml
name: Render manuscript

on:
  push:
    paths:
      - 'writeup/manuscript/**'
      - 'data/08_reporting/**'
      - '.github/workflows/manuscript.yml'

jobs:
  render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: quarto-dev/quarto-actions/setup@v2
      - run: quarto render writeup/manuscript/manuscript.qmd
      - uses: actions/upload-artifact@v4
        with:
          name: manuscript
          path: writeup/manuscript/_manuscript/
```

## What you've built

Recap of files now in your project:

```
penguins-study/
├── data/
│   ├── 01_raw/011_external/penguins.csv          (raw)
│   ├── 02_intermediate/021_cleaned/penguins_clean.csv   (333 rows)
│   ├── features/041_domain/                       (+2 domain features)
│   ├── features/044_scaled/                       (StandardScaler)
│   ├── model-input/{051_test,052_train,053_validation}/
│   ├── models/{061_baseline,062_candidate}/
│   ├── model-output/{071_predictions,072_probabilities,073_evaluation}/
│   └── 08_reporting/082_figures/{penguins_pairplot,boxplots,cm_rf}.png
├── notebooks/02-exploration/eda/<ts>_eda_penguins-overview.qmd
├── scripts/{feature_engineer,scale_features,split_data,train_*,evaluate,plot_cm}.py
├── dvc.yaml                                       (4 stages)
├── writeup/manuscript/manuscript.qmd
└── writeup/manuscript/references.bib
```

Plus all the seed-bank components dormant in `.garden/components/` that
you didn't grow.

## Next steps

This walkthrough covered the happy path. For the full feature surface:

- [Reference: Garden CLI](/docs/reference/garden)
- [Reference: Components](/docs/reference/components)
- [Reference: justfile recipes](/docs/reference/justfile)
- [Reference: Data stages](/docs/reference/data-stages)
- [Reference: Writeup formats](/docs/reference/writeup)
- [Reference: Safety net](/docs/reference/safety-net)
