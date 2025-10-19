# Justfile Update Pattern for Cross-Platform Support

## Overview
This document provides the standard pattern for adding cross-platform shell support to all justfiles in the template project.

## Core Pattern

### 1. Add Shell Detection Variables (at top of file)

```just
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
```

### 2. Convert Script Invocations

#### Before:
```just
some-command:
    ./scripts/my-script.sh
```

#### After:
```just
some-command:
    {{SHELL_CMD}} ./scripts/my-script.{{SCRIPT_EXT}}
```

### 3. Handle Inline Bash Scripts

#### Option A: Keep as Bash (recommended for complex scripts)
```just
complex-task:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Complex logic"
    if [ -f "file" ]; then
        cat file
    fi
```

#### Option B: Make Cross-Platform (for simple commands)
```just
simple-task:
    @echo "This works in both"
    @test -f file && cat file || echo "No file"
```

#### Option C: Create separate recipes for each shell (when necessary)
```just
task: _task-impl

[unix]
_task-impl:
    bash -c 'unix-specific-command'

[windows]
_task-impl:
    pwsh -c 'windows-specific-command'
```

### 4. Add Shell Info Command (optional but recommended)

```just
# Show current shell configuration
show-shell:
    @echo "Shell Type: {{SHELL_TYPE}}"
    @echo "Script Ext: {{SCRIPT_EXT}}"
    @echo "Shell Cmd:  {{SHELL_CMD}}"
```

## Common Patterns by Justfile Type

### Analysis Justfiles
```just
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }

# Example: Run analysis script
run-analysis:
    {{SHELL_CMD}} ./scripts/analysis.{{SCRIPT_EXT}}

# Example: Setup environment
setup:
    {{SHELL_CMD}} ./infrastructure/setup.{{SCRIPT_EXT}}
```

### Writeup Justfiles
```just
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }

# Example: Generate manuscript
generate:
    {{SHELL_CMD}} ./scripts/generate.{{SCRIPT_EXT}}
```

### Pipeline Justfiles
```just
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }

# Already updated in nextflow/pipeline-lifecycle.just
# Use as reference for other pipeline justfiles
```

## Commands That Don't Need Changes

These are already cross-platform and work as-is:
- `uv` commands: `uv sync`, `uv run`, etc.
- `python3` / `python` commands
- `quarto` commands
- `docker` commands
- `git` commands
- `just` commands
- Most CLI tools that are cross-platform

## Commands That Need Wrapper Scripts

These should be wrapped in shell scripts (both .sh and .ps1 versions):
- Complex `sed`/`awk` operations
- File operations using shell-specific syntax
- Environment variable manipulation
- Conditional logic based on file existence
- Multiple command pipelines

## Testing Checklist

For each updated justfile:
- [ ] Add shell detection variables
- [ ] Update all script invocations to use `{{SHELL_CMD}}` and `{{SCRIPT_EXT}}`
- [ ] Ensure PowerShell version of scripts exist
- [ ] Test with `SHELL_TYPE=bash just <command>`
- [ ] Test with `SHELL_TYPE=powershell just <command>`
- [ ] Verify backward compatibility (default behavior unchanged)

## Priority Order for Updates

1. **Core** (HIGH priority):
   - expansion.just
   - analysis/analysis.just  
   - writeup/writeup.just

2. **Analysis** (MEDIUM priority):
   - analysis/pipelines/nextflow/* (already done)
   - analysis/scripts/scripts.just
   - analysis/infrastructure/environments.just
   - analysis/notebooks/notebooks.just

3. **Writeup** (MEDIUM priority):
   - writeup/manuscript/manuscript.just
   - writeup/presentation/presentation.just
   - writeup/grants/grants.just

4. **Language Packages** (LOW priority):
   - analysis/packages/justfiles/*.just (17 files)

## Example: Complete Justfile Update

### Before:
```just
# old.just
install:
    pip install -r requirements.txt

run-script:
    ./scripts/process.sh

setup:
    #!/usr/bin/env bash
    if [ ! -d ".venv" ]; then
        python -m venv .venv
    fi
```

### After:
```just
# new.just
# Shell Platform Selection
SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }

# No change needed - pip is cross-platform
install:
    pip install -r requirements.txt

# Updated to use shell variables
run-script:
    {{SHELL_CMD}} ./scripts/process.{{SCRIPT_EXT}}

# Keep as bash for complex logic (or extract to script)
setup:
    #!/usr/bin/env bash
    if [ ! -d ".venv" ]; then
        python -m venv .venv
    fi

# Add shell info (optional)
show-shell:
    @echo "Shell: {{SHELL_TYPE}}"
    @echo "Command: {{SHELL_CMD}}"
```

## Notes
- Always test both shell modes after updates
- Document any platform-specific quirks
- Keep Bash scripts as fallback for Unix-heavy operations
- PowerShell scripts should work on Windows, macOS, and Linux (PowerShell Core 7+)
