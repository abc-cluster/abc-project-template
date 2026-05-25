# Template safety net (Phase 0)

This directory contains the regression-test harness for the template. It captures
deterministic baselines of every CTT scenario's generated output so that any
refactor — including the upcoming Garden / restructure work — can be verified to
preserve all existing capabilities.

## Why this exists

The template ships ~800 files and 54 CTT scenarios. Without a safety net, it's
easy for a refactor to:

- Drop a file silently (a recipe goes missing, a `.gitkeep` is forgotten)
- Change a file's content unintentionally (a Jinja substitution breaks)
- Add files that shouldn't be there (cleanup logic doesn't fire)

This harness catches all three by comparing **per-scenario manifests** of
`<sha256>\t<size>\t<path>` lines.

## Files

| File | Purpose |
|---|---|
| `snapshot-baselines.sh` | Regenerate baselines from a fresh CTT run. Run this AFTER intentional template changes. |
| `check-baselines.sh` | Compare current CTT output against baselines. Run this BEFORE refactor work and IN CI. |
| `baseline/INDEX.txt` | One line per scenario: `<scenario>\t<files>\t<bytes>\t<manifest_sha256>` |
| `baseline/<scenario>/manifest.txt` | Per-scenario file manifest, sorted by path |

## Workflow

### Before starting refactor work

```bash
./tests/check-baselines.sh
```

Confirms current state matches committed baselines. **Must pass before you change
anything.** If it fails, either:

- The committed baselines are stale (someone forgot to regenerate after a
  template change) — fix by running `./tests/snapshot-baselines.sh` and
  reviewing the diff carefully before committing.
- Something has drifted in the template — fix the drift before refactoring.

### During refactor work

After each meaningful change, run:

```bash
./tests/check-baselines.sh
```

Expect failures while you're moving things around — the baselines are pinned to
the **pre-refactor** state. Use the diff output to verify that:

- "MISSING" files have an explanation (intentionally dropped or moved)
- "ADDED" files have an explanation (new component scaffolding)
- "CHANGED" files have an explanation (Jinja template improvement, path update)

Track these in your PR description. **Nothing should disappear without a
documented reason.**

### After refactor work

Once the refactor is complete and you're confident the new template is correct:

```bash
./tests/snapshot-baselines.sh    # regenerate baselines
git add tests/baseline/
git commit -m "tests: snapshot post-refactor baselines"
```

Subsequent PRs are gated by `check-baselines.sh` against this new baseline.

### Quick check during dev (single scenario)

```bash
./tests/check-baselines.sh --scenario minimal-starter
./tests/check-baselines.sh --scenario full-academic
./tests/check-baselines.sh --no-rerun --scenario bioinformatics    # skip ctt, just diff
```

### Iterating on a small scenario set

`ctt-minimal.toml` and `ctt-debug.toml` exist for fast feedback on a single
scenario. To use them for baselining a subset:

```bash
./tests/snapshot-baselines.sh ctt-minimal.toml
./tests/check-baselines.sh ctt-minimal.toml
```

Note: this overwrites the relevant baselines. Don't commit unless you intend
the baseline set to shrink.

## Manifest format

Each `baseline/<scenario>/manifest.txt`:

```
# Manifest for scenario: full-academic
# Format: <sha256>\t<size>\t<relative-path>
# Sorted by path. Paths relative to scenario root.
# DO NOT EDIT — regenerate via ./tests/snapshot-baselines.sh
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855	0	.gitkeep
abc123def456...	1234	README.md
...
```

Sorted by path so diffs are stable. Hashes detect content changes; sizes give
quick visual sanity. Empty files appear with the canonical empty-string SHA256.

## How CTT works (gotchas)

CTT writes each scenario to `<repo_root>/<scenario_key>/` directly — **not** to
`.ctt/` even though `[config] output_dir = ".ctt"` is set in `ctt.toml`. The
upstream tool ignores that setting (see `_config.py` in the
`copier-template-tester` package — it doesn't read `output_dir`).

This means after `ctt run` completes you'll see ~54 directories at the project
root (`full-academic/`, `analysis-only/`, `bioinformatics/`, etc.). Our scripts
clean these up after capturing manifests, leaving only the manifests in
`tests/baseline/`.

The `tests/lib/scenarios.py` helper parses `ctt.toml` to extract the scenario
keys via regex (avoids depending on `tomllib` which is Python 3.11+; macOS
default is 3.9).

## What this does NOT do

- **Doesn't run any tests inside generated projects.** It only checks the
  template emits identical files. If a generated project's `just setup` would
  fail, this harness won't catch it. (Future work: run smoke-tests inside each
  generated tree.)
- **Doesn't validate Jinja template correctness.** `ctt run` does that
  implicitly (renders without error), but it doesn't validate semantic
  correctness of the rendered output.
- **Doesn't catch `.gitignore`d files.** The manifest walks the filesystem;
  files Copier didn't emit aren't tracked.
- **Doesn't normalize timestamps or UUIDs.** If `.copier-answers.yml` (or any
  emitted file) contains a content-changing dynamic value, the diff will flag
  it. If we hit this, add a normalization pass to both scripts. So far the
  template's outputs appear deterministic; revisit if not.

## CTT scenario inventory

The `ctt.toml` file contains 54 scenarios across these axes:

| Axis | Scenarios |
|---|---|
| Project type baselines | full-academic, analysis-only, manuscript-only, package-dev, custom-{minimal,maximal}, minimal-starter |
| Specializations | bioinformatics, quick-manuscript |
| Progressive enhancement | progressive-{minimal-tracking, minimal-writeup, full-upgrade} |
| Documentation formats | docs-{markdown, rmarkdown} |
| Version control | vcs-{jujutsu, fossil, hybrid} |
| Experiment tracking | tracking-{wandb, neptune-r} |
| Infrastructure combos | infra-{docker-only, cloud, virtualization} |
| Writeup subcomponents | writeup-{presentations, grants, posters-abstracts, reports-blog} |
| Data variations | data-{validation, versioning-only} |
| Package dev variants | package-dev-{r, multilang} |
| CI/CD variants | ci-{gha-only, precommit-only} |
| Analysis combos | analysis-{scripts-only, eda-focus, ml-focus} |
| Edge cases | absolutely-minimal, maximum-everything |
| Migration tests | 17 scenarios under `migration-*` covering folder removal, tool cleanup, language switching, downgrade |

When the refactor adds new components, **add a new CTT scenario** to exercise
the planted state. The safety net only catches what it can see.

## CI integration (future)

```yaml
# .github/workflows/template-test.yml
- name: Verify template baselines
  run: ./tests/check-baselines.sh
```

Add this as a required check on PRs.
