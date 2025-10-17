#!/usr/bin/env bash
# index-validator.sh
# Validates the documentation index for consistency and broken links

set -euo pipefail

PROJECT_ROOT="${1:-.}"
DOCS_DIR="${PROJECT_ROOT}/docs"
INDEX_FILE="${DOCS_DIR}/README.md"

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

if [[ ! -f "$INDEX_FILE" ]]; then
    echo -e "${RED}✗ Index file not found: ${INDEX_FILE}${NC}"
    exit 1
fi

echo "Validating documentation index..."
echo ""

# Track issues
ISSUES=0

# Check for required sections
echo "Checking required sections..."
REQUIRED_SECTIONS=(
    "Quick Reference"
    "Documentation Structure"
    "File-to-Documentation Mapping"
    "Feature Documentation"
    "Architecture Documentation"
    "Gotchas & Important Notes"
    "Key Decisions"
    "Planning Sessions"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "## .*${section}" "$INDEX_FILE"; then
        echo -e "${GREEN}✓${NC} Section found: ${section}"
    else
        echo -e "${RED}✗${NC} Missing section: ${section}"
        ((ISSUES++))
    fi
done

echo ""

# Check for broken links
echo "Checking for broken documentation links..."
BROKEN_LINKS=0

# Extract markdown links from index: [text](./path/to/file.md)
grep -oE '\]\(\.\/[^)]+\.md\)' "$INDEX_FILE" | sed 's/](\.\///' | sed 's/)//' | while read -r link; do
    FULL_PATH="${DOCS_DIR}/${link}"
    if [[ ! -f "$FULL_PATH" ]]; then
        echo -e "${RED}✗${NC} Broken link: ${link}"
        ((BROKEN_LINKS++))
    fi
done

if [[ $BROKEN_LINKS -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} No broken links found"
else
    echo -e "${YELLOW}⚠${NC}  Found ${BROKEN_LINKS} broken links"
    ((ISSUES+=BROKEN_LINKS))
fi

echo ""

# Check for orphaned documentation (docs not referenced in index)
echo "Checking for orphaned documentation files..."
ORPHANED=0

find "$DOCS_DIR" -name "*.md" -not -name "README.md" -not -path "*/\.*" | while read -r doc_file; do
    REL_PATH="${doc_file#$DOCS_DIR/}"
    if ! grep -q "$REL_PATH" "$INDEX_FILE"; then
        echo -e "${YELLOW}⚠${NC}  Orphaned doc (not in index): ${REL_PATH}"
        ((ORPHANED++))
    fi
done

if [[ $ORPHANED -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} No orphaned documentation files"
else
    echo -e "${YELLOW}⚠${NC}  Found ${ORPHANED} orphaned documentation files"
    ((ISSUES+=ORPHANED))
fi

echo ""

# Check last updated timestamp
echo "Checking last updated timestamp..."
if grep -q "Last updated:" "$INDEX_FILE"; then
    LAST_UPDATED=$(grep "Last updated:" "$INDEX_FILE" | tail -1)
    echo -e "${GREEN}✓${NC} Timestamp found: ${LAST_UPDATED}"
else
    echo -e "${YELLOW}⚠${NC}  No 'Last updated' timestamp found"
    ((ISSUES++))
fi

echo ""
echo "================================"

if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✓ Index validation passed${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Found ${ISSUES} issue(s)${NC}"
    echo "Consider running the maintain-index skill to fix these issues"
    exit 0  # Exit 0 so it doesn't break workflows
fi
