---
sidebar_position: 3
title: 2. Writing
---

# Phase 2 — Writing

Drafting the manuscript in `writeup/manuscript/`, **pulling figures and
numbers from versioned reports** (Phase 1).

## Penguins manuscript skeleton

After the [penguins tutorial](/docs/penguins/overview), open `writeup/manuscript/manuscript.qmd`
and replace the body:

```markdown
---
title: "Palmer penguin species classification: a baseline study"
author:
  - name: Your Name
    orcid: 0000-0000-0000-0000
    affiliations:
      - University Name
date: today
abstract: |
  We replicate baseline species classification on the Palmer Penguins
  dataset using logistic regression and random forest. With four physical
  measurements plus two engineered features, a random forest achieves
  0.99 test accuracy.
keywords: [classification, palmer penguins, random forest]
bibliography: references.bib
csl: nature.csl
format:
  html: { toc: true, code-fold: true }
  pdf:  { documentclass: article, include-in-header: assets/header.tex }
---

# Introduction

The Palmer Penguins dataset [@horst2020palmer] provides four physical
measurements for three penguin species observed at Palmer Station,
Antarctica. We use it as a teaching example for baseline classification
methods — small enough to inspect by hand, structured enough to teach
feature engineering and cross-validation.

# Data

Source: [palmerpenguins R package GitHub](https://github.com/allisonhorst/palmerpenguins).
After dropping rows missing any of `species`, `bill_length_mm`,
`bill_depth_mm`, `flipper_length_mm`, or `body_mass_g`, **n = 333** records
remained.

| Species   | n   |
|-----------|-----|
| Adelie    | 146 |
| Gentoo    | 119 |
| Chinstrap |  68 |

@fig-pairplot shows the cluster structure: Gentoo separates on flipper length
and body mass, while Adelie and Chinstrap differ on bill length.

![Pairplot of penguin measurements by species (v0.5).](
../../data/publications/v0.5/figures/pairplot.png){#fig-pairplot}

# Methods

## Features

Two domain features were derived in addition to the four physical measurements:

- `bill_ratio = bill_length / bill_depth`
- `body_density_proxy = body_mass / flipper_length`

All features were standardized to zero mean and unit variance.

## Models

A multinomial logistic regression baseline and a random forest with
200 trees were trained on a stratified 64% / 16% / 20% (train / val / test)
split with `random_state = 42`.

# Results

The random forest classifier achieved **0.99 test accuracy** (logistic
regression baseline: 0.97). @fig-cm shows the confusion matrix.

![Confusion matrix on the test set (Random Forest, n=200, v0.5).](
../../data/publications/v0.5/figures/confusion-matrix.png){#fig-cm}

The single misclassified row was a Chinstrap with unusually short bill
mistaken for Adelie. Per-species F1 scores are in
@tbl-classification-report.

```{python}
#| label: tbl-classification-report
#| tbl-cap: "Per-species F1 / precision / recall (v0.5)"
import pandas as pd
# Read the snapshotted version, not the live data/model-output/
with open("../../data/publications/v0.5/tables/classification-report.txt") as f:
    print(f.read())
```

# Discussion

The Palmer Penguins dataset is well-separated in feature space; even the
logistic regression baseline achieves 0.97 test accuracy. The added
domain features made a marginal contribution; permutation importance
suggests `flipper_length` and `bill_length` carry most signal.

# Data and code availability

Source code: https://github.com/your-org/penguins-paper
Versioned reports: `data/publications/v0.5/`
DVC remote: s3://your-bucket/penguins-paper/

# References
```

## Why pull from `data/publications/v0.5/` not `data/08_reporting/`

| Pulling from | Risk |
|---|---|
| `data/08_reporting/082_figures/cm_rf.png` | Re-running the analysis silently changes the figure under your feet; reviewers see different numbers between rounds |
| `data/publications/v0.5/figures/confusion-matrix.png` | Stable. v0.5 is git-tagged. Reviewers in round 1 see exactly what the author saw at submission. |

The pattern: `data/08_reporting/` is *current state*; `data/publications/v<x>/` is
*frozen state*. Manuscripts pull frozen state.

## Build commands

```bash
just manuscript-render      # build all formats once
just manuscript-watch       # auto-rebuild on save
just manuscript-clean       # remove _manuscript/
```

`manuscript-render` produces:

- `_manuscript/manuscript.html` — preview / Pages-deployable
- `_manuscript/manuscript.pdf` — for journal submission
- `_manuscript/manuscript.docx` — if reviewers want Word

## Citations

`references.bib` lives next to the manuscript:

```bibtex
@article{horst2020palmer,
  author = {Horst, Allison Marie and Hill, Alison Presmanes and Gorman, Kristen B.},
  title = {palmerpenguins: Palmer Archipelago (Antarctica) penguin data},
  year = {2020},
  url = {https://allisonhorst.github.io/palmerpenguins/},
}

@article{breiman2001random,
  author = {Breiman, Leo},
  title = {Random Forests},
  journal = {Machine learning},
  year = {2001},
}
```

Cite with `@horst2020palmer`. For citation styles, drop a `.csl` file in the
manuscript directory and reference it in front matter (`csl: nature.csl`).
[CSL repository](https://github.com/citation-style-language/styles) has 10,000+
journal styles.

## Splitting into sections (longer manuscripts)

```yaml
# manuscript.qmd
{{< include sections/_intro.qmd >}}
{{< include sections/_methods.qmd >}}
{{< include sections/_results.qmd >}}
{{< include sections/_discussion.qmd >}}
```

Each section is a partial `.qmd` with `_` prefix (Quarto doesn't render
standalone). Per-section authorship is straightforward via PR review.

## Cross-references

| Want | Syntax |
|---|---|
| Figure | `![Caption](path){#fig-name}` → `@fig-name` |
| Table | `: Caption {#tbl-name}` → `@tbl-name` |
| Equation | `$$ ... $$ {#eq-name}` → `@eq-name` |
| Section | Add `{#sec-intro}` after a heading → `@sec-intro` |

## Live preview

```bash
just manuscript-watch
```

Opens a browser tab. As you save, the rendered HTML reloads. Best workflow:
draft on the left, preview on the right.

[Next: Review →](./review)
