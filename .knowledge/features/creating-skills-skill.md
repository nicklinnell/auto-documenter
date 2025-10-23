# Feature: Creating Skills Skill

## Overview

The creating-skills skill is an intelligent workflow that guides users through creating properly structured, well-documented Claude skills. It handles the entire skill creation lifecycle - from gathering requirements to creating the SKILL.md file, bundling resources (templates/scripts), and generating feature documentation. The skill ensures all created skills follow best practices with correct YAML frontmatter, clear activation conditions, and proper progressive loading architecture.

**Why it exists**: Creating skills manually requires understanding multiple conventions (character limits, naming patterns, frontmatter structure, bundled resources, documentation requirements). This skill automates the process and enforces best practices, reducing errors and ensuring consistency across all skills in the auto-documenter system.

## Implementation Details

### Key Files

- `skills/creating-skills/SKILL.md` - Main skill definition with creation workflow (175 lines)
- `skills/creating-skills/templates/SKILL-template.md` - Standard structure template for new skills (78 lines)
- `skills/creating-skills/templates/validation-checklist.md` - Comprehensive validation checklist (100 lines)
- `.claude-plugin/marketplace.json:13` - Registers this skill in the plugin
- `agents/skill-documenter.md` - Agent invoked to document newly created skills

### How It Works

#### 1. Activation

The skill activates when:
- User explicitly requests "create a skill for X" or "build a skill"
- User asks how to structure a skill
- User needs help with SKILL.md format
- User wants to add bundled resources to a skill

**Activation mechanism**: Claude scans the skill description during task execution and matches user intent against the description in YAML frontmatter.

#### 2. Requirement Gathering

**Questions asked:**
- What task should this skill perform?
- When should Claude activate this skill? (specific triggers)
- What tools does the skill need?
- What templates or scripts should be bundled?
- Is this project-specific (`.claude/skills/`) or user-global (`~/.claude/skills/`)?

**Decision point**: Location determines where the skill directory is created.

#### 3. Skill Structure Creation

**Directory layout created:**
```
skills/{skill-name}/
├── SKILL.md              # Required: Skill definition
├── templates/            # Optional: Bundled templates
│   └── *.md
└── scripts/              # Optional: Helper scripts
    └── *.sh
```

**Tools used:**
- Write tool to create SKILL.md
- Bash tool to create directories (`mkdir -p`)
- Bash tool to set script permissions (`chmod +x scripts/*.sh`)

#### 4. SKILL.md Generation

**Frontmatter requirements** (enforced by skill):
- `name`: Gerund form (e.g., "processing-pdfs"), kebab-case, max 64 characters
- `description`: Includes BOTH what it does AND when to activate (max 1024 characters)

**Body structure** (from SKILL-template.md):
1. Role description: "You are a..."
2. "When to Activate" section with specific triggers
3. "Your Task" section explaining the goal
4. Step-by-step "Process" sections
5. "Best Practices" section
6. "Bundled Resources" section (if applicable)
7. "Tools Available" and "Agents Available" sections
8. "Important Notes" for gotchas

**Template usage**: The skill reads `templates/SKILL-template.md` and fills in placeholders with user-provided information.

#### 5. Bundled Resources Creation

**Templates:**
- Stored in `templates/` subdirectory
- Use clear placeholders: `{feature-name}`, `{date}`, `{variable-name}`
- Documented in SKILL.md "Bundled Resources" section
- Accessed via relative paths from SKILL.md location

**Scripts:**
- Stored in `scripts/` subdirectory
- Made executable: `chmod +x scripts/*.sh`
- Include usage comments at top
- Handle errors gracefully (exit 0 to avoid breaking workflows)
- Documented in SKILL.md

#### 6. Documentation Generation

