# Architecture Overview

## Purpose

The auto-documenter plugin is a contextual memory system for Claude Code that creates and maintains project documentation, automatically injecting relevant context before code changes.

## Core Components

### 1. Slash Commands
Five user-facing commands that create and manage documentation:
- `/auto-documenter:doc-init` - Initialises the .knowledge/ structure
- `/auto-documenter:doc-feature` - Documents specific features
- `/auto-documenter:doc-update` - Updates docs after changes
- `/auto-documenter:doc-review` - Audits documentation coverage
- `/auto-documenter:doc-plan` - Saves planning sessions

### 2. Hook System
Automated hooks that integrate documentation into the development workflow:
- **PreToolUse** - Injects relevant documentation before Edit/Write operations
- **PostToolUse** - Reminds developers to update documentation after changes

### 3. Index Management
The `@doc-manager` agent maintains a central index (`.knowledge/README.md`) that:
- Maps source files to their documentation
- Provides quick summaries of all documented features
- Enables efficient context loading (only loads relevant docs, not everything)

### 4. Plugin Configuration
- `plugin.json` - Plugin metadata and component references
- `hooks.json` - Hook definitions and matchers
- Command files (`.md`) - Markdown-based slash command definitions with YAML frontmatter
- Agent files (`.md`) - Markdown-based agent definitions with YAML frontmatter

## Design Principles

1. **Minimal Context** - Only inject documentation that's relevant to the current operation
2. **Automatic Integration** - Hooks ensure documentation is considered without manual effort
3. **Living Documentation** - Documentation evolves with the codebase
4. **Feature-Focused** - Document features/capabilities, not individual files
5. **"Why" Over "What"** - Capture design decisions and gotchas, not just code behaviour

## Data Flow

```
User edits file
    ↓
PreToolUse Hook triggered
    ↓
Check .knowledge/README.md index
    ↓
Find relevant documentation for that file
    ↓
Inject documentation into context
    ↓
Claude Code proceeds with informed changes
    ↓
PostToolUse Hook triggered
    ↓
Remind user to update docs if needed
```

## Technology Stack

- **Shell Scripts** (bash) - Hook implementation
- **Markdown** - Documentation format and command definitions
- **YAML Frontmatter** - Metadata for commands and agents
- **JSON** - Configuration files
- **JQ** - JSON parsing in hook scripts
- **Git** - Change detection for `/auto-documenter:doc-update`

## Key Files

- `plugin.json` - Plugin manifest
- `hooks/pre-tool-use.sh` - Context injection hook
- `hooks/post-tool-use.sh` - Documentation reminder hook
- `hooks/hooks.json` - Hook configuration
- `commands/*.md` - Slash command definitions
- `agents/doc-manager.md` - Index maintenance agent

---

*Created: 2025-10-10*
*Last updated: 2025-10-10*
