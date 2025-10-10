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

### Hook System
- `hooks/hooks.json` → [features/hook-system.md](features/hook-system.md)
- `hooks/pre-tool-use.sh` → [features/hook-system.md](features/hook-system.md)
- `hooks/post-tool-use.sh` → [features/hook-system.md](features/hook-system.md)
- `plugin.json` → [features/hook-system.md](features/hook-system.md)

### Index Management
- `agents/doc-manager.md` → [features/index-management.md](features/index-management.md)
- `docs/README.md` → [features/index-management.md](features/index-management.md)
- `hooks/pre-tool-use.sh:21` → [features/index-management.md](features/index-management.md)
- `commands/doc-feature.md:66` → [features/index-management.md](features/index-management.md)
- `commands/doc-update.md:31` → [features/index-management.md](features/index-management.md)
- `commands/doc-plan.md:60` → [features/index-management.md](features/index-management.md)

### Command System
- `plugin.json:8` → [features/command-system.md](features/command-system.md)
- `commands/doc-init.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-feature.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-update.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-review.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-plan.md` → [features/command-system.md](features/command-system.md)

---

## 📝 Feature Documentation

### [Hook System](features/hook-system.md)
Automatically injects relevant documentation into Claude Code's context before file edits and reminds developers to update documentation after changes. Ensures Claude always considers design decisions and gotchas before modifying code.

### [Index Management](features/index-management.md)
Maintains a central `docs/README.md` file that maps source files to documentation. The `@doc-manager` agent scans all docs, extracts file mappings, and generates summaries, enabling efficient context loading in hooks.

### [Command System](features/command-system.md)
Provides five slash commands (`/auto-documenter:doc-init`, `/auto-documenter:doc-feature`, `/auto-documenter:doc-update`, `/auto-documenter:doc-review`, `/auto-documenter:doc-plan`) defined as markdown files with YAML frontmatter. Commands use tool allowlists and argument substitution to create and maintain documentation.

---

## 🏗️ Architecture Documentation

### [Overview](architecture/overview.md)
Core architecture and design principles of the auto-documenter plugin system.

---

## ⚠️ Gotchas & Important Notes

### [Hook System Gotchas](gotchas/hook-system-gotchas.md)
Critical points about executable permissions, basename-only matching limitations, jq dependencies, silent failures, AWK extraction fragility, and CLAUDE_PLUGIN_ROOT path resolution.

---

## 🤔 Key Decisions

*No decisions documented yet.*

---

## 💡 Planning Sessions

*No plans saved yet. Use `/auto-documenter:doc-plan <name>` to save a planning session.*

---

*Last updated: 2025-10-10 09:40*
