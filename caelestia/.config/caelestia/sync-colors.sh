#!/usr/bin/env bash
set -euo pipefail

# Matugen expands ~ in output paths, but not XDG environment variables.
scheme_dir="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia"
install -Dm644 "$HOME/.cache/matugen/caelestia.json" "$scheme_dir/scheme.json"
