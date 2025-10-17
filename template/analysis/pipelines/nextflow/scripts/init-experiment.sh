#!/usr/bin/env bash
set -euo pipefail

# Nextflow Experiment Initialization Script
# Creates new experiment directories and populates templates

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="${BASE_DIR}/experiments/templates"
CONFIGS_DIR="${BASE_DIR}/experiments/configs"

# Default values
TYPE=""
NAME=""
SCENARIO="local-local"
PARAMS_TEMPLATE="default-params"
CHAIN_ID=""
PARENT_ID=""
TAGS=""
RESEARCHER="${USER}"
PURPOSE=""
PROJECT_NAME=""
DATASET=""

# Print usage
usage() {
    cat << EOF
Usage: $(basename "$0") --type TYPE --name NAME [OPTIONS]

Required:
  --type TYPE               Experiment type: development, production, or planning
  --name NAME               Short name for the experiment

Optional:
  --scenario SCENARIO       Execution scenario (default: local-local)
                           Options: local-local, local-remote, tower, planning-only
  --params-template TPL     Parameter template (default: default-params)
                           Options: default-params, minimal-test, full-dataset
  --purpose PURPOSE         Purpose description
  --project PROJECT         Project name
  --dataset DATASET         Dataset name
  --researcher NAME         Researcher name (default: current user)
  --chain-id ID             Resume chain ID
  --parent-id ID            Parent experiment ID (for resume)
  --tags TAGS               Comma-separated tags

Example:
  $(basename "$0") --type development --name "test-alignment" --purpose "Test new aligner"

EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            TYPE="$2"
            shift 2
            ;;
        --name)
            NAME="$2"
            shift 2
            ;;
        --scenario)
            SCENARIO="$2"
            shift 2
            ;;
        --params-template)
            PARAMS_TEMPLATE="$2"
            shift 2
            ;;
        --purpose)
            PURPOSE="$2"
            shift 2
            ;;
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --dataset)
            DATASET="$2"
            shift 2
            ;;
        --researcher)
            RESEARCHER="$2"
            shift 2
            ;;
        --chain-id)
            CHAIN_ID="$2"
            shift 2
            ;;
        --parent-id)
            PARENT_ID="$2"
            shift 2
            ;;
        --tags)
            TAGS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            ;;
    esac
done

# Validate required arguments
if [[ -z "$TYPE" ]] || [[ -z "$NAME" ]]; then
    echo -e "${RED}Error: --type and --name are required${NC}"
    usage
fi

# Validate type
if [[ ! "$TYPE" =~ ^(development|production|planning)$ ]]; then
    echo -e "${RED}Error: Invalid type '$TYPE'. Must be: development, production, or planning${NC}"
    exit 1
fi

# Validate scenario
if [[ ! "$SCENARIO" =~ ^(local-local|local-remote|tower|planning-only)$ ]]; then
    echo -e "${RED}Error: Invalid scenario '$SCENARIO'${NC}"
    exit 1
fi

# Generate experiment ID
TIMESTAMP=$(date +%Y%m%d_%H%M)
EXP_ID="${TIMESTAMP}_${TYPE:0:4}-${NAME}"
echo -e "${BLUE}🧪 Creating experiment: ${EXP_ID}${NC}"

# Determine phase
if [[ "$TYPE" == "planning" ]]; then
    PHASE="pipeline-development"
else
    PHASE="pipeline-development"
fi

# Create experiment directory
EXP_DIR="${BASE_DIR}/experiments/${TYPE}/runs/${EXP_ID}"
if [[ -d "$EXP_DIR" ]]; then
    echo -e "${RED}Error: Experiment directory already exists: $EXP_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}📁 Creating directory structure...${NC}"
mkdir -p "${EXP_DIR}"/{nextflow-logs,reports/tower}

# Get current date and time for templates
CURRENT_DATE=$(date +%Y-%m-%d)
CURRENT_TIME=$(date +%H:%M:%S)
CURRENT_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Function to substitute template placeholders
substitute_template() {
    local input_file="$1"
    local output_file="$2"
    
    sed -e "s|{{EXPERIMENT_ID}}|${EXP_ID}|g" \
        -e "s|{{TYPE}}|${TYPE}|g" \
        -e "s|{{SCENARIO}}|${SCENARIO}|g" \
        -e "s|{{PHASE}}|${PHASE}|g" \
        -e "s|{{DATE}}|${CURRENT_DATE}|g" \
        -e "s|{{TIME}}|${CURRENT_TIME}|g" \
        -e "s|{{TIMESTAMP}}|${CURRENT_TIMESTAMP}|g" \
        -e "s|{{RESEARCHER}}|${RESEARCHER}|g" \
        -e "s|{{PURPOSE}}|${PURPOSE}|g" \
        -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
        -e "s|{{DATASET}}|${DATASET}|g" \
        -e "s|{{NAME}}|${NAME}|g" \
        -e "s|{{WORKSPACE}}|default|g" \
        -e "s|{{CHAIN_ID}}|${CHAIN_ID}|g" \
        -e "s|{{RUN_NUMBER}}|1|g" \
        -e "s|{{IS_RESUME}}|false|g" \
        -e "s|{{PARENT_RUN}}|${PARENT_ID:-null}|g" \
        -e "s|{{EXECUTION_ID}}|exec-${TIMESTAMP}-001|g" \
        -e "s|{{HEAD_LOCATION}}|local|g" \
        -e "s|{{TASKS_LOCATION}}|$(echo $SCENARIO | cut -d'-' -f2)|g" \
        -e "s|{{TOWER_ENABLED}}|true|g" \
        -e "s|{{PRIMARY_STORAGE}}||g" \
        -e "s|{{LOCAL_PATH}}|${EXP_DIR}/results|g" \
        -e "s|{{STATUS}}|planned|g" \
        -e "s|{{GIT_BRANCH}}||g" \
        -e "s|{{GIT_COMMIT}}||g" \
        -e "s|{{IS_DIRTY}}|false|g" \
        -e "s|{{TOWER_RUN_ID}}||g" \
        -e "s|{{TOWER_URL}}||g" \
        "$input_file" > "$output_file"
}

