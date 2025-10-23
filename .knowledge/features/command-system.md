# Feature: Command System

## Overview
The command system provides five slash commands (`/auto-documenter:doc-init`, `/auto-documenter:doc-feature`, `/auto-documenter:doc-update`, `/auto-documenter:doc-review`, `/auto-documenter:doc-plan`) that create and maintain project documentation. Commands are defined as markdown files with YAML frontmatter containing descriptions, tool allowlists, and prompt templates that get expanded with user arguments.

## Implementation Details

### Key Files
- `plugin.json:8` - Points to `"commands": "./commands/"` directory
- `commands/doc-init.md` - Initialises documentation structure (2316 bytes)
- `commands/doc-feature.md` - Documents specific features (2085 bytes)
- `commands/doc-update.md` - Updates docs after changes (1719 bytes)
- `commands/doc-review.md` - Audits documentation coverage (2499 bytes)
- `commands/doc-plan.md` - Saves planning sessions (2277 bytes)

### How It Works

#### 1. Command Discovery & Loading

**Plugin Configuration** (`plugin.json`):
```json
{
  "commands": "./commands/"
}
```

- Claude Code scans the `./commands/` directory
- Discovers all `.md` files
- Command name = `plugin-name:filename` without extension (`doc-init.md` → `/auto-documenter:doc-init`)
- Commands are loaded at plugin installation time

#### 2. Command File Structure

**YAML Frontmatter** (metadata):
```yaml
---
description: Brief description shown in command list
allowed-tools: Write, Read, Grep, Glob, Edit, Bash
---
```

**Markdown Body** (prompt template):
- Instructions for Claude Code to execute
- Can reference arguments using `$1`, `$2`, etc.
- Contains step-by-step execution plan
- Specifies output format and structure

**Example** (`doc-feature.md`):
```markdown
---
description: Document a specific feature with context and gotchas
allowed-tools: Write, Read, Grep, Glob, Edit
---

You are documenting a feature for the auto-documentation system. The feature name is: **$1**

Follow these steps:
1. **Gather Context**: [instructions]
2. **Create Feature Documentation**: [template]
3. **Update the Index**: [instructions]
...
```

#### 3. Command Execution Flow

**User invocation**:
```bash
/doc-feature authentication
```

**Claude Code processes**:
1. Parses command name: `doc-feature`
2. Looks up `commands/doc-feature.md`
3. Reads YAML frontmatter
4. Extracts `allowed-tools` list
5. Reads markdown body (prompt template)
6. Substitutes `$1` with `authentication`
7. Executes the expanded prompt with tool restrictions
8. Claude Code follows the instructions in the prompt

**Tool restriction**:
- Claude Code only allows tools listed in `allowed-tools`
- Prevents commands from using unintended tools
- Example: `/auto-documenter:doc-review` cannot use Write (read-only audit)

#### 4. Argument Substitution

**Positional arguments**:
- `$1` = first argument
- `$2` = second argument (if applicable)
- `$n` = nth argument

**Example**:
```bash
# User runs:
/auto-documenter:doc-plan user-authentication-redesign

# Template contains:
The plan name is: **$1**

# Expands to:
The plan name is: **user-authentication-redesign**
```

**No arguments**:
- Commands like `/auto-documenter:doc-init`, `/auto-documenter:doc-review`, `/auto-documenter:doc-update` take no arguments
- No `$1` substitution needed
- Prompt is executed as-is

#### 5. Command Descriptions

Commands appear in Claude Code's command palette with their descriptions:

| Command | Description | Arguments |
|---------|-------------|-----------|
| `/auto-documenter:doc-init` | Initialize documentation structure in the current project | None |
| `/auto-documenter:doc-feature` | Document a specific feature with context and gotchas | `<feature-name>` |
| `/auto-documenter:doc-update` | Update existing documentation based on recent changes | None |
| `/auto-documenter:doc-review` | Review and audit documentation coverage | None |
| `/auto-documenter:doc-plan` | Save a planning session to the .knowledge/plans/ directory | `<plan-name>` |

### Dependencies

- **Claude Code Plugin System** - Loads commands from plugin.json
- **Markdown Parser** - Parses YAML frontmatter and markdown body
- **Variable Substitution** - Replaces `$1`, `$2`, etc. with arguments
- **Tool Access Control** - Enforces `allowed-tools` restrictions
- **Working Directory Context** - Commands execute in user's project directory

### Configuration

#### Plugin-Level Configuration (`plugin.json`)
```json
{
  "commands": "./commands/"  // Directory path (relative to plugin root)
}
```

**Supported formats**:
- Directory path: `"./commands/"` - Claude Code scans for all `.md` files
- **NOT** array of files (unlike agents, which are an array)

