# Feature: Hook System

## Overview
The hook system automatically injects relevant documentation into Claude Code's context before file edits and reminds developers to update documentation after changes. This ensures Claude always considers design decisions and gotchas before modifying code, preventing accidental removal of critical logic.

## Implementation Details

### Key Files
- `hooks/hooks.json` - Hook definitions and tool matchers (26 lines)
- `hooks/pre-tool-use.sh` - Context injection before Edit/Write operations (58 lines)
- `hooks/post-tool-use.sh` - Documentation reminders after Edit/Write operations (52 lines)
- `plugin.json` - References hooks.json via the "hooks" field

### How It Works

#### PreToolUse Hook (Context Injection)
1. **Trigger**: Fires before `Edit`, `Write`, or `MultiEdit` tool calls
2. **Input**: Receives `$TOOL_INPUT` environment variable containing tool parameters as JSON
3. **Process**:
   - Parses `file_path` from `$TOOL_INPUT` using `jq`
   - Checks if `docs/README.md` exists (exits silently if not)
   - Searches the index for documentation referencing the target file
   - Uses basename matching: `grep -i "$(basename "$FILE_PATH")"`
   - Extracts documentation file paths using regex: `docs/[a-zA-Z0-9_/-]+\.md`
4. **Output**: Injects a formatted message with:
   - Overview sections from relevant docs
   - Important Notes & Critical Points sections
   - Limited to first 50 lines per doc (via `head -50`)
   - Links to full documentation files

#### PostToolUse Hook (Documentation Reminders)
1. **Trigger**: Fires after `Edit`, `Write`, or `MultiEdit` tool calls complete
2. **Input**: Receives both `$TOOL_NAME` and `$TOOL_INPUT` environment variables
3. **Process**:
   - Verifies the tool was Edit/Write/MultiEdit
   - Parses `file_path` from `$TOOL_INPUT`
   - Skips trivial files: `docs/*`, `*.json`, `*.md`, `*.lock`, `package.json`
   - Checks if file is documented by searching `docs/README.md`
4. **Output**:
   - **If documented**: Suggests `/auto-documenter:doc-update` to refresh documentation
   - **If not documented**: Suggests `/auto-documenter:doc-feature` or `/auto-documenter:doc-review`

### Dependencies
- **bash** - Shell interpreter (both scripts use `#!/bin/bash`)
- **jq** - JSON parsing for `$TOOL_INPUT` parameter extraction
- **grep** - Pattern matching for documentation lookup
- **awk** - Section extraction from markdown documentation
- **Claude Code** - Provides hook environment variables and execution context

### Configuration

#### Environment Variables (Provided by Claude Code)
- `$TOOL_NAME` - Name of the tool being invoked (e.g., "Edit", "Write")
- `$TOOL_INPUT` - JSON string containing tool parameters (e.g., `{"file_path": "src/app.ts"}`)
- `$CLAUDE_PLUGIN_ROOT` - Absolute path to the plugin installation directory

