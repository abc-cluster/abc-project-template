#!/usr/bin/env python3
"""Garden — the dormant-component manager.

Subcommands:
    garden                     status (planted vs dormant)
    garden list                show all components, grouped by category
    garden list dormant        only dormant
    garden list planted        only planted
    garden show <id>           details for one component
    grow <id>                  plant a component
    prune <id>                 archive a planted component
    grow preset:<name>         plant a curated bundle
    garden replant             ensure manifest matches active state
    garden diff <id>           show local changes vs seed
    garden update              pull new component versions from upstream

Component IDs use `<category>:<name>` form (e.g. `data:features`,
`lang:julia`).

The seed bank lives at `.garden/components/<category>/<name>/`. Each component
has a `component.yaml` and a `files/` subtree (what gets copied to the active
tree). Optional `post-grow.sh` / `post-prune.sh` scripts run lifecycle hooks.

Manifest lives at `.garden/manifest.yaml` and tracks what's planted.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

# ──────────────────────────────────────────────────────────────────────────────
# YAML — we avoid PyYAML so the script runs on any python3.
# Component manifests are simple key-value + lists; we hand-parse a strict
# subset.
# ──────────────────────────────────────────────────────────────────────────────


def _strip_yaml_inline_comment(s: str) -> str:
    """Remove ` # ...` inline comment, but preserve `#` inside quoted strings."""
    in_quote = None
    for i, ch in enumerate(s):
        if in_quote:
            if ch == in_quote:
                in_quote = None
        elif ch in ('"', "'"):
            in_quote = ch
        elif ch == "#" and (i == 0 or s[i - 1] in (" ", "\t")):
            return s[:i].rstrip()
    return s.rstrip()


def _unquote(s: str) -> str:
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in ('"', "'"):
        return s[1:-1]
    return s


def _indent_of(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def parse_simple_yaml(text: str) -> dict:
    """Minimal YAML subset that handles our manifest needs:
    - top-level scalars, lists, nested dicts
    - block scalars (`|`)
    - inline empty list/dict (`[]`, `{}`)
    - lists of scalars OR lists of dicts (each `- key: val` opens a dict)
    - inline comments
    Sufficient for component.yaml and manifest.yaml. NOT a full YAML parser.
    """
    raw_lines = [_strip_yaml_inline_comment(ln) for ln in text.splitlines()]
    # Strip blank lines from the END only; keep mid-file blanks for block-scalar detection
    while raw_lines and not raw_lines[-1].strip():
        raw_lines.pop()

    def parse_block(start: int, base_indent: int) -> tuple[dict | list, int]:
        """Parse a block starting at `start` whose entries are indented at
        `base_indent`. Returns (parsed value, index of first line not in block)."""
        # Detect whether this block is a list (starts with '-') or a mapping
        i = start
        # Skip blank lines
        while i < len(raw_lines) and not raw_lines[i].strip():
            i += 1
        if i >= len(raw_lines):
            return {}, i
        first_indent = _indent_of(raw_lines[i])
        if first_indent < base_indent:
            return {}, i
        if raw_lines[i].lstrip().startswith("- "):
            return parse_list_block(start, base_indent)
        return parse_dict_block(start, base_indent)

    def parse_dict_block(start: int, base_indent: int) -> tuple[dict, int]:
        out: dict = {}
        i = start
        while i < len(raw_lines):
            raw = raw_lines[i]
            if not raw.strip():
                i += 1
                continue
            if raw.lstrip().startswith("#"):
                i += 1
                continue
            ind = _indent_of(raw)
            if ind < base_indent:
                break
            if ind > base_indent:
                # shouldn't happen if input is well-formed; skip
                i += 1
                continue
            stripped = raw.strip()
            m = re.match(r'^"?([^":]+)"?\s*:\s*(.*)$', stripped)
            if not m:
                i += 1
                continue
            key = m.group(1).strip().strip('"').strip("'")
            rest = m.group(2).strip()
            if rest == "":
                # Look ahead: child block (list or dict) at deeper indent, or empty
                j = i + 1
                while j < len(raw_lines) and not raw_lines[j].strip():
                    j += 1
                if j < len(raw_lines) and _indent_of(raw_lines[j]) > base_indent:
                    child, end = parse_block(i + 1, _indent_of(raw_lines[j]))
                    out[key] = child
                    i = end
                    continue
                out[key] = ""
                i += 1
                continue
            if rest == "[]":
                out[key] = []
                i += 1
                continue
            if rest == "{}":
                out[key] = {}
                i += 1
                continue
            if rest == "|":
                # Block scalar
                lines: list[str] = []
                j = i + 1
                block_indent: int | None = None
                while j < len(raw_lines):
                    if not raw_lines[j].strip():
                        lines.append("")
                        j += 1
                        continue
                    cur_ind = _indent_of(raw_lines[j])
                    if cur_ind <= base_indent:
                        break
                    if block_indent is None:
                        block_indent = cur_ind
                    lines.append(raw_lines[j][block_indent:])
                    j += 1
                out[key] = "\n".join(lines).rstrip()
                i = j
                continue
            # Scalar value on same line
            out[key] = _unquote(rest)
            i += 1
        return out, i

    def parse_list_block(start: int, base_indent: int) -> tuple[list, int]:
        out: list = []
        i = start
        while i < len(raw_lines):
            raw = raw_lines[i]
            if not raw.strip():
                i += 1
                continue
            if raw.lstrip().startswith("#"):
                i += 1
                continue
            ind = _indent_of(raw)
            if ind < base_indent:
                break
            if ind > base_indent:
                i += 1
                continue
            stripped = raw.strip()
            if not stripped.startswith("- "):
                break
            after_dash = stripped[2:].strip()
            # Is this `- key: value`? Then this list element is a dict.
            # Require a space after the colon (or end-of-line) to distinguish
            # from scalars like `- core:base` which are just strings with a colon.
            m = re.match(r'^"?([A-Za-z_][\w-]*)"?:(?:\s+(.*)|$)', after_dash)
            if m:
                # Build a dict from this line + subsequent indented lines
                # The dict's keys are at base_indent + 2 (after "- ").
                nested = {}
                key1 = m.group(1).strip()
                rest1 = (m.group(2) or "").strip()
                if rest1 == "":
                    # nested block
                    j = i + 1
                    while j < len(raw_lines) and not raw_lines[j].strip():
                        j += 1
                    if j < len(raw_lines) and _indent_of(raw_lines[j]) > base_indent + 2:
                        child, end = parse_block(i + 1, _indent_of(raw_lines[j]))
                        nested[key1] = child
                        i = end
                    else:
                        nested[key1] = ""
                        i += 1
                else:
                    nested[key1] = _unquote(rest1)
                    i += 1
                # Continue the dict by reading lines indented at base_indent + 2
                while i < len(raw_lines):
                    r2 = raw_lines[i]
                    if not r2.strip():
                        i += 1
                        continue
                    if _indent_of(r2) <= base_indent:
                        break
                    if r2.lstrip().startswith("- "):
                        break  # next list item
                    if _indent_of(r2) != base_indent + 2:
                        i += 1
                        continue
                    s2 = r2.strip()
                    m2 = re.match(r'^"?([A-Za-z_][\w-]*)"?\s*:\s*(.*)$', s2)
                    if not m2:
                        i += 1
                        continue
                    k2 = m2.group(1).strip()
                    r2v = m2.group(2).strip()
                    if r2v == "":
                        i += 1
                    else:
                        nested[k2] = _unquote(r2v)
                        i += 1
                out.append(nested)
            else:
                # Plain scalar list item
                out.append(_unquote(after_dash))
                i += 1
        return out, i

    result, _ = parse_dict_block(0, 0)
    return result


def dump_simple_yaml(data: dict, indent: int = 0) -> str:
    """Serialize the small subset we use. Sufficient for the manifest."""
    out: list[str] = []
    pad = "  " * indent
    for key, val in data.items():
        if isinstance(val, list):
            if not val:
                out.append(f"{pad}{key}: []")
            else:
                out.append(f"{pad}{key}:")
                for item in val:
                    if isinstance(item, dict):
                        first = True
                        for k2, v2 in item.items():
                            prefix = f"{pad}  - " if first else f"{pad}    "
                            out.append(f"{prefix}{k2}: {scalar_yaml(v2)}")
                            first = False
                    else:
                        out.append(f"{pad}  - {scalar_yaml(item)}")
        elif isinstance(val, dict):
            if not val:
                out.append(f"{pad}{key}: {{}}")
            else:
                out.append(f"{pad}{key}:")
                out.append(dump_simple_yaml(val, indent + 1))
        else:
            out.append(f"{pad}{key}: {scalar_yaml(val)}")
    return "\n".join(out)


def scalar_yaml(v) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    s = str(v)
    if "\n" in s or any(c in s for c in ":#") or s.startswith("- "):
        return f'"{s}"'
    return f'"{s}"'


# ──────────────────────────────────────────────────────────────────────────────
# Paths
# ──────────────────────────────────────────────────────────────────────────────


PROJECT_ROOT = Path.cwd()
GARDEN_DIR = PROJECT_ROOT / ".garden"
COMPONENTS_DIR = GARDEN_DIR / "components"
PRESETS_DIR = GARDEN_DIR / "presets"
MANIFEST_PATH = GARDEN_DIR / "manifest.yaml"
DORMANT_HISTORY = GARDEN_DIR / "dormant-history"


# ──────────────────────────────────────────────────────────────────────────────
# Data classes
# ──────────────────────────────────────────────────────────────────────────────


@dataclass
class Component:
    id: str                   # e.g. "data:features"
    description: str = ""
    status: str = "experimental"   # stable | experimental | shell-incomplete
    version: str = "0.0.0"
    depends: list[str] = field(default_factory=list)
    files: list[str] = field(default_factory=list)
    recipes: list[str] = field(default_factory=list)
    adds_imports: list[str] = field(default_factory=list)
    post_grow_hint: str = ""

    @classmethod
    def from_yaml(cls, path: Path) -> Component:
        data = parse_simple_yaml(path.read_text())
        return cls(
            id=data.get("id", ""),
            description=data.get("description", ""),
            status=data.get("status", "experimental"),
            version=data.get("version", "0.0.0"),
            depends=data.get("depends", []) if isinstance(data.get("depends"), list) else [],
            files=data.get("files", []) if isinstance(data.get("files"), list) else [],
            recipes=data.get("recipes", []) if isinstance(data.get("recipes"), list) else [],
            adds_imports=data.get("adds_imports", []) if isinstance(data.get("adds_imports"), list) else [],
            post_grow_hint=data.get("post_grow_hint", ""),
        )


def component_seed_path(comp_id: str) -> Path:
    """Convert `data:features` -> `.garden/components/data/features/`."""
    if ":" not in comp_id:
        die(f"invalid component id: {comp_id} (expected `<category>:<name>`)")
    category, name = comp_id.split(":", 1)
    return COMPONENTS_DIR / category / name


# ──────────────────────────────────────────────────────────────────────────────
# Manifest helpers
# ──────────────────────────────────────────────────────────────────────────────


def load_manifest() -> dict:
    if not MANIFEST_PATH.exists():
        return {"template_version": "0.0.0", "template_source": "", "planted": []}
    return parse_simple_yaml(MANIFEST_PATH.read_text())


def save_manifest(data: dict) -> None:
    header = (
        "# Garden manifest — tracks planted components.\n"
        "# Updated by `just grow` and `just prune`. Do not edit by hand.\n\n"
    )
    MANIFEST_PATH.write_text(header + dump_simple_yaml(data) + "\n")


def planted_ids(manifest: dict) -> set[str]:
    return {entry.get("id", "") for entry in manifest.get("planted", []) if entry.get("id")}


# ──────────────────────────────────────────────────────────────────────────────
# Discovery
# ──────────────────────────────────────────────────────────────────────────────


def discover_components() -> list[Component]:
    if not COMPONENTS_DIR.exists():
        return []
    comps: list[Component] = []
    for cat_dir in sorted(COMPONENTS_DIR.iterdir()):
        if not cat_dir.is_dir():
            continue
        for comp_dir in sorted(cat_dir.iterdir()):
            if not comp_dir.is_dir():
                continue
            cyaml = comp_dir / "component.yaml"
            if cyaml.is_file():
                try:
                    comps.append(Component.from_yaml(cyaml))
                except Exception as exc:  # pragma: no cover
                    print(f"warn: skipping {cyaml}: {exc}", file=sys.stderr)
    return comps


def find_component(comp_id: str) -> Component:
    seed = component_seed_path(comp_id)
    cyaml = seed / "component.yaml"
    if not cyaml.is_file():
        die(f"component not found in seed bank: {comp_id}\nLooked at: {cyaml}")
    return Component.from_yaml(cyaml)


# ──────────────────────────────────────────────────────────────────────────────
# Operations
# ──────────────────────────────────────────────────────────────────────────────


def cmd_garden_status(_args) -> int:
    manifest = load_manifest()
    planted = manifest.get("planted", [])
    components = discover_components()
    planted_set = planted_ids(manifest)

    print(f"Template: {manifest.get('template_source', '?')} @ {manifest.get('template_version', '?')}")
    print()
    print(f"Planted components ({len(planted)}):")
    if planted:
        for entry in planted:
            mark = " [modified]" if entry.get("locally_modified") else ""
            print(f"  ✓ {entry.get('id'):28} v{entry.get('version', '?'):8} (planted {entry.get('planted_at', '?')}){mark}")
    else:
        print("  (none — try `just grow <component>`)")
    print()
    dormant = [c for c in components if c.id not in planted_set]
    print(f"Dormant components ({len(dormant)}):")
    if dormant:
        for c in dormant[:10]:
            print(f"  · {c.id:28} {c.description[:50]}")
        if len(dormant) > 10:
            print(f"  ... and {len(dormant) - 10} more — `just garden list dormant`")
    return 0


def cmd_garden_list(args) -> int:
    components = discover_components()
    manifest = load_manifest()
    planted = planted_ids(manifest)

    filter_arg = args.filter or "all"
    if filter_arg == "planted":
        components = [c for c in components if c.id in planted]
    elif filter_arg == "dormant":
        components = [c for c in components if c.id not in planted]

    by_category: dict[str, list[Component]] = {}
    for c in components:
        cat = c.id.split(":", 1)[0]
        by_category.setdefault(cat, []).append(c)

    for cat in sorted(by_category):
        print(f"\n{cat}:")
        for c in sorted(by_category[cat], key=lambda x: x.id):
            mark = "✓" if c.id in planted else "·"
            status_tag = ""
            if c.status == "experimental":
                status_tag = " (experimental)"
            elif c.status == "shell-incomplete":
                status_tag = " (bash-only)"
            print(f"  {mark} {c.id:28} {c.description[:60]}{status_tag}")
    if not by_category:
        print("(no components in seed bank yet)")
    return 0


def cmd_garden_show(args) -> int:
    c = find_component(args.id)
    print(f"id:          {c.id}")
    print(f"description: {c.description}")
    print(f"status:      {c.status}")
    print(f"version:     {c.version}")
    if c.depends:
        print(f"depends:     {', '.join(c.depends)}")
    print(f"files:       {len(c.files)}")
    for f in c.files[:20]:
        print(f"             - {f}")
    if len(c.files) > 20:
        print(f"             ... and {len(c.files) - 20} more")
    if c.recipes:
        print(f"recipes:     {', '.join(c.recipes)}")
    if c.adds_imports:
        print(f"imports:     {', '.join(c.adds_imports)}")
    if c.post_grow_hint:
        print()
        print("post-grow hint:")
        for line in c.post_grow_hint.splitlines():
            print(f"  {line}")
    return 0


def cmd_grow(args) -> int:
    target = args.id
    if target.startswith("preset:"):
        return grow_preset(target.split(":", 1)[1])

    manifest = load_manifest()
    planted = planted_ids(manifest)

    # Resolve dependencies (DFS)
    to_plant: list[str] = []
    visiting: set[str] = set()

    def visit(cid: str) -> None:
        if cid in planted or cid in [t for t in to_plant]:
            return
        if cid in visiting:
            die(f"dependency cycle through {cid}")
        visiting.add(cid)
        c = find_component(cid)
        for dep in c.depends:
            visit(dep)
        visiting.discard(cid)
        to_plant.append(cid)

    visit(target)

    print(f"Planting {len(to_plant)} component(s):")
    for cid in to_plant:
        plant_one(cid, manifest)
    save_manifest(manifest)
    return 0


def plant_one(comp_id: str, manifest: dict) -> None:
    c = find_component(comp_id)
    seed = component_seed_path(comp_id)
    files_dir = seed / "files"

    # Copy files into active tree
    copied: list[str] = []
    if files_dir.is_dir():
        for src in files_dir.rglob("*"):
            if src.is_file():
                rel = src.relative_to(files_dir)
                dst = PROJECT_ROOT / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
                copied.append(str(rel))

    # Add justfile imports
    add_imports_to_justfile(c.adds_imports)

    # Run post-grow hook if present
    hook = seed / "post-grow.sh"
    if hook.is_file():
        subprocess.run(["bash", str(hook)], cwd=PROJECT_ROOT, check=False)

    # Update manifest
    entry = {
        "id": c.id,
        "version": c.version,
        "planted_at": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
    }
    manifest.setdefault("planted", [])
    # Replace if already there
    manifest["planted"] = [e for e in manifest["planted"] if e.get("id") != c.id] + [entry]

    print(f"  ✓ {c.id} ({len(copied)} files)")
    if c.post_grow_hint:
        for line in c.post_grow_hint.splitlines():
            print(f"    {line}")


def cmd_prune(args) -> int:
    target = args.id
    manifest = load_manifest()
    if target not in planted_ids(manifest):
        die(f"{target} is not planted")

    c = find_component(target)
    seed = component_seed_path(target)

    # Archive copy under dormant-history
    DORMANT_HISTORY.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
    archive = DORMANT_HISTORY / f"{target.replace(':', '_')}_{timestamp}"
    archive.mkdir(parents=True)

    # Remove planted files; archive them first
    files_dir = seed / "files"
    if files_dir.is_dir():
        for src in files_dir.rglob("*"):
            if src.is_file():
                rel = src.relative_to(files_dir)
                planted_path = PROJECT_ROOT / rel
                if planted_path.exists():
                    archived_path = archive / rel
                    archived_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(planted_path, archived_path)
                    if not args.keep_files:
                        planted_path.unlink()
                        # cleanup empty parent dirs
                        parent = planted_path.parent
                        while parent != PROJECT_ROOT and parent.exists() and not any(parent.iterdir()):
                            parent.rmdir()
                            parent = parent.parent

    # Remove justfile imports
    remove_imports_from_justfile(c.adds_imports)

    # Run post-prune hook
    hook = seed / "post-prune.sh"
    if hook.is_file():
        subprocess.run(["bash", str(hook)], cwd=PROJECT_ROOT, check=False)

    # Update manifest
    manifest["planted"] = [e for e in manifest.get("planted", []) if e.get("id") != target]
    save_manifest(manifest)

    print(f"  ✓ pruned {target} (archived to {archive.relative_to(PROJECT_ROOT)})")
    if args.keep_files:
        print(f"  · files retained in active tree")
    return 0


def grow_preset(name: str) -> int:
    """Plant a preset — either from .garden/presets/<name>.yaml file OR from
    .garden/manifest.yaml's `presets.<name>` section."""
    # Try presets/ dir first
    pfile = PRESETS_DIR / f"{name}.yaml"
    components: list[str] = []
    description: str = ""
    post_hint: str = ""
    if pfile.is_file():
        data = parse_simple_yaml(pfile.read_text())
        components = data.get("components", []) or []
        description = data.get("description", "")
        post_hint = data.get("post_grow_hint", "")
    else:
        # Fall back to manifest.yaml's `presets.<name>`
        manifest = load_manifest()
        preset = manifest.get("presets", {}).get(name)
        if not preset:
            die(f"preset not found: {pfile} or manifest.yaml:presets.{name}")
        components = preset.get("components", []) or []
        description = preset.get("description", "")

    if not components:
        die(f"preset '{name}' has no components")

    if description:
        print(f"Planting preset '{name}' — {description}")
    print(f"  ({len(components)} components)")
    for cid in components:
        class _A:
            id = cid
        cmd_grow(_A())
    if post_hint:
        print()
        for line in post_hint.splitlines():
            print(line)
    return 0


