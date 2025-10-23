# Auto-Documenter Plugin for Claude Code

An intelligent documentation system with **Skills** that creates contextual memory for Claude Code, helping it understand your project's design decisions, features, and important implementation details before making changes.

## ⭐ What's New in v2.0

**Skills-First Architecture**: Auto-Documenter now includes intelligent skills that automatically activate when needed:

- 🎯 **Smart Auto-Activation**: Claude recognizes when to document features without explicit commands
- 🔄 **Cross-Platform**: Skills work in Claude Apps, Claude Code, and the API
- 📦 **Bundled Tools**: Each skill includes templates, scripts, and best practices
- ⚡ **Token Efficient**: Progressive loading keeps context minimal

## 🎯 Purpose

This plugin solves a critical problem: Claude Code needs context about **why** things were built a certain way, not just **what** the code does. Auto-Documenter creates a living memory system that:

- Documents features with their rationale and gotchas using intelligent skills
- Automatically surfaces relevant documentation before code changes
- Maintains a searchable index of all project knowledge
- Reminds you to update documentation as code evolves
- Provides reusable documentation workflows across all your projects

## 🚀 Quick Start

### Installation

```bash
# Install from GitHub
/plugin marketplace add https://github.com/nicklinnell/auto-documenter.git
/plugin install auto-documenter
```

### Initialise in Your Project

Simply ask Claude to initialise documentation, and the `initialising-documentation` skill will activate automatically:

```
"Let's setup documentation for this project"
```

This creates a `.knowledge/` directory with:
- `README.md` - Central index and file mappings
- `features/` - Feature documentation
- `architecture/` - Design decisions
- `gotchas/` - Critical warnings
- `decisions/` - ADRs (Architecture Decision Records)
- `plans/` - Saved planning sessions from plan mode

## ✨ Skills (New in v2.0)

Skills are intelligent workflows that automatically activate when relevant. You don't need to remember commands - just work naturally!

### `documenting-features`
**Auto-activates when**: You implement/modify a feature, or say "document this feature"

Creates comprehensive feature documentation:
- Searches codebase for related files
- Documents implementation details with context
- Captures gotchas and critical points
- Updates the central index automatically
- Includes bundled template and code extraction script

**Natural usage:**
```
You: "I've just built the authentication system, let's document it"
Claude: [documenting-features skill activates automatically]
```

### `initialising-documentation`
**Auto-activates when**: New project, or you mention "initialise docs" or "setup documentation"

Initialises comprehensive documentation structure:
- Creates .knowledge/ directory with standard layout
- Sets up central index (.knowledge/README.md)
- Creates initial architecture overview
- Includes bundled templates and schema

**Natural usage:**
```
You: "Let's setup documentation for this project"
Claude: [initialising-documentation skill activates automatically]
```

### `maintaining-index`
**Auto-activates when**: Documentation is created/modified, or you say "update the index"

Keeps documentation index current:
- Scans all documentation files
- Updates file-to-documentation mappings
- Validates links and structure
- Includes index validation script

**Natural usage:**
```
You: "Make sure the docs index is up to date"
Claude: [maintaining-index skill activates automatically]
```

## 📚 Commands

### `/doc-plan <plan-name>` - Save Planning Sessions

The only remaining command - use this to explicitly save planning sessions to `.knowledge/plans/`.

**Example:**
```bash
/doc-plan user-auth-redesign
/doc-plan api-performance-optimization
```

**Why this command remains:** Planning sessions are explicitly saved artifacts that work better as commands than auto-activating skills. All other documentation workflows are now handled by skills.

---

### ℹ️ Migrating from v1.x Commands?

All documentation commands have been replaced by auto-activating skills:

| Old Command (v1.x) | New Approach (v2.0) | Natural Language |
|-------------------|---------------------|------------------|
| `/doc-init` | `initialising-documentation` skill | "initialise docs" |
| `/doc-feature <name>` | `documenting-features` skill | "document the <name> feature" |
| `/doc-update` | `maintaining-index` skill | "update the docs" |
| `/doc-review` | `reviewing-documentation` skill | "review the docs" |

**See [MIGRATION.md](./MIGRATION.md) for detailed migration examples.**

## 🤖 Automatic Features

### Smart Context Injection (PreToolUse Hook)

**Before** Claude Code edits or writes a file, the plugin:
1. Checks if `.knowledge/README.md` exists
2. Searches the index for relevant documentation
3. Injects only the pertinent sections into Claude's context
4. Keeps context minimal for efficiency

This ensures Claude Code **always** reviews important gotchas and design decisions before making changes.

