#!/usr/bin/env bash
# build-templates.sh — assembles Cadence session templates from fragment files.
#
# Usage:
#   build-templates.sh [<type> [<dest>]]
#
# <type> is one of: trivial, feature-dev, bugfix, analysis
# If omitted, all four types are built into templates/<type>.md.
# <dest> is an optional output path; when provided, output goes there instead of
# the default templates/<type>.md. Only valid when <type> is also specified.
#
# Environment:
#   CLAUDE_PLUGIN_ROOT or CURSOR_PLUGIN_ROOT must be set to the plugin root directory.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${CURSOR_PLUGIN_ROOT:-}}"

if [ -z "$PLUGIN_ROOT" ]; then
  echo "Error: neither CLAUDE_PLUGIN_ROOT nor CURSOR_PLUGIN_ROOT is set." >&2
  exit 1
fi

FRAGMENTS_DIR="$PLUGIN_ROOT/templates/fragments"
TEMPLATES_DIR="$PLUGIN_ROOT/templates"

build_type() {
  local type="$1"
  local dest="${2:-$TEMPLATES_DIR/${type}.md}"
  local recipe="$FRAGMENTS_DIR/recipe-${type}.txt"

  if [ ! -f "$recipe" ]; then
    echo "Error: recipe file not found: $recipe" >&2
    exit 1
  fi

  # Concatenate fragments in recipe order into output file
  > "$dest"
  while IFS= read -r fragment || [ -n "$fragment" ]; do
    # Skip blank lines in recipe
    [ -z "$fragment" ] && continue
    local frag_path="$FRAGMENTS_DIR/$fragment"
    if [ ! -f "$frag_path" ]; then
      echo "Error: fragment file not found: $frag_path" >&2
      exit 1
    fi
    cat "$frag_path" >> "$dest"
  done < "$recipe"

  echo "Built: $dest"
}

TYPES=(trivial feature-dev bugfix analysis)

if [ $# -ge 1 ]; then
  build_type "$1" "${2:-}"
else
  for type in "${TYPES[@]}"; do
    build_type "$type"
  done
fi
