# Auto-Documenter v2.0: Skills-First Architecture

**Date:** 2025-10-17
**Branch:** `feature/skills-architecture`
**Status:** Planning → Implementation

## Vision

Transform auto-documenter from a command-driven documentation tool into a skills-first platform that:
1. Provides reusable documentation workflows (skills)
2. Maintains project-specific documentation (docs/)
3. Enables skill creation and documentation (meta-capability)

## Key Insight: Skills vs Documentation

**Skills** (Reusable Workflows):
- **Audience:** Claude (to perform tasks)
- **Purpose:** HOW to document, create skills, maintain docs
- **Location:** `.claude/skills/` (plugin-bundled) or `~/.claude/skills/` (user global)
- **Lifetime:** Reusable across all projects
- **Examples:** "How to document a feature", "How to create a skill"

**Project Documentation** (Project-Specific Content):
- **Audience:** Developers (human and Claude) working on THIS project
- **Purpose:** WHAT this codebase does, decisions, architecture
- **Location:** `docs/` folder in project repository
- **Lifetime:** Lives with the project
- **Examples:** "Our authentication system", "Database schema decisions"

**Relationship:** Skills teach Claude HOW to create docs; `docs/` contains WHAT the project does.

---

## Proposed Architecture

### Directory Structure

```
auto-documenter/
├── .claude-plugin/
│   ├── plugin.json (updated to include skills)
│   └── marketplace.json
├── skills/                           # NEW - Core documentation workflows
│   ├── document-feature/
│   │   ├── SKILL.md
│   │   ├── templates/
│   │   │   └── feature-template.md
│   │   └── scripts/
│   │       └── extract-context.sh
│   ├── document-codebase/
│   │   ├── SKILL.md
│   │   └── templates/
│   │       ├── index-template.md
│   │       └── structure-schema.json
│   ├── maintain-index/
│   │   ├── SKILL.md
│   │   └── scripts/
│   │       └── index-validator.sh
│   ├── create-skill/                 # NEW - Meta capability
│   │   ├── SKILL.md
│   │   └── templates/
│   │       ├── SKILL-template.md
│   │       └── validation-checklist.md
│   └── review-documentation/
│       ├── SKILL.md
│       └── scripts/
│           └── coverage-analysis.sh
├── agents/                           # ENHANCED - More specialist agents
│   ├── doc-manager.md (existing)
│   ├── doc-reader.md (existing)
│   ├── code-context-extractor.md    # NEW
│   └── skill-documenter.md          # NEW
├── commands/                         # REDUCED - Only explicit overrides
│   ├── init.md (simplified from doc-init.md)
│   └── sync.md (new - force sync)
├── hooks/                            # UPDATED - Suggest skills
│   ├── hooks.json
│   ├── pre-tool-use.sh
│   └── post-tool-use.sh (updated)
└── docs/ (project's own documentation)
```

---

## Core Skills Design

### 1. document-feature

**When Claude Uses It:** User implements/modifies a feature, mentions "document this feature"

**What It Does:**
- Extracts code context from relevant files
- Uses feature documentation template
- Invokes `@code-context-extractor` and `@doc-manager` agents
- Creates/updates `docs/features/{feature-name}.md`

**Bundled Resources:**
- `templates/feature-template.md` - Standard feature doc structure
- `scripts/extract-context.sh` - Extract imports, exports, key functions

### 2. document-codebase

**When Claude Uses It:** User starts new project, mentions "initialise docs", "setup documentation"

**What It Does:**
- Creates initial `docs/` structure
- Generates `docs/README.md` index
- Sets up standard subdirectories (features/, architecture/, gotchas/, decisions/, plans/)
- Creates initial architecture overview

**Bundled Resources:**
- `templates/index-template.md` - Index structure
- `templates/structure-schema.json` - Standard directory layout

### 3. maintain-index

**When Claude Uses It:** After documentation files are created/modified

**What It Does:**
- Scans all documentation files
- Updates `docs/README.md` with current file list and summaries
- Validates links and structure
- Invokes `@doc-manager` agent

**Bundled Resources:**
- `scripts/index-validator.sh` - Validate index consistency

### 4. create-skill

**When Claude Uses It:** User wants to create a new skill, mentions "create a skill for X"

**What It Does:**
- Interactive skill creation workflow
- Generates properly formatted SKILL.md with frontmatter
- Creates skill directory structure
- Documents the skill in project docs
- Invokes `@skill-documenter` agent

**Bundled Resources:**
- `templates/SKILL-template.md` - Proper SKILL.md structure
- `templates/validation-checklist.md` - Ensure skill follows best practices

### 5. review-documentation

**When Claude Uses It:** User asks about documentation status, coverage, or quality

**What It Does:**
- Analyses documentation coverage (which files/features are documented)
- Checks for broken links and outdated content
- Identifies gaps and suggests improvements
- Generates coverage report

**Bundled Resources:**
- `scripts/coverage-analysis.sh` - Calculate doc coverage metrics

---

## Specialist Agents Design

### 1. doc-manager (existing - keep as is)

**Colour:** Blue
**Purpose:** Maintains central documentation index
**Tools:** Read, Grep, Glob, Edit, Write
**Invoked By:** Skills, hooks

### 2. doc-reader (existing - keep as is)

**Colour:** Green
**Purpose:** Provides comprehensive doc access to other agents
**Tools:** Read, Grep, Glob
**Invoked By:** Other agents

### 3. code-context-extractor (NEW)

**Colour:** Purple
**Purpose:** Extracts relevant context from code for documentation
**Tools:** Read, Grep, Glob, Bash
**Invoked By:** `document-feature` skill, `create-skill` skill

