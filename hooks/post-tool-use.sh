#!/bin/bash

# PostToolUse hook for auto-documenter
# This script reminds the user to update documentation after significant changes

# Parse the tool name and input
TOOL_NAME="$TOOL_NAME"
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

# Only proceed for Edit/Write operations
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "MultiEdit" ]]; then
    exit 0
fi

# Skip if no file_path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Skip documentation files themselves
if [[ "$FILE_PATH" == docs/* ]]; then
    exit 0
fi

# Skip config and trivial files
if [[ "$FILE_PATH" == *.json ]] || [[ "$FILE_PATH" == *.md ]] || [[ "$FILE_PATH" == *package.json ]] || [[ "$FILE_PATH" == *.lock ]]; then
    exit 0
fi

# Check if docs system is initialised
if [ ! -f "docs/README.md" ]; then
    exit 0
fi

# Check if this file is already documented
if grep -q "$(basename "$FILE_PATH")" "docs/README.md" 2>/dev/null; then
    # File is documented - gentle reminder to update if needed
    echo ""
    echo "💡 **Documentation Tip**: \`$FILE_PATH\` has existing documentation. If this change is significant, consider running:"
    echo "   \`/doc-update\` to refresh the documentation"
    echo ""
else
    # File is not documented - suggest documenting it
    echo ""
    echo "📝 **Documentation Reminder**: \`$FILE_PATH\` isn't documented yet. If this is a significant feature or change, consider:"
    echo "   \`/doc-feature <feature-name>\` to document this feature"
    echo "   \`/doc-review\` to see overall documentation coverage"
    echo ""
fi

exit 0
