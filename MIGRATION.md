# Migration Guide: Commands → Skills

**Version:** 2.0.0
**Date:** 2025-10-17
**Status:** Commands removed (except /doc-plan) - use skills instead

## Overview

Auto-documenter v2.0 introduces a skills-first architecture where documentation workflows activate automatically through natural language, rather than requiring explicit slash commands.

**Breaking Change:** Commands have been removed (except `/doc-plan`). Use natural language with skills instead.

## What Changed?

### Before (v1.x - Commands)
```bash
# Explicit command invocation
/doc-init
/doc-feature authentication
/doc-update
/doc-review
/doc-plan api-redesign
```

### After (v2.0 - Skills)
```
# Natural language activation
You: "Let's setup documentation"
Claude: [document-codebase skill activates]

You: "Document the authentication system"
Claude: [document-feature skill activates]

You: "Make sure the docs are current"
Claude: [maintain-index skill activates]

You: "Check our documentation coverage"
Claude: [review-documentation skill activates]

# Plans still use command (no replacement)
/doc-plan api-redesign
```

## Migration Map

| Old Command | New Skill | Natural Language Examples |
|-------------|-----------|---------------------------|
| `/doc-init` | `document-codebase` | "initialise docs", "setup documentation", "create docs structure" |
| `/doc-feature <name>` | `document-feature` | "document the <name> feature", "add docs for <name>", "document this" |
| `/doc-update` | `maintain-index` | "update the docs", "refresh documentation", "make sure docs are current" |
| `/doc-review` | `review-documentation` | "review the docs", "check documentation coverage", "audit our documentation" |
| `/doc-plan <name>` | _(no replacement)_ | Still use `/doc-plan <name>` - command remains supported |

## Benefits of Skills

### 1. **No Command Memorization**
You don't need to remember specific command syntax - just describe what you want in natural language.

**Before:**
```bash
# Had to remember: /doc-feature, not /document-feature or /doc-new-feature
/doc-feature user-dashboard
```

**After:**
```
# Just describe what you want
You: "I've built a user dashboard, let's document it"
Claude: [document-feature skill activates automatically]
```

### 2. **Cross-Platform**
Skills work in Claude Apps, API, and Claude Code - not just Claude Code.

### 3. **Automatic Activation**
Claude recognizes when documentation is needed without you having to think about it.

### 4. **Composability**
Skills can invoke other skills and agents automatically, creating more sophisticated workflows.

## Gradual Migration Path

You can migrate at your own pace:

### Phase 1: Try Skills (Keep Using Commands)
- Start using natural language for new documentation tasks
- Fall back to commands when needed
- Both work identically

### Phase 2: Prefer Skills (Commands as Backup)
- Default to natural language
- Use commands only when skills don't activate
- Report any activation issues

### Phase 3: Skills Only (Commands for Edge Cases)
- Fully adopt natural language workflows
- Only use commands for explicit overrides
- `/doc-plan` remains useful

## Common Questions

### Q: Will my existing workflows break?
**A:** Yes, if you were using `/doc-feature`, `/doc-init`, `/doc-update`, or `/doc-review` commands. These have been removed. Use natural language with skills instead.

### Q: Do I have to migrate?
**A:** Yes. The commands no longer exist. Use natural language to activate skills, or use `/doc-plan` for planning sessions.

### Q: What if a skill doesn't activate?
**A:** Try rephrasing your request. Skills activate based on natural language recognition. Examples: "document this feature", "initialise docs", "update the documentation", "review the docs".

### Q: What if I really need the old commands?
**A:** Checkout the previous version (v1.1.0) if you need the old commands. However, skills provide the same functionality with a better experience.

### Q: Why remove commands?
**A:** Skills provide a better experience (auto-activation, cross-platform support, better composability) and maintaining both added unnecessary complexity.

## Detailed Migration Examples

### Example 1: Starting a New Project

**Before (Commands):**
```bash
/doc-init
# Wait for completion
/doc-feature authentication
# Wait for completion
/doc-feature api-routes
```

**After (Skills):**
```
You: "Let's setup documentation for this project"
Claude: [document-codebase skill activates, creates docs/ structure]

You: "Document the authentication system"
Claude: [document-feature skill activates, creates docs/features/authentication.md]

You: "Document the API routing"
Claude: [document-feature skill activates, creates docs/features/api-routes.md]
```

###  Example 2: After Making Changes

**Before (Commands):**
```bash
# Make code changes
git add .
/doc-update
```

**After (Skills):**
```
# Make code changes
You: "Make sure the documentation is current"
Claude: [maintain-index skill activates, scans and updates index]
```

### Example 3: Periodic Review

**Before (Commands):**
```bash
/doc-review
# Read the output
/doc-feature payment-processing  # Based on review
```

**After (Skills):**
```
You: "Check our documentation coverage"
Claude: [review-documentation skill activates, generates coverage report]

You: "Document the payment processing system"
Claude: [document-feature skill activates]
```

## When to Use the Remaining Command

The `/doc-plan` command is still useful for:

1. **Explicit Planning Sessions**: Save planning outputs to `docs/plans/`
2. **Dated Archives**: Planning sessions with timestamps for historical reference
3. **Scripting**: If you need to automate plan saving

For all other documentation workflows, use skills with natural language.

## Reporting Issues

If you encounter skill activation issues:

1. **Try rephrasing** - Use different natural language to trigger the skill
2. **Report the issue** - Help us improve skill activation patterns
3. **Share your phrase** - Tell us what you said that didn't trigger the skill

## Timeline

- **v1.1.0** (2025-01-17): Command-based workflows
- **v2.0.0** (2025-10-17): Skills-first architecture, old commands removed (except /doc-plan)

## Need Help?

- See [README.md](./README.md) for skills overview
- See [docs/features/skills-system.md](./docs/features/skills-system.md) for technical details
- Try both approaches and use what works best for you

---

**Remember:** v2.0.0 is skills-first. Use natural language to activate documentation workflows.