def cmd_replant(args) -> int:
    """Plant components according to defaults_for_project_type for the
    project_type recorded in .copier-answers.yml. Used as a copier _tasks hook
    after scaffolding."""
    answers_path = PROJECT_ROOT / ".copier-answers.yml"
    if not answers_path.is_file():
        # Quietly succeed when not in a copier-rendered project
        if args.verbose:
            print("(no .copier-answers.yml found; nothing to replant)")
        return 0

    answers_text = answers_path.read_text()
    # Tiny ad-hoc parser: find `project_type: "..."` line
    project_type = ""
    for line in answers_text.splitlines():
        m = re.match(r'^project_type:\s*(.*)$', line)
        if m:
            project_type = m.group(1).strip().strip('"').strip("'")
            break

    if not project_type:
        if args.verbose:
            print("(no project_type in .copier-answers.yml; nothing to replant)")
        return 0

    manifest = load_manifest()
    defaults = manifest.get("defaults_for_project_type", {})
    components = defaults.get(project_type, [])
    if not components:
        if args.verbose:
            print(f"(no defaults_for_project_type for '{project_type}'; nothing to replant)")
        return 0

    print(f"Replanting {len(components)} component(s) for project_type: {project_type}")
    planted = planted_ids(manifest)
    for cid in components:
        if cid in planted:
            print(f"  · {cid} already planted")
            continue
        try:
            plant_one(cid, manifest)
        except SystemExit:
            print(f"  ✗ failed to plant {cid} — skipping")
            continue
        except Exception as exc:
            print(f"  ✗ failed to plant {cid}: {exc}")
            continue
    save_manifest(manifest)
    return 0


