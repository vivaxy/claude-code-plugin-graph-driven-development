#!/usr/bin/env bash
# build-templates.sh — assembles a Cadence session template from fragment files.
#
# Usage:
#   build-templates.sh <type> <dest>
#
# <type> is one of: trivial, feature-dev, bugfix, analysis
# <dest> is the output path (e.g. <project>/.claude/sessions/<folder>/session.md)
#
# Environment:
#   CLAUDE_PLUGIN_ROOT or CURSOR_PLUGIN_ROOT — plugin root directory.
#   When neither is set, the script infers the root from its own location (templates/../).

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: build-templates.sh <type> <dest>" >&2
  echo "  type: trivial | feature-dev | bugfix | analysis" >&2
  echo "  dest: output path (e.g. <project>/.claude/sessions/<folder>/session.md)" >&2
  exit 1
fi

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${CURSOR_PLUGIN_ROOT:-}}"

if [ -z "$PLUGIN_ROOT" ]; then
  # Fall back to the directory containing this script's parent (templates/ → plugin root)
  SCRIPT_DIR="$( cd "$(dirname "$0")" && pwd )"
  PLUGIN_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
fi

FRAGMENTS_DIR="$PLUGIN_ROOT/templates/fragments"

type="$1"
dest="$2"
recipe="$FRAGMENTS_DIR/recipe-${type}.txt"

if [ ! -f "$recipe" ]; then
  echo "Error: recipe file not found: $recipe" >&2
  exit 1
fi

> "$dest"
while IFS= read -r fragment || [ -n "$fragment" ]; do
  [ -z "$fragment" ] && continue
  frag_path="$FRAGMENTS_DIR/$fragment"
  if [ ! -f "$frag_path" ]; then
    echo "Error: fragment file not found: $frag_path" >&2
    exit 1
  fi
  cat "$frag_path" >> "$dest"
done < "$recipe"

echo "Built: $dest"
