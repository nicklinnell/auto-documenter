# Architecture Overview

## Purpose

The auto-documenter plugin is a contextual memory system for Claude Code that creates and maintains project documentation through intelligent, auto-activating skills that work across all Claude platforms (Apps, API, and Code). It automatically injects relevant context before code changes, making documentation feel seamless rather than a separate task.

## Core Components

### 1. Skills System (CORE)

**The heart of auto-documenter v2.0** - Intelligent, auto-activating documentation workflows that replace manual command invocation:

- **`initialising-documentation`** - Bootstraps documentation structure in new projects
- **`documenting-features`** - Documents specific features with context and gotchas
- **`reviewing-documentation`** - Audits documentation coverage and identifies gaps
- **`maintaining-index`** - Maintains the central documentation index
- **`creating-skills`** - Creates new Claude skills with proper structure

**Key Characteristics**:
- **Progressive Loading**: 3-layer architecture (Metadata ~100 tokens, Instructions <5k tokens, Resources 0 tokens until used)
- **Auto-Activation**: Claude recognizes documentation moments naturally based on skill descriptions
- **Bundled Resources**: Each skill can include templates and scripts in its directory
- **Cross-Platform**: Works in Claude Apps, API, and Code

See: [Skills System documentation](.knowledge/features/skills-system.md:14)

### 2. Agent System

Specialized AI agents that perform focused tasks:

- **`@doc-manager`** - Maintains `.knowledge/README.md` index by scanning documentation files and generating organised summaries
- **`@doc-reader`** - Reads documentation and reports back with comprehensive, detailed information
- **`@code-context-extractor`** - Extracts imports, exports, functions, dependencies, and architectural patterns from code
- **`@skill-documenter`** - Documents skills and their usage patterns in the project documentation system

**Integration**: Skills invoke agents for complex operations (e.g., documenting-features uses @code-context-extractor, then @skill-documenter)

See: [Index Management](.knowledge/features/index-management.md:47), [Doc Reader Agent](.knowledge/features/doc-reader-agent.md:15)

### 3. Hook System

Automated hooks that integrate documentation into the development workflow:

- **PreToolUse Hook** - Injects relevant documentation before Edit/Write operations
  - Searches `.knowledge/README.md` index for files being edited
  - Loads only relevant documentation (not entire directories)
  - Provides context about design decisions and gotchas

- **PostToolUse Hook** - Reminds developers to update documentation after changes
  - Detects when documented files are modified
  - Suggests appropriate documentation update workflows
  - Skips trivial files (.json, .lock, etc.)

See: [Hook System documentation](.knowledge/features/hook-system.md:16)

### 4. Index Management

The `.knowledge/README.md` serves as a smart map of all project documentation:

- **File-to-Documentation Mapping**: Maps source files to their documentation
- **Feature Summaries**: 1-2 sentence summaries of all documented features
- **Organised Sections**: Features, Architecture, Gotchas, Decisions, Planning Sessions
- **Efficient Loading**: Hooks use index to load only relevant docs, not everything

**Maintained by**: `@doc-manager` agent and `maintaining-index` skill

See: [Index Management documentation](.knowledge/features/index-management.md:20)

### 5. Plugin Configuration

Configuration files that define the plugin structure:

- **`.claude-plugin/marketplace.json`** - Plugin manifest and metadata (v2.0.1)
- **`hooks/hooks.json`** - Hook definitions and tool matchers
- **`skills/*/SKILL.md`** - Skill definitions with YAML frontmatter
- **`agents/*.md`** - Agent definitions with YAML frontmatter

**Note**: v2.0 moved from command-first to skills-first architecture. Legacy commands still supported for backward compatibility.

## Design Principles

