#!/usr/bin/env bash
# tests/migrate-root-tooling.sh
#
# Address Phase 3.5+ losses by migrating root-level language tooling files
# and the misc/ directory into Garden components. Restores the conditional-
# emission behavior the original template had.
#
# Mapping:
#   bb.edn, clay.edn, deps.edn, dev.cljs.edn, nbb.edn  → lang:clojure (extend)
#   dune-project                                       → lang:ocaml (extend)
#   jreleaser.yml                                      → lang:java (extend)
#   package.json                                       → lang:javascript (NEW)
#   template/misc/{meetings-*,meetings.template.org}   → tooling:org-meetings (NEW)
#   template/misc/dirkeeper.py, dirpruner.py           → quality:dir-utils (NEW)
#
# Cleanup (deletes):
#   template/template.iml                              (IntelliJ; obsolete)
#   template/{% if _final_include_*%} files            (Phase 3.5 Jinja orphans)
#   template/update-justfiles.{sh,ps1}                 (legacy refactor scripts)

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# ─── helpers ─────────────────────────────────────────────────────────────────

# extend_component <component-id> <src-file> [<dest-relative-name>]
# Moves src-file into the component's files/ tree at dest-relative-name (default: basename).
extend_component() {
    local comp_id="$1"
    local src="$2"
    local dest_name="${3:-$(basename "$src")}"
    local cat="${comp_id%%:*}"
    local name="${comp_id##*:}"
    local comp_dir="template/.garden/components/$cat/$name"

    if [[ ! -f "$src" ]]; then
        echo "  · skip $src (not found)"
        return 0
    fi
    if [[ ! -d "$comp_dir" ]]; then
        echo "  ! component $comp_id doesn't exist; create it first"
        return 1
    fi

    local files_dir="$comp_dir/files"
    mkdir -p "$files_dir"
    local target="$files_dir/$dest_name"

    if git ls-files --error-unmatch "$src" > /dev/null 2>&1; then
        git mv "$src" "$target"
    else
        mv "$src" "$target"
    fi
    echo "  ✓ extended $comp_id ← $(basename "$src")"
}

# create_component <category> <name> <description>
# Creates an empty component skeleton ready for extend_component to add files.
create_component() {
    local cat="$1" name="$2" desc="$3"
    local comp_dir="template/.garden/components/$cat/$name"
    if [[ -d "$comp_dir" ]]; then
        return 0
    fi
    mkdir -p "$comp_dir/files"
    cat > "$comp_dir/component.yaml" <<EOF
id: "$cat:$name"
description: "$desc"
status: "experimental"
version: "0.1.0"
files: []
EOF
    echo "  ✓ created $cat:$name"
}

# rebuild_files_list <component-dir>
# Regenerates the `files:` list in component.yaml from the actual contents of files/
rebuild_files_list() {
    local comp_dir="$1"
    local yaml="$comp_dir/component.yaml"
    [[ -f "$yaml" ]] || return 0

    # Build the new files: block
    local file_lines=""
    while IFS= read -r f; do
        rel="${f#$comp_dir/files/}"
        file_lines+="  - $rel"$'\n'
    done < <(find "$comp_dir/files" -type f 2>/dev/null | sort)

    # Splice into yaml: replace any existing `files:` and following indented list.
    python3 - "$yaml" "$file_lines" <<'PY'
import re, sys
path, files_block = sys.argv[1], sys.argv[2]
text = open(path).read()
# Strip existing files: block (`files:` line plus indented list items)
new = re.sub(r'^files:.*?(?=^[a-zA-Z_]|\Z)', '', text, flags=re.MULTILINE | re.DOTALL)
# Insert new files: block before `adds_imports:` or `post_grow_hint:` or end
files_section = "files:\n" + (files_block or "  []\n")
m = re.search(r'^(adds_imports:|post_grow_hint:)', new, flags=re.MULTILINE)
if m:
    new = new[:m.start()] + files_section + new[m.start():]
else:
    new = new.rstrip() + "\n" + files_section
open(path, 'w').write(new)
PY
}

