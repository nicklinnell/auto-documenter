# Feature: Doc Reader Agent

## Overview
The doc-reader agent is a read-only documentation access agent that provides comprehensive, detailed information from project documentation. It uses the `docs/README.md` index to discover relevant documentation and reports back with complete content, source references, and related file paths.

## Implementation Details

### Key Files
- `agents/doc-reader.md` - Agent definition with responsibilities and prompt (73 lines)
- `.claude-plugin/plugin.json:9` - Agent registration in plugin configuration
- `docs/README.md` - Index file used to discover documentation

### How It Works

#### 1. Agent Purpose
The doc-reader agent serves as the **read complement** to the doc-manager agent:
- **Doc-manager**: Writes and maintains the index
- **Doc-reader**: Reads documentation using the index

Unlike the doc-manager which summarises and organises, the doc-reader provides **complete, unfiltered content** so that other agents or the main conversation have full context to complete their tasks.

#### 2. Workflow

```
User/Agent Query
      ↓
Read docs/README.md index
      ↓
Identify relevant documentation files
      ↓
Read ALL relevant documentation
      ↓
Extract complete content (no summarisation)
      ↓
Report back with:
  - Full content from each doc
  - Source references (file:line)
  - Related source files
  - Cross-references
```

#### 3. Key Characteristics

**Read-Only Access**:
- Tools: Read, Grep, Glob only
- Cannot modify documentation
- Cannot create new files
- Pure consumption of existing docs

**Comprehensive Output**:
- Includes full relevant sections, not summaries
- Preserves code examples, lists, formatting
- Provides source references: `docs/category/file.md:line_number`
- Lists all related source files mentioned
- Includes architectural context and decision rationale

**Index-Driven Discovery**:
1. Always starts by reading `docs/README.md`
2. Uses file-to-documentation mapping to find relevant docs
3. Follows the index structure to understand what exists
4. Prioritises documentation based on relevance to query

#### 4. Usage Pattern

**Manual Invocation**:
```
@doc-reader <query>
```

**Example Queries**:
- "How does the hook system work?"
- "Find all documentation about agent configuration"
- "What are all the gotchas for the documentation commands?"
- "Show me everything about the index management system"

**Agent Response Structure**:
1. **Overview**: What documentation was found and read
2. **Complete Documentation Content**: For each relevant doc file
   - File path: `docs/category/file.md`
   - Full relevant content (actual content, not summary)
   - Preserved code examples, lists, formatting
   - Line numbers for key sections
3. **Related Source Files**: Complete list with paths
4. **Cross-References**: Other related documentation

#### 5. Integration with Other Agents

The doc-reader can be invoked by other agents when they need context:

**Example: Agent Planning a Feature**
```
Agent: @doc-reader Find documentation about how hooks work
Doc-reader: [Returns complete hook documentation]
Agent: [Uses context to plan feature implementation]
```

**Example: Agent Updating Documentation**
```
Agent: @doc-reader Show me all gotchas for the command system
Doc-reader: [Returns full gotchas documentation]
Agent: [Updates documentation avoiding known issues]
```

### Dependencies
- **Claude Code Agent System** - Provides agent execution environment
- **Documentation Index** (`docs/README.md`) - Required for discovering documentation
- **Read tool** - Reads documentation files
- **Glob tool** - Finds documentation files matching patterns
- **Grep tool** - Searches for specific content in documentation

### Configuration

#### Agent Definition (YAML Frontmatter)
```yaml
---
name: doc-reader
description: Reads project documentation and reports back with comprehensive, detailed information and source references for other agents
tools: Read, Grep, Glob
model: sonnet
color: green
---
```

**Tool Allowlist**:
- Read: For reading documentation files
- Grep: For searching within documentation
- Glob: For finding documentation files
- NO Edit/Write: Read-only agent
- NO Bash: Pure file operations only

**Model Selection**:
- Uses `sonnet` model (Claude Sonnet)
- Requires reasoning to understand query intent
- Needs context window for reading multiple docs simultaneously
- Can handle comprehensive documentation content

**Colour Coding**:
- Green: Indicates read-only, non-destructive operations
- Distinguishes from doc-manager (blue) which modifies files

## Important Notes & Gotchas

### ⚠️ Critical Points

1. **Depends on Index Accuracy**
   - Agent relies on `docs/README.md` being up to date
   - If index is stale, agent won't find recent documentation
   - No validation that index entries actually exist
   - **Mitigation**: Regularly regenerate index with `@doc-manager`

2. **No Built-In Query Intelligence**
   - Agent doesn't use semantic search or embedding
   - Relies on pattern matching and file name relevance
   - Complex queries may need rephrasing
   - **Example**: "auth" matches better than "how users log in"

