#!/usr/bin/env bash
# tests/move-data-stages.sh
#
# Phase 2 — Batch 2: move dormant data stages into the seed bank.
#
# Stays in active root (the everyday-use stages):
#   00_scratch, 01_raw, 02_intermediate, 03_primary, 08_reporting
#
# Moves to seed bank (specialty / advanced stages):
#   04_feature           → data:features
#   05_model_input       → data:model-input
#   06_models            → data:models
#   07_model_output      → data:model-output
#   09_logs              → data:logs
#   10_backups           → data:backups
#   11_benchmarks        → data:benchmarks
#   12_publications      → data:publications
#   13_external_validation → data:external-validation
#   14_collaboration     → data:collaboration
#   15_pipelines         → data:pipelines-stage   (note: NOT same as the pipelines/ tools)
#
# Run from project root:
#     bash tests/move-data-stages.sh
#     ./tests/check-baselines.sh ctt-minimal.toml
#     ./tests/snapshot-baselines.sh ctt.toml

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SOURCE_BASE="template/analysis/data"
TARGET_BASE="template/.garden/components/data"

# parallel arrays — name | source-subdir | description
NAMES=(features model-input models model-output logs backups benchmarks publications external-validation collaboration pipelines-stage)
SOURCES=(04_feature 05_model_input 06_models 07_model_output 09_logs 10_backups 11_benchmarks 12_publications 13_external_validation 14_collaboration 15_pipelines)
DESCS=(
    "Feature engineering stage (transforms, scaling, encoding, dimensionality reduction)"
    "Model input — train/validation/test/production splits"
    "Model artifacts — baseline / candidate / ensemble / optimized / production"
    "Model output — predictions / probabilities / evaluation / explanations"
    "Pipeline / training / metadata / lineage / experiment logs"
    "Versioned and timestamped data backups"
    "Reference datasets and benchmark comparisons"
    "Publication-ready figures and tables"
    "External validation datasets"
    "Collaboration / shared data area"
    "Pipeline-internal data stage (work directories, intermediate pipeline outputs)"
)

# `data:features` already exists as a sample component from Phase 1; it has
# different files. We need to merge: this script writes a fuller component.yaml
# and adds the real data stage tree, overwriting the placeholder.

moved=0
for i in "${!NAMES[@]}"; do
    name="${NAMES[$i]}"
    src="${SOURCES[$i]}"
    desc="${DESCS[$i]}"
    source_dir="$SOURCE_BASE/$src"

    if [[ ! -d "$source_dir" ]]; then
        echo "  · skip $name (no source at $source_dir)"
        continue
    fi

    target_dir="$TARGET_BASE/$name/files/data/$name"
    component_yaml="$TARGET_BASE/$name/component.yaml"

    # Remove the previous placeholder component (if any) entirely
    if [[ -d "$TARGET_BASE/$name" ]]; then
        rm -rf "$TARGET_BASE/$name"
    fi

    mkdir -p "$target_dir"

    # Move every file under the source data stage into the seed bank.
    # We rename `04_feature` → `features` etc. in the destination.
    if git ls-files --error-unmatch "$source_dir" > /dev/null 2>&1; then
        # Use git mv on each tracked file individually to preserve history
        git ls-files "$source_dir" | while IFS= read -r f; do
            rel="${f#$source_dir/}"
            mkdir -p "$(dirname "$target_dir/$rel")"
            git mv "$f" "$target_dir/$rel"
        done
        # Remove any leftover empty dirs
        find "$source_dir" -type d -empty -delete 2>/dev/null || true
    else
        # Plain mv (handles untracked files)
        cp -R "$source_dir/" "$target_dir/"
        rm -rf "$source_dir"
    fi

    # File list for component.yaml
    file_lines=""
    while IFS= read -r f; do
        rel="${f#$TARGET_BASE/$name/files/}"
        file_lines+="  - $rel"$'\n'
    done < <(find "$TARGET_BASE/$name/files" -type f | sort)

    cat > "$component_yaml" <<EOF
id: "data:$name"
description: "$desc"
status: "experimental"
version: "0.1.0"
files:
${file_lines}post_grow_hint: |
  Created data/$name/ stage directory.
EOF

    moved=$((moved + 1))
    echo "  ✓ moved $src → $TARGET_BASE/$name/"
done

echo ""
echo "==> Moved $moved data stages into seed bank."
echo ""
echo "Active data stages remaining: 00_scratch, 01_raw, 02_intermediate, 03_primary, 08_reporting"
echo ""
echo "Next steps:"
echo "  ./tests/check-baselines.sh ctt-minimal.toml      # verify diff"
echo "  ./tests/snapshot-baselines.sh ctt.toml           # lock in"
