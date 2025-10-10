# Hook System Gotchas

## ⚠️ Critical Points

### 1. Executable Permissions Are Mandatory
**Location**: `hooks/pre-tool-use.sh`, `hooks/post-tool-use.sh`

Both hook scripts MUST have executable permissions:
```bash
chmod +x hooks/pre-tool-use.sh
chmod +x hooks/post-tool-use.sh
```

**Why this matters**:
- Claude Code won't execute non-executable scripts
- Hooks fail silently if permissions are wrong
- Git may not preserve executable bits depending on configuration

**When this breaks**:
- Manual `git clone` without executable bit preservation
- Windows development environments
- Zip file distributions

**How to verify**:
```bash
ls -la hooks/*.sh
# Should show: -rwxr-xr-x
```

---

### 2. Basename-Only Matching Limitation
**Location**: `hooks/pre-tool-use.sh:25`

```bash
RELEVANT_DOCS=$(echo "$INDEX_CONTENT" | grep -i "$(basename "$FILE_PATH")" | ...)
```

**The Problem**:
- Only matches on filename, not full path
- Cannot distinguish `src/utils/auth.ts` from `lib/utils/auth.ts`
- Both files trigger the same documentation

**Real-world scenario**:
```
Project structure:
  src/client/api.ts       → Client-side API wrapper
  src/server/api.ts       → Server-side API routes

docs/README.md contains:
  - src/client/api.ts → docs/features/client-api.md
  - src/server/api.ts → docs/features/server-api.md

When editing src/server/api.ts:
  PreToolUse hook searches for "api.ts"
  Finds BOTH client-api.md and server-api.md
  Injects BOTH documentation sections (wrong!)
```

**Workaround**:
- Use unique filenames across the project
- Accept that ambiguous files get all matching docs
- Future: Implement full-path matching

---

### 3. JQ Dependency Is Unchecked
**Location**: `hooks/pre-tool-use.sh:8`, `hooks/post-tool-use.sh:8`

```bash
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
```

**The Problem**:
- Scripts assume `jq` is installed
- No verification or error handling
- If jq is missing, parsing fails silently
- Hook exits with code 0 (success) even though it failed

**Symptoms of missing jq**:
- Hooks never fire, even for documented files
- No error messages
- `$FILE_PATH` is empty, causing early exit

**Detection**:
```bash
# Check if jq is installed
command -v jq
# Should output: /usr/bin/jq (or similar)

# If missing, install:
# macOS: brew install jq
# Ubuntu: apt-get install jq
# Fedora: dnf install jq
```

---

### 4. Silent Failures By Design
**Location**: Throughout both hook scripts

**Every error condition exits with code 0**:
```bash
if [ -z "$FILE_PATH" ]; then
    exit 0  # Not exit 1!
fi

if [ ! -f "docs/README.md" ]; then
    exit 0  # Not exit 1!
fi
```

**Why**:
- Hooks should never block the user's workflow
- Better to silently fail than interrupt development
- UX over debuggability

**The trade-off**:
- ✅ Users never get blocked by broken hooks
- ✅ Documentation system is optional, not mandatory
- ❌ Impossible to distinguish "hook didn't fire" from "hook had no work to do"
- ❌ Debugging is difficult

**How to debug**:
Add temporary echo statements:
```bash
echo "DEBUG: FILE_PATH=$FILE_PATH" >&2
echo "DEBUG: RELEVANT_DOCS=$RELEVANT_DOCS" >&2
```

---

### 5. AWK Section Extraction Is Fragile
**Location**: `hooks/pre-tool-use.sh:44-48`

```bash
awk '
    /^## Overview/,/^## [^O]/ { if (!/^## [^O]/) print }
    /^## Important Notes/,/^## / { if (!/^## [^I]/) print }
    /^### ⚠️ Critical Points/,/^### / { if (!/^### [^⚠]/) print }
' "$DOC" | head -50
```

**Assumptions**:
- Documentation uses exactly `## Overview` (two hashes, one space)
- Sections are separated by level-2 headers (`##`)
- Critical points use the emoji `⚠️`

**What breaks extraction**:
- `##Overview` (no space) - Won't match
- `## overview` (lowercase) - Won't match (wait, `-i` flag missing!)
- `### Overview` (level 3) - Won't match
- `## ⚠️ Important Notes` (emoji in wrong place) - Pattern breaks
- Non-UTF-8 terminals - Emoji may not render

**Impact**:
- Documentation isn't extracted, so context isn't injected
- Users don't see gotchas before editing
- Defeats the entire purpose of the hook

**Mitigation**:
- Follow the exact template structure from `/doc-feature`
- Test documentation extraction manually:
  ```bash
  awk '/^## Overview/,/^## [^O]/ { if (!/^## [^O]/) print }' docs/features/your-feature.md
  ```

---

### 6. CLAUDE_PLUGIN_ROOT Path Resolution
**Location**: `hooks/hooks.json:9`, `hooks/hooks.json:20`

```json
"command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/pre-tool-use.sh"
```

**Historical issue** (fixed in commit a87e75f):
- Previous versions used relative paths
- Broke when Claude Code changed working directories
- Hooks couldn't find script files

**Current implementation**:
- Uses `${CLAUDE_PLUGIN_ROOT}` environment variable
- Claude Code injects this variable at runtime
- Points to the absolute plugin installation directory

**What can still go wrong**:
- Variable not set (older Claude Code versions?)
- Path contains spaces and isn't quoted
- Symlinks cause path mismatches

**Verification**:
```bash
echo "CLAUDE_PLUGIN_ROOT is: ${CLAUDE_PLUGIN_ROOT}"
ls "${CLAUDE_PLUGIN_ROOT}/hooks/"
```

---

## 🧪 Testing Gotchas

### Test 1: Verify Executable Permissions
```bash
# Check permissions
ls -la hooks/*.sh

# Fix if needed
chmod +x hooks/*.sh

# Verify again
ls -la hooks/*.sh | grep "rwx"
```

### Test 2: Verify JQ Installation
```bash
# Test jq
echo '{"file_path": "test.ts"}' | jq -r '.file_path'

# Should output: test.ts
# If error: install jq
```

### Test 3: Test AWK Extraction
```bash
# Create test documentation
cat > /tmp/test-doc.md << 'EOF'
## Overview
This is the overview section.

## Implementation Details
Implementation here.

## Important Notes
Notes here.

### ⚠️ Critical Points
- Critical point 1
- Critical point 2
EOF

# Test extraction
awk '
    /^## Overview/,/^## [^O]/ { if (!/^## [^O]/) print }
    /^## Important Notes/,/^## / { if (!/^## [^I]/) print }
    /^### ⚠️ Critical Points/,/^### / { if (!/^### [^⚠]/) print }
' /tmp/test-doc.md

# Should show Overview and Critical Points
```

---

## 📋 Pre-flight Checklist

Before deploying hooks to a new environment:

- [ ] JQ is installed: `command -v jq`
- [ ] Hook scripts are executable: `ls -la hooks/*.sh`
- [ ] `$CLAUDE_PLUGIN_ROOT` is set: `echo $CLAUDE_PLUGIN_ROOT`
- [ ] Documentation follows template structure
- [ ] Test hook manually with sample `$TOOL_INPUT`
- [ ] Verify UTF-8 terminal support for emoji rendering

---

*Created: 2025-10-10*
*Last updated: 2025-10-10*
