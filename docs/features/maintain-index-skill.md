# Feature: maintain-index Skill

## Overview

The `maintain-index` skill automatically keeps the central documentation index (docs/README.md) current by scanning all documentation files and updating mappings, summaries, and links. It eliminates the need to manually invoke `@doc-manager` or remember to update the index after documentation changes.

**Why it exists**: Documentation indexes quickly become stale as docs are added, modified, or removed. Manual index maintenance is tedious and error-prone. Auto-activation ensures the index is always current, making documentation discoverable and useful.

## Implementation Details

### Key Files

- `skills/maintain-index/SKILL.md` - Skill definition and index maintenance workflow
- `skills/maintain-index/scripts/index-validator.sh` - Bash script for validating index consistency, checking for broken links and missing sections

### How It Works

**Activation Triggers**:
- Documentation files are created or modified
- User mentions "update the index", "sync docs", "refresh documentation index"
- After using `document-feature` or `document-codebase` skills
- When documentation seems out of sync with the index

**Index Maintenance Process**:
1. **Scan All Documentation**: Glob for all .md files in docs/ subdirectories
2. **Extract Metadata**: Parse titles, overviews, key files, dates from each doc
3. **Build File Mappings**: Map source files to their documentation
4. **Update Index Sections**:
   - File-to-Documentation Mapping
   - Feature Documentation with summaries
   - Architecture Documentation
   - Gotchas & Important Notes
   - Key Decisions (ADRs)
   - Planning Sessions
5. **Validate Structure**: Run index-validator.sh to check consistency
6. **Invoke @doc-manager**: Delegate actual Edit operations to the agent
7. **Report Status**: Inform user of files scanned, sections updated, issues found

**Validation Script** (`index-validator.sh`):
Checks for:
- Required sections present in index
- Broken documentation links
- Orphaned documentation files (docs not referenced in index)
- Missing "Last updated" timestamp
- Returns exit code 0 (always) to avoid breaking workflows

### Dependencies

**Internal**:
- `@doc-manager` agent - Performs actual index Edit operations
- `@doc-reader` agent - Can read existing docs for context
- Validation script (`scripts/index-validator.sh`)

**External**:
- bash (for script execution)
- grep/awk (for parsing markdown)
- find (for discovering files)

**Tools Used**:
- Read - Read documentation files to extract information
- Grep - Search for specific patterns in docs
- Glob - Find all documentation files
- Edit - Update the docs/README.md index
- Write - Create new index if it doesn't exist

### Configuration

**Skill Frontmatter**:
```yaml
name: maintain-index
description: Keep the documentation index current by scanning all documentation files and updating docs/README.md. Use after documentation is created/modified, or when user mentions "update the index", "sync docs", or "refresh documentation index".
```

**Index Validator Usage**:
```bash
./skills/maintain-index/scripts/index-validator.sh .

# Output:
# - Checks for required sections
# - Validates documentation links
# - Identifies orphaned files
# - Verifies timestamp present
# - Exit code always 0 (non-blocking)
```

## Important Notes & Gotchas

### ⚠️ Critical Points

- **Always Scan Actual Files**: Never rely on memory or cache - read the actual documentation
- **Update Timestamp**: Always update "Last updated" date in the index
- **Broken Links**: Report but don't fail on broken links (docs might be WIP)
- **Invoke @doc-manager**: This skill coordinates work but delegates to the agent for execution
- **File-to-Doc Mapping First**: The mapping section is most frequently used, so it should be first

### 🐛 Known Issues

- Validator script uses basename matching only (not full paths)
- No detection of duplicate documentation for the same files
- No validation of documentation quality or completeness
- Doesn't suggest documentation for undocumented files
- AWK parsing can be fragile with non-standard markdown

### 🔄 Future Improvements

- Add full path matching in validator (not just basenames)
- Detect duplicate/conflicting documentation
- Calculate and display documentation coverage metrics
- Suggest features that need documentation updates
- Add markdown linting to validation
- Support custom index templates
- Generate documentation coverage reports

## Testing

**Manual Testing**:
```bash
# Test natural language activation
You: "Make sure the docs index is up to date"
Claude: [maintain-index skill should activate]

# Test script directly
./skills/maintain-index/scripts/index-validator.sh .

# Expected output:
# - ✓ Section found: Quick Reference
# - ✓ Section found: File-to-Documentation Mapping
# - etc.

# Create a new feature doc and test index update
/doc-feature test-feature
# Then verify docs/README.md includes test-feature

# Test broken link detection
# 1. Add fake link to docs/README.md
# 2. Run validator
# 3. Should report broken link
```

**Validation Checklist**:
- [ ] All documentation files discovered via Glob
- [ ] Index sections updated correctly
- [ ] File-to-documentation mappings accurate
- [ ] Broken links reported but not blocking
- [ ] Orphaned files identified
- [ ] "Last updated" timestamp current
- [ ] @doc-manager invoked for actual edits

**Validator Script Tests**:
```bash
# Test validator finds all required sections
./skills/maintain-index/scripts/index-validator.sh .

# Test with missing section (should warn)
# Edit docs/README.md, remove a section, run validator

# Test with broken link (should detect)
# Add bad link to index, run validator

# Test with orphaned doc (should identify)
# Create doc file, don't add to index, run validator
```

## Related Documentation

- [Skills System](./skills-system.md) - Overall skills architecture
- [doc-manager Agent](./doc-manager-agent.md) - Agent that performs index maintenance
- [Index Management](./index-management.md) - How the central index works
- [Command System](./command-system.md) - How skills complement commands

---
*Created: 2025-10-17*
*Last updated: 2025-10-17*
