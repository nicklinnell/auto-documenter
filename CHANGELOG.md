# Changelog

All notable changes to the auto-documenter plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-17

### Removed - Commands Replaced by Skills

#### Removed Commands (Replaced by Skills)
- **doc-feature** - Use `document-feature` skill (natural language: "document this feature")
- **doc-init** - Use `document-codebase` skill (natural language: "initialise docs")
- **doc-update** - Use `maintain-index` skill (natural language: "update the docs")
- **doc-review** - Use `review-documentation` skill (natural language: "review the docs")

#### Remaining Command
- **doc-plan** - Still supported (no skill replacement, better as explicit command)

#### Migration Support
- Added comprehensive MIGRATION.md guide
- Skills provide all functionality via natural language
- README updated with skills-first approach
- Clear examples for all workflows

### Added - Phase 2: Enhanced Capabilities

#### New Skills
- **create-skill** skill - Meta-capability for creating and documenting new skills
  - Bundled template: `SKILL-template.md` for standard structure
  - Bundled checklist: `validation-checklist.md` for quality assurance
  - Auto-activates when user wants to create skills
  - Guides through proper SKILL.md format with frontmatter
  - Invokes `@skill-documenter` for automatic documentation

- **review-documentation** skill - Audits documentation coverage and quality
  - Bundled script: `coverage-analysis.sh` for metrics calculation
  - Auto-activates when user asks about docs status/coverage
  - Identifies well-documented vs undocumented areas
  - Detects stale documentation (>6 months)
  - Finds broken links and orphaned files
  - Provides prioritised recommendations

#### New Agents
- **code-context-extractor** (purple) - Extracts code context for documentation
  - Parses imports, exports, functions, classes
  - Identifies dependencies and architectural patterns
  - Finds TODOs, FIXMEs, and important comments
  - Used by document-feature and create-skill skills
  - Tools: Read, Grep, Glob, Bash

- **skill-documenter** (orange) - Documents skills automatically
  - Creates feature docs for skills following standard template
  - Extracts metadata from SKILL.md frontmatter
  - Documents bundled resources (templates, scripts)
  - Updates documentation index via @doc-manager
  - Tools: Read, Grep, Glob, Edit, Write

#### Hook Updates
- Updated post-tool-use.sh to be less noisy
- Now mentions skills instead of just commands
- Trusts skills to auto-activate vs explicit suggestions
- Reduced notification frequency

### Added - Phase 1: Skills Infrastructure

#### Core Skills
- **document-feature** skill - Automatically documents features with context and gotchas
  - Bundled template: `feature-template.md`
  - Bundled script: `extract-context.sh` for code analysis
  - Auto-activates when user implements/modifies features
  - Replaces manual `/doc-feature` command invocation (command still works)

- **document-codebase** skill - Initialises comprehensive documentation structure
  - Bundled template: `index-template.md` for docs/README.md
  - Bundled schema: `structure-schema.json` defining standard layout
  - Auto-activates when user starts new project or mentions "initialise docs"
  - Replaces manual `/doc-init` command invocation (command still works)

- **maintain-index** skill - Keeps documentation index current
  - Bundled script: `index-validator.sh` for consistency checking
  - Auto-activates after documentation changes
  - Works with `@doc-manager` agent for index updates
  - Replaces manual index maintenance

#### Infrastructure
- Added `skills/` directory support in plugin.json
- Skills use progressive loading (metadata → instructions → resources)
- Skills work alongside existing commands (no breaking changes)
- Cross-platform: Skills work in Claude Apps, API, and Claude Code

### Changed
- Updated plugin version from 1.1.0 to 2.0.0 (major version bump)
- Enhanced plugin description to mention skills
- Plugin.json now includes `"skills": "./skills/"` field

### Maintained (Backward Compatibility)
- All existing slash commands still functional:
  - `/auto-documenter:doc-feature`
  - `/auto-documenter:doc-init`
  - `/auto-documenter:doc-update`
  - `/auto-documenter:doc-review`
  - `/auto-documenter:doc-plan`
- All existing agents still functional:
  - `@doc-manager` (blue) - Index maintenance
  - `@doc-reader` (green) - Documentation access
- All existing hooks still functional:
  - PreToolUse - Inject documentation context
  - PostToolUse - Suggest documentation actions

### Documentation
- Added comprehensive architecture plan: `docs/plans/skills-architecture-v2.md`
- Documented skills-first vision and implementation strategy
- Included phased rollout plan (Phase 1, 2, 3)

### Technical Details
- Skills metadata limits: name (64 chars), description (1024 chars)
- Skills employ YAML frontmatter for metadata
- Bundled scripts are executable and validated
- Skills invoke agents for complex operations

## [1.1.0] - 2025-01-17

### Added
- `@doc-reader` agent for comprehensive documentation access
- Agents can now read full documentation without individual file reads

### Changed
- Improved hook system reliability
- Enhanced index management

## [1.0.0] - Initial Release

### Added
- Initial plugin structure
- Slash commands for documentation
- `@doc-manager` agent
- Hook system for automatic context injection
- Documentation structure with features/, architecture/, gotchas/, decisions/, plans/
