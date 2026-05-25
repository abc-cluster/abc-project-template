#!/usr/bin/env bash
# tests/move-writeup-formats.sh
#
# Phase 2 — Batch 3: move dormant writeup formats into the seed bank.
#
# Stays in active root: manuscript/ (most common case)
# Moves to seed bank:   abstracts/, blog/, book/, grants/, poster/,
#                       presentation/, report/

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SOURCE_BASE="template/writeup"
TARGET_BASE="template/.garden/components/writeup"

NAMES=(abstracts blog book grants poster presentation report)
DESCS=(
    "Conference and journal abstract templates"
    "Quarto blog with research log"
    "Book-length manuscript scaffolding"
    "NSF / NIH / DOE / ERC grant proposal templates"
    "Academic and professional poster templates"
    "Beamer / Reveal.js / Quarto presentation templates (academic, corporate, workshop)"
    "Technical and executive report templates"
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

    target_dir="$TARGET_BASE/$name/files/writeup/$name"
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
id: "writeup:$name"
description: "$desc"
status: "experimental"
version: "0.1.0"
files:
${file_lines}post_grow_hint: |
  Created writeup/$name/ with format-specific scaffolding.
EOF

    moved=$((moved + 1))
    echo "  ✓ moved $name → $TARGET_BASE/$name/"
done

echo ""
echo "==> Moved $moved writeup formats into seed bank."
echo "Active writeup remaining: manuscript/"
