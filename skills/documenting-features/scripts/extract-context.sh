#!/usr/bin/env bash
# extract-context.sh
# Helper script to extract code context for documentation

set -euo pipefail

# Usage: extract-context.sh <file_path>
# Extracts imports, exports, and key functions from a file

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" ]]; then
    echo "Usage: extract-context.sh <file_path>" >&2
    exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File not found: $FILE_PATH" >&2
    exit 1
fi

echo "=== Imports ==="
grep -E "^import |^const .* = require\(" "$FILE_PATH" 2>/dev/null || echo "(none)"

echo ""
echo "=== Exports ==="
grep -E "^export |^module\.exports" "$FILE_PATH" 2>/dev/null || echo "(none)"

echo ""
echo "=== Key Functions/Classes ==="
grep -E "^(export )?(async )?(function|class|const|let) " "$FILE_PATH" 2>/dev/null || echo "(none)"

echo ""
echo "=== TODOs/FIXMEs ==="
grep -E "TODO|FIXME|XXX|HACK" "$FILE_PATH" 2>/dev/null || echo "(none)"
