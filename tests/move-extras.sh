#!/usr/bin/env bash
# tests/move-extras.sh
#
# Phase 2 — Batch 6: move shell/editor/build/VCS extras into the seed bank.
#
# Components created:
#   shell:fish        — .fish/ shell aliases, completions, starship prompt
#   editor:emacs      — .emacs.proj/, .dir-locals.el (if present)
#   build:bazel       — .bazelrc, .bazelversion, MODULE.bazel, WORKSPACE
#   tooling:mise      — .mise/tasks/
#   vcs:jujutsu       — jj.just (when present in template root after copier)

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SOURCE_BASE="template"
TARGET_BASE="template/.garden/components"

# Move helper: copies/moves a SINGLE file or directory into a component.
move_into() {
    local component_path="$1"      # e.g. shell/fish
    local desc="$2"
    local src_relative="$3"        # path relative to template/, e.g. .fish or .bazelrc

    local src="$SOURCE_BASE/$src_relative"
    if [[ ! -e "$src" ]]; then
        echo "  · skip $component_path/$src_relative (no source)"
        return 0
    fi

    local comp_dir="$TARGET_BASE/$component_path"
    local files_dir="$comp_dir/files/$src_relative"
    local component_yaml="$comp_dir/component.yaml"

    mkdir -p "$(dirname "$files_dir")"

    if [[ -d "$src" ]]; then
        if git ls-files --error-unmatch "$src" > /dev/null 2>&1; then
            git ls-files "$src" | while IFS= read -r f; do
                rel="${f#$src/}"
                mkdir -p "$(dirname "$files_dir/$rel")"
                git mv "$f" "$files_dir/$rel"
            done
            find "$src" -type d -empty -delete 2>/dev/null || true
        else
            mkdir -p "$files_dir"
            cp -R "$src/" "$files_dir/"
            rm -rf "$src"
        fi
    else
        # File
        mkdir -p "$(dirname "$files_dir")"
        if git ls-files --error-unmatch "$src" > /dev/null 2>&1; then
            git mv "$src" "$files_dir"
        else
            mv "$src" "$files_dir"
        fi
    fi

    # Generate or update component.yaml — accumulating mode
    local file_lines=""
    if [[ -d "$comp_dir/files" ]]; then
        while IFS= read -r f; do
            rel="${f#$comp_dir/files/}"
            file_lines+="  - $rel"$'\n'
        done < <(find "$comp_dir/files" -type f | sort)
    fi

    local component_id="${component_path/\//:}"

    cat > "$component_yaml" <<EOF
id: "$component_id"
description: "$desc"
status: "experimental"
version: "0.1.0"
files:
${file_lines}post_grow_hint: |
  Restored $src_relative from seed bank.
EOF

    echo "  ✓ moved $src_relative → $comp_dir/"
}

move_into shell/fish    "Fish shell aliases, completions, config, and starship prompt"  ".fish"
move_into editor/emacs  "Emacs project setup (.emacs.proj/, .dir-locals.el)"            ".emacs.proj"
move_into editor/emacs  "Emacs project setup (.emacs.proj/, .dir-locals.el)"            ".dir-locals.el"
move_into build/bazel   "Bazel build system files (MODULE.bazel, WORKSPACE, etc.)"      ".bazelrc"
move_into build/bazel   "Bazel build system files"                                       ".bazelversion"
move_into build/bazel   "Bazel build system files"                                       "MODULE.bazel"
move_into build/bazel   "Bazel build system files"                                       "WORKSPACE"
move_into tooling/mise  "mise task runner configuration (.mise/tasks/)"                 ".mise"
move_into vcs/jujutsu   "Jujutsu version-control extra recipes (jj.just)"               "jj.just.jinja"

echo ""
echo "==> Batch 6 done."
