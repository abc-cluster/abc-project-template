---
sidebar_position: 7
title: 6. Build the manuscript
---

# Step 6 — Write up the results

The Full Academic Project preset planted `writeup:manuscript` style content
under `writeup/manuscript/`. Build a short technical note pulling in the
figures we've generated.

## Manuscript template

Open `writeup/manuscript/manuscript.qmd` (or rename to `penguins-classifier.qmd`).
Replace the body with something like:

```markdown
---
title: "Penguin species classification: a baseline study"
author: "Your Name"
date: today
format:
  html: default
  pdf: default
bibliography: references.bib
---

# Abstract

We replicate baseline species classification on the Palmer Penguins
dataset using logistic regression and random forest. With four physical
measurements plus two engineered features, a random forest achieves
~0.99 test accuracy.

# Introduction

The Palmer Penguins dataset [@horst2020palmer] provides measurements of
three penguin species at the Palmer Station, Antarctica. With 333 complete
records (after dropping rows with missing key fields), the task of species
classification is well-posed but offers a clean teaching example.

# Data

The raw data was downloaded from the
[palmerpenguins R package GitHub](https://github.com/allisonhorst/palmerpenguins).
After dropping rows missing any of `species`, `bill_length_mm`,
`bill_depth_mm`, `flipper_length_mm`, or `body_mass_g`, **n = 333** records
remained, distributed:

```{r}
#| label: tbl-counts
#| tbl-cap: "Sample counts per species"
library(readr)
df <- read_csv("../../data/02_intermediate/021_cleaned/penguins_clean.csv",
               show_col_types = FALSE)
table(df$species)
```

# Methods

## Features

We computed two domain features in addition to the four physical
measurements:

- `bill_ratio = bill_length / bill_depth`
- `body_density_proxy = body_mass / flipper_length`

All features were standardized to zero mean and unit variance.

## Models

A multinomial logistic regression baseline and a random forest with
200 trees were trained on a stratified 64% / 16% / 20% (train / val / test)
split.

# Results

## Pairplot of features

![Pairplot of penguin measurements by species](
../../data/08_reporting/082_figures/penguins_pairplot.png){#fig-pairplot}

@fig-pairplot shows the cluster structure clearly: Gentoo separates on
flipper length and body mass, while Adelie and Chinstrap differ on bill
length.

## Test-set classification

The random forest model achieved 0.99 test accuracy. The single misclassified
row was a Chinstrap with unusually short bill misclassified as Adelie.

![Confusion matrix on the test set
(Random Forest, n_estimators=200)](../../data/08_reporting/082_figures/cm_rf.png){#fig-cm}

# Discussion

The Palmer Penguins dataset is well-separated in feature space; even the
logistic regression baseline achieves 0.97 test accuracy. The added
domain features (`bill_ratio`, `body_density_proxy`) made a marginal
contribution; permutation importance suggests `flipper_length` and
`bill_length` carry most signal.

# References
```

## Add bibtex

Create `writeup/manuscript/references.bib`:

```bibtex
@article{horst2020palmer,
  author = {Horst, Allison Marie and Hill, Alison Presmanes and Gorman, Kristen B.},
  title = {palmerpenguins: Palmer Archipelago (Antarctica) penguin data},
  year = {2020},
  url = {https://allisonhorst.github.io/palmerpenguins/},
}
```

## Render

```bash
just manuscript-render
```

This produces `writeup/manuscript/_manuscript/manuscript.html` and `.pdf`
(if LaTeX is installed for PDF).

## Watch mode

For an interactive write/preview loop:

```bash
just manuscript-watch
```

Quarto rebuilds on save.

## Commit

```bash
git add writeup/manuscript/
git commit -m "writeup: penguins classifier baseline manuscript"
```

[Next: Publish →](./publish)
