#!/usr/bin/env bash
# tests/flatten-active-root.sh
#
# Phase 3.5: eliminate the `template/analysis/` wrapper by promoting its
# children to top-level under `template/`.
#
# Mapping:
#   template/analysis/notebooks/      → template/notebooks/
#   template/analysis/data/           → template/data/
#   template/analysis/scripts/        → template/scripts/
#   template/analysis/packages/       → template/src/
#   template/analysis/pipelines/      → template/pipelines/
#   template/analysis/tests/          → template/tests/
#   template/analysis/infrastructure/ → template/infra/
#   template/analysis/config/         → template/config/
#   template/analysis/dashboards/     → template/dashboards/
#   template/analysis/databases/      → template/databases/
#   template/analysis/web/            → template/web/
#   template/analysis/pbin/           → template/pbin/
#   template/analysis/analysis.just   → DELETED (consolidated to top-level justfile)
#   template/analysis/*.md            → template/docs/architecture/   (keep but relocate)
#
# Result: `template/analysis/` directory disappears.

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SOURCE="template/analysis"

if [[ ! -d "$SOURCE" ]]; then
    echo "ERROR: $SOURCE not found — already flattened?" >&2
    exit 1
fi

# parallel arrays — source-name | dest-name
SRC_NAMES=(notebooks data scripts packages pipelines tests infrastructure config dashboards databases web pbin)
DST_NAMES=(notebooks data scripts src      pipelines tests infra          config dashboards databases web pbin)

moved=0
for i in "${!SRC_NAMES[@]}"; do
    src="$SOURCE/${SRC_NAMES[$i]}"
    dst="template/${DST_NAMES[$i]}"
    if [[ ! -e "$src" ]]; then
        echo "  · skip ${SRC_NAMES[$i]} (no source)"
        continue
    fi
    if [[ -e "$dst" ]]; then
        echo "  ! conflict: $dst already exists"
        continue
    fi

    if git ls-files --error-unmatch "$src" > /dev/null 2>&1; then
        # Use git mv to preserve history
        git ls-files "$src" | while IFS= read -r f; do
            rel="${f#$src/}"
            mkdir -p "$(dirname "$dst/$rel")"
            git mv "$f" "$dst/$rel"
        done
        find "$src" -type d -empty -delete 2>/dev/null || true
    else
        mv "$src" "$dst"
    fi
    moved=$((moved + 1))
    echo "  ✓ moved ${SRC_NAMES[$i]} → ${DST_NAMES[$i]}"
done

# Move architecture / improvement notes into docs/
mkdir -p template/docs/architecture
for f in "$SOURCE"/*.md; do
    if [[ -f "$f" ]]; then
        base=$(basename "$f")
        if git ls-files --error-unmatch "$f" > /dev/null 2>&1; then
            git mv "$f" "template/docs/architecture/$base"
        else
            mv "$f" "template/docs/architecture/$base"
        fi
        echo "  ✓ relocated $base → template/docs/architecture/"
    fi
done 2>/dev/null

# analysis.just consolidates into top-level tasks/ — for now, move it
if [[ -f "$SOURCE/analysis.just" ]]; then
    mkdir -p template/tasks
    if git ls-files --error-unmatch "$SOURCE/analysis.just" > /dev/null 2>&1; then
        git mv "$SOURCE/analysis.just" template/tasks/legacy-analysis.just
    else
        mv "$SOURCE/analysis.just" template/tasks/legacy-analysis.just
    fi
    echo "  ✓ moved analysis.just → tasks/legacy-analysis.just (Phase 4 will rewrite)"
fi

# Move remaining files (e.g. .gitkeep, .org files)
for f in "$SOURCE"/* "$SOURCE"/.[!.]*; do
    [[ -e "$f" ]] || continue
    base=$(basename "$f")
    if [[ -d "$f" ]]; then
        echo "  ! unexpected leftover dir: $f (not in mapping)"
    else
        if git ls-files --error-unmatch "$f" > /dev/null 2>&1; then
            git mv "$f" "template/$base"
        else
            mv "$f" "template/$base"
        fi
        echo "  ✓ moved leftover $base → template/$base"
    fi
done 2>/dev/null

# Remove now-empty wrapper
find "$SOURCE" -type d -empty -delete 2>/dev/null || true
if [[ -d "$SOURCE" ]]; then
    echo "  ! $SOURCE still has content — manual cleanup needed:"
    find "$SOURCE" -type f | head -10
else
    echo "  ✓ removed $SOURCE wrapper"
fi

echo ""
echo "==> Phase 3.5 flatten done. $moved subdirs promoted to top-level."
echo ""
echo "Next: review with 'git status' and run ./tests/check-baselines.sh ctt-minimal.toml"