#### hooks.json Structure
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",  // Regex for tool names
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/pre-tool-use.sh"
          }
        ]
      }
    ],
    "PostToolUse": [ /* same structure */ ]
  }
}
```

## Important Notes & Gotchas

### ⚠️ Critical Points

1. **Executable Permissions Required**
   - Hook scripts MUST be executable: `chmod +x hooks/*.sh`
   - Installation process should ensure this, but manual cloning may not
   - Hooks will fail silently if permissions are incorrect

2. **Basename-Only Matching Limitation** (pre-tool-use.sh:25)
   - Uses `basename "$FILE_PATH"` for matching documentation
   - **Problem**: Cannot distinguish files with same name in different directories
   - **Example**: Both `src/utils/auth.ts` and `lib/utils/auth.ts` match "auth.ts"
   - **Impact**: May inject incorrect documentation for ambiguous filenames
   - **Mitigation**: Use unique filenames or full path matching in future versions

3. **Silent Failures by Design**
   - All error conditions exit with code 0 (success)
   - Hooks never block the user's workflow
   - **Debugging challenge**: Hard to diagnose why hooks don't fire
   - **Trade-off**: UX over debuggability - intentional design choice

4. **JQ Dependency Not Checked**
   - Scripts assume `jq` is installed but don't verify
   - If `jq` is missing, `$TOOL_INPUT` parsing fails silently
   - **Solution**: Document jq as a system requirement

5. **Environment Variable Injection**
   - `$CLAUDE_PLUGIN_ROOT` must be correctly set by Claude Code
   - Recent fix (commit a87e75f) addressed path resolution issues
   - Without this variable, hooks can't find the correct script paths

6. **AWK Section Extraction Logic** (pre-tool-use.sh:44-48)
   - Extracts markdown sections using header pattern matching
   - **Fragile**: Assumes specific header formats (`## Overview`, `### ⚠️ Critical Points`)
   - Changes to documentation template structure could break extraction
   - Uses negative lookahead pattern to stop at next section

### 🐛 Known Issues

1. **No Multi-File Context Aggregation**
   - Each documentation file is processed independently
   - Cannot correlate information across multiple related docs
   - May present duplicate or conflicting information

2. **Head Truncation May Cut Mid-Sentence** (line 48)
   - `head -50` limits output but doesn't respect sentence boundaries
   - Can result in incomplete gotcha descriptions

3. **Grep Regex Extraction Limitations** (line 25)
   - Pattern `docs/[a-zA-Z0-9_/-]+\.md` doesn't match:
     - Docs with spaces in filenames
     - Docs with special characters
     - Docs in nested subdirectories with dots

4. **PostToolUse Skip Logic Too Broad** (post-tool-use.sh:26)
   - Skips ALL `.json` and `.md` files
   - Some JSON files (e.g., `tsconfig.json`, `schema.json`) might warrant documentation
   - Some markdown files (e.g., project-specific templates) might warrant documentation

### 🔄 Future Improvements

1. **Full Path Matching**
   - Replace basename matching with full path comparison
   - Use fuzzy matching or path normalisation
   - Build a proper file-to-doc mapping cache

2. **Dependency Checking**
   - Add `command -v jq` check at script start
   - Provide user-friendly error messages if dependencies are missing
   - Consider bundling jq or using pure bash JSON parsing

3. **Smart Section Extraction**
   - Replace AWK with a proper markdown parser
   - Extract sections based on YAML frontmatter tags
   - Support user-defined section priorities

4. **Hook Debugging Mode**
   - Add `DEBUG=1` environment variable support
   - Log to a debug file when enabled
   - Show why hooks fire or don't fire

5. **Caching Layer**
   - Cache parsed `docs/README.md` index
   - Invalidate cache when index changes
   - Reduce file I/O for every tool invocation

6. **Smarter File Type Detection**
   - Use file extension whitelist/blacklist configuration
   - Allow users to customise skip patterns
   - Consider file size and code complexity for skip decisions

## Testing

### Manual Testing
1. **Test PreToolUse Hook**:
   ```bash
   # Document a feature first
   /doc-feature test-feature

   # Try to edit a file mentioned in that feature's docs
   # Expected: See documentation context injected before the edit
   ```

2. **Test PostToolUse Hook**:
   ```bash
   # Edit a documented file
   # Expected: See "/doc-update" suggestion

   # Edit an undocumented file
   # Expected: See "/doc-feature" suggestion
   ```

3. **Test Hook Failures**:
   ```bash
   # Remove executable permissions
   chmod -x hooks/pre-tool-use.sh

   # Try to edit a file
   # Expected: Hook doesn't fire, but workflow continues

   # Restore permissions
   chmod +x hooks/pre-tool-use.sh
   ```

### Test Environment Variables
```bash
# Simulate hook execution
export TOOL_INPUT='{"file_path": "src/app.ts"}'
export TOOL_NAME="Edit"
export CLAUDE_PLUGIN_ROOT="/path/to/plugin"

bash hooks/pre-tool-use.sh
```

### Test Cases from INSTALL.md
- Test 5: Automatic Context Injection
- Test 6: Documentation Reminders

## Related Documentation
- [Architecture Overview](../architecture/overview.md) - Overall system design
- [Index Management](./index-management.md) - How docs/README.md is maintained
- [Plugin Configuration](../architecture/plugin-structure.md) - How hooks.json is loaded

---
*Created: 2025-10-10*
*Last updated: 2025-10-10*
