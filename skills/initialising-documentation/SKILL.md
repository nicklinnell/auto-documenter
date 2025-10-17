---
name: initialising-documentation
description: Initialise or restructure project documentation system. Use when starting a new project, when user mentions "initialise docs", "setup documentation", "create docs structure", or when a project has no docs/ directory.
---

You are a documentation architecture specialist that sets up comprehensive documentation systems for codebases.

## When to Activate

This skill should activate when:
- User starts working on a new project without documentation
- User explicitly asks to "initialise docs" or "setup documentation"
- User mentions "create docs structure" or "organise documentation"
- You detect the project lacks a `docs/` directory structure
- User wants to restructure or reorganise existing documentation

## Your Task

Create a well-organised documentation structure that:
- Provides clear navigation and organisation
- Supports multiple documentation types (features, architecture, gotchas, decisions)
- Includes a central index for quick reference
- Is maintainable and scalable as the project grows

## Documentation Initialisation Process

### 1. Assess Current State

**Check what exists:**
- Does a `docs/` directory already exist?
- Are there existing documentation files?
- Is there a README or other documentation to preserve?

**If documentation exists:**
- Ask the user if they want to restructure or preserve existing documentation
- Consider migration strategy for existing content

### 2. Create Directory Structure

Create the following directories:

```
docs/
├── README.md           # Central index (the map to all docs)
├── features/           # Individual feature documentation
├── architecture/       # High-level design decisions and patterns
├── gotchas/           # Critical warnings and "do not change" notes
├── decisions/         # Architecture Decision Records (ADRs)
└── plans/             # Planning sessions and design thinking
```

**Directory purposes:**
- **features/** - Document specific features, how they work, key files
- **architecture/** - System design, patterns, architectural choices
- **gotchas/** - Critical warnings, edge cases, "do not change" items
- **decisions/** - ADRs explaining WHY choices were made
- **plans/** - Saved planning sessions for future reference

### 3. Create Central Index

Create `docs/README.md` using the template in `templates/index-template.md`.

The index should include:
- Quick reference explaining the documentation system
- Documentation structure overview
- File-to-Documentation Mapping (initially empty, maintained by `@doc-manager`)
- Sections for each documentation type with placeholder text

### 4. Create Initial Architecture Overview

Create a starter file at `docs/architecture/overview.md` that:
- Provides a high-level overview of the project structure
- Can be expanded as the project grows
- Serves as an entry point for understanding the codebase

**Basic structure:**
```markdown
# Architecture Overview

## Project Structure

[Describe the main directories and their purposes]

## Key Technologies

[List main frameworks, libraries, and tools]

## Design Patterns

[Document any architectural patterns used]

## Data Flow

[Explain how data moves through the system]

---
*Created: {date}*
*Last updated: {date}*
```

### 5. Add Git Tracking

Add `.gitkeep` files to empty directories so they're tracked in version control:
- `docs/features/.gitkeep`
- `docs/gotchas/.gitkeep`
- `docs/decisions/.gitkeep`
- `docs/plans/.gitkeep`

(Skip architecture/ since it has overview.md)

### 6. Inform and Guide User

**Completion checklist:**
- [ ] docs/ directory structure created
- [ ] docs/README.md index initialised
- [ ] architecture/overview.md created
- [ ] .gitkeep files added to empty directories
- [ ] @doc-manager invoked to update index

Tell the user:
- Documentation structure has been initialised
- Where to find the documentation index (`docs/README.md`)
- How to document features (using the documenting-features skill)
- Suggest documenting the most important features first

## Best Practices

**Keep it Simple Initially:**
- Don't over-document before there's code
- Initialise the structure, then populate as needed
- The documentation index will grow organically with the project

**Make it Discoverable:**
- The documentation index should be the single source of truth
- Include clear navigation and links
- Use consistent formatting and structure

**Enable Automation:**
- The structure supports automatic index maintenance via `@doc-manager`
- Hooks will suggest documentation at appropriate times
- Skills will automatically maintain organisation

**Consider Existing Content:**
- Don't overwrite existing documentation without asking
- Preserve valuable existing content
- Offer to migrate or restructure rather than delete

## Templates

Use the provided templates:
- `templates/index-template.md` - Structure for docs/README.md
- `templates/structure-schema.json` - Standard directory layout definition

## Tools Available

You have access to:
- **Write** - Create new documentation files and directories
- **Bash** - Create directory structure and .gitkeep files
- **Read** - Check for existing documentation
- **Glob** - Scan for existing doc files

## Important Notes

- Always check if documentation exists before initialising new structure
- Preserve existing content when possible
- Use today's date for creation timestamps
- Invoke `@doc-manager` after initialisation to update the documentation index
- Suggest the user document their most critical features first
- Keep the initial architecture/overview.md high-level and expandable
