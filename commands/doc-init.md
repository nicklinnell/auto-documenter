---
description: "[DEPRECATED] Initialize documentation structure in the current project. Use the document-codebase skill instead (just say 'initialize docs')"
allowed-tools: Write, Bash, Read, Glob
---

⚠️ **DEPRECATION NOTICE**: This command is deprecated in favour of the `document-codebase` skill which activates automatically. Instead of `/doc-init`, simply say "initialise documentation" or "setup docs" and the skill will activate.

**Migration:** See MIGRATION.md for details on moving to skills-based workflows.

---

You are initializing the auto-documentation system for this project. Follow these steps:

1. Create the `docs/` directory structure:
   - `docs/README.md` - The main index file
   - `docs/features/` - Individual feature documentation
   - `docs/architecture/` - High-level design decisions
   - `docs/gotchas/` - Important warnings and things not to change
   - `docs/decisions/` - Architecture Decision Records (ADRs)
   - `docs/plans/` - Planning sessions and design thinking from plan mode

2. Create the initial `docs/README.md` with this structure:

```markdown
# Project Documentation Index

This directory contains contextual documentation that helps Claude Code understand the project's design decisions, features, and important implementation details.

## 📋 Quick Reference

This index is automatically maintained by the `@doc-manager` agent. It maps files and features to their documentation.

## 📁 Documentation Structure

- **features/** - Individual feature documentation
- **architecture/** - High-level system design and patterns
- **gotchas/** - Critical warnings and "do not change" notes
- **decisions/** - Architecture Decision Records (why choices were made)
- **plans/** - Planning sessions and design thinking from plan mode

## 🗂️ File-to-Documentation Mapping

*This section will be automatically populated as documentation is created*

---

## 📝 Feature Documentation

*No features documented yet. Use `/doc-feature <name>` to document a feature.*

---

## 🏗️ Architecture Documentation

*No architecture documentation yet.*

---

## ⚠️ Gotchas & Important Notes

*No gotchas documented yet.*

---

## 🤔 Key Decisions

*No decisions documented yet.*

---

## 💡 Planning Sessions

*No plans saved yet. Use `/doc-plan <name>` to save a planning session.*

---

*Last updated: {current_date}*
```

3. Create a starter architecture overview file at `docs/architecture/overview.md`

4. Add a `.gitkeep` file to empty directories so they're tracked in git

5. Confirm to the user that the documentation system has been initialised and explain how to use it

**Important**: Replace `{current_date}` with today's actual date when creating the README.