3. **Can Return Large Amounts of Content**
   - Agent provides complete content, not summaries
   - Multiple documentation files can result in long responses
   - May approach token limits for comprehensive queries
   - **Trade-off**: Completeness vs. conciseness

4. **No Content Filtering**
   - Returns everything relevant, including:
     - Internal implementation details
     - Historical context that may be outdated
     - Verbose code examples
   - User/agent must process the raw content

5. **Manual Invocation Only**
   - Not automatically triggered by hooks or commands
   - User or other agent must explicitly call `@doc-reader`
   - No proactive documentation suggestions
   - **Design choice**: Avoids unwanted context injection

### 🐛 Known Issues

1. **No Caching Between Invocations**
   - Each invocation reads from disk
   - Repeated queries re-read same files
   - Performance impact for large documentation sets
   - **Future**: Consider caching mechanism

2. **Index-Only Discovery**
   - Only finds documentation listed in `docs/README.md`
   - Orphaned docs not in index are invisible
   - No fallback to filesystem scanning
   - **Workaround**: Ensure all docs are indexed

3. **Basename Matching Limitation**
   - Inherits same limitation as hook system
   - If index uses basenames, ambiguous matches possible
   - **Example**: Both `src/auth.ts` and `lib/auth.ts` match "auth.ts"
   - See: [Hook System Gotchas](../gotchas/hook-system-gotchas.md#2-basename-only-matching-limitation)

4. **No Incremental Reading**
   - Reads entire documentation files at once
   - Cannot handle extremely large individual files well
   - No pagination or chunking mechanism
   - **Practical limit**: Files >10,000 lines may be problematic

5. **Cross-Reference Following**
   - Agent notes cross-references but doesn't automatically follow them
   - User must make separate queries for linked documentation
   - No automatic expansion of related docs
   - **Design choice**: Prevents unbounded context growth

### 🔄 Future Improvements

1. **Semantic Search Integration**
   - Use embeddings for better query matching
   - "How does authentication work?" → finds auth docs
   - Reduce reliance on exact keyword matches

2. **Smart Content Filtering**
   - Optionally summarise very long sections
   - Highlight most relevant excerpts first
   - Include "full content available on request" option

3. **Query Refinement Prompts**
   - If query too broad, suggest refinements
   - "Found 10 docs. Specify: hooks, agents, or commands?"
   - Interactive narrowing of scope

4. **Automatic Cross-Reference Following**
   - Option to recursively load referenced docs
   - Depth limit to prevent infinite expansion
   - Visual indication of reference depth

5. **Caching Layer**
   - Cache recently read documentation in memory
   - Invalidate on file modification timestamps
   - Significant performance improvement for repeated queries

6. **Integration with Git History**
   - Include commit messages for last doc changes
   - Show when documentation was last updated
   - Link to relevant commits for context

7. **Structured Output Modes**
   - Option for JSON output for programmatic consumption
   - Markdown tables for quick reference
   - Code-only extraction mode

## Testing

### Manual Testing

#### Test 1: Basic Query
```bash
# Create some documentation first
/auto-documenter:doc-init
/auto-documenter:doc-feature test-feature

# Query the doc-reader
@doc-reader Show me documentation about test-feature

# Verify:
# - Returns complete content from docs/features/test-feature.md
# - Includes source references with line numbers
# - Lists related source files
```

#### Test 2: Multi-Document Query
```bash
# Query across multiple docs
@doc-reader Find all documentation about hooks

# Verify:
# - Returns content from docs/features/hook-system.md
# - Returns content from docs/gotchas/hook-system-gotchas.md
# - Organized by file
# - Cross-references noted
```

#### Test 3: Index Dependency
```bash
# Corrupt or remove index
mv docs/README.md docs/README.md.backup

# Try query
@doc-reader Show me feature documentation

# Verify:
# - Agent reports no index found or empty results
# - Graceful failure, not crash

# Restore index
mv docs/README.md.backup docs/README.md
```

#### Test 4: Read-Only Verification
```bash
# Check agent configuration
cat agents/doc-reader.md | grep "^tools:"

# Verify:
# - Only lists: Read, Grep, Glob
# - Does NOT include: Edit, Write, Bash
```

#### Test 5: Source Reference Format
```bash
# Query documentation
@doc-reader Show hook system documentation

# Verify source references follow format:
# - docs/features/hook-system.md:42
# - docs/gotchas/hook-system-gotchas.md:156
# - Includes line numbers where relevant
```

### Automated Testing (Future)
- Unit tests for query parsing
- Integration tests with mock documentation
- Performance tests for large documentation sets
- Regression tests for output format changes

## Related Documentation
- [Index Management](./index-management.md) - How doc-reader uses the index
- [Command System](./command-system.md) - Commands that create docs for doc-reader
- [Architecture Overview](../architecture/overview.md) - Overall system design

---
*Created: 2025-10-13*
*Last updated: 2025-10-13*
