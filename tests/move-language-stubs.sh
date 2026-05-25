#!/usr/bin/env bash
# tests/move-language-stubs.sh
#
# Phase 2 — Batch 1: move all language justfile stubs into seed bank.
#
# Mechanical: for every template/analysis/packages/justfiles/<lang>.just
# (except julia which is already moved, and python/r which stay in active root),
# create template/.garden/components/lang/<lang>/ with file + component.yaml.
# Wraps content in {% raw %} so copier doesn't choke on Just `{{ }}` syntax.
#
# Run from project root:
#     bash tests/move-language-stubs.sh
#     ./tests/check-baselines.sh ctt-minimal.toml      # quick verify
#     ./tests/snapshot-baselines.sh ctt.toml           # full re-snap (~25 min)

set -eo pipefail   # not -u; bash 3.2 + readonly globals are fragile

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SOURCE_DIR="template/analysis/packages/justfiles"
TARGET_BASE="template/.garden/components/lang"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: $SOURCE_DIR not found" >&2
    exit 1
fi

# parallel arrays — bash 3.2 has no associative arrays
LANGS=(c cli clojure csharp distribution fsharp go groovy java ocaml powershell rust validation zig)
DESCS=(
    "C/C++ package development (build, test)"
    "CLI tool scaffolding"
    "Clojure / ClojureScript package development"
    "C# (.NET) package development"
    "Multi-language package distribution"
    "F# (.NET) package development"
    "Go module development (build, test)"
    "Groovy (with Gradle) package development"
    "Java (with Maven/Gradle) package development"
    "OCaml package development (with dune)"
    "PowerShell module development"
    "Rust crate development (cargo)"
    "Cross-language validation utilities"
    "Zig package development"
)

moved=0
for i in "${!LANGS[@]}"; do
    lang="${LANGS[$i]}"
    desc="${DESCS[$i]}"
    source_file="$SOURCE_DIR/$lang.just"
    if [[ ! -f "$source_file" ]]; then
        echo "  · skip $lang (no source at $source_file)"
        continue
    fi
    target_dir="$TARGET_BASE/$lang/files/tasks"
    target_file="$target_dir/$lang.just"
    component_yaml="$TARGET_BASE/$lang/component.yaml"

    mkdir -p "$target_dir"

    # Move (git mv if tracked; mv otherwise)
    if git ls-files --error-unmatch "$source_file" > /dev/null 2>&1; then
        git mv "$source_file" "$target_file"
    else
        mv "$source_file" "$target_file"
    fi

    # Wrap with {% raw %} blocks so copier passes Just syntax through
    {
        echo "{% raw %}"
        cat "$target_file"
        echo "{% endraw %}"
    } > "$target_file.tmp"
    mv "$target_file.tmp" "$target_file"

    # Write component.yaml
    cat > "$component_yaml" <<EOF
id: "lang:$lang"
description: "$desc"
status: "experimental"
version: "0.1.0"
files:
  - tasks/$lang.just
adds_imports:
  - tasks/$lang.just
post_grow_hint: |
  $lang recipes added under tasks/$lang.just.
  Note: experimental — recipe bodies are stubs.
EOF

    moved=$((moved + 1))
    echo "  ✓ moved $lang → $TARGET_BASE/$lang/"
done

echo ""
echo "==> Moved $moved language stubs into seed bank."
echo ""
echo "Next steps:"
echo "  1. ./tests/check-baselines.sh ctt-minimal.toml    # verify diff is sensible"
echo "  2. ./tests/snapshot-baselines.sh ctt.toml         # lock in new state"
echo "  3. git add template/.garden/components/lang/ template/analysis/packages/justfiles/"
echo "  4. git commit -m 'phase 2 batch 1: language stubs into seed bank'"
