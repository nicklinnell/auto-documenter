# Auto-Documenter Plugin for Claude Code

An intelligent documentation system that creates contextual memory for Claude Code, helping it understand your project's design decisions, features, and important implementation details before making changes.

## 🎯 Purpose

This plugin solves a critical problem: Claude Code needs context about **why** things were built a certain way, not just **what** the code does. Auto-Documenter creates a living memory system that:

- Documents features with their rationale and gotchas
- Automatically surfaces relevant documentation before code changes
- Maintains a searchable index of all project knowledge
- Reminds you to update documentation as code evolves

## 🚀 Quick Start

### Installation

```bash
# Install from GitHub
/plugin marketplace add https://github.com/nicklinnell/auto-documenter.git
/plugin install auto-documenter
```

### Initialise in Your Project

```bash
/doc-init
```

This creates a `docs/` directory with:
- `README.md` - Central index and file mappings
- `features/` - Feature documentation
- `architecture/` - Design decisions
- `gotchas/` - Critical warnings
- `decisions/` - ADRs (Architecture Decision Records)
- `plans/` - Saved planning sessions from plan mode

## 📚 Commands

### `/doc-init`
Initialises the documentation structure in your project. Run this once per project.

### `/doc-feature <feature-name>`
Creates comprehensive documentation for a specific feature:
- Automatically searches codebase for related files
- Documents implementation details
- Captures gotchas and critical points
- Updates the central index

**Example:**
```bash
/doc-feature authentication
/doc-feature user-dashboard
```

### `/doc-update`
Scans recent changes and updates relevant documentation:
- Checks git history for modified files
- Identifies affected documentation
- Updates file mappings
- Suggests new documentation needs

**Example:**
```bash
# After making changes
git add .
/doc-update
```

### `/doc-review`
Audits documentation coverage and identifies gaps:
- Analyses codebase structure
- Reports well-documented vs undocumented areas
- Prioritises documentation needs
- Suggests improvements

**Example:**
```bash
/doc-review
```

### `/doc-plan <plan-name>`
Saves a planning session to the `docs/plans/` directory:
- Preserves design thinking and planning sessions
- Date-stamps files for chronological tracking
- Provides historical context for future decisions
- Tracks implementation status

**Example:**
```bash
/doc-plan user-auth-redesign
/doc-plan api-performance-optimization
/doc-plan database-migration-v2
```

## 🤖 Automatic Features

### Smart Context Injection (PreToolUse Hook)

**Before** Claude Code edits or writes a file, the plugin:
1. Checks if `docs/README.md` exists
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

The `docs/README.md` file acts as a smart index:
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
3. **Keep it Current**: Run `/doc-update` after significant changes
4. **Review Regularly**: Run `/doc-review` periodically to catch gaps
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
/doc-update
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

```bash
# 1. Start a new project
/doc-init

# 2. Plan a feature (in plan mode)
# ... create plan ...
/doc-plan user-authentication

# 3. Build the feature
# ... write code ...

# 4. Document the implementation
/doc-feature user-authentication

# 5. Make changes later
# Claude Code automatically reads the auth docs before editing
# ... Claude makes safe changes ...

# 6. Update documentation
/doc-update

# 7. Periodic review
/doc-review
```

## 🐛 Troubleshooting

**Hook not triggering?**
- Check that `docs/README.md` exists
- Verify hooks are enabled in `.claude/settings.json`
- Ensure hook scripts are executable (`chmod +x hooks/*.sh`)

**Documentation not found?**
- Run `@doc-manager` to regenerate the index
- Check that feature docs are in `docs/features/`
- Verify file paths in documentation match actual files

## 📄 License

MIT

## 🤝 Contributing

Contributions welcome! This plugin is designed to be extended and customised for your team's needs.

---

**Built for Claude Code** | Making AI pair programming context-aware
