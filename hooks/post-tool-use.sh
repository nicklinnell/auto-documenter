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
if [[ "$FILE_PATH" == .knowledge/* ]]; then
    exit 0
fi

# Skip config and trivial files
if [[ "$FILE_PATH" == *.json ]] || [[ "$FILE_PATH" == *.md ]] || [[ "$FILE_PATH" == *package.json ]] || [[ "$FILE_PATH" == *.lock ]]; then
    exit 0
fi

# Check if .knowledge system is initialised
if [ ! -f ".knowledge/README.md" ]; then
    exit 0
fi

# Check if this file is already documented
if grep -q "$(basename "$FILE_PATH")" ".knowledge/README.md" 2>/dev/null; then
    # File is documented - less noisy, trust skills will activate
    echo ""
    echo "💡 **Tip**: \`$FILE_PATH\` has documentation. The \`maintain-index\` skill will keep it current automatically."
    echo ""
else
    # File is not documented - suggest skills that can help
    echo ""
    echo "📝 **Documentation**: \`$FILE_PATH\` isn't documented yet. Skills can help:"
    echo "   • Say \"document this feature\" to activate the \`document-feature\` skill"
    echo "   • Run \`/doc-review\` to see overall coverage"
    echo ""
fi

exit 0
