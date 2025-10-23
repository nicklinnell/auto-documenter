# Feature: Reviewing Documentation Skill

## Overview

The reviewing-documentation skill is a documentation quality analyst that assesses documentation coverage, identifies gaps, detects quality issues, and provides actionable recommendations. It calculates metrics, prioritises undocumented areas, checks for stale documentation, and generates comprehensive coverage reports. The skill uses a bundled coverage analysis script to automate metrics calculation and provides objective, encouraging feedback with specific next steps.

**Why it exists**: Documentation naturally drifts out of sync with code over time. Teams need periodic reviews to identify gaps, prioritise documentation needs, and maintain quality. This skill automates the assessment process, providing objective metrics and actionable recommendations rather than subjective opinions about documentation needs.

## Implementation Details

### Key Files

- `skills/reviewing-documentation/SKILL.md` - Main skill definition with review workflow (198 lines)
- `skills/reviewing-documentation/scripts/coverage-analysis.sh` - Automated coverage analysis script (139 lines)
- `skills/reviewing-documentation/templates/report-example.md` - Example coverage report template (34 lines)
- `.claude-plugin/marketplace.json:16` - Registers this skill in the plugin

### How It Works

#### 1. Activation

The skill activates when:
- User asks about documentation status or coverage
- User mentions "review docs", "check documentation", "audit docs"
- User wants to know what's documented vs undocumented
- Periodic documentation health checks are needed
- Before major releases or code handoffs

**Activation mechanism**: Claude scans the skill description during task execution and matches user intent.

#### 2. Project Structure Discovery

**Codebase scanning:**
- Uses Glob to find all source files (`.ts`, `.js`, `.py`, `.go`, `.rs`, etc.)
- Identifies main directories and their purposes
- Detects project type (web app, library, CLI tool)
- Notes significant files (`package.json`, main entry points, config files)

**Feature identification:**
- Parses directory structure for feature areas
- Looks for routes, API endpoints, service layers
- Finds models, utilities, infrastructure code
- Builds mental map of project architecture

#### 3. Documentation Coverage Assessment

**Scan existing documentation:**
1. Read `.knowledge/README.md` index
2. List all files in `.knowledge/features/`, `.knowledge/architecture/`, `.knowledge/gotchas/`
3. Count documentation files
4. Extract documented file mentions from each doc

**Coverage calculation:**
```
Coverage = (Files with docs / Total significant files) × 100%
```

**Automated script** (`coverage-analysis.sh`):
- Counts source files by directory (excludes `node_modules`, `dist`, etc.)
- Counts documentation files in `.knowledge/`
- Estimates coverage using heuristic: 1 doc ≈ 5 files
- Generates categorised output with colour coding
- Lists documented features, architecture, gotchas
- Identifies stale docs (>6 months old based on file modification time)
- Exits with code 0 (non-blocking)

#### 4. Gap Identification and Prioritisation

**Critical gaps** (document immediately):
- Core features with no documentation
- Complex algorithms or business logic
- Security-sensitive code (auth, permissions, payments)
- Performance-critical paths
- Files with "do not change" patterns

**Important gaps** (document soon):
- API endpoints and routes
- Data models and schemas
- Configuration and environment setup
- Integration points with external systems
- Error handling strategies

**Nice to have** gaps:
- Utility functions
- Helper classes
- Internal development tools
- Build and deployment scripts

#### 5. Quality Validation

**Checks performed:**
- Run `maintaining-index` skill's validator script (if available)
- Check for broken links in documentation
- Verify file paths in docs still exist
- Look for outdated dates (>6 months old)
- Find incomplete sections ("TODO", "TBD", placeholders)

**Quality indicators:**
- Does each doc have Overview, Implementation, Gotchas sections?
- Are creation/update dates present and current?
- Are key files listed and paths accurate?
- Are gotchas clearly marked with ⚠️?
- Are related docs cross-linked?

#### 6. Report Generation

**Report structure** (from `report-example.md`):
1. **Summary**: Total files, documented files, coverage percentage
2. **Well-Documented Areas** ✅: List of features with good docs
3. **Undocumented Areas** ⚠️: Categorised by priority (Critical → Important → Nice to Have)
4. **Documentation Quality Issues** 🔧: Stale docs, broken links, specific locations
5. **Recommendations**: Actionable next steps with skill suggestions

**Output format**: Objective metrics, specific examples, prioritised recommendations.

#### 7. Actionable Recommendations

**Provides specific next steps:**
- "Start with documenting {critical feature} - it's complex and has no docs"
- "Update {stale doc} - last modified {date}, code has changed since"
- "Fix {broken links} in .knowledge/README.md"
- "Consider documenting {important feature} for team handoff"

