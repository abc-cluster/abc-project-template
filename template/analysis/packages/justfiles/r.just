# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
# R Package Development Automation
# Tools for creating, testing, and building R research libraries

# Create a new R package
create-r-package name description="Research R library":
    #!/usr/bin/env bash
    echo "📦 Creating R package: {{name}}"
    # Implementation would go here

# Test an R package
test-r package:
    #!/usr/bin/env bash
    echo "🧪 Testing R package: {{package}}"
    # Implementation would go here
