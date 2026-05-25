
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# CLI Tools Development Automation
# Placeholder justfile

# Create a new CLI tool
create-cli-tool name description="Research CLI tool":
    #!/usr/bin/env bash
    echo "📦 Creating CLI tool: {{name}}"
