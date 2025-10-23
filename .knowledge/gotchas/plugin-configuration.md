# Gotchas: Plugin Configuration

## Overview

Critical gotchas and common mistakes when configuring Claude Code plugins, based on issues encountered while setting up the auto-documenter plugin.

## ⚠️ Critical Configuration Gotchas

### 1. plugin.json Should NOT Exist

**The Mistake:**
Creating a `.claude-plugin/plugin.json` file alongside `marketplace.json`.

**Why It's Wrong:**
- Claude Code plugins only use `marketplace.json` for configuration
- `plugin.json` is not part of the official Claude Code plugin schema
- Having both files causes confusion and incorrect plugin behavior
- Reference: [Anthropic skills repository](https://github.com/anthropics/skills) uses only `marketplace.json`

**The Fix:**
```bash
# Remove plugin.json if it exists
rm .claude-plugin/plugin.json
```

Only `.claude-plugin/marketplace.json` should exist.

### 2. Auto-Discovery of Components

**The Mistake:**
Trying to list `agents/`, `commands/`, and `hooks/` directories in configuration files.

**Why It's Wrong:**
- These directories are **automatically discovered** by Claude Code at runtime
- They live at the **plugin root level** (not inside `.claude-plugin/`)
- They do **NOT** need to be (and should not be) listed in `marketplace.json`
- Only `skills/` subdirectories need to be explicitly listed

**The Correct Structure:**
```
your-plugin/
├── .claude-plugin/
│   └── marketplace.json    ← Only config file needed
├── agents/                 ← Auto-discovered (no config needed)
│   ├── agent-one.md
│   └── agent-two.md
├── commands/               ← Auto-discovered (no config needed)
│   ├── command-one.md
│   └── command-two.md
├── hooks/                  ← Auto-discovered (no config needed)
│   ├── hooks.json
│   ├── pre-tool-use.sh
│   └── post-tool-use.sh
└── skills/                 ← Must be listed in marketplace.json
    ├── skill-one/
    │   └── SKILL.md
    └── skill-two/
        └── SKILL.md
```

### 3. Correct marketplace.json Structure

**The Mistake:**
Using incorrect schema or trying to mimic `plugin.json` format.

**Why It's Wrong:**
- `marketplace.json` has a specific nested structure with `plugins` array
- Each plugin entry contains metadata and a `skills` array
- Missing fields like `"strict": false` or incorrect nesting breaks loading

**The Correct Format:**
```json
{
  "name": "marketplace-name",
  "owner": {
    "name": "Your Name"
  },
  "metadata": {
    "description": "Marketplace description",
    "version": "x.y.z"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "Plugin description",
      "source": "./",
      "strict": false,
      "skills": [
        "./skills/skill-one",
        "./skills/skill-two",
        "./skills/skill-three"
      ]
    }
  ]
}
```

**Key Points:**
- `plugins` is an array (can contain multiple plugins from one marketplace)
- `source` typically points to `"./"` (current directory)
- `strict: false` allows flexible operation
- `skills` array lists relative paths to skill directories (containing `SKILL.md`)
- Each skill directory path should NOT include the `SKILL.md` filename

## 🔍 How We Discovered These Issues

### Initial Incorrect Setup
Our plugin originally had:
```json
// .claude-plugin/plugin.json (WRONG - shouldn't exist)
{
  "name": "auto-documenter",
  "version": "2.0.0",
  "commands": "./commands/",     // ❌ Invalid field
  "agents": [...],               // ❌ Invalid field
  "hooks": "./hooks/hooks.json", // ❌ Invalid field
  "skills": "./skills/"          // ❌ Wrong format
}
```

```json
// .claude-plugin/marketplace.json (WRONG structure)
{
  "name": "auto-documenter-marketplace",
  "owner": { "name": "Nick Linnell" },
  "plugins": [
    {
      "name": "auto-documenter",
      "version": "2.0.0",
      "source": {                 // ❌ Wrong nested structure
        "source": "github",
        "repo": "nicklinnell/auto-documenter"
      }
    }
  ]
}
```

### The Fix (v2.0.1)
After reviewing the [Anthropic skills repository](https://github.com/anthropics/skills):

1. **Removed** `.claude-plugin/plugin.json` entirely
2. **Rewrote** `.claude-plugin/marketplace.json` with correct structure:

```json
{
  "name": "auto-documenter",
  "owner": {
    "name": "Nick Linnell"
  },
  "metadata": {
    "description": "Automatic documentation system with skills for creating contextual memory in Claude Code",
    "version": "2.0.1"
  },
  "plugins": [
    {
      "name": "auto-documenter",
      "description": "Automatic documentation system with intelligent skills, agents, commands, and hooks that create contextual memory for Claude Code",
      "source": "./",
      "strict": false,
      "skills": [
        "./skills/initialising-documentation",
        "./skills/creating-skills",
        "./skills/documenting-features",
        "./skills/reviewing-documentation",
        "./skills/maintaining-index"
      ]
    }
  ]
}
```

## 📚 References

- **Official Example:** [Anthropic skills repository](https://github.com/anthropics/skills)
- **Official marketplace.json:** [skills/.claude-plugin/marketplace.json](https://github.com/anthropics/skills/blob/main/.claude-plugin/marketplace.json)
- **Claude Code Docs:** [Plugin Configuration](https://docs.claude.com/en/docs/claude-code/plugins)

## 🔧 Validation Checklist

When setting up a Claude Code plugin:

- [ ] Only `.claude-plugin/marketplace.json` exists (no `plugin.json`)
- [ ] `marketplace.json` has correct structure with `plugins` array
- [ ] `plugins[0].skills` is an array of relative paths to skill directories
- [ ] `plugins[0].strict` is set to `false`
- [ ] `agents/`, `commands/`, `hooks/` are NOT listed in config (auto-discovered)
- [ ] All skill directories contain a `SKILL.md` file
- [ ] Version follows semver (x.y.z format)

## 💡 Why This Matters

Incorrect plugin configuration causes:
- Plugin fails to load in Claude Code
- Skills not recognized or activated
- Agents/commands/hooks not discovered
- Confusing error messages
- Wasted time debugging

Following the official Anthropic example ensures your plugin works correctly across all Claude Code installations.

---

**Related Documentation:**
- [Plugin Configuration Best Practices](../architecture/plugin-configuration.md) (if created)
- [Skills System](../features/skills-system.md)

**File References:**
- `.claude-plugin/marketplace.json` - The only config file needed
- Reference implementation: https://github.com/anthropics/skills