1. **Auto-Activation Over Manual Commands** - Skills activate naturally when Claude recognizes documentation moments
2. **Minimal Context** - Only inject documentation that's relevant to the current operation
3. **Progressive Loading** - Unused bundled content costs zero tokens
4. **Living Documentation** - Documentation evolves with the codebase
5. **Feature-Focused** - Document features/capabilities, not individual files
6. **"Why" Over "What"** - Capture design decisions and gotchas, not just code behaviour
7. **Cross-Platform Compatibility** - Works across Claude Apps, API, and Code

## Architecture Evolution

### v1.x: Command-First
- Manual slash commands: `/doc-init`, `/doc-feature`, etc.
- User had to remember when and how to document
- Commands loaded all instructions upfront

### v2.0: Skills-First
- Auto-activating skills with progressive loading
- Claude recognizes documentation moments naturally
- Bundled resources (templates, scripts) cost zero tokens until used
- Commands still work for backward compatibility

## Data Flow

### Documentation Creation Flow
```
User implements feature
    ↓
Claude recognizes documentation moment
    ↓
documenting-features skill activates
    ↓
Skill invokes @code-context-extractor
    ↓
Context gathered from codebase
    ↓
Feature documentation created
    ↓
@doc-manager updates index
    ↓
Documentation ready for future use
```

### Context Injection Flow
```
User edits file
    ↓
PreToolUse Hook triggered
    ↓
Hook searches .knowledge/README.md index
    ↓
Relevant documentation identified
    ↓
Documentation injected into context
    ↓
Claude proceeds with informed changes
    ↓
PostToolUse Hook suggests doc updates
```

## Technology Stack

- **Bash Scripts** - Hook implementation and skill helper scripts
- **Markdown** - Documentation format, skill definitions, agent definitions
- **YAML Frontmatter** - Metadata for skills and agents
- **JSON** - Plugin configuration files
- **JQ** - JSON parsing in hook scripts
- **Git** - Change detection and version control
- **Grep/AWK** - Text processing in hooks and scripts

## Key Files

### Plugin Configuration
- `.claude-plugin/marketplace.json` - Plugin manifest (v2.0.1)
- `hooks/hooks.json` - Hook configuration

### Skills (5 total)
- `skills/initialising-documentation/SKILL.md` - Documentation structure bootstrap
- `skills/documenting-features/SKILL.md` - Feature documentation
- `skills/reviewing-documentation/SKILL.md` - Coverage auditing
- `skills/maintaining-index/SKILL.md` - Index maintenance
- `skills/creating-skills/SKILL.md` - Skill creation

### Agents (4 total)
- `agents/doc-manager.md` - Index maintenance agent
- `agents/doc-reader.md` - Documentation reading agent
- `agents/code-context-extractor.md` - Code analysis agent
- `agents/skill-documenter.md` - Skill documentation agent

### Hooks (2 total)
- `hooks/pre-tool-use.sh` - Context injection before edits
- `hooks/post-tool-use.sh` - Documentation reminders after edits

### Documentation Structure
```
.knowledge/
├── README.md              # Central index (maintained by @doc-manager)
├── features/              # Feature documentation
├── architecture/          # Architecture documentation
├── gotchas/               # Known issues and gotchas
├── decisions/             # Architecture Decision Records (ADRs)
└── plans/                 # Planning sessions
```

## Component Interactions

**Skills ↔ Agents**:
- Skills invoke agents for complex operations
- Example: `documenting-features` → `@code-context-extractor` → `@skill-documenter` → `@doc-manager`

**Hooks ↔ Index**:
- PreToolUse hook reads `.knowledge/README.md` to find relevant docs
- PostToolUse hook checks index to suggest updates

**Agents ↔ Index**:
- `@doc-manager` maintains and updates the index
- `@doc-reader` uses index to discover documentation

**Skills ↔ Templates/Scripts**:
- Skills bundle templates and scripts in their directories
- Progressive loading: only loaded when actually used

---

*Created: 2025-10-10*
*Last updated: 2025-10-23*
*Architecture version: v2.0 (skills-first)*