# ─── Migrate language tooling ────────────────────────────────────────────────

echo "==> Language tooling → lang:* components"

# Clojure ecosystem (bb=Babashka, clay=clay, deps=deps.edn, nbb=nbb)
extend_component "lang:clojure" "template/bb.edn"
extend_component "lang:clojure" "template/clay.edn"
extend_component "lang:clojure" "template/deps.edn"
extend_component "lang:clojure" "template/dev.cljs.edn"
extend_component "lang:clojure" "template/nbb.edn"

# OCaml
extend_component "lang:ocaml" "template/dune-project"

# Java release tooling (jreleaser)
extend_component "lang:java" "template/jreleaser.yml"

# JavaScript / Node — create new component
create_component "lang" "javascript" "JavaScript / Node.js package.json scaffolding"
extend_component "lang:javascript" "template/package.json"

# ─── Migrate misc/ ──────────────────────────────────────────────────────────

echo ""
echo "==> misc/ → tooling:org-meetings + quality:dir-utils"

# Org-mode meeting templates → new tooling:org-meetings component
create_component "tooling" "org-meetings" "Org-mode meeting templates and per-project meeting log"
extend_component "tooling:org-meetings" "template/misc/meetings.template.org"
extend_component "tooling:org-meetings" "template/misc/meetings-{{short_name}}.org"

# Directory hygiene utilities → new quality:dir-utils component
create_component "quality" "dir-utils" "Directory hygiene utilities (dirkeeper, dirpruner)"
extend_component "quality:dir-utils" "template/misc/dirkeeper.py"
extend_component "quality:dir-utils" "template/misc/dirpruner.py"

# Drop now-empty misc/
find template/misc -type d -empty -delete 2>/dev/null && echo "  ✓ removed template/misc/ (now empty)"

# ─── Cleanup orphans ─────────────────────────────────────────────────────────

echo ""
echo "==> Removing orphans"

# Phase 3.5 Jinja-in-filename leftovers (the cleanup logic was replaced by Garden replant)
for orphan in \
    'template/{% if _final_include_analysis %}analysis{% endif %}' \
    'template/{% if _final_include_misc %}misc{% endif %}' \
    'template/{% if _final_include_writeup %}writeup{% endif %}'; do
    if [[ -e "$orphan" ]]; then
        if git ls-files --error-unmatch "$orphan" > /dev/null 2>&1; then
            git rm -rf "$orphan"
        else
            rm -rf "$orphan"
        fi
        echo "  ✓ removed $orphan"
    fi
done

# IntelliJ project file (committed by accident from the template author's IDE)
if [[ -f "template/template.iml" ]]; then
    if git ls-files --error-unmatch template/template.iml > /dev/null 2>&1; then
        git rm template/template.iml
    else
        rm template/template.iml
    fi
    echo "  ✓ removed template.iml"
fi

# Legacy refactor scripts (the Garden model makes these obsolete)
for f in template/update-justfiles.sh template/update-justfiles.ps1; do
    if [[ -f "$f" ]]; then
        if git ls-files --error-unmatch "$f" > /dev/null 2>&1; then
            git rm "$f"
        else
            rm "$f"
        fi
        echo "  ✓ removed $(basename "$f") (legacy)"
    fi
done

# ─── Rebuild files: lists in extended components ────────────────────────────

echo ""
echo "==> Rebuilding files: lists in component.yaml files"
for comp in template/.garden/components/lang/clojure \
            template/.garden/components/lang/ocaml \
            template/.garden/components/lang/java \
            template/.garden/components/lang/javascript \
            template/.garden/components/tooling/org-meetings \
            template/.garden/components/quality/dir-utils; do
    if [[ -d "$comp" ]]; then
        rebuild_files_list "$comp"
        echo "  ✓ $(basename "$(dirname "$comp")")/$(basename "$comp")"
    fi
done

echo ""
echo "==> Done. Verify with:"
echo "    ./tests/check-baselines.sh ctt-minimal.toml"
echo "    git status"
