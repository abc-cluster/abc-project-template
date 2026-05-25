# Enhanced Pipeline Management with Just
# Comprehensive automation for research pipelines

# Variables
pipelines_dir := justfile_directory()
templates_dir := pipelines_dir + "/templates"
workflows_dir := pipelines_dir + "/workflows"
configs_dir := pipelines_dir + "/configs"
date := `date +%Y%m%d`
timestamp := `date +%Y%m%d_%H%M%S`
EXPERIMENTS_LOG := "pipelines-experiments.org"

# Default recipe
default:
    @echo "🔧 Pipeline Management Commands:"
    @just --list

# === Pipeline Creation ===

# Create new data processing pipeline
new-data-pipeline name:
    #!/usr/bin/env bash
    pipeline_id="{{timestamp}}_data_{{name}}"
    template_file="{{templates_dir}}/data-processing-pipeline.py"
    target_file="${pipeline_id}.py"
    
    if [ -f "$template_file" ]; then
        cp "$template_file" "$target_file"
        sed -i.bak "s/{{PIPELINE_ID}}/$pipeline_id/g" "$target_file"
        sed -i.bak "s/{{PIPELINE_NAME}}/{{name}}/g" "$target_file"
        sed -i.bak "s/{{DATE}}/{{date}}/g" "$target_file"
        rm "$target_file.bak"
        echo "📊 Created data pipeline: $target_file"
    else
        echo "❌ Template not found, creating basic pipeline..."
        cat > "$target_file" << EOF
#!/usr/bin/env python3
"""Data processing pipeline for {{name}}
Created: {{date}}
Pipeline ID: $pipeline_id
"""

import pandas as pd
from pathlib import Path
import logging

def setup_logging():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_data(input_path: str) -> pd.DataFrame:
    """Load raw data from input path"""
    # Add your data loading logic here
    pass

def process_data(df: pd.DataFrame) -> pd.DataFrame:
    """Process and clean the data"""
    # Add your data processing logic here
    pass

def save_data(df: pd.DataFrame, output_path: str):
    """Save processed data to output path"""
    # Add your data saving logic here
    pass

def main():
    setup_logging()
    logging.info(f"Starting data pipeline: $pipeline_id")
    
    # Pipeline execution
    # df = load_data("../data/01_raw/{{name}}.csv")
    # processed_df = process_data(df)
    # save_data(processed_df, "../data/02_processed/{{name}}_processed.csv")
    
    logging.info("Pipeline completed successfully")

if __name__ == "__main__":
    main()
EOF
        echo "📊 Created basic data pipeline: $target_file"
    fi

# Create new ML training pipeline
new-training-pipeline name:
    #!/usr/bin/env bash
    pipeline_id="{{timestamp}}_training_{{name}}"
    target_file="${pipeline_id}.py"
    
    cat > "$target_file" << EOF
#!/usr/bin/env python3
"""Model training pipeline for {{name}}
Created: {{date}}
Pipeline ID: $pipeline_id
"""

import mlflow
import mlflow.sklearn
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
import pandas as pd
import logging
import joblib
from pathlib import Path

def setup_logging():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_processed_data(data_path: str):
    """Load processed data for training"""
    # Add your data loading logic here
    pass

def train_model(X_train, y_train):
    """Train the model"""
    # Add your model training logic here
    pass

def evaluate_model(model, X_test, y_test):
    """Evaluate model performance"""
    # Add your model evaluation logic here
    pass

def save_model(model, model_path: str):
    """Save trained model"""
    joblib.dump(model, model_path)
    logging.info(f"Model saved to {model_path}")

def main():
    setup_logging()
    
    with mlflow.start_run(run_name=f"{{name}}_training_{{{timestamp}}}"):
        logging.info(f"Starting training pipeline: $pipeline_id")
        
        # Log parameters
        mlflow.log_param("pipeline_id", "$pipeline_id")
        mlflow.log_param("dataset", "{{name}}")
        mlflow.log_param("date", "{{date}}")
        
        # Pipeline execution
        # data = load_processed_data("../data/02_processed/{{name}}_processed.csv")
        # X_train, X_test, y_train, y_test = train_test_split(...)
        # model = train_model(X_train, y_train)
        # metrics = evaluate_model(model, X_test, y_test)
        # save_model(model, f"../models/{{name}}_model_{{{timestamp}}}.joblib")
        
        # Log metrics
        # mlflow.log_metrics(metrics)
        
        logging.info("Training pipeline completed successfully")

if __name__ == "__main__":
    main()
EOF
    echo "🤖 Created training pipeline: $target_file"

# === Pipeline Execution ===

# Run data processing pipeline
run-data-pipeline pipeline:
    @echo "▶️ Running data pipeline: {{pipeline}}"
    @if [ -f "{{pipeline}}" ]; then \
        python "{{pipeline}}"; \
    else \
        echo "❌ Pipeline not found: {{pipeline}}"; \
    fi

# Run training pipeline with experiment tracking
run-training-pipeline pipeline:
    @echo "🤖 Running training pipeline: {{pipeline}}"
    @if [ -f "{{pipeline}}" ]; then \
        python "{{pipeline}}"; \
    else \
        echo "❌ Pipeline not found: {{pipeline}}"; \
    fi

