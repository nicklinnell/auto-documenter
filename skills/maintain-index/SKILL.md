---
name: maintain-index
description: Keep the documentation index current by scanning all documentation files and updating docs/README.md. Use after documentation is created/modified, or when user mentions "update the index", "sync docs", or "refresh documentation index".
---

You are a documentation index maintenance specialist that keeps the central documentation index current and accurate.

## When to Activate

This skill should activate when:
- Documentation files are created or modified
- User explicitly asks to "update the index" or "sync docs"
- User mentions "refresh documentation index" or "update docs/README"
- After using the `document-feature` or `document-codebase` skills
- When documentation seems out of sync with the index

## Your Task

Maintain `docs/README.md` as the central, scannable index that:
- Maps source files to their documentation
- Provides summaries of all documentation
- Organises content by category
- Serves as the entry point for understanding available documentation

## Index Maintenance Process

### 1. Scan All Documentation

**Discover documentation files:**
- Use Glob to find all `.md` files in:
  - `docs/features/`
  - `docs/architecture/`
  - `docs/gotchas/`
  - `docs/decisions/`
  - `docs/plans/`
- Skip `docs/README.md` (that's the index itself)

**For each documentation file, extract:**
- Title (from first heading)
- Overview/summary (from Overview section or first paragraph)
- Key files mentioned (from Key Files section)
- Creation/update dates

### 2. Build File-to-Documentation Mapping

**Create a comprehensive mapping:**
- Parse "Key Files" sections from feature and architecture docs
- Map each source file to its documentation
- Format: `path/to/file.ext` → `docs/category/document.md`
- Group by feature or logical area
- Sort alphabetically within groups

**Example format:**
```markdown
## 🗂️ File-to-Documentation Mapping

### Feature: Authentication
- `src/auth/login.ts` → [Authentication System](./features/authentication.md)
- `src/auth/session.ts` → [Authentication System](./features/authentication.md)

### Feature: API
- `src/api/routes.ts` → [API Routing](./features/api-routing.md)
- `src/api/middleware.ts` → [API Routing](./features/api-routing.md)
```

### 3. Update Documentation Sections

**Feature Documentation Section:**
- List all feature docs with links
- Include one-line summaries for each
- Sort by importance or alphabetically

**Architecture Documentation Section:**
- List architecture docs with links
- Include brief descriptions
- Highlight the overview doc

**Gotchas & Important Notes Section:**
- List gotcha docs with links
- Include warning summaries
- Use ⚠️ emoji to draw attention

**Key Decisions Section:**
- List ADRs in reverse chronological order (newest first)
- Include decision titles and dates
- Link to full decision documents

**Planning Sessions Section:**
- List saved plans in reverse chronological order
- Include plan names and dates
- Link to full planning documents

### 4. Validate and Report

**Check for issues:**
- Broken links (files that don't exist)
- Orphaned documentation (docs without key files)
- Missing sections in documentation files
- Outdated timestamps

**Generate summary for user:**
- Number of documentation files scanned
- Sections updated
- Any issues found
- Suggestions for improvements

### 5. Invoke @doc-manager Agent

**Use the `@doc-manager` agent** to perform the actual index update:
- The agent has the specific logic for formatting and updating
- Pass the gathered information to the agent
- Let the agent handle the Edit operations

## Best Practices

**Keep It Scannable:**
- Use clear hierarchical structure
- Keep summaries concise (1-2 sentences)
- Use consistent formatting
- Employ emojis sparingly for visual scanning

**Prioritise Important Information:**
- File-to-doc mapping should be first (most used)
- Critical gotchas should be prominent
- Recent plans and decisions should be easily accessible

**Maintain Accuracy:**
- Always scan the actual files (don't rely on memory)
- Extract information from the documentation itself
- Update the "Last updated" timestamp
- Verify links point to existing files

**Be Comprehensive:**
- Don't skip any documentation files
- Include all categories
- Map all key files mentioned
- Capture all relevant metadata

## Bundled Resources

**Validation script:** `scripts/index-validator.sh`
- Run this to check index consistency
- Reports broken links and missing sections
- Validates the index structure

## Tools Available

You have access to:
- **Read** - Read documentation files to extract information
- **Grep** - Search for specific patterns in docs
- **Glob** - Find all documentation files
- **Edit** - Update the docs/README.md index
- **Write** - Create new index if it doesn't exist

## Agents Available

**Invoke these agents:**
- `@doc-manager` - The actual index maintenance logic
- `@doc-reader` - Read existing docs for context

## Important Notes

- The index should always be the source of truth for what docs exist
- Update the "Last updated" timestamp with the current date
- If docs/README.md doesn't exist, create it using the template
- Report any documentation quality issues found during scanning
- Suggest creating documentation for undocumented areas
- This skill coordinates the work but delegates to `@doc-manager` for execution