#### Command-Level Configuration (YAML Frontmatter)

**Required fields**:
```yaml
description: String shown in command palette
```

**Optional fields**:
```yaml
allowed-tools: Comma-separated list of tool names
```

**Available tools** (examples):
- Read, Write, Edit - File operations
- Glob, Grep - Search operations
- Bash - Shell commands
- Task - Agent invocation
- WebFetch, WebSearch - Internet access (if enabled)

**Tool allowlist behavior**:
- If `allowed-tools` is specified: Only those tools are available
- If `allowed-tools` is omitted: All tools available (not recommended)
- Claude Code enforces this at runtime

#### Command Prompt Guidelines (Best Practices)

1. **Clear step-by-step instructions**:
   - Number each step
   - Be explicit about what to create/modify
   - Specify file paths and formats

2. **Specify output structure**:
   - Provide markdown templates
   - Show example output
   - Define required sections

3. **Handle edge cases**:
   - Check if files exist before creating
   - Validate arguments if needed
   - Provide helpful error messages

4. **Integrate with other features**:
   - Reference `@doc-manager` agent
   - Update `.knowledge/README.md` index
   - Follow documentation templates

5. **Set user expectations**:
   - Confirm what was created
   - Show file locations
   - Suggest next steps

## Important Notes & Gotchas

### ⚠️ Critical Points

1. **Commands Directory vs Agents Array**
   - **Commands**: `"commands": "./commands/"` (directory path, scans for `.md`)
   - **Agents**: `"agents": ["./agents/doc-manager.md"]` (array of file paths)
   - **Recent change** (commits 38525a7, b6769f3): Simplified from file arrays to directory
   - **Breaking change**: Old format with arrays no longer works for commands
   - **Migration**: Move all command `.md` files to `./commands/` directory

2. **Filename = Command Name (with plugin namespace)**
   - `doc-feature.md` → `/auto-documenter:doc-feature` command
   - Hyphens preserved: `my-command.md` → `/auto-documenter:my-command`
   - Plugin name comes from `plugin.json` "name" field
   - **No override mechanism**: Can't rename command without renaming file
   - **Case sensitivity**: `doc-init.md` ≠ `Doc-Init.md` on Linux

3. **YAML Frontmatter Is Mandatory**
   - Commands without frontmatter may fail to load
   - Minimum requirement: `---` delimiters and `description:` field
   - **Silent failure**: Invalid YAML may cause command to not appear
   - **Testing**: List commands after plugin install to verify

4. **Tool Restrictions Are Enforced**
   - Claude Code blocks disallowed tool usage
   - Example: `/auto-documenter:doc-review` with `allowed-tools: Read, Grep, Glob, Bash` cannot use Write
   - **Error behavior**: Tool call is rejected, command may fail
   - **Security benefit**: Prevents read-only commands from making changes

5. **Argument Substitution Limitations**
   - Only positional arguments supported (`$1`, `$2`, etc.)
   - No named arguments: `--feature=auth` doesn't work
   - No default values: If user omits `$1`, template contains literal `$1`
   - **Workaround**: Command prompt should check for missing arguments

6. **Commands Execute in User's Project Directory**
   - Working directory = user's current project, NOT plugin directory
   - Paths like `./commands/` refer to user's project, not plugin's
   - **Consequence**: Commands must use absolute paths or check context
   - **Example**: Reading plugin files requires `$CLAUDE_PLUGIN_ROOT` or similar

7. **No Command Chaining or Composition**
   - Cannot call one slash command from another
   - Each command invocation is independent
   - **Workaround**: Use `@doc-manager` agent invocation within commands
   - **Example**: `/auto-documenter:doc-feature` can invoke agent, but not `/auto-documenter:doc-update`

### 🐛 Known Issues

1. **No Argument Validation**
   - Commands receive raw user input
   - No type checking or validation
   - Empty arguments possible: `/auto-documenter:doc-feature ""` (empty string)
   - Special characters not escaped: `/auto-documenter:doc-feature foo&bar` may break

2. **Tool Allowlist Not Granular**
   - Can't restrict specific operations within a tool
   - Example: Allow Read but not Write for specific paths
   - All-or-nothing: Either Bash is allowed or it isn't

3. **No Command Help Text**
   - Description field is short (one line)
   - No way to show detailed usage
   - Users must read README.md for command documentation

4. **Command Discovery Is Static**
   - Commands loaded at plugin installation
   - Adding new `.md` files requires plugin reload/reinstall
   - No hot-reloading during development

5. **Error Handling Is Command-Specific**
   - No standardized error reporting
   - Each command handles errors differently
   - Silent failures possible if prompt doesn't check conditions

### 🔄 Future Improvements

