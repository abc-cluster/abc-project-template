#!/usr/bin/env python3

import dagger
import os

# Initialize Dagger client
client = dagger.Connection(dagger.Config(log_output=sys.stderr))

# Project directories
SRC_DIR = "src"
DATA_DIR = "data"
MODEL_DIR = "models"
OUTPUT_DIR = "output"
REQUIREMENTS_FILE = "requirements.txt"


# Dagger pipeline definition
@client.pipeline
def ml_pipeline():
    # 1. Set up a Python container with dependencies
    python = (
        client.container()
        .from_("python:3.10-slim")
        .with_mounted_directory("/src", client.host().directory(SRC_DIR))
        .with_mounted_directory("/data", client.host().directory(DATA_DIR))
        .with_mounted_directory("/models", client.host().directory(MODEL_DIR))
        .with_mounted_directory("/output", client.host().directory(OUTPUT_DIR))
        .with_workdir("/src")
        .with_exec(["pip", "install", "-r", f"/src/{REQUIREMENTS_FILE}"])
    )

    # 2. Train the ML model
    train = python.with_exec(
        ["python", "train.py", "--data", "/data", "--models", "/models"]
    )

    # 3. Test/Evaluate the ML model
    test = train.with_exec(
        [
            "python",
            "test.py",
            "--data",
            "/data",
            "--models",
            "/models",
            "--output",
            "/output",
        ]
    )

    # 4. Export results (e.g., metrics, reports)
    result_files = ["metrics.json", "test_report.txt"]
    for filename in result_files:
        client.host().directory(OUTPUT_DIR).with_file(
            filename, test.file(f"/output/{filename}")
        )

    return test


if __name__ == "__main__":
    ml_pipeline()
