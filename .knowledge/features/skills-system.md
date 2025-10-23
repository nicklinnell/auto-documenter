# Feature: Skills System

## Overview

The Skills System is the core of auto-documenter v2.0, providing intelligent, auto-activating documentation workflows that replace manual command invocation. Skills use progressive loading architecture and work across all Claude platforms (Apps, API, and Code).

**Why it exists**: Users shouldn't need to remember specific commands or know when to document. Skills enable Claude to recognize documentation moments naturally and activate the appropriate workflow automatically, making documentation feel seamless rather than a separate task.

## Implementation Details

### Key Files

- `.claude-plugin/plugin.json` - Plugin manifest with skills directory registration
- `skills/document-feature/SKILL.md` - Feature documentation skill definition
- `skills/document-feature/templates/feature-template.md` - Standard feature doc template
- `skills/document-feature/scripts/extract-context.sh` - Code context extraction script
- `skills/document-codebase/SKILL.md` - Codebase initialization skill definition
- `skills/document-codebase/templates/index-template.md` - Documentation index template
- `skills/document-codebase/templates/structure-schema.json` - Standard directory structure definition
- `skills/maintain-index/SKILL.md` - Index maintenance skill definition
- `skills/maintain-index/scripts/index-validator.sh` - Documentation validation script

### How It Works

**Skills Architecture**:
1. **Metadata Layer** (~100 tokens): YAML frontmatter with name and description loaded for all skills
2. **Instructions Layer** (<5k tokens): Full SKILL.md content loaded when skill activates
3. **Resources Layer** (0 tokens until used): Bundled templates/scripts accessed via bash as needed

**Skill Activation**:
- Claude scans skill descriptions during task execution
- When user intent matches a skill's description, skill activates automatically
- Skills can invoke agents (`@doc-manager`, `@doc-reader`) for complex operations
- Skills have access to specific tools defined in their SKILL.md

**Progressive Loading**:
- Unused bundled content costs zero tokens
- Only relevant files loaded when needed
- Keeps context minimal and efficient

### Dependencies

**Internal**:
- Existing agents: `@doc-manager` (maintains index), `@doc-reader` (reads docs)
- Existing hooks: PreToolUse (context injection), PostToolUse (suggestions)
- Documentation structure: `.knowledge/` directory with standard layout

**External**:
- bash (for script execution)
- grep, awk (for text processing in scripts)
- git (optional, for some validation features)

### Configuration

**Plugin Configuration** (`.claude-plugin/plugin.json`):
```json
{
  "skills": "./skills/"
}
```

**Skill Structure** (each skill):
```
skills/{skill-name}/
├── SKILL.md              # Skill definition with YAML frontmatter
├── templates/            # (optional) Template files
└── scripts/              # (optional) Executable helper scripts
```

**SKILL.md Format**:
```yaml
---
name: skill-name
description: When to use this skill (max 1024 chars)
---

[Skill instructions in markdown]
```

## Important Notes & Gotchas

### ⚠️ Critical Points

- **Description is Key**: The description in YAML frontmatter determines when Claude activates the skill. Be specific and clear about activation conditions.
- **Character Limits**: name max 64 chars, description max 1024 chars (enforced by Claude Code)
- **No Network Access**: Skills cannot make external API calls or install packages at runtime
- **Script Permissions**: All bundled scripts must be executable (`chmod +x`)
- **Backward Compatibility**: All existing commands must continue working alongside skills

### 🐛 Known Issues

- Skills are filesystem-based and don't sync across Claude Apps/API automatically
- Skill activation depends on Claude's interpretation of user intent (can have false negatives/positives)
- No runtime package installation means all dependencies must be pre-installed

### 🔄 Future Improvements

- Add skill usage analytics to understand activation patterns
- Create skill debugging/testing framework
- Build skill discovery mechanism (list available skills)
- Add skill dependency management
- Consider skill versioning and updates

## Testing

**Manual Testing**:
1. Test natural language activation: "document this feature" → document-feature activates
2. Test explicit command still works: `/doc-feature test` → creates docs
3. Verify bundled resources load correctly: check templates are used
4. Validate scripts execute: run extract-context.sh manually

**Validation Scripts**:
```bash
# Validate index consistency
./skills/maintain-index/scripts/index-validator.sh .

# Test code extraction
./skills/document-feature/scripts/extract-context.sh path/to/file.ts
```

**Integration Testing**:
- Skills should work alongside existing commands
- Skills should invoke agents correctly
- Skills should respect tool permissions
- Skills should handle errors gracefully

## Related Documentation

- [Skills Architecture Plan](../plans/skills-architecture-v2.md) - Comprehensive design and phasing
- [Command System](./command-system.md) - How skills complement commands
- [Agent System](./agent-system.md) - How skills invoke agents
- [Hook System](./hook-system.md) - How hooks interact with skills

---
*Created: 2025-10-17*
*Last updated: 2025-10-17*
