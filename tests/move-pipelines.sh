#!/usr/bin/env bash
# tests/move-pipelines.sh
#
# Phase 2 — Batch 5: move pipeline systems into the seed bank.
# nextflow/ → pipelines:nextflow
# snakemake/ → pipelines:snakemake
# Top-level pipelines.just stays in active root.

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SOURCE_BASE="template/analysis/pipelines"
TARGET_BASE="template/.garden/components/pipelines"

NAMES=(nextflow snakemake)
DESCS=(
    "Nextflow pipeline scaffolding (with Tower integration)"
    "Snakemake pipeline scaffolding (with cluster profiles)"
)

moved=0
for i in "${!NAMES[@]}"; do
    name="${NAMES[$i]}"
    desc="${DESCS[$i]}"
    src_dir="$SOURCE_BASE/$name"

    if [[ ! -d "$src_dir" ]]; then
        echo "  · skip $name (no source)"
        continue
    fi

    target_dir="$TARGET_BASE/$name/files/pipelines/$name"
    component_yaml="$TARGET_BASE/$name/component.yaml"

    [[ -d "$TARGET_BASE/$name" ]] && rm -rf "$TARGET_BASE/$name"
    mkdir -p "$target_dir"

    if git ls-files --error-unmatch "$src_dir" > /dev/null 2>&1; then
        git ls-files "$src_dir" | while IFS= read -r f; do
            rel="${f#$src_dir/}"
            mkdir -p "$(dirname "$target_dir/$rel")"
            git mv "$f" "$target_dir/$rel"
        done
        find "$src_dir" -type d -empty -delete 2>/dev/null || true
    else
        cp -R "$src_dir/" "$target_dir/"
        rm -rf "$src_dir"
    fi

    file_lines=""
    while IFS= read -r f; do
        rel="${f#$TARGET_BASE/$name/files/}"
        file_lines+="  - $rel"$'\n'
    done < <(find "$TARGET_BASE/$name/files" -type f | sort)

    cat > "$component_yaml" <<EOF
id: "pipelines:$name"
description: "$desc"
status: "experimental"
version: "0.1.0"
files:
${file_lines}post_grow_hint: |
  Created pipelines/$name/ scaffolding. Requires $name installed on PATH.
EOF

    moved=$((moved + 1))
    echo "  ✓ moved $name → $TARGET_BASE/$name/"
done

echo ""
echo "==> Moved $moved pipeline systems into seed bank."
