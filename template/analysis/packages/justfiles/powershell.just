# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# PowerShell Module Development Automation
# Placeholder justfile

# Create a new PowerShell module
create-powershell-module name description="Research PowerShell module":
    #!/usr/bin/env bash
    echo "📦 Creating PowerShell module: {{name}}"
