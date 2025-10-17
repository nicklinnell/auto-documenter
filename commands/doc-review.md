---
description: "[DEPRECATED] Review and audit documentation coverage. Use the review-documentation skill instead (just say 'review the docs')"
allowed-tools: Read, Grep, Glob, Bash
---

⚠️ **DEPRECATION NOTICE**: This command is deprecated in favour of the `review-documentation` skill which activates automatically. Instead of `/doc-review`, simply say "review the documentation" or "check documentation coverage" and the skill will activate.

**Migration:** See MIGRATION.md for details on moving to skills-based workflows.

---

You are conducting a documentation coverage audit for this project.

## Your Task

1. **Analyse Project Structure**:
   - List all source code directories and major files
   - Identify key features and modules in the codebase
   - Use Glob to find major code files (*.ts, *.js, *.py, etc.)

2. **Review Existing Documentation**:
   - Read `docs/README.md` to see what's currently documented
   - List all feature documentation files in `docs/features/`
   - Check architecture documentation in `docs/architecture/`
   - Review gotchas in `docs/gotchas/`
   - Check decision records in `docs/decisions/`

3. **Identify Coverage Gaps**:
   - Compare the codebase structure with documented features
   - Find significant features or modules that lack documentation
   - Identify files that appear in multiple features but aren't clearly mapped
   - Look for complex code areas that would benefit from architecture docs

4. **Generate Audit Report**:
   - Summarise current documentation coverage
   - List well-documented areas
   - Highlight undocumented or poorly documented features
   - Suggest priority areas for documentation
   - Recommend which `/doc-feature` or architecture docs to create

5. **Check Documentation Quality**:
   - Identify documentation that might be outdated
   - Check if file-to-documentation mappings are accurate
   - Suggest improvements to existing docs

## Report Structure

Present your findings in this format:

```markdown
# Documentation Coverage Audit

## Summary
- **Total Features Documented**: X
- **Architecture Docs**: X
- **Gotchas/Warnings**: X
- **Decision Records**: X

## Well-Documented Areas ✅
- [Feature name] - comprehensive coverage
- [Another feature] - good detail

## Documentation Gaps ⚠️

### High Priority (Core Features)
- [Feature/module name] - why it needs documentation
- [Another feature] - impact and importance

### Medium Priority
- [Feature name] - suggested focus areas

### Low Priority
- [Minor features or utilities]

## Recommendations

1. **Immediate Actions**:
   - `/doc-feature [feature-name]` - [reason]
   - Create architecture doc for [system]

2. **Quality Improvements**:
   - Update [existing doc] - [why]
   - Add gotchas for [feature]

3. **Index Maintenance**:
   - Regenerate file mappings using `@doc-manager`
```

Be thorough but prioritise areas that will provide the most value for future development.
