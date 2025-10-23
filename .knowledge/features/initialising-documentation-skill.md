# Feature: initialising-documentation Skill

## Overview

The `initialising-documentation` skill automatically initialises comprehensive documentation structure for projects. It recognizes when a project lacks documentation and creates the complete `.knowledge/` hierarchy with templates and guidance, eliminating the need to manually run `/doc-init`.

**Why it exists**: Setting up documentation structure is often deferred because it feels like overhead. By auto-activating when starting new projects or when users mention "initialise docs", the skill makes documentation setup frictionless and ensures consistency across all projects.

## Implementation Details

### Key Files

- `skills/initialising-documentation/SKILL.md` - Skill definition and initialisation workflow
- `skills/initialising-documentation/templates/index-template.md` - Template for .knowledge/README.md central index
- `skills/initialising-documentation/templates/structure-schema.json` - JSON schema defining standard directory layout

### How It Works

**Activation Triggers**:
- User starts working on a project without a `.knowledge/` directory
- User mentions "initialise docs", "setup documentation", "create docs structure"
- User wants to restructure or reorganise existing documentation
- Claude detects a project lacks proper documentation

**Initialisation Process**:
1. **Assess Current State**: Check if .knowledge/ exists, what existing docs are present
2. **Create Directory Structure**:
   ```
   .knowledge/
   ├── README.md           # Central index
   ├── features/           # Feature documentation
   ├── architecture/       # System design
   ├── gotchas/           # Critical warnings
   ├── decisions/         # Architecture Decision Records
   └── plans/             # Planning sessions
   ```
3. **Create Central Index**: Generate .knowledge/README.md using index-template.md
4. **Create Architecture Overview**: Initial .knowledge/architecture/overview.md
5. **Add Git Tracking**: .gitkeep files in empty directories
6. **Inform User**: Explain structure and suggest next steps

**Directory Purposes**:
- **features/**: Document specific features, how they work, key files
- **architecture/**: System design, patterns, architectural choices
- **gotchas/**: Critical warnings, edge cases, "do not change" items
- **decisions/**: ADRs explaining WHY choices were made
- **plans/**: Saved planning sessions for future reference

### Dependencies

**Internal**:
- `@doc-manager` agent - Can be invoked after initialisation to verify index
- Index template (`templates/index-template.md`)
- Structure schema (`templates/structure-schema.json`)

**External**:
- bash (for creating directories and .gitkeep files)

**Tools Used**:
- Write - Create new documentation files and directories
- Bash - Create directory structure and .gitkeep files
- Read - Check for existing documentation
- Glob - Scan for existing doc files

### Configuration

**Skill Frontmatter**:
```yaml
name: initialising-documentation
description: Initialise or restructure project documentation system. Use when starting a new project, when user mentions "initialise docs", "setup documentation", "create docs structure", or when a project has no .knowledge/ directory.
```

**Structure Schema** (`structure-schema.json`):
Defines standard layout with:
- Directory paths and purposes
- File naming conventions
- Required files per directory
- Template associations

**Index Template** (`index-template.md`):
Provides standard structure for .knowledge/README.md with:
- Quick Reference section
- Documentation Structure overview
- File-to-Documentation Mapping (auto-populated)
- Placeholder sections for each doc type

## Important Notes & Gotchas

### ⚠️ Critical Points

- **Check Before Creating**: Always verify .knowledge/ doesn't already exist to avoid overwriting
- **Preserve Existing Content**: If docs exist, ask user before restructuring
- **Git Tracking**: .gitkeep files ensure empty directories are committed to git
- **Initial Architecture Doc**: Keep .knowledge/architecture/overview.md high-level and expandable
- **Index is Central**: The .knowledge/README.md is the map - it must be discoverable and accurate

### 🐛 Known Issues

- No migration tool for converting existing documentation to standard structure
- Doesn't detect non-standard doc locations (e.g., wiki/, documentation/)
- No validation that user has git installed before creating .gitkeep files
- Doesn't suggest what to document first based on codebase analysis

### 🔄 Future Improvements

- Add migration tool for existing documentation
- Detect and preserve non-standard doc locations
- Analyse codebase to suggest initial features to document
- Create initial .knowledge/architecture/overview.md with actual project structure analysis
- Support custom directory structures via configuration
- Add skill to restructure existing documentation

## Testing

**Manual Testing**:
```bash
# Test natural language activation
You: "Let's setup documentation for this project"
Claude: [initialising-documentation skill should activate]

# Verify structure
ls -R .knowledge/
# Should show: README.md, features/, architecture/, gotchas/, decisions/, plans/

# Verify .gitkeep files
find docs -name .gitkeep

# Verify templates used
cat .knowledge/README.md  # Should match index-template.md structure
cat .knowledge/architecture/overview.md  # Should exist with basic structure
```

**Validation Checklist**:
- [ ] .knowledge/ directory created
- [ ] All 5 subdirectories present (features, architecture, gotchas, decisions, plans)
- [ ] .knowledge/README.md exists and uses template structure
- [ ] .knowledge/architecture/overview.md exists
- [ ] .gitkeep files in empty directories
- [ ] Timestamps are current dates
- [ ] No existing documentation was overwritten

## Related Documentation

- [Skills System](./skills-system.md) - Overall skills architecture
- [Index Management](./index-management.md) - How the central index works
- [Command System](./command-system.md) - How skills complement /doc-init command
- [Architecture Plan](../plans/skills-architecture-v2.md) - Original design thinking

---
*Created: 2025-10-17*
*Last updated: 2025-10-17*