**Capabilities:**
- Parse imports/exports
- Extract function signatures and key logic
- Identify dependencies
- Find related files
- Extract code comments and docstrings

### 4. skill-documenter (NEW)

**Colour:** Orange
**Purpose:** Documents skills and their usage patterns
**Tools:** Read, Grep, Glob, Edit, Write
**Invoked By:** `create-skill` skill

**Capabilities:**
- Document skill purpose and usage
- Extract skill metadata (name, description, bundled resources)
- Create skill usage examples
- Add skill to project documentation index

---

## Commands Design (Reduced)

### 1. /auto-documenter:init

**Purpose:** Force documentation initialisation (explicit override)
**When to Use:** Manual setup, overriding existing structure
**Implementation:** Thin wrapper around `document-codebase` skill

### 2. /auto-documenter:sync

**Purpose:** Force index synchronisation (explicit override)
**When to Use:** Manual maintenance, troubleshooting
**Implementation:** Thin wrapper around `maintain-index` skill

**Note:** Most old commands (doc-feature, doc-update, doc-review, doc-plan) are replaced by skills that auto-activate.

---

## Hooks Updates

### pre-tool-use.sh (keep existing behaviour)

- Injects relevant documentation context before Edit/Write/MultiEdit
- No changes needed

### post-tool-use.sh (UPDATE)

**Current Behaviour:**
- Suggests `/doc-update` if file documented
- Suggests `/doc-feature` if file undocumented

**New Behaviour:**
- Inform user that `document-feature` skill will auto-activate if needed
- Suggest `/auto-documenter:sync` only if index seems out of sync
- Less noisy, more trust in automatic skill activation

---

## Implementation Strategy: Phased Approach

### Phase 1: Add Skills Infrastructure (No Breaking Changes)

**Goals:**
- Add skills support without removing existing functionality
- Users can start using skills while keeping commands
- Test skills in parallel with existing workflows

**Tasks:**
1. Update `.claude-plugin/plugin.json` to include `skills` field
2. Create `skills/` directory structure
3. Implement first 2-3 core skills:
   - `document-feature`
   - `document-codebase`
   - `maintain-index`
4. Keep all existing commands functional
5. Test that skills auto-activate appropriately

**Success Criteria:**
- Plugin loads with skills directory
- Skills auto-activate when relevant
- Existing commands still work
- No breaking changes for current users

---

### Phase 2: Enhance with New Capabilities

**Goals:**
- Add skill creation/documentation meta-capability
- Add new specialist agents
- Update hooks to work better with skills

**Tasks:**
1. Create `create-skill` skill with templates
2. Create `review-documentation` skill
3. Add new agents:
   - `code-context-extractor`
   - `skill-documenter`
4. Update `post-tool-use.sh` hook to be less noisy
5. Add skill-related documentation to project docs

**Success Criteria:**
- Users can create well-documented skills using the plugin
- Skills and agents work together smoothly
- Hooks are less intrusive
- Plugin is self-documenting

---

### Phase 3: Deprecation (Optional, Later)

**Goals:**
- Clean up redundant commands
- Streamline user experience
- Maintain backward compatibility or provide migration path

**Tasks:**
1. Mark old commands as deprecated in descriptions
2. Add deprecation warnings when commands are used
3. Provide migration guide for users
4. Eventually convert commands to thin wrappers or remove

**Success Criteria:**
- Clear migration path for users
- Documentation updated
- Backward compatibility maintained or clearly communicated

---

## Benefits Summary

### For Users

✅ **Natural language activation** - Skills auto-activate, no need to remember commands
✅ **Cross-platform portability** - Skills work in Claude Apps, API, and Claude Code
✅ **Composability** - Skills work together automatically
✅ **Less manual invocation** - Claude knows when to document things
✅ **Skill creation support** - Meta-capability helps create and document new skills

### For Development

✅ **Bundled resources** - Skills can include templates, scripts, schemas
✅ **Progressive loading** - Only load what's needed (metadata → instructions → resources)
✅ **Clear separation** - Skills (workflows) vs Agents (helpers) vs Commands (overrides)
✅ **Token efficient** - Unused bundled content costs zero tokens

### For the Plugin

✅ **Expanded scope** - Project documentation + skill creation/documentation platform
✅ **Meta-capability** - Helps users create skills, not just project docs
✅ **More valuable** - Go-to plugin for skill creators
✅ **Future-proof** - Aligns with Claude Code's skills-first direction

---

## Migration Considerations

### Backward Compatibility

**Keep During Phase 1:**
- All existing slash commands functional
- Existing hooks work unchanged
- Existing agents work unchanged
- Plugin version: 1.x.x (minor/patch bump)

**Add in Phase 1:**
- Skills directory and support
- Skills work alongside commands
- No breaking changes

**Phase 2 Additions:**
- New capabilities (not breaking)
- Plugin version: 2.0.0 (major bump for new features)

### User Communication

- Changelog explaining skills addition
- Examples showing skills vs commands
- Migration guide (when Phase 3 occurs)
- Documentation updates

---

## Next Steps

1. ✅ Save this plan document
2. Proceed with **Phase 1 Implementation**:
   - Update plugin.json
   - Create skills directory structure
   - Implement first 3 core skills
   - Test functionality
3. Document Phase 1 changes
4. Get feedback before Phase 2
5. Iterate

---

## References

- [Anthropic Skills Announcement](https://www.anthropic.com/news/skills)
- [Claude Code Skills Documentation](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
- Current plugin documentation: `/docs/README.md`