**Skill suggestions:**
- "Use documenting-features skill to document {feature name}"
- "Run maintaining-index skill to fix broken links"
- "Use initialising-documentation skill if .knowledge/ doesn't exist"

### Dependencies

**Internal:**
- `scripts/coverage-analysis.sh` - Automated coverage calculation
- `templates/report-example.md` - Report format template
- `.knowledge/README.md` - Documentation index (if exists)
- `@doc-reader` agent - For reading existing documentation comprehensively
- `@doc-manager` agent - For getting current index status

**External:**
- bash - For running coverage analysis script
- find - For file discovery (used in coverage script)
- grep - For pattern matching in docs
- date - For calculating file ages (stale doc detection)

**Tools required:**
- Read - Read existing documentation
- Grep - Search for patterns in code and docs
- Glob - Find files by pattern
- Bash - Run coverage analysis script

### Configuration

**Coverage Script Options** (`coverage-analysis.sh`):
- `$1` - Project root directory (default: `.`)
- Searches for extensions: `.ts`, `.js`, `.jsx`, `.tsx`, `.py`, `.go`, `.rs`
- Excludes: `node_modules`, `dist`, `build`, `.git`, `coverage`, `__pycache__`
- Estimates coverage heuristic: 1 doc covers ≈5 files
- Stale threshold: 6 months (180 days)

**Coverage thresholds:**
- ≥70% = Excellent coverage ✅
- 40-69% = Moderate coverage ⚠️ (consider documenting more critical features)
- <40% = Low coverage ⚠️ (prioritise documenting core features)

**Output colour coding:**
- Blue - Section headers
- Green - Good status
- Yellow - Warnings/improvements needed
- No colour - Regular output

## Important Notes & Gotchas

### ⚠️ Critical Points

1. **Coverage is a Heuristic, Not Truth** (coverage-analysis.sh:50-51)
   - Script assumes 1 doc ≈ 5 files (rough estimate)
   - **Reality**: Some docs cover 1 file, others cover 20
   - Actual coverage requires parsing docs for file mentions
   - **Use case**: Coverage metric is a starting point for conversation, not absolute truth
   - **Mitigation**: Review prioritises critical gaps over hitting percentage targets

2. **Don't Document Everything** (SKILL.md:180)
   - Not every file needs documentation
   - Focus on significant features, not trivial utilities
   - **Example**: `src/utils/capitalise.ts` doesn't need docs, `src/payments/processor.ts` does
   - **Philosophy**: Quality over quantity
   - Coverage goal is NOT 100%

3. **Stale Detection Uses File Modification Time** (coverage-analysis.sh:118)
   - `find ... -mtime +180` checks file modification date, not "Last updated" in docs
   - **Problem**: If doc file is touched (permissions changed, git rebase), it appears recent
   - **Impact**: Truly stale docs might not be detected
   - **Alternative**: Parse "Last updated" dates in markdown footer (more accurate, more complex)

4. **Script Exits 0 Always** (coverage-analysis.sh:138)
   - Coverage script always `exit 0` even if coverage is 0%
   - **Reason**: Non-blocking - shouldn't break user workflows
   - **Trade-off**: Can't use exit codes to signal poor coverage
   - **Design choice**: Reviews are informational, not enforcement

5. **Platform-Specific Date Command** (coverage-analysis.sh:117)
   - Uses `date -v-6m` (macOS) with fallback to `date -d "6 months ago"` (Linux)
   - **Failure mode**: If both fail, defaults to hardcoded `2024-01-01`
   - **Impact**: Stale detection may not work on some platforms
   - **Fix needed**: More robust date handling or use Python/Node for portability

6. **Skill Suggests Other Skills, Doesn't Implement** (SKILL.md:184)
   - This skill ONLY reviews and reports
   - Does NOT document features itself
   - Does NOT fix broken links itself
   - **Reason**: Separation of concerns - review ≠ implementation
   - **User flow**: Review → Recommendations → User invokes suggested skills

### 🐛 Known Issues

1. **Coverage Heuristic is Oversimplified**
   - 1 doc = 5 files assumption is arbitrary
   - Doesn't account for doc quality or completeness
   - Can't distinguish between stub docs and comprehensive docs
   - **Better approach**: Parse "Key Files" sections in docs, count mentioned files

2. **No Broken Link Detection**
   - Skill mentions checking for broken links in quality validation
   - But coverage script doesn't implement this
   - **Missing**: `maintaining-index/scripts/index-validator.sh` should be invoked
   - **Workaround**: Manually suggest running the validator

