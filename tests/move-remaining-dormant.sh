#!/usr/bin/env bash
# tests/move-remaining-dormant.sh
#
# Phase 3.5+: move database scaffolds, web frameworks, dashboards, and
# remaining infra/ leftovers into the seed bank. These were promoted to
# top-level by the flatten but should be dormant.

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# helper: move a top-level template/<src> dir into seed bank component <category>:<name>
# files land back under <land-path>
move_to_seed() {
    local src_dir="$1"
    local category="$2"
    local name="$3"
    local land_path="$4"
    local desc="$5"

    if [[ ! -e "$src_dir" ]]; then
        echo "  · skip $category:$name (no source $src_dir)"
        return 0
    fi

    local target_dir="template/.garden/components/$category/$name/files/$land_path"
    local component_yaml="template/.garden/components/$category/$name/component.yaml"

    [[ -d "template/.garden/components/$category/$name" ]] && rm -rf "template/.garden/components/$category/$name"
    mkdir -p "$target_dir"

    if [[ -d "$src_dir" ]]; then
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
    else
        # single file
        if git ls-files --error-unmatch "$src_dir" > /dev/null 2>&1; then
            git mv "$src_dir" "$target_dir/$(basename "$src_dir")"
        else
            mv "$src_dir" "$target_dir/$(basename "$src_dir")"
        fi
    fi

    file_lines=""
    while IFS= read -r f; do
        rel="${f#template/.garden/components/$category/$name/files/}"
        file_lines+="  - $rel"$'\n'
    done < <(find "template/.garden/components/$category/$name/files" -type f | sort)

    cat > "$component_yaml" <<EOF
id: "$category:$name"
description: "$desc"
status: "experimental"
version: "0.1.0"
files:
${file_lines}post_grow_hint: |
  Restored $land_path/ scaffolding.
EOF
    echo "  ✓ moved $src_dir → $category:$name"
}

# === databases/ — 8 subdirs ===
for db in postgresql sqlite duckdb dolt xtdb datalevin immudb irmin; do
    move_to_seed "template/databases/$db" "db" "$db" "databases/$db" "$db database scaffolding"
done
[[ -d "template/databases" ]] && find template/databases -type d -empty -delete 2>/dev/null

# === web/ — 3 frameworks ===
move_to_seed "template/web/pode"   "web" "pode"   "web/pode"   "Pode (PowerShell) web framework"
move_to_seed "template/web/python" "web" "python" "web/python" "Python web framework templates (Flask/FastAPI)"
move_to_seed "template/web/r"      "web" "r"      "web/r"      "R web framework templates (Shiny/Plumber)"
[[ -d "template/web" ]] && find template/web -type d -empty -delete 2>/dev/null

# === dashboards/ — Quarto dashboards ===
move_to_seed "template/dashboards" "analysis" "dashboards" "dashboards" "Quarto dashboards (Observable, Shiny)"

# === infra/ leftover orchestrator files ===
# 01_virtualization/, 02_orchestration/, 03_automation/ subdir READMEs and orchestrator justfiles
move_to_seed "template/infra/_templates"        "infra" "_orchestrator-templates" "infra/_templates"        "Infrastructure justfile orchestrator templates"
move_to_seed "template/infra/01_virtualization" "infra" "virtualization-readme"   "infra/01_virtualization" "Virtualization category README"
move_to_seed "template/infra/02_orchestration"  "infra" "orchestration-readme"    "infra/02_orchestration"  "Orchestration category README"
move_to_seed "template/infra/03_automation"     "infra" "automation-readme"       "infra/03_automation"     "Automation category README"

# Top-level setup_java duplicates (already in infra:env-setup component)
[[ -f "template/infra/setup_java.sh" ]] && rm template/infra/setup_java.sh && echo "  ✓ removed duplicate setup_java.sh"
[[ -f "template/infra/setup_java.ps1" ]] && rm template/infra/setup_java.ps1 && echo "  ✓ removed duplicate setup_java.ps1"

# Move the orchestrator justfiles to seed bank
move_to_seed "template/infra/infrastructure.just.jinja" "infra" "_just-orchestrator" "infra/infrastructure.just.jinja" "Top-level infra justfile orchestrator (jinja)"
move_to_seed "template/infra/environments.just"         "infra" "_envs-orchestrator" "infra/environments.just"         "Environments justfile orchestrator"

# Remove .gitkeep at top level (no longer needed)
[[ -f "template/infra/.gitkeep" ]] && rm template/infra/.gitkeep && echo "  ✓ removed template/infra/.gitkeep"

# Drop now-empty infra dir
find template/infra -type d -empty -delete 2>/dev/null && echo "  ✓ template/infra removed (now empty)"

echo ""
echo "==> Done. Run check-baselines + snapshot-baselines to lock in."
