#!/usr/bin/env bash
# Launch fish with project-specific config

FISH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.fish" && pwd)"
export XDG_CONFIG_HOME="$FISH_DIR"
export fish_history="$FISH_DIR/history"

exec fish --init-command "source $FISH_DIR/config.fish"
