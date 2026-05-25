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
