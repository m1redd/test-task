#!/usr/bin/env bash
#
# PostToolUse hook: auto-format files after Edit/Write with prettier.
# Skips node_modules, dist, .git, and deleted files.
#

set -euo pipefail

# Read tool input from stdin
INPUT=$(cat)

# Extract file_path from the tool input JSON
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit if no file path found
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Skip directories that should never be formatted
case "$FILE_PATH" in
  */node_modules/*|*/dist/*|*/.git/*) exit 0 ;;
esac

# Skip if file was deleted
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Run prettier on the file (ignore-unknown handles non-formattable files)
npx prettier --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true

exit 0
