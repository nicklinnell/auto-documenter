---
description: "Save a planning session to the .knowledge/plans/ directory (command still supported - no direct skill replacement)"
allowed-tools: Write, Read, Edit, Bash
---

ℹ️ **NOTE**: This command is still supported. While most commands have been replaced by auto-activating skills, this command remains useful for explicitly saving planning sessions. Skills work well for active workflows, but explicit plan saving is better handled by a command.

You are saving a planning session to the documentation. The plan name is: **$1**

Follow these steps:

1. **Determine the filename**:
   - Get today's date in YYYY-MM-DD format
   - Create filename: `.knowledge/plans/YYYY-MM-DD-$1.md`
   - Example: `.knowledge/plans/2025-10-10-user-authentication-redesign.md`

2. **Check if .knowledge/ exists**:
   - If `.knowledge/README.md` doesn't exist, inform the user to run `/doc-init` first
   - If `.knowledge/plans/` doesn't exist, create it

3. **Gather the plan content**:
   - Ask the user to provide the plan content
   - Suggest they paste the plan from their previous planning session
   - Format: Accept multiline markdown input

4. **Create the plan document** with this structure:

```markdown
# Plan: $1

**Date**: {current_date}
**Status**: Proposed

## Overview
[Brief summary of what this plan is about]

## Plan Details

[The main content of the plan - paste the plan output here]

## Outcomes

- [ ] Implemented
- [ ] Partially implemented
- [ ] Not implemented
- [ ] Superseded by another approach

## Notes

[Any additional context, decisions made, or follow-up items]

---

*Saved from planning session on {current_date}*
```

5. **Update the index**:
   - Read `.knowledge/README.md`
   - Add this plan to the "Planning Sessions" section
   - Format: `- **YYYY-MM-DD**: [$1](plans/YYYY-MM-DD-$1.md) - [brief summary]`
   - Update the last modified date
   - Use `@doc-manager` if needed to regenerate the index

6. **Confirm to the user**:
   - Show where the plan was saved
   - Remind them they can update the status later as implementation progresses
   - Suggest running `@doc-manager` to update the index

## Usage Examples

```bash
# Save a plan for user authentication redesign
/doc-plan user-auth-redesign

# Save a plan for database migration
/doc-plan database-migration-v2

# Save a plan for performance optimisation
/doc-plan api-performance-optimization
```

## Tips

- Use descriptive, kebab-case names (e.g., `feature-name` not `Feature Name`)
- Keep plan names concise but meaningful
- Update the "Outcomes" section later to track what was actually implemented
- Plans serve as historical context for future decisions
