# Feature: document-feature Skill

## Overview

The `document-feature` skill automatically creates comprehensive feature documentation when users implement or modify features. It eliminates the need to manually invoke `/doc-feature` by recognizing documentation moments through natural language.

**Why it exists**: Feature documentation should be created immediately after implementation while context is fresh. Manual commands create friction and are often forgotten. Auto-activation ensures documentation happens naturally as part of the development workflow.

## Implementation Details

### Key Files

- `skills/document-feature/SKILL.md` - Skill definition and workflow instructions
- `skills/document-feature/templates/feature-template.md` - Standard feature documentation template
- `skills/document-feature/scripts/extract-context.sh` - Bash script for extracting code context (imports, exports, functions, TODOs)

### How It Works

**Activation Triggers**:
- User implements or modifies a feature
- User mentions "document this feature" or "add docs for [feature name]"
- After significant code changes that introduce new functionality
- When preparing code for review or handoff

**Documentation Process**:
1. **Gather Context**: Search codebase for related files using Grep/Glob
2. **Extract Code Details**: Use extract-context.sh to parse imports, exports, functions
3. **Create Documentation**: Generate docs/features/{feature-name}.md using template
4. **Invoke @doc-manager**: Update docs/README.md index automatically
5. **Extract Gotchas**: Create docs/gotchas/{feature-name}-gotchas.md if critical warnings exist
6. **Confirm Completion**: Report what was documented and where

**Template Structure**:
The skill uses a standard template with sections for:
- Overview (what & why)
- Key Files (which files implement this feature)
- How It Works (step-by-step implementation details)
- Dependencies (external libraries, internal features)
- Configuration (env vars, settings)
- Gotchas (critical points, known issues, future improvements)
- Testing (how to test, test locations)
- Related Documentation (links to architecture docs)

### Dependencies

**Internal**:
- `@doc-manager` agent - Updates the documentation index
- `@doc-reader` agent - Reads existing documentation for context
- Feature template (`templates/feature-template.md`)
- Code extraction script (`scripts/extract-context.sh`)

**External**:
- bash (for script execution)
- grep/awk (for code parsing in extract-context.sh)

**Tools Used**:
- Read - Read files to understand implementation
- Grep - Search for patterns and related code
- Glob - Find files by pattern
- Write - Create new documentation files
- Edit - Update existing documentation

### Configuration

**Skill Frontmatter**:
```yaml
name: document-feature
description: Document a specific feature with context, implementation details, and gotchas. Use when the user implements or modifies a feature, or mentions "document this feature" or "add docs for [feature name]".
```

**Extract Context Script Usage**:
```bash
./skills/document-feature/scripts/extract-context.sh path/to/file.ts

# Output sections:
# === Imports ===
# === Exports ===
# === Key Functions/Classes ===
# === TODOs/FIXMEs ===
```

## Important Notes & Gotchas

### ⚠️ Critical Points

- **Focus on "Why" not "What"**: Documentation should explain design decisions, not just repeat what the code does
- **Template is Guidance**: The template should be adapted to the feature, not followed rigidly
- **Gotchas are Critical**: Separate gotcha files should only be created for truly critical warnings
- **Date Timestamps**: Always include creation and last updated dates
- **Invoke @doc-manager**: Must invoke the agent to update the index after creating docs

### 🐛 Known Issues

- extract-context.sh only works for JavaScript/TypeScript files (grep-based, not AST parsing)
- Script doesn't handle complex import syntax (dynamic imports, re-exports)
- No validation that key files mentioned actually exist
- Doesn't detect circular dependencies or architectural issues

### 🔄 Future Improvements

- Add AST-based code parsing for more accurate context extraction
- Support more languages (Python, Go, Rust, etc.)
- Validate that key files exist and are accessible
- Auto-detect dependencies by parsing imports
- Generate test file suggestions based on feature files
- Link to related PRs or commits for historical context

## Testing

**Manual Testing**:
```bash
# Test natural language activation
You: "I've built authentication, let's document it"
Claude: [document-feature skill should activate]

# Test explicit command still works
/doc-feature authentication

# Test script directly
./skills/document-feature/scripts/extract-context.sh src/auth/login.ts
```

**Validation Checklist**:
- [ ] Feature doc created in docs/features/
- [ ] Uses standard template structure
- [ ] Includes all key sections (Overview, Implementation, Gotchas)
- [ ] Timestamps are current dates
- [ ] Index updated by @doc-manager
- [ ] Gotcha file created if critical warnings exist

## Related Documentation

- [Skills System](./skills-system.md) - Overall skills architecture
- [Index Management](./index-management.md) - How @doc-manager maintains the index
- [Command System](./command-system.md) - How skills complement /doc-feature command

---
*Created: 2025-10-17*
*Last updated: 2025-10-17*