# ──────────────────────────────────────────────────────────────────────────────
# Justfile import management
# ──────────────────────────────────────────────────────────────────────────────


JUSTFILE = PROJECT_ROOT / "justfile"
GARDEN_MARKER_BEGIN = "# >>> garden imports (managed by .garden/garden.py) >>>"
GARDEN_MARKER_END = "# <<< garden imports <<<"


def _read_justfile_lines() -> list[str]:
    if not JUSTFILE.exists():
        return []
    return JUSTFILE.read_text().splitlines()


def _write_justfile_lines(lines: list[str]) -> None:
    JUSTFILE.write_text("\n".join(lines) + "\n")


def _ensure_garden_block(lines: list[str]) -> tuple[list[str], int, int]:
    """Return (lines, begin_idx, end_idx) of the garden-managed block.
    Inserts an empty block at top if missing."""
    for i, line in enumerate(lines):
        if line.strip() == GARDEN_MARKER_BEGIN:
            for j in range(i + 1, len(lines)):
                if lines[j].strip() == GARDEN_MARKER_END:
                    return lines, i, j
    new_block = [GARDEN_MARKER_BEGIN, GARDEN_MARKER_END, ""]
    return new_block + lines, 0, 1


def add_imports_to_justfile(imports: list[str]) -> None:
    if not imports:
        return
    lines = _read_justfile_lines()
    lines, begin, end = _ensure_garden_block(lines)
    block = lines[begin + 1 : end]
    existing = set(line.strip() for line in block)
    new_lines = list(block)
    for imp in imports:
        line = f'import "{imp}"'
        if line not in existing:
            new_lines.append(line)
    new_lines.sort()
    out = lines[: begin + 1] + new_lines + lines[end:]
    _write_justfile_lines(out)


