# Feature: Index Management

## Overview
The index management system maintains a central `docs/README.md` file that acts as a smart map of all project documentation. The `@doc-manager` agent scans all documentation files, extracts file-to-documentation mappings, generates summaries, and keeps the index organised. This enables efficient context loading in hooks - only relevant documentation is loaded, not entire directories.

## Implementation Details

### Key Files
- `agents/doc-manager.md` - Agent definition with responsibilities and prompt (56 lines)
- `agents/doc-reader.md` - Agent that reads documentation and provides comprehensive context
- `.claude-plugin/plugin.json` - Plugin configuration listing both agents
- `docs/README.md` - The central index file (auto-generated and maintained)
- `hooks/pre-tool-use.sh:21` - Reads the index for documentation lookup
- `commands/doc-feature.md:66` - Updates index after feature documentation
- `commands/doc-update.md:31` - Refreshes index after updates
- `commands/doc-plan.md:60` - Adds plan references to index

### How It Works

#### 1. Index Structure
The `docs/README.md` file contains several key sections:

```markdown
## 🗂️ File-to-Documentation Mapping
Maps source code files to their documentation:
  src/app.ts → docs/features/app-core.md
  lib/auth.ts → docs/features/authentication.md

## 📝 Feature Documentation
Links to feature docs with 1-2 sentence summaries

## 🏗️ Architecture Documentation
Links to architecture docs with summaries

## ⚠️ Gotchas & Important Notes
Links to gotcha documents

## 🤔 Key Decisions
Links to Architecture Decision Records (ADRs)

## 💡 Planning Sessions
Date-stamped links to saved planning sessions
```

#### 2. Agent System

The index management system uses two agents:

##### A. Doc Manager Agent (`@doc-manager`)
The `@doc-manager` agent performs four main tasks:

**A. Scan Documentation Files**
- Glob patterns: `docs/features/*.md`, `docs/architecture/*.md`, etc.
- Reads each file to extract metadata
- Identifies file paths mentioned in "Key Files" sections

**B. Extract File Mappings**
- Parses "### Key Files" sections from feature documentation
- Format: `- path/to/file.ext - Description`
- Builds bidirectional mapping: file → docs, docs → files
- Groups mappings by feature/topic

**C. Generate Summaries**
- Extracts "## Overview" section from each document
- Condenses to 1-2 sentences
- Maintains context about what each doc covers
- Enables quick scanning of available documentation

**D. Update Index Atomically**
- Reads current `docs/README.md`
- Preserves structure and formatting
- Updates specific sections via Edit tool
- Maintains "Last updated" timestamp
- Never corrupts existing content

##### B. Doc Reader Agent (`@doc-reader`)
The `@doc-reader` agent complements the index by providing comprehensive documentation access:

**Purpose**:
- Reads documentation and reports back with detailed information
- Uses `docs/README.md` index to find relevant documentation
- Provides comprehensive context to other agents or the main conversation
- Includes full content, not summaries, with source references

**Key Characteristics**:
- **Tools**: Read, Grep, Glob (read-only access)
- **Model**: Sonnet
- **Colour**: Green
- **Invocation**: Manual via `@doc-reader` when detailed context needed

**How It Works**:
1. Starts by reading `docs/README.md` index
2. Identifies relevant documentation files based on query
3. Reads ALL relevant documentation (no skipping)
4. Reports back with complete content, preserving formatting
5. Includes source references: `docs/category/file.md:line_number`
6. Lists related source files mentioned in documentation

**Use Cases**:
- Agent needs full context about how a feature works
- Comprehensive information about architectural decisions required
- Detailed gotchas or edge cases need to be understood
- Planning a change and need documentation review

**Index Integration**:
- Relies on index to discover what documentation exists
- Uses file-to-documentation mapping to find relevant docs
- Provides the "read" complement to doc-manager's "write" role

#### 3. Hook Integration

**PreToolUse Hook Consumption** (`pre-tool-use.sh:21`):
```bash
# Read the index to find relevant documentation
INDEX_CONTENT=$(cat "docs/README.md")

# Search for files matching the target
RELEVANT_DOCS=$(echo "$INDEX_CONTENT" | grep -i "$(basename "$FILE_PATH")" | grep -oE 'docs/[a-zA-Z0-9_/-]+\.md' | sort -u)
```

**How hook uses the index**:
1. Reads entire `docs/README.md` into memory
2. Searches for basename of file being edited
3. Extracts documentation paths using regex
4. Loads only those specific documentation files
5. Injects their content into Claude's context

**Efficiency benefit**:
- Without index: Hook would need to scan all of `docs/` (expensive)
- With index: Hook reads one file, extracts paths, loads only relevant docs
- Scales to projects with hundreds of documentation files

