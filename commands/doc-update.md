---
description: "[DEPRECATED] Update existing documentation based on recent changes. Use the maintain-index skill instead (just say 'update the docs')"
allowed-tools: Read, Grep, Glob, Edit, Bash
---

⚠️ **DEPRECATION NOTICE**: This command is deprecated in favour of the `maintain-index` skill which activates automatically. Instead of `/doc-update`, simply say "update the documentation" or "make sure the docs are current" and the skill will activate.

**Migration:** See MIGRATION.md for details on moving to skills-based workflows.

---

You are updating the project documentation to reflect recent changes.

## Your Task

1. **Scan for Changes**:
   - Check git status to see recently modified files: `!git status --short`
   - If git history is available, check recent commits: `!git log --oneline -10`
   - Read the current `docs/README.md` index to understand existing documentation

2. **Identify Affected Documentation**:
   - Use the file-to-documentation mapping in `docs/README.md`
   - Determine which feature docs need updating based on changed files
   - Look for features that might be affected by the changes

3. **Update Relevant Documentation**:
   - For each affected feature document:
     - Read the existing documentation
     - Read the modified source files
     - Update the documentation to reflect changes
     - Update the "Last updated" timestamp
   - If new files were added to an existing feature, add them to the "Key Files" section

4. **Update the Index**:
   - Refresh the file-to-documentation mapping in `docs/README.md`
   - Update the last modified date
   - Use the `@doc-manager` agent if needed to regenerate the index

5. **Report Changes**:
   - Summarise what documentation was updated
   - List any features that might need new documentation (suggest using `/doc-feature`)
   - Highlight any gotchas or warnings that should be added

## Guidelines

- Focus on keeping documentation accurate and current
- Don't remove information unless it's clearly obsolete
- If unsure whether something changed significantly, note it in the summary
- Maintain the existing documentation structure and style
