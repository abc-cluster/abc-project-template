#!/usr/bin/env bash
# tests/check-baselines.sh
#
# Compare current CTT output against committed baselines.
# Exits non-zero if any scenario has differences.
#
# Usage:
#   ./tests/check-baselines.sh                    # full ctt.toml suite
#   ./tests/check-baselines.sh ctt-minimal.toml
#   ./tests/check-baselines.sh --no-rerun         # skip ctt; check whatever's already there
#   ./tests/check-baselines.sh --scenario NAME    # single scenario
#   ./tests/check-baselines.sh --keep             # leave scenario dirs in place after check
#
# Run BEFORE refactor work to confirm baselines are reproducible.
# Run AFTER refactor work / IN CI to catch regressions.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

CTT_CONFIG="ctt.toml"
BASELINE_DIR="tests/baseline"
ONLY_SCENARIO=""
RERUN=true
KEEP_OUTPUTS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-rerun) RERUN=false; shift ;;
        --keep)     KEEP_OUTPUTS=true; shift ;;
        --scenario) ONLY_SCENARIO="$2"; shift 2 ;;
        *.toml)     CTT_CONFIG="$1"; shift ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

if command -v sha256sum >/dev/null 2>&1; then
    HASHER="sha256sum"
else
    HASHER="shasum -a 256"
fi

# Resolve scenarios (portable; macOS bash 3.2 has no mapfile)
SCENARIOS=()
while IFS= read -r line; do
    SCENARIOS+=("$line")
done < <(python3 tests/lib/scenarios.py "$CTT_CONFIG")

# Run CTT if asked
if $RERUN; then
    if ! command -v ctt >/dev/null 2>&1; then
        echo "ERROR: 'ctt' not found on PATH" >&2
        exit 1
    fi
    for s in "${SCENARIOS[@]}"; do
        [[ -d "$s" ]] && rm -rf "$s"
    done
    if [[ "$CTT_CONFIG" != "ctt.toml" ]]; then
        cp ctt.toml ctt.toml.bak.$$
        cp "$CTT_CONFIG" ctt.toml
        trap 'mv ctt.toml.bak.$$ ctt.toml 2>/dev/null || true' EXIT
    fi
    echo "==> Running ctt..."
    LOG=$(mktemp)
    if ! ctt -b . > "$LOG" 2>&1; then
        echo "ERROR: ctt failed (last 30 lines):" >&2
        tail -30 "$LOG" >&2
        exit 1
    fi
    # CTT skips copier _tasks; run replant on each scenario to mirror real copier
    for scenario in "${SCENARIOS[@]}"; do
        [[ -d "$scenario" ]] || continue
        if [[ -f "$scenario/.garden/garden.py" ]]; then
            (cd "$scenario" && python3 .garden/garden.py replant > /dev/null 2>&1) || true
        fi
    done
fi

if [[ ! -d "$BASELINE_DIR" ]] || [[ ! -f "$BASELINE_DIR/INDEX.txt" ]]; then
    echo "ERROR: no baselines found at $BASELINE_DIR/" >&2
    echo "Generate them: ./tests/snapshot-baselines.sh" >&2
    exit 1
fi

# Helpers
build_current_manifest() {
    local scenario_path="$1" out_file="$2"
    {
        echo "# (current run)"
    } > "$out_file"
    (
        cd "$scenario_path"
        find . -type f -not -path "./.git/*" -print0 |
            sort -z |
            while IFS= read -r -d '' f; do
                rel="${f#./}"
                size=$(stat -f '%z' "$f" 2>/dev/null || stat -c '%s' "$f" 2>/dev/null || echo "0")
                hash=$($HASHER "$f" | awk '{print $1}')
                printf '%s\t%s\t%s\n' "$hash" "$size" "$rel"
            done
    ) >> "$out_file"
}