#### 4. Command Integration

**After `/auto-documenter:doc-feature`**:
- Command creates `docs/features/feature-name.md`
- Command manually updates `docs/README.md` with new feature
- Optionally calls `@doc-manager` to verify and clean up index

**After `/auto-documenter:doc-update`**:
- Command modifies existing documentation
- May add new file mappings
- Calls `@doc-manager` to regenerate index sections

**After `/auto-documenter:doc-plan`**:
- Command creates `docs/plans/YYYY-MM-DD-plan-name.md`
- Adds entry to "Planning Sessions" section
- Uses `@doc-manager` to maintain chronological order

### Dependencies
- **Claude Code Agent System** - Provides agent execution environment
- **Read tool** - Reads documentation files and index
- **Glob tool** - Finds all documentation files in subdirectories
- **Grep tool** - Searches for patterns in documentation (optional)
- **Edit tool** - Updates specific sections of `docs/README.md`
- **Write tool** - Creates new index if none exists
- **Markdown parsing** - Extracts sections based on header levels

### Configuration

#### Agent Definitions

##### Plugin Configuration (`.claude-plugin/plugin.json`)
```json
{
  "agents": ["./agents/doc-manager.md", "./agents/doc-reader.md"]
}
```

Both agents are registered in the plugin configuration.

##### Doc Manager Agent (YAML Frontmatter)
```yaml
---
name: doc-manager
description: Maintains the documentation index in docs/README.md by scanning all documentation files and generating organised summaries
tools: Read, Grep, Glob, Edit, Write
model: sonnet
color: blue
---
```

**Tool allowlist**:
- Read, Grep, Glob: For scanning documentation
- Edit, Write: For updating the index
- NO Bash access: Pure file operations only

**Model selection**:
- Uses `sonnet` model (Claude Sonnet)
- Requires reasoning for accurate section extraction
- Needs context window for reading multiple docs

##### Doc Reader Agent (YAML Frontmatter)
```yaml
---
name: doc-reader
description: Reads project documentation and reports back with comprehensive, detailed information and source references for other agents
tools: Read, Grep, Glob
model: sonnet
color: green
---
```

**Tool allowlist**:
- Read, Grep, Glob: For reading and searching documentation
- NO Edit or Write: Read-only access
- NO Bash access: Pure file operations only

**Model selection**:
- Uses `sonnet` model (Claude Sonnet)
- Requires reasoning for understanding documentation queries
- Needs context window for reading multiple documentation files

#### Index Template (from `/auto-documenter:doc-init`)
Created by `commands/doc-init.md` with placeholder structure:
- Empty sections with guidance text
- Emoji visual markers (📋 📁 🗂️ 📝 🏗️ ⚠️ 🤔 💡)
- Hierarchical markdown headers
- "Last updated" timestamp at bottom

## Important Notes & Gotchas

### ⚠️ Critical Points

1. **Index Is a Single Point of Failure**
   - If `docs/README.md` is corrupted, hooks stop working
   - PreToolUse hook exits silently if index is missing (line 16-18)
   - No automatic recovery mechanism
   - **Mitigation**: Keep index in git, commit frequently

