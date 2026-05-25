#!/usr/bin/env bash
# tests/move-justfiles-to-tasks.sh
#
# Phase 4: centralize all per-area justfiles under template/tasks/.
# Strip the duplicated SHELL_TYPE block from each (shared in tasks/_shell.just).
#
# Mapping (source → tasks/):
#   data/data.just              → tasks/data.just
#   notebooks/notebooks.just    → tasks/notebooks.just
#   pipelines/pipelines.just    → tasks/pipelines.just
#   scripts/scripts.just        → tasks/scripts.just
#   src/packages.just           → tasks/packages.just
#   src/justfiles/python.just   → tasks/python.just
#   src/justfiles/r.just        → tasks/r.just
#   writeup/writeup.just        → tasks/writeup.just
#   writeup/manuscript/manuscript.just  → tasks/manuscript.just
#   writeup/manuscript/manuscript.pwsh.just → tasks/manuscript.pwsh.just
#   writeup/manuscript/pollen/pollen.just  → tasks/pollen.just
#   misc/codeqc.just            → tasks/quality.just
#   expansion.just              → tasks/expansion.just
#   tasks/legacy-analysis.just  → DELETED (subsumed by other tasks files)

set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

mkdir -p template/tasks

# Helper: move a justfile into tasks/, stripping the SHELL_TYPE block.
relocate() {
    local src="$1"
    local dst="template/tasks/$2"
    if [[ ! -f "$src" ]]; then
        echo "  · skip $src (not found)"
        return 0
    fi
    if [[ -e "$dst" ]]; then
        echo "  ! conflict: $dst already exists"
        return 0
    fi
    if git ls-files --error-unmatch "$src" > /dev/null 2>&1; then
        git mv "$src" "$dst"
    else
        mv "$src" "$dst"
    fi
    # Strip leading SHELL_TYPE block (the 3 lines + blank line that appear
    # at the top of every justfile)
    python3 -c "
import re, sys
p = sys.argv[1]
text = open(p).read()
shell_block = re.compile(
    r'^# Shell Platform Selection\n'
    r'SHELL_TYPE := env_var_or_default.*\n'
    r'SCRIPT_EXT := if SHELL_TYPE == \"powershell\".*\n'
    r'SHELL_CMD := if SHELL_TYPE == \"powershell\".*\n+',
    re.M
)
new = shell_block.sub('', text, count=1)
if new != text:
    open(p,'w').write(new)
" "$dst"
    echo "  ✓ moved $src → $dst"
}

relocate "template/data/data.just"                              data.just
relocate "template/notebooks/notebooks.just"                    notebooks.just
relocate "template/pipelines/pipelines.just"                    pipelines.just
relocate "template/scripts/scripts.just"                        scripts.just
relocate "template/src/packages.just"                           packages.just
relocate "template/src/justfiles/python.just"                   python.just
relocate "template/src/justfiles/r.just"                        r.just
relocate "template/writeup/writeup.just"                        writeup.just
relocate "template/writeup/manuscript/manuscript.just"          manuscript.just
relocate "template/writeup/manuscript/manuscript.pwsh.just"     manuscript.pwsh.just
relocate "template/writeup/manuscript/pollen/pollen.just"       pollen.just
relocate "template/misc/codeqc.just"                            quality.just
relocate "template/expansion.just"                              expansion.just

# Drop legacy-analysis.just (its recipes were duplicates that imported the others)
if [[ -f template/tasks/legacy-analysis.just ]]; then
    if git ls-files --error-unmatch template/tasks/legacy-analysis.just > /dev/null 2>&1; then
        git rm template/tasks/legacy-analysis.just
    else
        rm template/tasks/legacy-analysis.just
    fi
    echo "  ✓ removed template/tasks/legacy-analysis.just (subsumed)"
fi

# Drop now-empty src/justfiles/ if empty
find template/src/justfiles -type d -empty -delete 2>/dev/null

echo ""
echo "==> Phase 4 justfile consolidation done."