3. **Stale Date Detection Unreliable**
   - File modification time ≠ content update time
   - Git operations can change file times
   - **Example**: `git rebase` or `chmod` makes file appear recent
   - **Better**: Parse markdown footer dates, compare to git commit dates

4. **No Component-Level Breakdown**
   - Coverage is project-wide only
   - Can't see: "features/ = 80% covered, gotchas/ = 20% covered"
   - **Impact**: Hard to identify which areas need focus
   - **Enhancement**: Add directory-level coverage breakdown

5. **Report Template Not Used Automatically**
   - `templates/report-example.md` is provided as example
   - Skill doesn't programmatically generate reports using the template
   - **Current**: Skill formats report manually in output
   - **Ideal**: Fill template placeholders, output structured report

6. **No Trend Tracking**
   - Review is point-in-time snapshot
   - Can't show: "Coverage improved from 40% to 55% since last review"
   - **Enhancement**: Store review history, show trends

### 🔄 Future Improvements

1. **Accurate Coverage Calculation**
   - Parse "Key Files" sections from all docs
   - Count unique files mentioned
   - Calculate true coverage: mentioned files / total significant files

2. **Component-Level Metrics**
   - Break down coverage by directory
   - Show: Features 80%, Architecture 50%, Gotchas 20%
   - Identify which areas need attention

3. **Automated Link Validation**
   - Invoke index-validator.sh automatically
   - Check all markdown links
   - Verify file paths in "Key Files" sections exist

4. **Trend Tracking**
   - Save review reports to `.knowledge/reviews/YYYY-MM-DD.md`
   - Compare current coverage to previous reviews
   - Show improvement over time

5. **Content Quality Analysis**
   - Detect stub docs (< 50 lines, missing sections)
   - Find docs with many TODOs or TBDs
   - Measure gotcha density (files with warnings vs total)

6. **Integration with Git**
   - Find files changed recently but not documented
   - Identify high-churn files (frequently modified, likely complex)
   - Suggest documenting files with many contributors

7. **Configurable Thresholds**
   - Allow users to set coverage targets
   - Customise stale threshold (default 6 months)
   - Configure file type patterns to scan

8. **Interactive Mode**
   - Ask: "Which area should we focus on first?"
   - Offer to invoke documenting-features skill immediately
   - Generate TODOs for undocumented features

## Testing

### Manual Testing

**Test 1: Review a Well-Documented Project**
```
1. Use auto-documenter project itself
2. Ask: "Review the documentation coverage"
3. Verify:
   - Coverage analysis script runs
   - Coverage percentage calculated
   - Well-documented areas listed
   - Gaps identified and prioritised
   - Quality issues noted (if any)
   - Recommendations provided
```

**Test 2: Review a New Project (No Docs)**
```
1. Create empty project with source files
2. Ask: "Check documentation status"
3. Verify:
   - Script handles missing .knowledge/ gracefully
   - Coverage reported as 0%
   - Recommends running initialising-documentation skill
   - Doesn't crash or error
```

**Test 3: Stale Documentation Detection**
```
1. Touch a doc file to make it >6 months old: `touch -t 202401010000 .knowledge/features/old.md`
2. Run review
3. Verify:
   - Stale docs section lists the old file
   - Modification date shown
   - Recommendation to review for accuracy
```

**Test 4: Coverage Script Standalone**
```bash
# Run coverage script directly
./skills/reviewing-documentation/scripts/coverage-analysis.sh .

# Verify output:
# - Counts source files correctly
# - Counts doc files correctly
# - Calculates coverage percentage
# - Lists features, architecture, gotchas
# - Identifies stale docs
# - Exits with code 0
```

### Integration Testing

- Verify @doc-reader agent is invoked correctly
- Test that skill suggests other skills appropriately
- Ensure coverage script runs on different platforms (macOS, Linux)
- Test with projects in different languages (TypeScript, Python, Go, Rust)

### Example Output

See `templates/report-example.md` for expected report format.

## Related Documentation

- [Skills System](.knowledge/features/skills-system.md:3) - Overall skills architecture
- [Maintaining Index Skill](.knowledge/features/maintaining-index-skill.md) - Complementary skill for fixing issues (not yet created)
- [Documenting Features Skill](.knowledge/features/documenting-features-skill.md) - Skill suggested for documenting gaps (not yet created)
- [Architecture Overview](.knowledge/architecture/overview.md:15) - This skill as part of v2.0 architecture

---
*Created: 2025-10-23*
*Last updated: 2025-10-23*
