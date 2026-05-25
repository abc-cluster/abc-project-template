# workbench.just — ABC-cluster workbench session shortcuts
# Planted by: just grow infra:workbench
# Requires: abc CLI (https://abc-cluster.github.io/docs/cli)

# Start a workbench session (reads defaults from .abc-workbench.yaml)
workbench-start:
    abc workbench start

# Start with custom resources
workbench-start-large:
    abc workbench start --cores 4 --memory 8192

# Stop the running workbench session (also imports atuin shell history)
workbench-stop:
    abc workbench stop

# Show status of current workbench session
workbench-status:
    abc workbench status

# Print the workbench URL (open in browser)
workbench-url:
    abc workbench url

# Tail workbench container logs
workbench-logs:
    abc workbench logs

# Configure DVC remote using cluster MinIO credentials
# Run after `abc workbench start` has injected ABC_MINIO_ENDPOINT etc.
workbench-dvc-remote:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "${ABC_MINIO_ENDPOINT:-}" ]; then
        echo "❌ ABC_MINIO_ENDPOINT not set. Start a workbench session first:"
        echo "   just workbench-start"
        exit 1
    fi
    PROJECT=$(grep '^project:' .abc-workbench.yaml | awk '{print $2}' | tr -d '"')
    dvc remote add -d abc-minio "s3://${PROJECT}/data" --config .dvc/config.local
    dvc remote modify abc-minio endpointurl "${ABC_MINIO_ENDPOINT}" --config .dvc/config.local
    dvc remote modify abc-minio access_key_id "${AWS_ACCESS_KEY_ID:-}" --config .dvc/config.local
    dvc remote modify abc-minio secret_access_key "${AWS_SECRET_ACCESS_KEY:-}" --config .dvc/config.local
    echo "✅ DVC remote 'abc-minio' configured (local config only, not committed)"

# Check workbench prerequisites
workbench-doctor:
    #!/usr/bin/env bash
    echo "🔍 Workbench prerequisites:"
    command -v abc    &>/dev/null && echo "  ✅ abc CLI"      || echo "  ❌ abc CLI not found (https://abc-cluster.github.io/docs/cli)"
    command -v quarto &>/dev/null && echo "  ✅ quarto"       || echo "  ❌ quarto not found (just grow writeup:quarto → quarto install)"
    command -v dvc    &>/dev/null && echo "  ✅ dvc"          || echo "  ⚠️  dvc not found (optional, needed for data versioning)"
    command -v s5cmd  &>/dev/null && echo "  ✅ s5cmd"        || echo "  ⚠️  s5cmd not found (optional, faster S3 staging)"
    [ -f .abc-workbench.yaml ] && echo "  ✅ .abc-workbench.yaml" || echo "  ❌ .abc-workbench.yaml missing"