2. **Basename-Only Search Limitation**
   - Hook searches index using `basename "$FILE_PATH"` only
   - Index maps full paths: `src/auth.ts → docs/features/auth.md`
   - Search matches "auth.ts" in both `src/auth.ts` and `lib/auth.ts`
   - **Result**: Index is correct, but hook search is ambiguous
   - **See**: [Hook System Gotchas](../gotchas/hook-system-gotchas.md#2-basename-only-matching-limitation)

3. **Manual vs Automatic Index Updates**
   - Commands like `/auto-documenter:doc-feature` manually update the index
   - Agent is called separately to verify/clean up
   - Not all commands automatically invoke `@doc-manager`
   - **Risk**: Index can become stale if agent isn't invoked
   - **Solution**: Periodically run `@doc-manager regenerate the documentation index`

4. **Concurrent Documentation Edits**
   - Agent reads entire index, modifies sections, writes back
   - If multiple edits happen simultaneously, race condition possible
   - Last write wins, earlier changes may be lost
   - **Rare scenario**: Multiple developers documenting at same time
   - **Mitigation**: Git conflict resolution will catch this

5. **Section Extraction Depends on Exact Headers**
   - Agent expects specific header names: `## Overview`, `### Key Files`
   - Typos break extraction: `## Overiew` (missing 'v')
   - Case sensitivity: `## overview` may not match
   - Markdown variations: `##Overview` (no space) won't match
   - **Impact**: Files not added to index, hooks won't find them

6. **Regex Path Extraction in Hooks** (pre-tool-use.sh:25)
   ```bash
   grep -oE 'docs/[a-zA-Z0-9_/-]+\.md'
   ```
   - Only matches alphanumeric paths with underscores, hyphens, slashes
   - Doesn't match:
     - Paths with spaces: `docs/my feature.md`
     - Paths with dots: `docs/v1.2-features.md` (stops at dot)
     - Paths with special chars: `docs/auth&session.md`
   - **Impact**: Valid documentation isn't found by hooks

### 🐛 Known Issues

1. **No Validation of Documentation Links**
   - Agent doesn't verify that linked docs actually exist
   - Broken links: `[Feature](features/missing.md)` added to index
   - PreToolUse hook will try to read non-existent files
   - Results in empty context injection

2. **No Circular Reference Detection**
   - Doc A can reference Doc B, which references Doc A
   - Agent may infinite loop if following references
   - Current implementation doesn't follow references (safe)
   - Future enhancement might need cycle detection

3. **Planning Session Timestamps**
   - Plans use filename format: `YYYY-MM-DD-plan-name.md`
   - Not validated by agent
   - Malformed dates: `2025-13-45-plan.md` accepted
   - Affects chronological sorting

4. **Index Bloat Over Time**
   - Old documentation accumulates in index
   - No automatic removal of outdated entries
   - File-to-documentation mapping grows unbounded
   - **Workaround**: Manually remove obsolete entries

5. **No Index Version Tracking**
   - Index format may evolve over time
   - No version field to track format changes
   - Future changes may break older hooks
   - Migration path not defined

### 🔄 Future Improvements

1. **Index Validation Tool**
   - Verify all documentation links are valid
   - Check that referenced files exist
   - Detect orphaned documentation (not in index)
   - Report stale entries

2. **Automatic Agent Invocation**
   - Hook into PostToolUse for documentation changes
   - Auto-regenerate index after doc modifications
   - Reduce manual `@doc-manager` calls

3. **Full-Path Indexing**
   - Replace basename matching with full path
   - Store: `{"src/auth.ts": ["docs/features/auth.md"]}`
   - Enables precise documentation lookup
   - Requires JSON or YAML index format

4. **Index Caching**
   - Cache parsed index in memory/file
   - Invalidate on `docs/README.md` modification
   - Reduce repeated file reads in hooks
   - Significant performance improvement

5. **Structured Index Format**
   - Consider YAML or JSON instead of markdown
   - Easier parsing (no regex needed)
   - Enables rich metadata (tags, priority, timestamps)
   - Backward compatibility challenge

6. **Smart Summary Generation**
   - Use LLM to generate concise summaries
   - Extract key phrases automatically
   - Highlight most critical information
   - Better than manual overview extraction

## Testing

### Manual Testing

#### Test 1: Index Generation
```bash
# Create some documentation
/auto-documenter:doc-feature test-feature
/auto-documenter:doc-plan test-plan

# Regenerate index
@doc-manager regenerate the documentation index

# Verify sections populated
cat docs/README.md
# Should show mappings, feature links, plan links
```

#### Test 2: Index Search (Hook Perspective)
```bash
# Create docs/README.md with test content
echo "src/app.ts → docs/features/app.md" >> docs/README.md

# Simulate hook search
basename "src/app.ts"  # Output: app.ts
grep -i "app.ts" docs/README.md | grep -oE 'docs/[a-zA-Z0-9_/-]+\.md'
# Should output: docs/features/app.md
```

#### Test 3: Agent Tool Access
```bash
# Verify agent has correct tools
cat agents/doc-manager.md | grep "^tools:"
# Should show: tools: Read, Grep, Glob, Edit, Write
```

#### Test 4: Index Corruption Recovery
```bash
# Backup current index
cp docs/README.md docs/README.md.backup

# Corrupt index
echo "garbage content" > docs/README.md

# Try hook operation (should fail gracefully)
# Edit any file - hook should exit silently

# Restore index
cp docs/README.md.backup docs/README.md

# Regenerate with agent
@doc-manager regenerate the documentation index
```

### Automated Testing (Future)
- Unit tests for index parsing logic
- Integration tests for agent invocation
- Regression tests for index format changes

## Related Documentation
- [Hook System](./hook-system.md) - How hooks consume the index
- [Command System](./command-system.md) - How commands update the index
- [Architecture Overview](../architecture/overview.md) - Overall system design
- [Hook System Gotchas](../gotchas/hook-system-gotchas.md#2-basename-only-matching-limitation) - Basename matching issue

---
*Created: 2025-10-10*
*Last updated: 2025-10-13*
