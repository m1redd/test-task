#!/usr/bin/env bash
#
# PostToolUse hook (async): runs TypeScript check on written .ts files.
#

set -euo pipefail

# Read tool input from stdin
INPUT=$(cat)

# Extract file_path from the tool input JSON
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit if no file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only check .ts files, skip .spec.ts and .test.ts
case "$FILE_PATH" in
  *.spec.ts|*.test.ts) exit 0 ;;
  *.ts) ;;  # proceed
  *) exit 0 ;;
esac

# Skip if file was deleted
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Run tsc and filter output to the changed file only
BASENAME=$(basename "$FILE_PATH")
TSC_OUTPUT=$(npx tsc --noEmit 2>&1 || true)

# Filter to lines mentioning the changed file
FILTERED=$(echo "$TSC_OUTPUT" | grep "$BASENAME" || true)

if [ -n "$FILTERED" ]; then
  echo "TypeScript errors in $FILE_PATH:"
  echo "$FILTERED"
fi

exit 0
