
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# Clojure Package Development Automation
# Placeholder justfile

# Create a new Clojure package
create-clojure-package name description="Research Clojure library":
    #!/usr/bin/env bash
    echo "📦 Creating Clojure package: {{name}}"
