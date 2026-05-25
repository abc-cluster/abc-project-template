# tasks/garden.just — recipes that drive the seed-bank manager.
#
# Imported by the top-level justfile. Provides:
#   just garden                      status (planted vs dormant)
#   just garden-list [planted|dormant]
#   just garden-show <id>
#   just grow <id>                   plant a component or preset:<name>
#   just prune <id>                  archive a planted component back to dormant
#
# The actual logic lives in `.garden/garden.py` so it stays language-portable
# and works without external Python dependencies.

GARDEN_PY := justfile_directory() / ".garden" / "garden.py"

# Default — show status. `just garden` from the project root.
[no-cd]
garden *args:
    @python3 {{GARDEN_PY}} status {{args}}

# List components (all | planted | dormant)
[no-cd]
garden-list filter="all":
    @python3 {{GARDEN_PY}} list {{filter}}

# Show details for a specific component
[no-cd]
garden-show id:
    @python3 {{GARDEN_PY}} show {{id}}

# Plant a component or a preset (preset:<name>)
[no-cd]
grow id:
    @python3 {{GARDEN_PY}} grow {{id}}

# Remove a planted component (archive a copy under .garden/dormant-history/)
[no-cd]
prune id *flags:
    @python3 {{GARDEN_PY}} prune {{flags}} {{id}}

# Plant defaults_for_project_type[<chosen>] from manifest. Run after scaffolding
# OR when re-cloning a project to get the planted set back. Idempotent.
[no-cd]
replant *flags:
    @python3 {{GARDEN_PY}} replant {{flags}}
