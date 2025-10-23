#!/bin/bash

# PreToolUse hook for auto-documenter
# This script reads relevant documentation before Edit/Write operations
# and injects it into Claude's context

# Parse the tool input JSON to get file_path
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')

# Exit if no file_path (not an Edit/Write operation we care about)
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Check if .knowledge/README.md exists
if [ ! -f ".knowledge/README.md" ]; then
    exit 0
fi

# Read the index to find relevant documentation
INDEX_CONTENT=$(cat ".knowledge/README.md")

# Extract documentation files that reference this file path
# This is a simple grep-based approach
RELEVANT_DOCS=$(echo "$INDEX_CONTENT" | grep -i "$(basename "$FILE_PATH")" | grep -oE '\.knowledge/[a-zA-Z0-9_/-]+\.md' | sort -u)

if [ -z "$RELEVANT_DOCS" ]; then
    # No specific documentation found, exit quietly
    exit 0
fi

# Build the context injection message
echo "📚 **Relevant Documentation Found**"
echo ""
echo "Before modifying \`$FILE_PATH\`, please review this documentation:"
echo ""

# Read and display each relevant doc (keeping it concise)
for DOC in $RELEVANT_DOCS; do
    if [ -f "$DOC" ]; then
        echo "### From $DOC:"
        echo ""
        # Extract just the Overview and Important Notes sections to keep context minimal
        awk '
            /^## Overview/,/^## [^O]/ { if (!/^## [^O]/) print }
            /^## Important Notes/,/^## / { if (!/^## [^I]/) print }
            /^### ⚠️ Critical Points/,/^### / { if (!/^### [^⚠]/) print }
        ' "$DOC" | head -50
        echo ""
        echo "*(Full documentation: $DOC)*"
        echo ""
    fi
done

echo "---"
echo ""
echo "✓ Proceed with your changes, keeping the above context in mind."
