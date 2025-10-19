# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }

# Remove broken imports
import 'pipelines/pipelines.just'
import 'dashboards/dashboards.just'
import "data/data.just"
import "infrastructure/environments.just"
import "infrastructure/infrastructure.just"
import "misc/utils.just"
import "notebooks/notebooks.just"
import "scripts/scripts.just"

# setup for development
setup: install git-setup

# install the packages
install:
  {% raw %}{{if path_exists("uv.lock") != "true" {"uv sync --all-groups --all-extras --inexact"} else {"uv sync --all-groups --all-extras --locked --inexact"} }}{% endraw %}

# ensure code quality before git commit via pre-commit and nbwipers
git-setup: install
  uv run nbwipers install local
  uv run pre-commit install --install-hooks

# run test coverage and create
test-cov:
  uv run pytest --cov {% raw %}{{module_name}}{% endraw %} --cov-report=lcov:lcov.info --cov-report=term-missing --cov-report html --cov-report xml

# update packages and uv lock file
update:
  uv sync -U --all-groups --all-extras --inexact

{% if experiment_tracking != "None" %}
# === Experiment Tracking ===

# Start experiment tracking server
track-start:
    {% if experiment_tracking == "MLflow" %}
    @mlflow ui --port 5000
    {% elif experiment_tracking == "Weights & Biases" %}
    @wandb login
    {% endif %}
{% endif %}

{% if include_deployment_templates %}
# === Deployment ===

# Build Docker image
docker-build:
    @docker build -t {{ project_name|lower|replace(" ", "-") }} .

# Run Docker container
docker-run:
    @docker run -p 8000:8000 {{ project_name|lower|replace(" ", "-") }}
{% endif %}