def remove_imports_from_justfile(imports: list[str]) -> None:
    if not imports:
        return
    lines = _read_justfile_lines()
    lines, begin, end = _ensure_garden_block(lines)
    block = lines[begin + 1 : end]
    drop = {f'import "{imp}"' for imp in imports}
    kept = [ln for ln in block if ln not in drop]
    out = lines[: begin + 1] + kept + lines[end:]
    _write_justfile_lines(out)


# ──────────────────────────────────────────────────────────────────────────────
# Entry
# ──────────────────────────────────────────────────────────────────────────────


def die(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="garden")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_status = sub.add_parser("status", help="show planted vs dormant overview")
    p_status.set_defaults(func=cmd_garden_status)

    p_list = sub.add_parser("list", help="list components")
    p_list.add_argument("filter", nargs="?", choices=["all", "planted", "dormant"], default="all")
    p_list.set_defaults(func=cmd_garden_list)

    p_show = sub.add_parser("show", help="show component details")
    p_show.add_argument("id")
    p_show.set_defaults(func=cmd_garden_show)

    p_grow = sub.add_parser("grow", help="plant a component or preset")
    p_grow.add_argument("id")
    p_grow.set_defaults(func=cmd_grow)

    p_prune = sub.add_parser("prune", help="remove a planted component")
    p_prune.add_argument("id")
    p_prune.add_argument("--keep-files", action="store_true",
                         help="leave files in active tree; only update manifest")
    p_prune.set_defaults(func=cmd_prune)

    p_replant = sub.add_parser(
        "replant",
        help="plant defaults_for_project_type[<chosen>] from manifest "
             "(used by copier _tasks after scaffolding)")
    p_replant.add_argument("--verbose", action="store_true")
    p_replant.set_defaults(func=cmd_replant)

    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
