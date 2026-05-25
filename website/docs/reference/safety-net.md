---
sidebar_position: 8
title: Safety net (CTT harness)
---

# Reference — CTT safety net

The `tests/` directory contains a regression-test harness that captures
deterministic baselines of every CTT scenario's output. Used to verify no
capability is lost during refactors.

## Purpose

The template has 800+ files in the seed bank and 54 CTT scenarios. Without
a safety net, it's easy for a refactor to:

- Drop a file silently
- Change a file's content unintentionally
- Add files that shouldn't be there

The harness catches all three by comparing **per-scenario manifests** of
`<sha256>\t<size>\t<path>` lines.

## Files

| File | Purpose |
|---|---|
| `tests/snapshot-baselines.sh` | Regenerate baselines from a fresh CTT run |
| `tests/check-baselines.sh` | Diff current CTT output vs committed baselines |
| `tests/lib/scenarios.py` | Parse `ctt.toml` for scenario keys |
| `tests/baseline/INDEX.txt` | Per-scenario file count, byte total, manifest hash |
| `tests/baseline/<scenario>/manifest.txt` | Per-scenario file manifest |

## Workflow

### Before refactor work

```bash
./tests/check-baselines.sh
```

Confirms current state matches committed baselines. **Must pass before you
change anything.**

### During refactor work

After each meaningful change:

```bash
./tests/check-baselines.sh
```

Expect failures while moving things around. The diff output shows:

- **MISSING** (in baseline, not in current) — files that disappeared
- **ADDED** (in current, not in baseline) — new files
- **CHANGED** (different content hash) — modified files

Document each in your PR.

### After refactor work

```bash
./tests/snapshot-baselines.sh    # regenerate baselines
git add tests/baseline/
git commit -m "tests: snapshot post-refactor baselines"
```

Subsequent PRs are gated by `check-baselines.sh` against this new baseline.

## Single-scenario testing

```bash
./tests/check-baselines.sh --scenario minimal-starter
./tests/check-baselines.sh ctt-minimal.toml      # use minimal config (1 scenario)
./tests/check-baselines.sh --no-rerun            # skip ctt; diff existing scenario dirs
```

## CI integration

`.github/workflows/template-baselines.yml`:

```yaml
name: Template baselines

on:
  pull_request:
    paths:
      - 'template/**'
      - 'copier.yml'
      - 'ctt.toml'
      - 'ctt-*.toml'
      - 'tests/**'
  push:
    branches: [master, main]

jobs:
  check-baselines:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: pipx install copier-template-tester
      - run: ./tests/check-baselines.sh
```

## How CTT works (gotchas)

- CTT writes each scenario to `<repo_root>/<scenario_key>/` directly — NOT
  to `.ctt/`. The `output_dir` setting in `ctt.toml` is ignored upstream.
- CTT skips copier `_tasks` (calls `worker.run_copy()`, not
  `worker.run_tasks()`). The harness runs `garden replant` manually after
  CTT to mirror real copier behavior.
- Scenarios use `[output."x"]` flat tables. Nested `[output."x".answers]`
  is silently ignored by CTT — every scenario was being rendered with
  default answers before this was discovered (Phase 3).

## Manifest format

```
# Manifest for scenario: full-academic
# Format: <sha256>\t<size>\t<relative-path>
# Sorted by path. Paths relative to scenario root.
# DO NOT EDIT — regenerate via ./tests/snapshot-baselines.sh
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855	0	.gitkeep
abc123def456...	1234	README.md
...
```

Sorted by path so diffs are stable. Hashes detect content changes; sizes
give quick visual sanity. Empty files appear with the canonical empty-string
SHA256.

## What it does NOT verify

- **Doesn't run any tests inside generated projects.** It only checks the
  template emits identical files. If a generated project's `just setup`
  would fail, this harness won't catch it.
- **Doesn't validate Jinja correctness semantically.** `ctt run` checks it
  renders without error; the harness checks the rendered output's stability.
- **Doesn't catch `.gitignore`d files.** The manifest walks the filesystem;
  files Copier didn't emit aren't tracked.

## Phase reference

The template was migrated through phases gated by this harness:

- **Phase 0** — built the safety net itself
- **Phase 1** — Garden machinery (`.garden/`, `garden.py`)
- **Phase 2** — 49 components moved to seed bank
- **Phase 3** — copier `_tasks` invokes `garden replant`
- **Phase 3.5** — flatten `analysis/` wrapper
- **Phase 4** — justfile consolidation
- **Phase 5** — polish (just tour/doctor/where, README, CI)

See [`tests/PHASE-*-COMPLETE.md`](https://github.com/abc-cluster/abc-project-template/tree/main/tests)
for per-phase details.
