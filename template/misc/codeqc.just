# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# format and sort imports
format:
  uv run ruff check --fix --select=I001 .
  uv run ruff format .

# autofix with ruff
autofix:
  uv run ruff --fix --show-fixes .

# lint with ruff
lint:
  uv run ruff check --output-format=full .

# check for typos
typos:
  uv run typos .

add-license:
  licenseheaders -t .LICENSE.template  --settings .licenseheaders.json