**Agent invocation**: The skill invokes `@skill-documenter` agent which:
1. Reads the newly created SKILL.md
2. Discovers bundled resources (templates, scripts)
3. Creates `.knowledge/features/{skill-name}-skill.md` following feature template
4. Invokes `@doc-manager` to update the documentation index
5. Documents activation triggers, bundled resources, and gotchas

**Output**: Feature documentation file and updated index.

#### 7. Validation

**Checklist** (from validation-checklist.md):
- SKILL.md has valid YAML frontmatter
- Name is gerund form, ≤64 chars
- Description includes activation conditions, ≤1024 chars
- Scripts are executable (`chmod +x`)
- Templates have clear placeholders
- Skill is documented in `.knowledge/features/`
- Test activation with natural language

### Dependencies

**Internal:**
- `@skill-documenter` agent - Documents the newly created skill
- `@doc-manager` agent - Updates the documentation index
- `templates/SKILL-template.md` - Standard skill structure template
- `templates/validation-checklist.md` - Validation checklist

**External:**
- bash - For directory creation and script permissions
- File system access for creating skill directories

**Tools required:**
- Write - Create SKILL.md and bundled resources
- Bash - Create directories, set permissions
- Read - Check existing skills for examples
- Edit - Modify existing skills (if updating)

### Configuration

**Character Limits** (enforced by Claude Code):
- `name`: max 64 characters
- `description`: max 1024 characters

**Naming Convention**:
- Use gerund form: "processing-pdfs", not "process-pdfs" or "pdf-processor"
- Use kebab-case: "creating-skills", not "creating_skills" or "CreatingSkills"
- Be descriptive: "documenting-features" not "doc-feat"

**Location Options**:
- Project-specific: `.claude/skills/` or `skills/` (tracked in project repo)
- User-global: `~/.claude/skills/` (available across all projects)

## Important Notes & Gotchas

### ⚠️ Critical Points

1. **Description is Make-or-Break** (SKILL.md:115-119)
   - The description field determines when Claude activates the skill
   - **Good**: "Document a specific feature... Use when the user implements or modifies a feature, or mentions 'document this feature'"
   - **Bad**: "Documents features" (too vague, no activation conditions)
   - If description is unclear, skill will never activate or activate incorrectly
   - **Impact**: Wasted skill development effort if activation description is poor

2. **Character Limits Are Strictly Enforced** (SKILL.md:158)
   - name ≤64 chars, description ≤1024 chars
   - Claude Code will reject skills that exceed these limits
   - No error messages if you exceed - skill just won't load
   - **Mitigation**: Use validation-checklist.md before finalizing

3. **Script Permissions Must Be Set** (SKILL.md:161)
   - Scripts in `scripts/` subdirectory MUST be executable
   - Use `chmod +x scripts/*.sh` after creation
   - **Failure mode**: Skill tries to execute script, fails silently
   - **Why silent**: Scripts should exit 0 on error to avoid breaking workflows

4. **Progressive Loading Architecture**
   - Only frontmatter (name + description) loads initially (~100 tokens)
   - SKILL.md body loads when skill activates (~5k tokens)
   - Bundled resources load only when accessed (0 tokens until used)
   - **Design goal**: Keep initial cost minimal, load more only as needed

5. **No Runtime Package Installation** (SKILL.md:131-134)
   - Skills cannot install npm packages, Python libraries, etc. at runtime
   - All dependencies must be pre-installed on the system
   - **Workaround**: Document required system dependencies in "Important Notes"
   - **Example**: If skill needs jq, document "Requires jq to be installed"

6. **Gerund Naming Is Required**
   - Correct: "creating-skills", "documenting-features", "maintaining-index"
   - Incorrect: "create-skills", "document-features", "maintain-index"
   - **Rationale**: Gerunds describe ongoing processes, matches skill nature
   - **Migration note**: Some old skills may not follow this (legacy compatibility)

### 🐛 Known Issues

1. **No Validation During Creation**
   - Skill creation process doesn't automatically validate character limits
   - User must manually check with validation-checklist.md
   - **Risk**: Creating invalid skills that won't load
   - **Workaround**: Always use the checklist

