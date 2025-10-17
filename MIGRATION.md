# Migration Guide: Commands → Skills

**Version:** 2.0.0
**Date:** 2025-10-17
**Status:** Commands deprecated but still functional

## Overview

Auto-documenter v2.0 introduces a skills-first architecture where documentation workflows activate automatically through natural language, rather than requiring explicit slash commands.

**Good news:** All existing commands still work! This migration is optional and gradual.

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
**A:** No! All commands still work exactly as before. This is a non-breaking change.

### Q: Do I have to migrate?
**A:** No, it's optional. Commands will continue to work for the foreseeable future.

### Q: What if a skill doesn't activate?
**A:** Fall back to the command. Skills activate based on natural language recognition, which isn't perfect. Commands are your explicit override.

### Q: Can I use both?
**A:** Yes! Use natural language when convenient, commands when you need explicit control.

### Q: Why deprecate commands if they still work?
**A:** We're guiding users toward the better experience (skills) while maintaining backward compatibility. Skills provide auto-activation, cross-platform support, and better composability.

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

## When to Still Use Commands

Commands are still useful for:

1. **Explicit Override**: When you want to force an action regardless of context
2. **Scripting**: Commands work better in automation scripts
3. **Teaching/Demos**: Commands are explicit and clear for demonstrations
4. **Debugging**: If a skill isn't activating, commands bypass the activation logic
5. **Planning**: `/doc-plan` has no direct skill replacement

## Reporting Issues

If you encounter skill activation issues:

1. **Try the command first** - Commands are your immediate workaround
2. **Report the issue** - Help us improve skill activation patterns
3. **Share your phrase** - Tell us what you said that didn't trigger the skill

## Timeline

- **v2.0.0** (2025-10-17): Skills introduced, commands deprecated but fully functional
- **v2.x.x** (future): Continued support for both, skill activation improvements
- **v3.0.0** (TBD): Potential removal of deprecated commands (with extensive notice)

## Need Help?

- See [README.md](./README.md) for skills overview
- See [docs/features/skills-system.md](./docs/features/skills-system.md) for technical details
- Try both approaches and use what works best for you

---

**Remember:** This is a gradual migration. Commands work indefinitely, giving you time to adopt skills at your own pace.
