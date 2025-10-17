#!/usr/bin/env bash
# coverage-analysis.sh
# Analyses documentation coverage and generates a report

set -euo pipefail

PROJECT_ROOT="${1:-.}"
DOCS_DIR="${PROJECT_ROOT}/docs"

# Colours for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

echo "Analysing documentation coverage..."
echo ""

# Count source files (excluding common ignore patterns)
echo "${BLUE}📊 Scanning codebase...${NC}"
TOTAL_FILES=$(find "${PROJECT_ROOT}" \
    -type f \
    \( -name "*.ts" -o -name "*.js" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) \
    -not -path "*/node_modules/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -path "*/.git/*" \
    -not -path "*/coverage/*" \
    -not -path "*/__pycache__/*" \
    | wc -l | tr -d ' ')

echo "Total source files: ${TOTAL_FILES}"

# Count documentation files
if [[ ! -d "$DOCS_DIR" ]]; then
    echo "${YELLOW}⚠  No docs/ directory found${NC}"
    echo "Coverage: 0%"
    echo ""
    echo "Recommendation: Run document-codebase skill to initialise documentation"
    exit 0
fi

DOC_FILES=$(find "${DOCS_DIR}" -name "*.md" -not -name "README.md" | wc -l | tr -d ' ')
echo "Documentation files: ${DOC_FILES}"
echo ""

# Calculate coverage (rough estimate)
# This is a simplified metric - actual coverage requires parsing docs for file mentions
if [[ $TOTAL_FILES -gt 0 ]]; then
    # Rough heuristic: assume each doc covers ~5 files on average
    ESTIMATED_COVERED=$((DOC_FILES * 5))
    if [[ $ESTIMATED_COVERED -gt $TOTAL_FILES ]]; then
        ESTIMATED_COVERED=$TOTAL_FILES
    fi
    COVERAGE=$((ESTIMATED_COVERED * 100 / TOTAL_FILES))
else
    COVERAGE=0
fi

echo "${BLUE}📈 Documentation Coverage${NC}"
echo "Estimated coverage: ${COVERAGE}%"
echo ""

# Coverage quality assessment
if [[ $COVERAGE -ge 70 ]]; then
    echo "${GREEN}✓ Excellent coverage${NC}"
elif [[ $COVERAGE -ge 40 ]]; then
    echo "${YELLOW}⚠ Moderate coverage - consider documenting more critical features${NC}"
else
    echo "${YELLOW}⚠ Low coverage - prioritise documenting core features${NC}"
fi

echo ""

# List documented features
echo "${BLUE}📝 Documented Features${NC}"
if [[ -d "${DOCS_DIR}/features" ]]; then
    FEATURE_COUNT=$(find "${DOCS_DIR}/features" -name "*.md" | wc -l | tr -d ' ')
    echo "Feature docs: ${FEATURE_COUNT}"
    find "${DOCS_DIR}/features" -name "*.md" -exec basename {} .md \; | sed 's/^/  - /'
else
    echo "No features/ directory"
fi

echo ""

# List architecture docs
echo "${BLUE}🏗️  Architecture Documentation${NC}"
if [[ -d "${DOCS_DIR}/architecture" ]]; then
    ARCH_COUNT=$(find "${DOCS_DIR}/architecture" -name "*.md" | wc -l | tr -d ' ')
    echo "Architecture docs: ${ARCH_COUNT}"
    find "${DOCS_DIR}/architecture" -name "*.md" -exec basename {} .md \; | sed 's/^/  - /'
else
    echo "No architecture/ directory"
fi

echo ""

# List gotchas
echo "${BLUE}⚠️  Gotchas & Warnings${NC}"
if [[ -d "${DOCS_DIR}/gotchas" ]]; then
    GOTCHA_COUNT=$(find "${DOCS_DIR}/gotchas" -name "*.md" | wc -l | tr -d ' ')
    if [[ $GOTCHA_COUNT -gt 0 ]]; then
        echo "Gotcha docs: ${GOTCHA_COUNT}"
        find "${DOCS_DIR}/gotchas" -name "*.md" -exec basename {} .md \; | sed 's/^/  - /'
    else
        echo "No gotcha files (consider documenting critical warnings)"
    fi
else
    echo "No gotchas/ directory"
fi

echo ""

# Check for stale documentation (>6 months old)
echo "${BLUE}🕒 Stale Documentation Check${NC}"
SIX_MONTHS_AGO=$(date -v-6m +%Y-%m-%d 2>/dev/null || date -d "6 months ago" +%Y-%m-%d 2>/dev/null || echo "2024-01-01")
STALE_DOCS=$(find "${DOCS_DIR}" -name "*.md" -type f -mtime +180 2>/dev/null | wc -l | tr -d ' ')

if [[ $STALE_DOCS -gt 0 ]]; then
    echo "${YELLOW}⚠ Found ${STALE_DOCS} documentation file(s) older than 6 months${NC}"
    echo "Consider reviewing these for accuracy:"
    find "${DOCS_DIR}" -name "*.md" -type f -mtime +180 -exec ls -lh {} \; 2>/dev/null | awk '{print "  - " $NF " (modified: " $6 " " $7 ")"}'
else
    echo "${GREEN}✓ All documentation is recent (<6 months old)${NC}"
fi

echo ""
echo "================================"
echo "${GREEN}Coverage analysis complete${NC}"
echo ""
echo "Next steps:"
echo "  1. Review undocumented critical features"
echo "  2. Update stale documentation"
echo "  3. Use document-feature skill for new docs"
echo "  4. Run maintain-index skill to update the index"

exit 0
