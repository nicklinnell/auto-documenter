# Installation Guide

## Quick Install (From GitHub)

1. **Add the plugin marketplace**:
   ```bash
   /plugin marketplace add https://github.com/nicklinnell/auto-documenter.git
   ```

2. **Install the plugin**:
   ```bash
   /plugin install auto-documenter
   ```

3. **Verify installation**:
   ```bash
   /plugin
   ```
   You should see `auto-documenter` in the list.

## Alternative: Local Install (For Development)

If you've cloned the repository locally:

1. **Add the plugin marketplace**:
   ```bash
   /plugin marketplace add /path/to/your/local/auto-documenter
   ```

2. **Install the plugin**:
   ```bash
   /plugin install auto-documenter
   ```

## First Use

In any project where you want documentation:

```bash
/doc-init
```

This creates the `docs/` directory structure.

## Testing the Plugin

### Test 1: Initialisation
```bash
cd /path/to/your/test-project
/doc-init
```

**Expected**: Creates `docs/README.md`, `docs/features/`, `docs/architecture/`, `docs/gotchas/`, `docs/decisions/`, `docs/plans/`

### Test 2: Feature Documentation
```bash
/doc-feature authentication
```

**Expected**:
- Scans codebase for authentication-related files
- Creates `docs/features/authentication.md`
- Updates `docs/README.md` index

### Test 3: Documentation Update
Make a change to a file, then:
```bash
/doc-update
```

**Expected**: Updates relevant feature docs based on changed files

### Test 4: Coverage Review
```bash
/doc-review
```

**Expected**: Generates a report showing documented vs undocumented areas

### Test 5: Automatic Context Injection
1. Document a feature: `/doc-feature user-profile`
2. Try to edit a file related to that feature
3. **Expected**: PreToolUse hook shows relevant documentation before you proceed

### Test 6: Documentation Reminders
1. Edit a source file
2. **Expected**: PostToolUse hook reminds you to update docs if applicable

### Test 7: Planning Sessions
After creating a plan in plan mode:
```bash
/doc-plan user-authentication-redesign
```

**Expected**:
- Creates `docs/plans/YYYY-MM-DD-user-authentication-redesign.md`
- Updates `docs/README.md` plans index
- Provides template for plan content and status tracking

## Troubleshooting

### Hooks Not Working?

Check hook script permissions:
```bash
ls -la auto-documenter/hooks/
```

Both `.sh` files should be executable (`-rwxr-xr-x`). If not:
```bash
chmod +x auto-documenter/hooks/pre-tool-use.sh
chmod +x auto-documenter/hooks/post-tool-use.sh
```

### Agent Not Found?

Verify agent configuration:
```bash
cat auto-documenter/agents/doc-manager/agent.json
```

Should show valid JSON with description and prompt fields.

### Commands Not Available?

Check command files:
```bash
ls -la auto-documenter/commands/
```

Should see:
- `doc-init.md`
- `doc-feature.md`
- `doc-update.md`
- `doc-review.md`
- `doc-plan.md`

## GitHub Repository

The plugin is hosted at: **https://github.com/nicklinnell/auto-documenter**

**Team installation**:
Team members can install directly from GitHub with:
```bash
/plugin marketplace add https://github.com/nicklinnell/auto-documenter.git
/plugin install auto-documenter
```

## Contributing

To contribute or fork this plugin:

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/yourusername/auto-documenter.git
   cd auto-documenter
   ```
3. **Make your changes** and test locally
4. **Submit a pull request** to https://github.com/nicklinnell/auto-documenter

## Next Steps

1. Try the plugin in a real project
2. Customise the hook scripts for your workflow
3. Adjust documentation templates in the commands
4. Share feedback and improvements!
