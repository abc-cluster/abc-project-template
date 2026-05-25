#!/usr/bin/env bash
# tests/move-infra-subsystems.sh
#
# Phase 2 — Batch 4: move dormant infrastructure subsystems into the seed bank.
#
# Each numbered subsystem becomes its own component. The infrastructure/
# directory itself is left in place for now (Phase 3 will rename to infra/
# at top level).

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SOURCE_BASE="template/analysis/infrastructure"
TARGET_BASE="template/.garden/components/infra"

# parallel arrays — name | source-relative-path | description
NAMES=(lxd multipass juju waypoint cloud-scripts dagger packer terraform env-setup)
SOURCES=(
    01_virtualization/012_lxd
    01_virtualization/013_multipass
    02_orchestration/023_juju
    02_orchestration/024_waypoint
    03_automation/031_automations
    03_automation/032_dagger
    03_automation/033_packer
    03_automation/035_terraform
    04_environments
)
DESCS=(
    "LXD container-based development environments"
    "Multipass-based VM development environments (cloud-init)"
    "Juju bundles for Nomad-Docker, Jupyter+MinIO on MicroK8s"
    "Waypoint deployment configurations"
    "Cloud automation scripts (bash + powershell + python)"
    "Dagger CI/CD pipeline definitions"
    "Packer image build configurations"
    "Terraform configurations (microk8s, multipass, OCI VM, microcloud)"
    "Java environment setup scripts (cross-platform)"
)

moved=0
for i in "${!NAMES[@]}"; do
    name="${NAMES[$i]}"
    src_rel="${SOURCES[$i]}"
    desc="${DESCS[$i]}"
    src_dir="$SOURCE_BASE/$src_rel"

    if [[ ! -d "$src_dir" ]]; then
        echo "  · skip $name (no source at $src_dir)"
        continue
    fi

    target_dir="$TARGET_BASE/$name/files/infra/$name"
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
id: "infra:$name"
description: "$desc"
status: "experimental"
version: "0.1.0"
files:
${file_lines}post_grow_hint: |
  Created infra/$name/ with subsystem-specific scaffolding.
  Inspect the generated files; some require external tools (e.g. terraform, packer).
EOF

    moved=$((moved + 1))
    echo "  ✓ moved $src_rel → $TARGET_BASE/$name/"
done

echo ""
echo "==> Moved $moved infrastructure subsystems into seed bank."