2. **Template Placeholders Not Enforced**
   - Templates should use `{variable-name}` format for placeholders
   - But nothing prevents inconsistent formats like `{{variable}}` or `$variable`
   - **Impact**: Confusion when using bundled templates
   - **Best practice**: Stick to `{variable-name}` convention

3. **Scripts Must Handle Errors Gracefully**
   - Scripts should `exit 0` even on failure
   - **Reason**: Prevents breaking the user's workflow
   - **Trade-off**: Makes debugging harder (silent failures)
   - **Mitigation**: Include debug logging in scripts

4. **Activation Ambiguity**
   - Multiple skills can have overlapping activation conditions
   - Claude chooses which skill to activate based on description match
   - **Example**: Both "creating-skills" and "documenting-features" might match "document"
   - **Impact**: Non-deterministic skill activation
   - **Mitigation**: Make descriptions very specific and distinct

5. **No Automatic Plugin Registration**
   - Creating a skill doesn't automatically add it to `.claude-plugin/marketplace.json`
   - User must manually add skill path to the "skills" array
   - **Workaround**: Skill tells user to add to plugin.json in confirmation message

### 🔄 Future Improvements

1. **Automated Validation**
   - Run validation-checklist.md checks programmatically
   - Report character count before finalization
   - Validate YAML frontmatter syntax

2. **Interactive Skill Builder**
   - Guided wizard with multiple choice questions
   - Auto-fill frontmatter based on answers
   - Live character count display

3. **Skill Testing Framework**
   - Automated tests for activation conditions
   - Test bundled resources are accessible
   - Verify scripts execute correctly

4. **Skill Discovery Mechanism**
   - Command to list all available skills
   - Show activation conditions for each
   - Filter by category or purpose

5. **Skill Templates Library**
   - Pre-built skill templates for common patterns
   - Example: "Create a skill that processes files"
   - Accelerate skill development

## Testing

### Manual Testing

**Test 1: Create a Simple Skill (No Bundled Resources)**
```
1. Ask: "Create a skill for converting markdown to PDF"
2. Verify:
   - skills/converting-markdown-to-pdf/ directory created
   - SKILL.md has valid frontmatter
   - Name uses gerund form
   - Description includes activation conditions
   - Character limits respected
   - Feature docs created at .knowledge/features/converting-markdown-to-pdf-skill.md
```

**Test 2: Create a Skill with Templates**
```
1. Ask: "Create a skill for generating API documentation that includes a template"
2. Verify:
   - templates/ subdirectory created
   - Template files present
   - Templates documented in SKILL.md "Bundled Resources"
   - Templates have clear placeholders ({api-name}, {endpoint})
```

**Test 3: Create a Skill with Scripts**
```
1. Ask: "Create a skill that uses a bash script to validate JSON"
2. Verify:
   - scripts/ subdirectory created
   - Script file is executable (chmod +x)
   - Script includes usage comments
   - Script handles errors gracefully (exit 0)
   - Script documented in SKILL.md
```

**Test 4: Validation Checklist**
```
1. Create a skill
2. Run through validation-checklist.md manually
3. Verify all checkboxes pass
4. Test natural language activation
```

### Integration Testing

- Verify @skill-documenter is invoked and creates feature docs
- Verify @doc-manager updates the index
- Test that bundled templates are accessible from SKILL.md location
- Test that bundled scripts execute correctly

## Related Documentation

- [Skills System](.knowledge/features/skills-system.md:3) - Overall skills architecture and progressive loading
- [Skill Documenter Agent](.knowledge/features/skill-documenter-agent.md) - Agent that documents newly created skills (not yet created)
- [Architecture Overview](.knowledge/architecture/overview.md:9) - Skills as core component of v2.0

---
*Created: 2025-10-23*
*Last updated: 2025-10-23*
