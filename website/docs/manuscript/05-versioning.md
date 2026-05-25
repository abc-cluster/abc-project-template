---
sidebar_position: 5
title: 4. Versioning
---

# Phase 4 — Versioning

Use git tags to mark manuscript milestones. Each tag freezes both the
manuscript text AND the versioned reports it pulls from.

## Tag schema

```
v0.1-eda                  exploratory analysis snapshot
v0.3-features             after feature engineering
v0.5-baseline             baseline + candidate models locked
v0.7-final-model          hyperparameter-tuned production model
v1.0-preprint             frozen for preprint submission
v1.1-revision-r1          after reviewer round 1
v1.2-revision-r2          after reviewer round 2
v1.0-final                accepted version
```

Semver-ish: `v<major>.<minor>-<phase>`. Major bumps mark big methodological
changes; minor bumps mark draft revisions.

## Tag a milestone

```bash
git add writeup/manuscript/ data/publications/v0.5/
git commit -m "v0.5-baseline: classifier results in manuscript"
git tag -a v0.5-baseline -m "Penguins manuscript draft 0.5

Includes:
- Random forest test accuracy 0.99
- Confusion matrix figure
- Per-species F1 table
- Methods section complete
- Results section complete
- Introduction draft (needs polish)

Reviewers: @collaborator-1, @collaborator-2"
git push --tags
```

The tag message is the milestone log. Future you (or reviewers checking
`git tag -n`) sees what each version meant.

## Reproduce any prior version

To rebuild v0.5's PDF exactly as the author saw it at the time:

```bash
git checkout v0.5-baseline
dvc checkout                                           # if DVC-tracked
just manuscript-render
# writeup/manuscript/_manuscript/manuscript.pdf is byte-identical
git switch -                                            # back to main
```

Useful when:
- Reviewer references "Figure 3 from the original submission" — you can show
  exactly that figure
- Co-author asks "what did the random forest accuracy say in the v0.5 draft?"
  — you check out the tag, render, look
- Funder audits the analysis — you point to specific tagged versions

## What to tag vs. what to commit

Every commit doesn't need a tag. Tag at **decision points**:

| Action | Commit? | Tag? |
|---|---|---|
| Fix a typo | ✓ | ✗ |
| Add a paragraph | ✓ | ✗ |
| Replace a figure | ✓ | ✗ |
| Snapshot a new version | ✓ | ✓ |
| Submit for internal review | ✓ | ✓ (`v0.5-internal-review`) |
| Submit preprint | ✓ | ✓ (`v1.0-preprint`) |
| Submit to journal | ✓ | ✓ (`v1.0-journal-submission`) |
| Receive reviewer comments | ✗ | ✗ (just save the comments) |
| Address comments → resubmit | ✓ | ✓ (`v1.1-revision-r1`) |
| Paper accepted | ✓ | ✓ (`v1.0-final`) |

## Linking tags to Zenodo DOIs

Each preprint / final tag should produce a Zenodo DOI for permanent citation.
See [Phase 5 — Preprint](./preprint) for the full Zenodo workflow.

A useful convention is to put the DOI in the tag message:

```bash
git tag -a v1.0-preprint -m "Penguins manuscript v1.0 preprint

Zenodo DOI: 10.5281/zenodo.1234567
bioRxiv: https://www.biorxiv.org/content/...

Snapshot of:
- data/publications/v1.0/
- writeup/manuscript/manuscript.qmd"
```

This way, `git show v1.0-preprint` always tells you "where did this version go".

## A `manuscript-versions.md` log file

For human readers, keep a chronological log:

```markdown
<!-- writeup/manuscript/VERSIONS.md -->
# Version history

## v1.0-final — 2026-09-15
- Accepted at *Journal of Bioinformatics*, 2026 vol. X issue Y
- Zenodo DOI: 10.5281/zenodo.1234599
- Final figures: `data/publications/v1.0/`

## v1.2-revision-r2 — 2026-08-30
- Addressed reviewer round 2: bill_ratio sensitivity analysis added
- Updated @fig-pairplot to v1.2/figures/pairplot.png
- Response letter: writeup/manuscript/journal/responses/r2.md

## v1.1-revision-r1 — 2026-07-20
- Addressed reviewer round 1: clarified train/val/test stratification
- Added supplementary table S1 (full hyperparameter sweep)
- Response letter: writeup/manuscript/journal/responses/r1.md

## v1.0-preprint — 2026-06-15
- bioRxiv submission (DOI 10.1101/...)
- Zenodo DOI: 10.5281/zenodo.1234567

## v0.5-baseline — 2026-05-22
- Internal review draft
- Random forest baseline locked at n=200 trees
```

## CI tagging

Add a lightweight workflow to lint tags:

```yaml
# .github/workflows/manuscript-tag.yml
on:
  push:
    tags: ['v*']

jobs:
  validate-tag:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - name: Verify v<n>.<n>-<label> format
        run: |
          tag="${GITHUB_REF#refs/tags/}"
          echo "$tag" | grep -qE '^v[0-9]+\.[0-9]+-[a-z][a-z0-9-]*$' || {
            echo "Tag '$tag' doesn't match v<major>.<minor>-<label>"
            exit 1
          }
      - name: Render manuscript at this tag
        run: |
          quarto render writeup/manuscript/manuscript.qmd
      - uses: softprops/action-gh-release@v1
        with:
          files: |
            writeup/manuscript/_manuscript/manuscript.pdf
            writeup/manuscript/_manuscript/manuscript.html
```

Each tag becomes a GitHub Release with the rendered PDF + HTML attached —
permanent download links for collaborators and reviewers.

[Next: Preprint →](./preprint)
