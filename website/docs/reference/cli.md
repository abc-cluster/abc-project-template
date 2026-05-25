---
sidebar_position: 3
title: CLI commands
---

# Reference — CLI commands

Quick lookup of every CLI command, recipe, and flag.

## Scaffolding (copier)

```bash
copier copy --trust gh:abc-cluster/abc-project-template <DIR>
copier update                    # in an existing project, pull latest template
copier copy --defaults ...       # accept all default answers (CI-friendly)
copier copy --data 'key=value' ...  # pass an answer non-interactively
```

## Top-level commands

```bash
just                          # list all available recipes
just tour                     # 5-line orientation
just doctor                   # tool/state health check
just where <thing>            # find where X lives in this project
just setup                    # install deps (uv + pre-commit)
```

`just where` recognized terms:
`raw-data`, `intermediate`, `processed`, `features`, `models`, `results`,
`figures`, `tables`, `notebooks`, `scripts`, `src`, `tests`, `manuscript`,
`poster`, `grants`, `presentation`, `pipeline`, `config`, `garden`.

## Garden commands

```bash
just garden                              # status (planted vs dormant)
just garden-list [planted|dormant]       # detailed listing
just garden-show <id>                    # component details
just grow <id>                           # plant a component
just grow preset:<name>                  # plant a curated bundle
just prune <id> [--keep-files]           # archive a planted component
just replant [--verbose]                 # plant defaults_for_project_type[chosen]
```

## Notebook commands (always-active)

```bash
just notebooks new-eda <name> [stage]              # new EDA notebook
just notebooks new-model <name> [stage] [type]     # new modeling notebook
just notebooks new-experiment <substage> <desc>    # custom experiment
just notebooks list                                # all notebooks
just notebooks list-stage <stage>                  # notebooks in a stage
just notebooks list-recent                         # last 7 days
just notebooks search <query>                      # search notebook contents
just notebooks run <notebook>                      # render a single notebook
just notebooks run-stage <stage>                   # render all in a stage
```

## Data commands (always-active core; rich set with `data:features`)

Always available:

```bash
just data download-external <url> <name>          # download external dataset
just data validate-dataset <path>                 # schema/quality validation
just data profile-dataset <path>                  # statistical profile (HTML)
just data quality-report <path>                   # quality assessment
just data clean-dataset <source> <target>        # automated cleaning
just data split-dataset <source> <target>        # train/val/test splits
```

With `pipelines:nextflow` planted:

```bash
just data nextflow-set-pipeline <name>            # set current pipeline
just data nextflow-get-pipeline                   # show current
just data nextflow-run-experiment <a> <d>         # run pipeline
just data nextflow-list-analyses                  # list runs
just data nextflow-publish-analysis <a> <r> <d>   # publish results
```

## Pipeline commands

```bash
just pipeline                  # dvc repro (whole pipeline)
just pipeline-dag              # visualize pipeline graph
just pipeline-clean            # remove intermediate outputs
```

## Manuscript commands (writeup:manuscript active by default)

```bash
just manuscript-render         # render manuscript to PDF + HTML
just manuscript-watch          # auto-rebuild on save
just manuscript-clean          # remove rendered outputs
```

## Cross-platform recipe naming

For recipes with significant shell logic, paired variants exist:

```bash
just data validate-dataset             # auto: bash on Unix, pwsh on Windows
just data validate-dataset-bash        # explicit bash
just data validate-dataset-pwsh        # explicit PowerShell
```

Use `SHELL_TYPE=powershell just <recipe>` to force shell selection on the
auto variant.

## Test harness commands (in template repo, not generated projects)

```bash
./tests/snapshot-baselines.sh ctt.toml      # capture baselines for all 54 CTT scenarios
./tests/check-baselines.sh ctt-minimal.toml # verify a single scenario reproduces
./tests/check-baselines.sh                  # verify the full suite
./tests/check-baselines.sh --no-rerun       # use existing scenario dirs (debug)
./tests/check-baselines.sh --keep           # don't clean up scenario dirs after check
./tests/check-baselines.sh --scenario NAME  # check just one scenario
```

## Environment variables

| Variable | Used by | Effect |
|---|---|---|
| `SHELL_TYPE` | `tasks/_shell.just` | Force `bash` or `powershell` |
| `CTT_OUTPUT_DIR` | snapshot-baselines.sh | Override `.ctt/` output dir |
| `KEEP_OUTPUTS` | snapshot-baselines.sh | Don't clean up scenario dirs after capture |
| `LIMIT` | snapshot-baselines.sh | Process only first N scenarios |
| `ABC_DEBUG` | (planned, abc-cluster-cli) | Enable debug logging |