### Documentation Reminders (PostToolUse Hook)

**After** significant code changes, the plugin:
- Reminds you to update documentation if the file is already documented
- Suggests creating documentation for new, undocumented features
- Stays quiet for trivial files (configs, locks, etc.)

## 🏗️ How It Works

### The Index System

The `.knowledge/README.md` file acts as a smart index:
- **File-to-Documentation Mapping**: Maps source files to their docs
- **Quick Summaries**: One-line summaries of each documented feature
- **Minimal Context**: Only loads relevant docs, not the entire directory

### The doc-manager Agent

A specialised agent (`@doc-manager`) maintains the index:
- Scans all documentation files
- Extracts file mappings and summaries
- Keeps the README organised and up-to-date
- Identifies broken links or missing docs

Invoke it manually after bulk documentation changes:
```bash
@doc-manager regenerate the documentation index
```

## 📖 Documentation Structure

Each feature document follows this template:

```markdown
# Feature: [Name]

## Overview
What this feature does and why it exists

## Implementation Details
### Key Files
### How It Works
### Dependencies
### Configuration

## Important Notes & Gotchas
### ⚠️ Critical Points
### 🐛 Known Issues
### 🔄 Future Improvements

## Testing

## Related Documentation
```

This structure ensures:
- Quick scanning via the Overview section
- Critical information is highlighted
- Future maintainers understand the "why"

## 🎯 Best Practices

1. **Document Features, Not Files**: Focus on features/capabilities, not individual files
2. **Capture the "Why"**: Explain decisions, trade-offs, and gotchas
3. **Keep it Current**: Ask Claude to "update the docs" after significant changes (activates `maintaining-index` skill)
4. **Review Regularly**: Ask Claude to "review the docs" periodically to catch gaps (activates `reviewing-documentation` skill)
5. **Use the Index**: The README is your map - keep it accurate

## 🔧 Advanced Usage

### Customising Hooks

The hook scripts are in `hooks/`. You can modify them to:
- Change which files trigger documentation checks
- Customise the context injection format
- Add project-specific logic

### Integrating with Git Workflows

Add to your commit process:
```bash
git add .
# Ask Claude: "update the docs index"
git commit -m "feat: new feature with updated docs"
```

### Team Distribution

To share this plugin with your team, they can install directly from GitHub:

```bash
/plugin marketplace add https://github.com/nicklinnell/auto-documenter.git
/plugin install auto-documenter
```

## 🤔 Why This Matters

Without contextual memory:
- Claude Code might remove "magic numbers" that are actually critical
- Refactoring could break carefully designed patterns
- Important performance optimisations get lost
- Edge case handling gets simplified away

With Auto-Documenter:
- ✅ Claude Code reads gotchas before editing
- ✅ Design rationale is preserved
- ✅ New team members understand the "why"
- ✅ Code evolves without losing context

## 📝 Example Workflow

### With Skills (v2.0 - Natural Language)

```
# 1. Start a new project
You: "Let's setup documentation for this project"
Claude: [initialising-documentation skill activates]

# 2. Build a feature
You: [write code for authentication]

# 3. Document naturally
You: "I've built the authentication system, let's document it"
Claude: [documenting-features skill activates]

# 4. Make changes later
You: [edit auth files]
Claude: [Reads auth docs automatically before editing]

# 5. Update documentation
You: "Make sure the docs are current"
Claude: [maintaining-index skill activates]

# 6. Periodic review
You: "Review the documentation"
Claude: [reviewing-documentation skill activates]
```

### With Commands (v1.x - Explicit)

```bash
# 1. Start a new project
/doc-init

# 2. Plan a feature (in plan mode)
/doc-plan user-authentication

# 3. Build the feature
# ... write code ...

# 4. Document the implementation
/doc-feature user-authentication

# 5. Make changes later
# Claude Code automatically reads the auth docs before editing

# 6. Update documentation
/doc-update

# 7. Periodic review
/doc-review
```

## 🐛 Troubleshooting

**Hook not triggering?**
- Check that `.knowledge/README.md` exists
- Verify hooks are enabled in `.claude/settings.json`
- Ensure hook scripts are executable (`chmod +x hooks/*.sh`)

**Documentation not found?**
- Run `@doc-manager` to regenerate the index
- Check that feature docs are in `.knowledge/features/`
- Verify file paths in documentation match actual files

## 📄 License

MIT

## 🤝 Contributing

Contributions welcome! This plugin is designed to be extended and customised for your team's needs.

---

**Built for Claude Code** | Making AI pair programming context-aware
