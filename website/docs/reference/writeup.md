---
sidebar_position: 7
title: Writeup formats
---

# Reference — Writeup formats

The `writeup/` directory holds academic outputs. `writeup/manuscript/` is
active by default; other formats are dormant components.

## Active by default

```
writeup/
└── manuscript/
    ├── manuscript.qmd     (or .Rmd / .md depending on documentation_format)
    ├── references.bib
    ├── _quarto.yml
    ├── assets/
    │   ├── logo.png
    │   └── header.tex
    └── _manuscript/        # rendered output (gitignored)
```

Build with:
```bash
just manuscript-render
just manuscript-watch        # auto-rebuild on save
```

## Dormant components

| Component | Path when planted | What it provides |
|---|---|---|
| `writeup:abstracts` | `writeup/abstracts/` | Conference + journal abstract templates |
| `writeup:blog` | `writeup/blog/` | Quarto blog with research log |
| `writeup:book` | `writeup/book/` | Long-form book scaffolding |
| `writeup:grants` | `writeup/grants/` | NSF / NIH / DOE / ERC proposal templates |
| `writeup:poster` | `writeup/poster/` | Academic + professional poster templates |
| `writeup:presentation` | `writeup/presentation/` | Beamer + Reveal.js + Quarto talks |
| `writeup:report` | `writeup/report/` | Technical + executive report templates |

## Plant individually

```bash
just grow writeup:poster
ls writeup/poster/
# academic-template/  professional-template/
```

## Plant the academic-writing bundle

```bash
just grow preset:academic-writing
# → core:base + writeup:presentation + writeup:abstracts +
#   writeup:poster + writeup:grants
```

## Pulling in figures and tables

Manuscripts conventionally pull from `data/08_reporting/`:

```markdown
![Pairplot of measurements](../../data/08_reporting/082_figures/pairplot.png)
```

For tables generated in code:

```{r}
library(readr)
read_csv("../../data/08_reporting/081_tables/results.csv")
```

For Quarto cross-referencing:

```markdown
![Caption](path/to/figure.png){#fig-name}

See @fig-name.
```

## Render commands

### Manuscript

```bash
just manuscript-render          # render to PDF + HTML
just manuscript-watch           # auto-rebuild on save
just manuscript-clean           # remove _manuscript/
```

### Other formats (when planted)

```bash
just writeup poster-render <template-name>
just writeup presentation-render <template-name>
just writeup abstract-new <conference-name>
just writeup grant-new <funder-name>
```

## Citation management

`references.bib` lives in each writeup subdir. To share citations across
manuscript / poster / presentation, symlink:

```bash
ln -s ../manuscript/references.bib writeup/poster/references.bib
```

## Cross-platform considerations

- **Quarto** works identically on Linux / macOS / Windows
- **Beamer** (LaTeX) needs a TeX distribution: TeX Live / MiKTeX
- **Reveal.js** runs purely in the browser; no extra deps
- **Pollen** (Racket) needs Racket installed (used by `tasks/pollen.just`)

## Multi-language documents

For projects that mix Python and R chunks, use Quarto:

```yaml
---
title: "Mixed analysis"
format: html
jupyter: python3
---

{python}
import pandas as pd
df = pd.read_csv("data.csv")
df.head()
```

```{r}
library(readr)
df <- read_csv("data.csv")
summary(df)
```

## Templates ship with examples

Each writeup component includes at least one fully-worked example so
new users have a starting point.
