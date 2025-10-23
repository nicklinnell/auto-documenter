# Skill Validation Checklist

Use this checklist to ensure your skill follows Claude Code best practices.

## ✅ Structure

- [ ] SKILL.md file exists in skills/{skill-name}/ directory
- [ ] YAML frontmatter is properly formatted (---)
- [ ] `name` field is present (kebab-case, max 64 chars)
- [ ] `description` field is present (max 1024 chars)
- [ ] Body content is in markdown format

## ✅ Frontmatter Quality

- [ ] Name is descriptive and unique
- [ ] Name uses kebab-case (e.g., document-feature, not DocumentFeature)
- [ ] Description includes WHAT the skill does
- [ ] Description includes WHEN Claude should activate it
- [ ] Description is specific about activation triggers
- [ ] Character limits respected (name ≤64, description ≤1024)

## ✅ Activation Description

**Good examples:**
- "Document a specific feature... Use when the user implements or modifies a feature, or mentions 'document this feature'"
- "Initialise project documentation... Use when starting a new project or when user mentions 'initialise docs'"

**Bad examples:**
- "Documents features" (no activation conditions)
- "Helps with documentation" (too vague)

## ✅ Body Content

- [ ] Clear role statement ("You are a...")
- [ ] "When to Activate" section with specific triggers
- [ ] "Your Task" section explaining the goal
- [ ] Step-by-step process with numbered sections
- [ ] "Best Practices" section
- [ ] "Tools Available" section (if tools are used)
- [ ] "Agents Available" section (if agents are invoked)
- [ ] "Important Notes" section for gotchas

## ✅ Bundled Resources

- [ ] Templates stored in templates/ subdirectory
- [ ] Scripts stored in scripts/ subdirectory
- [ ] Scripts are executable (chmod +x)
- [ ] Scripts include usage comments
- [ ] Scripts handle errors gracefully (exit 0)
- [ ] Templates have clear placeholders ({variable-name})
- [ ] Bundled resources are documented in SKILL.md

## ✅ Documentation

- [ ] Skill is documented in .knowledge/features/{skill-name}-skill.md
- [ ] Feature documentation follows standard template
- [ ] Skill added to .knowledge/README.md index
- [ ] Activation triggers documented
- [ ] Bundled resources documented
- [ ] Gotchas and limitations documented

## ✅ Testing

- [ ] Test with natural language activation
- [ ] Test explicit skill invocation (if supported)
- [ ] Verify bundled templates are accessible
- [ ] Verify scripts execute correctly
- [ ] Test with sample inputs/scenarios
- [ ] Verify skill completes successfully

## ✅ Best Practices

- [ ] Skill is focused on one workflow (not a mega-skill)
- [ ] Progressive disclosure (metadata < instructions < resources)
- [ ] No runtime package installation
- [ ] System dependencies documented
- [ ] Error handling is graceful
- [ ] Output is clear and actionable

## 🚫 Common Mistakes to Avoid

- ❌ Vague activation descriptions
- ❌ Missing character limit validation
- ❌ Scripts without execute permissions
- ❌ Undocumented bundled resources
- ❌ Missing "When to Activate" section
- ❌ Tools/agents not listed
- ❌ No error handling in scripts
- ❌ Mega-skills that do too much
- ❌ Activation conditions buried in body (should be in description)

## 📋 Sign-off

Skill Name: ________________
Created By: ________________
Date: ________________

Validated by checking all items above: [ ]
Ready for use: [ ]
