---
description: "[DEPRECATED] Document a specific feature with context and gotchas. Use the document-feature skill instead (just say 'document this feature')"
allowed-tools: Write, Read, Grep, Glob, Edit
---

⚠️ **DEPRECATION NOTICE**: This command is deprecated in favour of the `document-feature` skill which activates automatically. Instead of `/doc-feature <name>`, simply say "document the {name} feature" and the skill will activate.

**Migration:** See MIGRATION.md for details on moving to skills-based workflows.

---

You are documenting a feature for the auto-documentation system. The feature name is: **$1**

Follow these steps:

1. **Gather Context**:
   - Search the codebase for files related to this feature
   - Use Grep and Glob to find relevant code
   - Understand the implementation

2. **Create Feature Documentation** at `docs/features/$1.md` with this structure:

```markdown
# Feature: $1

## Overview
[Brief description of what this feature does and why it exists]

## Implementation Details

### Key Files
- `path/to/file.ts` - [What this file does]
- `path/to/another.ts` - [What this file does]

### How It Works
[Step-by-step explanation of the feature's implementation]

### Dependencies
- [External libraries or other features this depends on]

### Configuration
[Any configuration options, environment variables, or settings]

## Important Notes & Gotchas

### ⚠️ Critical Points
- [Things that should NOT be changed]
- [Edge cases to be aware of]
- [Performance considerations]

### 🐛 Known Issues
- [Any known bugs or limitations]

### 🔄 Future Improvements
- [Potential enhancements or refactoring opportunities]

## Testing
- [How to test this feature]
- [Location of tests]

## Related Documentation
- [Links to related architecture docs or other features]

---
*Created: {date}*
*Last updated: {date}*
```

3. **Update the Index**:
   - Read `docs/README.md`
   - Add this feature to the "Feature Documentation" section
   - Update the "File-to-Documentation Mapping" section with the key files
   - Update the last modified date

4. **Extract Gotchas**:
   - If there are critical warnings or "do not change" items, also create/update a gotcha file at `docs/gotchas/$1-gotchas.md`

5. **Confirm**: Tell the user what was documented and where the files are located

**Important**:
- Be thorough but concise
- Focus on the "why" not just the "what"
- Highlight anything that future developers (or Claude) should know before modifying this code
