# r-dev.just — R development tasks
# Planted by: just grow lang:r
#
# Requires: R + renv  (activate with: pixi run -e r-analysis R)
# Or use system R if pixi is not installed.

R_CMD := env_var_or_default("R_CMD", "pixi run -e r-analysis Rscript")
R_INTERACTIVE := env_var_or_default("R_INTERACTIVE", "pixi run -e r-analysis R")

# ─── Environment ──────────────────────────────────────────────────────────────

# Initialise renv in the project root (first-time setup)
r-init:
    #!/usr/bin/env bash
    {{R_CMD}} -e "renv::init()"
    echo "✅ renv initialised. Lockfile: renv.lock"

# Install packages from renv.lock (restore after clone)
r-restore:
    #!/usr/bin/env bash
    {{R_CMD}} -e "renv::restore()"
    echo "✅ renv restored from renv.lock"

# Update renv.lock to match currently installed packages
r-snapshot:
    #!/usr/bin/env bash
    {{R_CMD}} -e "renv::snapshot()"
    echo "✅ renv.lock updated"

# Open interactive R console
r-console:
    {{R_INTERACTIVE}}

# ─── Analysis ─────────────────────────────────────────────────────────────────

# Run the main analysis script
r-analysis:
    {{R_CMD}} src/R/analysis.R

# Run a specific R script (usage: just r-run scripts/r/my-script.R)
r-run script:
    {{R_CMD}} "{{script}}"

# Render a Quarto document using R (usage: just r-render notebooks/analysis.qmd)
r-render file:
    quarto render "{{file}}" --to html

# ─── Package development ──────────────────────────────────────────────────────

# Create a new R package in packages/<name>
r-create-package name description="Research R library":
    #!/usr/bin/env bash
    pkg_dir="packages/r/{{name}}"
    mkdir -p "${pkg_dir}"
    cd "${pkg_dir}"
    {{R_CMD}} -e "usethis::create_package('.', open = FALSE)"
    echo "📦 R package scaffold created: ${pkg_dir}"
    echo "   Run: cd ${pkg_dir} && {{R_INTERACTIVE}}"

# Test an R package in packages/<name>
r-test-package name:
    #!/usr/bin/env bash
    cd "packages/r/{{name}}"
    {{R_CMD}} -e "devtools::test()"

# Build an R package in packages/<name>
r-build-package name:
    #!/usr/bin/env bash
    cd "packages/r/{{name}}"
    {{R_CMD}} -e "devtools::build()"

# Check an R package (CRAN-style check)
r-check-package name:
    #!/usr/bin/env bash
    cd "packages/r/{{name}}"
    {{R_CMD}} -e "devtools::check()"

# ─── Quality ──────────────────────────────────────────────────────────────────

# Lint R scripts with lintr
r-lint dir="src/R":
    #!/usr/bin/env bash
    {{R_CMD}} -e "lintr::lint_dir('{{dir}}')"

# Format R scripts with styler
r-format dir="src/R":
    #!/usr/bin/env bash
    {{R_CMD}} -e "styler::style_dir('{{dir}}')"

# ─── Doctor ───────────────────────────────────────────────────────────────────

# Check R environment health
r-doctor:
    #!/usr/bin/env bash
    echo "🔍 R environment check:"
    command -v Rscript &>/dev/null && echo "  ✅ Rscript: $(Rscript --version 2>&1)" || echo "  ❌ Rscript not found"
    {{R_CMD}} -e "renv::status()" 2>/dev/null && echo "  ✅ renv status OK" || echo "  ⚠️  renv not initialised — run: just r-init"
    [ -f renv.lock ] && echo "  ✅ renv.lock present" || echo "  ⚠️  renv.lock missing — run: just r-snapshot"