# Run evaluation pipeline
run-evaluation-pipeline model_path test_data:
    @echo "📊 Running evaluation pipeline"
    @python .justscripts/run-evaluation-pipeline.py {{model_path}} {{test_data}}

# === Nextflow Workflows ===

# Run Nextflow hello example
run-nf-hello:
    nextflow run hello

# Run Nextflow data processing workflow
run-nf-data-pipeline:
    @echo "🔄 Running Nextflow data pipeline"
    @if [ -f "{{workflows_dir}}/nextflow/data-pipeline.nf" ]; then \
        nextflow run "{{workflows_dir}}/nextflow/data-pipeline.nf"; \
    else \
        echo "❌ Nextflow data pipeline not found"; \
    fi

# Run Nextflow ML pipeline
run-nf-ml-pipeline:
    @echo "🔄 Running Nextflow ML pipeline"
    @if [ -f "{{workflows_dir}}/nextflow/ml-pipeline.nf" ]; then \
        nextflow run "{{workflows_dir}}/nextflow/ml-pipeline.nf"; \
    else \
        echo "❌ Nextflow ML pipeline not found"; \
    fi

# === DVC Pipelines ===

# Initialize DVC pipeline
init-dvc:
    @echo "📦 Initializing DVC pipeline"
    @dvc init --no-scm 2>/dev/null || echo "DVC already initialized"
    @dvc dag || echo "No DVC pipeline found"

# Run DVC pipeline
run-dvc:
    @echo "📦 Running DVC pipeline"
    @dvc repro

# === Pipeline Management ===

# List all pipelines
list:
    @echo "📋 All Pipelines:"
    @find . -name "*.py" -o -name "*.nf" | grep -E "(pipeline|workflow)" | sort

# List recent pipelines
list-recent:
    @echo "📋 Recent Pipelines (last 7 days):"
    @find . -name "*.py" -o -name "*.nf" -mtime -7 | sort

# Validate pipeline
validate-pipeline pipeline:
    @echo "✅ Validating pipeline: {{pipeline}}"
    @if [[ "{{pipeline}}" == *.py ]]; then \
        python -m py_compile "{{pipeline}}" && echo "✅ Python syntax valid"; \
    elif [[ "{{pipeline}}" == *.nf ]]; then \
        nextflow validate "{{pipeline}}" 2>/dev/null && echo "✅ Nextflow syntax valid" || echo "⚠️ Nextflow validation failed"; \
    fi

# === Experiment Integration ===

# Log pipeline experiment to org file
log-experiment pipeline_name description result:
    #!/usr/bin/env bash
    ts={{timestamp}}
    exp_id="${ts}_{{pipeline_name}}"
    stage="pipelines"
    
    # Ensure experiment log exists
    if [ ! -f {{EXPERIMENTS_LOG}} ]; then
        cat > {{EXPERIMENTS_LOG}} << EOF
#+TITLE: Pipeline Experiments Log
#+AUTHOR: {{pipeline_name}}
#+STARTUP: showall

| Experiment ID | Stage | Author | Date/Time (UTC) | Description | Key Result/Metric |
|---------------|-------|--------|-----------------|-------------|-------------------|
EOF
    fi
    
    echo "| $exp_id | $stage | abhi18av | $ts | {{description}} | {{result}} |" >> {{EXPERIMENTS_LOG}}
    echo "📝 Logged pipeline experiment: $exp_id"

# === Setup and Utilities ===

# Setup pipeline directories
setup:
    @mkdir -p {{templates_dir}} {{workflows_dir}}/nextflow {{workflows_dir}}/dvc {{workflows_dir}}/prefect {{configs_dir}}
    @echo "📁 Created pipeline directory structure"
    @echo "📝 Directory structure:"
    @echo "  {{templates_dir}} - Pipeline templates"
    @echo "  {{workflows_dir}}/nextflow - Nextflow workflows"
    @echo "  {{workflows_dir}}/dvc - DVC pipelines"
    @echo "  {{workflows_dir}}/prefect - Prefect workflows"
    @echo "  {{configs_dir}} - Configuration files"

# Clean pipeline outputs
clean:
    @echo "🧹 Cleaning pipeline outputs..."
    @find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    @find . -name "*.pyc" -delete 2>/dev/null || true
    @find . -name ".nextflow*" -exec rm -rf {} + 2>/dev/null || true
    @echo "✅ Pipeline cleanup completed"

# Generate pipeline statistics
stats:
    #!/usr/bin/env bash
    echo "📊 Pipeline Statistics:"
    echo "======================"
    python_pipelines=$(find . -name "*.py" | grep -E "(pipeline|workflow)" | wc -l)
    nextflow_pipelines=$(find . -name "*.nf" | wc -l)
    total_pipelines=$((python_pipelines + nextflow_pipelines))
    
    echo "Total pipelines: $total_pipelines"
    echo "Python pipelines: $python_pipelines"
    echo "Nextflow pipelines: $nextflow_pipelines"
    
    if command -v dvc &> /dev/null; then
        echo "DVC pipeline status:"
        dvc status 2>/dev/null || echo "  No DVC pipeline found"
    fi