diff_manifest() {
    local scenario="$1" baseline="$2" current="$3"
    local b_clean c_clean
    b_clean=$(mktemp); c_clean=$(mktemp)
    grep -v '^#' "$baseline" | sort -k3 > "$b_clean"
    grep -v '^#' "$current" | sort -k3 > "$c_clean"
    if cmp -s "$b_clean" "$c_clean"; then
        rm -f "$b_clean" "$c_clean"
        return 0
    fi
    local missing added changed
    missing=$(comm -23 <(awk '{print $3}' "$b_clean") <(awk '{print $3}' "$c_clean"))
    added=$(comm -13 <(awk '{print $3}' "$b_clean") <(awk '{print $3}' "$c_clean"))
    changed=$(join -1 3 -2 3 -t $'\t' "$b_clean" "$c_clean" | awk -F'\t' '$2 != $4 {print $1}')
    if [[ -n "$missing" ]]; then
        echo "  [$scenario] MISSING (in baseline, not in current):"
        echo "$missing" | sed 's/^/    - /' | head -50
        local m_count
        m_count=$(printf '%s\n' "$missing" | wc -l | tr -d ' ')
        if [[ "$m_count" -gt 50 ]]; then echo "    ... ($((m_count - 50)) more)"; fi
    fi
    if [[ -n "$added" ]]; then
        echo "  [$scenario] ADDED (in current, not in baseline):"
        echo "$added" | sed 's/^/    + /' | head -50
        local a_count
        a_count=$(printf '%s\n' "$added" | wc -l | tr -d ' ')
        if [[ "$a_count" -gt 50 ]]; then echo "    ... ($((a_count - 50)) more)"; fi
    fi
    if [[ -n "$changed" ]]; then
        echo "  [$scenario] CHANGED (content hash differs):"
        echo "$changed" | sed 's/^/    ~ /' | head -50
        local c_count
        c_count=$(printf '%s\n' "$changed" | wc -l | tr -d ' ')
        if [[ "$c_count" -gt 50 ]]; then echo "    ... ($((c_count - 50)) more)"; fi
    fi
    rm -f "$b_clean" "$c_clean"
    return 1
}

# Iterate
pass=0; fail=0; missing_baseline=0; missing_current=0
fail_scenarios=()

for scenario in "${SCENARIOS[@]}"; do
    if [[ -n "$ONLY_SCENARIO" && "$scenario" != "$ONLY_SCENARIO" ]]; then
        continue
    fi
    if [[ ! -d "$scenario" ]]; then
        echo "  [$scenario] CTT did not produce output"
        missing_current=$((missing_current + 1))
        fail_scenarios+=("$scenario (no current output)")
        continue
    fi
    baseline="$BASELINE_DIR/$scenario/manifest.txt"
    if [[ ! -f "$baseline" ]]; then
        echo "  [$scenario] NO BASELINE — run snapshot-baselines.sh"
        missing_baseline=$((missing_baseline + 1))
        fail_scenarios+=("$scenario (no baseline)")
        continue
    fi
    current=$(mktemp)
    build_current_manifest "$scenario" "$current"
    if diff_manifest "$scenario" "$baseline" "$current"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        fail_scenarios+=("$scenario")
    fi
    rm -f "$current"
done

# Cleanup
if ! $KEEP_OUTPUTS; then
    for s in "${SCENARIOS[@]}"; do
        [[ -d "$s" ]] && rm -rf "$s"
    done
fi

echo ""
echo "==> Summary"
echo "    Pass:                  $pass"
echo "    Fail:                  $fail"
echo "    Missing baseline:      $missing_baseline"
echo "    Missing current:       $missing_current"

if [[ $fail -gt 0 || $missing_baseline -gt 0 || $missing_current -gt 0 ]]; then
    echo ""
    echo "Failed scenarios:"
    printf '  - %s\n' "${fail_scenarios[@]}"
    exit 1
fi
echo ""
echo "All baselines match. ✓"
