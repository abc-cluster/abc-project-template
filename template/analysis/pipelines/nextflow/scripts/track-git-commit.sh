#!/usr/bin/env bash
set -euo pipefail

# Git State Tracking Script
# Captures current git repository state for experiment tracking

EXP_DIR="${1:-.}"
EXP_ID="${2:-unknown}"

# Output file
GIT_INFO_FILE="${EXP_DIR}/git-info.yaml"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Not in a git repository, creating minimal git-info.yaml"
    cat > "$GIT_INFO_FILE" << EOF
# Git Repository Information
experiment_id: "${EXP_ID}"
captured_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

repository:
  path: ""
  remote_url: ""

git:
  branch: ""
  commit_hash: ""
  commit_message: ""
  commit_author: ""
  commit_date: ""

is_dirty: false
uncommitted_changes:
  modified: []
  added: []
  deleted: []
  untracked: []

diff_patch: ""
tags: []
EOF
    exit 0
fi

# Get repository information
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "")
COMMIT_MSG=$(git log -1 --pretty=%B 2>/dev/null | head -1 || echo "")
COMMIT_AUTHOR=$(git log -1 --pretty=%an 2>/dev/null || echo "")
COMMIT_DATE=$(git log -1 --pretty=%ai 2>/dev/null || echo "")

# Check if repository is dirty
IS_DIRTY=false
if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    IS_DIRTY=true
fi

# Get lists of changed files
MODIFIED_FILES=$(git status --porcelain 2>/dev/null | grep "^ M" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
ADDED_FILES=$(git status --porcelain 2>/dev/null | grep "^A" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
DELETED_FILES=$(git status --porcelain 2>/dev/null | grep "^D" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
UNTRACKED_FILES=$(git status --porcelain 2>/dev/null | grep "^??" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')

# Convert comma-separated to YAML array format
to_yaml_array() {
    if [[ -z "$1" ]]; then
        echo "[]"
    else
        echo "$1" | tr ',' '\n' | sed 's/^/  - /'
    fi
}

# Write git-info.yaml
cat > "$GIT_INFO_FILE" << EOF
# Git Repository Information
# Snapshot of repository state at experiment creation/execution

experiment_id: "${EXP_ID}"
captured_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Repository Details
repository:
  path: "${REPO_ROOT}"
  remote_url: "${REPO_REMOTE}"

# Git State
git:
  branch: "${BRANCH}"
  commit_hash: "${COMMIT}"
  commit_message: "${COMMIT_MSG}"
  commit_author: "${COMMIT_AUTHOR}"
  commit_date: "${COMMIT_DATE}"
  
# Dirty State
is_dirty: ${IS_DIRTY}
uncommitted_changes:
  modified:
$(to_yaml_array "$MODIFIED_FILES")
  added:
$(to_yaml_array "$ADDED_FILES")
  deleted:
$(to_yaml_array "$DELETED_FILES")
  untracked:
$(to_yaml_array "$UNTRACKED_FILES")

# Uncommitted diff (if dirty)
diff_patch: ""

# Tags
tags: []
EOF

# Update database with git info
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/register-experiment.py" ]]; then
    python3 "${SCRIPT_DIR}/register-experiment.py" update-git-info \
        --id "${EXP_ID}" \
        --commit "${COMMIT}" \
        --branch "${BRANCH}" \
        --dirty "${IS_DIRTY}" 2>/dev/null || true
fi

echo "✅ Git state captured: ${BRANCH}@${COMMIT:0:7} (dirty: ${IS_DIRTY})"
