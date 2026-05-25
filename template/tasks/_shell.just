# tasks/_shell.just — shared cross-platform shell detection.
#
# Imported once by the top-level justfile. Defines:
#   SHELL_TYPE   "bash" or "powershell"   (default: "powershell" on Windows, "bash" elsewhere)
#   SCRIPT_EXT   "sh" or "ps1"            (auto-derived from SHELL_TYPE)
#   SHELL_CMD    "bash" or "pwsh"         (auto-derived from SHELL_TYPE)
#
# To force a specific shell: `SHELL_TYPE=powershell just <recipe>`
#
# Recipe convention (Phase 4+):
#   - For trivial recipes, write inline (works everywhere via just's shell handling)
#   - For non-trivial recipes, dispatch to scripts/<area>/<recipe>.{{SCRIPT_EXT}}
#   - For paired recipes, prefer explicit `xyz` / `xyz-pwsh` / `xyz-bash` naming
#     over auto-detection — easier to debug and CI test both shells

SHELL_TYPE := env_var_or_default('SHELL_TYPE', if os() == "windows" { "powershell" } else { "bash" })
SCRIPT_EXT := if SHELL_TYPE == "powershell" { "ps1" } else { "sh" }
SHELL_CMD := if SHELL_TYPE == "powershell" { "pwsh" } else { "bash" }
