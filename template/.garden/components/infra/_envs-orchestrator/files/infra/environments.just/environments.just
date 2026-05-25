# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# === Environment Management ===

# Install dependencies
install:
    {% if programming_language == "Python" or programming_language == "Both" %}
    pixi install
    {% endif %}
    {% if programming_language == "R" or programming_language == "Both" %}
    Rscript -e "renv::restore()"
    {% endif %}