# Copy and populate templates
echo -e "${GREEN}📄 Copying templates...${NC}"

substitute_template "${TEMPLATES_DIR}/metadata.yaml.template" "${EXP_DIR}/metadata.yaml"
substitute_template "${TEMPLATES_DIR}/execution.yaml.template" "${EXP_DIR}/execution.yaml"
substitute_template "${TEMPLATES_DIR}/experiment-plan.md.template" "${EXP_DIR}/experiment-plan.md"
substitute_template "${TEMPLATES_DIR}/execution-log.md.template" "${EXP_DIR}/execution-log.md"
substitute_template "${TEMPLATES_DIR}/results-manifest.yaml.template" "${EXP_DIR}/results-manifest.yaml"
substitute_template "${TEMPLATES_DIR}/git-info.yaml.template" "${EXP_DIR}/git-info.yaml"
substitute_template "${TEMPLATES_DIR}/tower-info.yaml.template" "${EXP_DIR}/tower-info.yaml"
substitute_template "${TEMPLATES_DIR}/README.md.template" "${EXP_DIR}/README.md"

# Copy parameter template
PARAMS_FILE="${CONFIGS_DIR}/params/${PARAMS_TEMPLATE}.yaml"
if [[ -f "$PARAMS_FILE" ]]; then
    cp "$PARAMS_FILE" "${EXP_DIR}/params.yaml"
    echo -e "${GREEN}✅ Copied parameter template: ${PARAMS_TEMPLATE}${NC}"
else
    echo -e "${YELLOW}⚠️  Parameter template not found: ${PARAMS_FILE}${NC}"
    echo -e "${YELLOW}   Creating default params.yaml${NC}"
    cat > "${EXP_DIR}/params.yaml" << EOF
# Experiment Parameters: ${EXP_ID}
# Generated: ${CURRENT_DATE} ${CURRENT_TIME}

# Input/Output
input: "../data/01_raw/*.csv"
outdir: "./results"

# Pipeline Options
resume: false
help: false

# Resource Limits
max_cpus: 16
max_memory: "64.GB"
max_time: "24.h"

# Experiment Tracking
experiment_id: "${EXP_ID}"
researcher: "${RESEARCHER}"
EOF
fi

# Create empty samplesheet template
cat > "${EXP_DIR}/samplesheet.csv" << EOF
sample_id,input_file,condition
sample1,/path/to/input1.csv,control
sample2,/path/to/input2.csv,treatment
EOF

# Track git commit if not planning-only
if [[ "$SCENARIO" != "planning-only" ]]; then
    if [[ -f "${SCRIPT_DIR}/track-git-commit.sh" ]]; then
        echo -e "${GREEN}📝 Tracking git commit...${NC}"
        bash "${SCRIPT_DIR}/track-git-commit.sh" "${EXP_DIR}" "${EXP_ID}" || {
            echo -e "${YELLOW}⚠️  Git tracking failed (may not be in a git repo)${NC}"
        }
    else
        echo -e "${YELLOW}⚠️  track-git-commit.sh not found, skipping git tracking${NC}"
    fi
fi

# Register in database
echo -e "${GREEN}💾 Registering in database...${NC}"
python3 "${SCRIPT_DIR}/register-experiment.py" create \
    --id "${EXP_ID}" \
    --type "${TYPE}" \
    --scenario "${SCENARIO}" \
    --phase "${PHASE}" \
    --researcher "${RESEARCHER}" \
    --purpose "${PURPOSE}" \
    --project "${PROJECT_NAME}" \
    --dataset "${DATASET}" \
    --tags "${TAGS}"

# Create/update symlink in active directory
ACTIVE_DIR="${BASE_DIR}/experiments/${TYPE}/active"
mkdir -p "${ACTIVE_DIR}"
SYMLINK="${ACTIVE_DIR}/${NAME}"

if [[ -L "$SYMLINK" ]]; then
    rm "$SYMLINK"
fi
ln -s "../runs/${EXP_ID}" "$SYMLINK"
echo -e "${GREEN}🔗 Created symlink: ${TYPE}/active/${NAME} -> ${EXP_ID}${NC}"

# Summary
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Experiment created successfully!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BLUE}Experiment ID:${NC} ${EXP_ID}"
echo -e "  ${BLUE}Type:${NC}          ${TYPE}"
echo -e "  ${BLUE}Scenario:${NC}      ${SCENARIO}"
echo -e "  ${BLUE}Location:${NC}      ${EXP_DIR}"
echo -e "  ${BLUE}Symlink:${NC}       experiments/${TYPE}/active/${NAME}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo -e "  1. Edit experiment plan: ${EXP_DIR}/experiment-plan.md"
echo -e "  2. Configure parameters: ${EXP_DIR}/params.yaml"
echo -e "  3. Update samplesheet:   ${EXP_DIR}/samplesheet.csv"
echo ""
if [[ "$SCENARIO" != "planning-only" ]]; then
    echo -e "${YELLOW}🚀 Run Commands:${NC}"
    echo -e "  just run-local ${EXP_ID}"
    echo -e "  just run-aws ${EXP_ID}"
    echo -e "  just run-tower ${EXP_ID}"
fi
echo ""
