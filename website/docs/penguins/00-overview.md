---
sidebar_position: 1
title: Overview
---

# 🐧 Penguins study — end-to-end tutorial

A worked example: scaffold a project, load the
[Palmer Penguins dataset](https://allisonhorst.github.io/palmerpenguins/),
explore it, build a classifier, generate figures, and render a manuscript.

## What you'll build

By the end, you'll have:

- A scaffolded project (`penguins-study`) with the right components planted
- Raw + processed data under `data/`
- An EDA notebook
- Engineered features in `data/features/`
- A trained model in `data/models/`
- Predictions + evaluation in `data/model-output/`
- Figures and tables in `data/08_reporting/`
- A short manuscript in `writeup/manuscript/`

## Why penguins

- The [Palmer Penguins dataset](https://github.com/allisonhorst/palmerpenguins)
  is small (~340 rows × 8 columns), well-labeled, and easy to explore
- It's an established teaching dataset that replaced Iris
- Three species, four physical measurements, one categorical sex —
  perfect for classification + EDA

## What you'll learn

- How `copier copy` + `just replant` set up a tailored project
- How `just grow` plants additional capability mid-project
- The standard data-stage layout (raw → intermediate → features → model)
- How DVC and Quarto connect to produce reproducible outputs
- How to render a manuscript that pulls in figures from `data/08_reporting/`

## Prerequisites

Before starting:

```bash
python3 --version    # 3.10+
copier --version
just --version
```

If any are missing, [install them first](/docs/install).

You'll also want:
- [`pixi`](https://pixi.sh/) (or `uv`) for Python env management
- [`quarto`](https://quarto.org/) for rendering (optional — needed for §6, §7)

## Time estimate

- **§1–2 (scaffold + data):** 5 min
- **§3–4 (explore + features):** 20 min
- **§5–6 (model + report):** 30 min
- **§7 (publish):** 15 min
- **Total:** ~70 min for the full walkthrough

[Begin: Scaffold the project →](./scaffold)
