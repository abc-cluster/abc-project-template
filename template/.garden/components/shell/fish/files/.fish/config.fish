# fish/config.fish for project-specific Fish shell setup

# Source global fish config if it exists (merge global and project configs)
if test -f ~/.config/fish/config.fish
    source ~/.config/fish/config.fish
end

# Set project-specific environment variable for starship
set -gx PROJECT_NAME "your_project"

# Point Starship to the project-specific configuration
set -gx STARSHIP_CONFIG (dirname (status --current-filename))/starship.toml

# Initialize Starship prompt for fish
starship init fish | source

# Source project-specific aliases and functions
if test -f (dirname (status --current-filename))/aliases.fish
    source (dirname (status --current-filename))/aliases.fish
end

for f in (dirname (status --current-filename))/functions/*.fish
    source $f
end

# Use project-specific fish history
set -gx fish_history (dirname (status --current-filename))/history