1. **Named Arguments**
   - Support `--feature=auth` syntax
   - Enable optional arguments with defaults
   - Improve user experience

2. **Argument Validation**
   - Define argument types in frontmatter
   - Validate before command execution
   - Provide helpful error messages

3. **Command Help System**
   - Add `help:` field in frontmatter with multi-line usage
   - Enable `/auto-documenter:doc-feature --help` to show detailed help
   - Auto-generate help from prompt structure

4. **Command Composition**
   - Allow commands to invoke other commands
   - Build complex workflows
   - Example: `/auto-documenter:doc-feature-and-commit` combines feature doc + git commit

5. **Interactive Prompts**
   - Ask user for arguments if not provided
   - Present choices: "Document which feature? [1] auth, [2] api, [3] ui"
   - Improve discoverability

6. **Command Templates Generator**
   - `/plugin create-command <name>` scaffolds new command file
   - Pre-fills YAML frontmatter
   - Reduces boilerplate

## Testing

### Manual Testing

#### Test 1: Command Discovery
```bash
# After plugin installation
/help

# Should list all 5 commands:
# - /auto-documenter:doc-init
# - /auto-documenter:doc-feature
# - /auto-documenter:doc-update
# - /auto-documenter:doc-review
# - /auto-documenter:doc-plan
```

#### Test 2: Argument Substitution
```bash
# Run command with argument
/auto-documenter:doc-feature test-feature

# Verify Claude Code received:
# "The feature name is: **test-feature**"
# (Check by observing command execution)
```

#### Test 3: Tool Restrictions
```bash
# Run /auto-documenter:doc-review (allowed-tools: Read, Grep, Glob, Bash)
/auto-documenter:doc-review

# Observe that Claude Code cannot use Write or Edit
# Command should only read and report, not modify files
```

#### Test 4: Missing Arguments
```bash
# Run command without required argument
/auto-documenter:doc-feature

# Command should either:
# 1. Ask user to provide feature name
# 2. Show error message
# 3. Process "$1" literally (bad)
```

#### Test 5: Command in Subdirectory
```bash
# Create project subdirectory
mkdir -p myproject/src
cd myproject/src

# Run command
/auto-documenter:doc-init

# Verify .knowledge/ created in myproject/src/ (working directory)
# NOT in plugin directory
```

### Automated Testing (Future)

- Parse all command `.md` files and validate YAML frontmatter
- Check for `$1` references in prompts that take arguments
- Verify allowed-tools lists contain valid tool names
- Test argument substitution logic

### Test Cases from INSTALL.md

- Test 1: Initialization (`/auto-documenter:doc-init`)
- Test 2: Feature Documentation (`/auto-documenter:doc-feature authentication`)
- Test 3: Documentation Update (`/auto-documenter:doc-update`)
- Test 4: Coverage Review (`/auto-documenter:doc-review`)
- Test 7: Planning Sessions (`/auto-documenter:doc-plan user-auth-redesign`)

## Related Documentation

- [Index Management](./index-management.md) - How commands update the index
- [Hook System](./hook-system.md) - Automatic features that complement commands
- [Plugin Structure](../architecture/plugin-structure.md) - How plugin.json loads commands
- [Architecture Overview](../architecture/overview.md) - Overall system design

## Command Reference

### `/auto-documenter:doc-init`
**Purpose**: Bootstrap documentation system in a new project
**Arguments**: None
**Tools**: Write, Bash, Read, Glob
**Output**: Creates `.knowledge/` directory structure with README template

### `/auto-documenter:doc-feature <feature-name>`
**Purpose**: Document a specific feature with implementation details and gotchas
**Arguments**: `<feature-name>` - Name of the feature (kebab-case recommended)
**Tools**: Write, Read, Grep, Glob, Edit
**Output**: Creates `.knowledge/features/<feature-name>.md` and updates index

### `/auto-documenter:doc-update`
**Purpose**: Update existing documentation based on recent git changes
**Arguments**: None
**Tools**: Read, Grep, Glob, Edit, Bash
**Output**: Updates relevant feature docs and refreshes file mappings

### `/auto-documenter:doc-review`
**Purpose**: Audit documentation coverage and identify gaps
**Arguments**: None
**Tools**: Read, Grep, Glob, Bash
**Output**: Generates coverage report with recommendations

### `/auto-documenter:doc-plan <plan-name>`
**Purpose**: Save a planning session for future reference
**Arguments**: `<plan-name>` - Name of the plan (kebab-case recommended)
**Tools**: Write, Read, Edit, Bash
**Output**: Creates `.knowledge/plans/YYYY-MM-DD-<plan-name>.md` and updates index

---
*Created: 2025-10-10*
*Last updated: 2025-10-10*
