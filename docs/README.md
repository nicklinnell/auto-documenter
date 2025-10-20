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

### Skills System (v2.0)
- `.claude-plugin/plugin.json` → [features/skills-system.md](features/skills-system.md)
- `skills/documenting-features/SKILL.md` → [features/skills-system.md](features/skills-system.md), [features/documenting-features-skill.md](features/documenting-features-skill.md)
- `skills/initialising-documentation/SKILL.md` → [features/skills-system.md](features/skills-system.md), [features/initialising-documentation-skill.md](features/initialising-documentation-skill.md)
- `skills/maintaining-index/SKILL.md` → [features/skills-system.md](features/skills-system.md), [features/maintaining-index-skill.md](features/maintaining-index-skill.md)
- `skills/*/templates/*` → [features/skills-system.md](features/skills-system.md)
- `skills/*/scripts/*` → [features/skills-system.md](features/skills-system.md)

### Plugin Configuration (v2.0.1)
- `.claude-plugin/marketplace.json` → [gotchas/plugin-configuration.md](gotchas/plugin-configuration.md)
- `.claude-plugin/plugin.json` (REMOVED) → [gotchas/plugin-configuration.md](gotchas/plugin-configuration.md)

### Hook System
- `hooks/hooks.json` → [features/hook-system.md](features/hook-system.md)
- `hooks/pre-tool-use.sh` → [features/hook-system.md](features/hook-system.md)
- `hooks/post-tool-use.sh` → [features/hook-system.md](features/hook-system.md)
- `plugin.json` → [features/hook-system.md](features/hook-system.md)

### Index Management
- `agents/doc-manager.md` → [features/index-management.md](features/index-management.md)
- `agents/doc-reader.md` → [features/index-management.md](features/index-management.md), [features/doc-reader-agent.md](features/doc-reader-agent.md)
- `.claude-plugin/plugin.json` → [features/index-management.md](features/index-management.md)
- `docs/README.md` → [features/index-management.md](features/index-management.md)
- `hooks/pre-tool-use.sh:21` → [features/index-management.md](features/index-management.md)
- `commands/doc-feature.md:66` → [features/index-management.md](features/index-management.md)
- `commands/doc-update.md:31` → [features/index-management.md](features/index-management.md)
- `commands/doc-plan.md:60` → [features/index-management.md](features/index-management.md)

### Doc Reader Agent
- `agents/doc-reader.md` → [features/doc-reader-agent.md](features/doc-reader-agent.md)
- `.claude-plugin/plugin.json:9` → [features/doc-reader-agent.md](features/doc-reader-agent.md)
- `docs/README.md` → [features/doc-reader-agent.md](features/doc-reader-agent.md)

### Command System
- `plugin.json:8` → [features/command-system.md](features/command-system.md)
- `commands/doc-init.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-feature.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-update.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-review.md` → [features/command-system.md](features/command-system.md)
- `commands/doc-plan.md` → [features/command-system.md](features/command-system.md)

---

## 📝 Feature Documentation

### [Skills System](features/skills-system.md) ⭐ NEW v2.0
Core skills-first architecture providing intelligent, auto-activating documentation workflows. Skills use progressive loading (metadata → instructions → resources) and work cross-platform across Claude Apps, API, and Code. Includes three core skills with bundled templates and scripts.

### [documenting-features Skill](features/documenting-features-skill.md) ⭐ NEW v2.0
Automatically creates comprehensive feature documentation when users implement or modify features. Auto-activates on natural language ("document this feature") and includes bundled template and code extraction script for parsing imports, exports, and functions.

### [initialising-documentation Skill](features/initialising-documentation-skill.md) ⭐ NEW v2.0
Automatically initialises comprehensive documentation structure for projects. Auto-activates when starting new projects or on "initialise docs" mentions. Creates complete docs/ hierarchy with standard subdirectories, central index, and initial architecture overview.

### [maintaining-index Skill](features/maintaining-index-skill.md) ⭐ NEW v2.0
Automatically keeps the central documentation index (docs/README.md) current by scanning all documentation files. Auto-activates after documentation changes or on "update the index" mentions. Includes validation script for checking consistency and broken links.

### [Hook System](features/hook-system.md)
Automatically injects relevant documentation into Claude Code's context before file edits and reminds developers to update documentation after changes. Ensures Claude always considers design decisions and gotchas before modifying code.

### [Index Management](features/index-management.md)
Maintains a central `docs/README.md` file that maps source files to documentation. The `@doc-manager` and `@doc-reader` agents work together: doc-manager writes and maintains the index, whilst doc-reader provides comprehensive read access to documentation for agents and users.

### [Doc Reader Agent](features/doc-reader-agent.md)
A read-only agent that uses the documentation index to discover and provide comprehensive, detailed information from project documentation with complete content, source references, and related file paths for other agents or the main conversation.

### [Command System](features/command-system.md)
Provides five slash commands (`/auto-documenter:doc-init`, `/auto-documenter:doc-feature`, `/auto-documenter:doc-update`, `/auto-documenter:doc-review`, `/auto-documenter:doc-plan`) defined as markdown files with YAML frontmatter. Commands use tool allowlists and argument substitution to create and maintain documentation.

---

## 🏗️ Architecture Documentation

### [Overview](architecture/overview.md)
Core architecture and design principles of the auto-documenter plugin system.

---

## ⚠️ Gotchas & Important Notes

### [Plugin Configuration Gotchas](gotchas/plugin-configuration.md) ⭐ NEW v2.0.1
Critical gotchas about Claude Code plugin configuration: why plugin.json should NOT exist, auto-discovery of agents/commands/hooks directories, correct marketplace.json structure, and common mistakes to avoid. Based on fixes in v2.0.1.

### [Hook System Gotchas](gotchas/hook-system-gotchas.md)
Critical points about executable permissions, basename-only matching limitations, jq dependencies, silent failures, AWK extraction fragility, and CLAUDE_PLUGIN_ROOT path resolution.

---

## 🤔 Key Decisions

*No decisions documented yet.*

---

## 💡 Planning Sessions

### [Skills Architecture v2.0](plans/skills-architecture-v2.md) - 2025-10-17
Comprehensive plan for transforming auto-documenter into a skills-first platform. Defines vision, architecture, three core skills (documenting-features, initialising-documentation, maintaining-index), and three-phase implementation strategy with backward compatibility.

---

*Last updated: 2025-10-20*
