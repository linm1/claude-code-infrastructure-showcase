# Hooks

Claude Code hooks that enable skill auto-activation, file tracking, and validation.

---

## Windows Compatibility

These hooks are designed to work on both **Windows** (via Git Bash) and **Unix/macOS** systems.

### Windows Setup Requirements

1. **Install Git for Windows** (includes Git Bash)
   - Download from https://git-scm.com/download/win

2. **Install jq** (JSON processor required by hooks)
   ```powershell
   # Using Chocolatey (Admin PowerShell)
   choco install jq

   # Or using winget
   winget install jqlang.jq
   ```

3. **Set Git Bash path** (fixes "not recognized as internal command" errors)
   ```powershell
   # Run in Admin PowerShell
   [System.Environment]::SetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH', 'C:\Program Files\Git\bin\bash.exe', 'User')
   ```

4. **Restart VS Code completely** after setting the environment variable

5. **Install hook dependencies**
   ```bash
   cd .claude/hooks
   npm install
   ```

### Why This Matters

On Windows, Claude Code may try to execute hooks through CMD/PowerShell instead of Git Bash. The `$CLAUDE_PROJECT_DIR` variable syntax is Unix-style and causes errors like:
```
'$CLAUDE_PROJECT_DIR' is not recognized as an internal or external command
```

**Solution:** All hook commands in `settings.json` use `bash .claude/hooks/script.sh` format instead of `$CLAUDE_PROJECT_DIR/.claude/hooks/script.sh`. This ensures hooks run through Git Bash on all platforms.

---

## What Are Hooks?

Hooks are scripts that run at specific points in Claude's workflow:
- **UserPromptSubmit**: When user submits a prompt
- **PreToolUse**: Before a tool executes  
- **PostToolUse**: After a tool completes
- **Stop**: When user requests to stop

**Key insight:** Hooks can modify prompts, block actions, and track state - enabling features Claude can't do alone.

---

## Essential Hooks (Start Here)

### skill-activation-prompt (UserPromptSubmit)

**Purpose:** Automatically suggests relevant skills based on user prompts and file context

**How it works:**
1. Reads `skill-rules.json`
2. Matches user prompt against trigger patterns
3. Checks which files user is working with
4. Injects skill suggestions into Claude's context

**Why it's essential:** This is THE hook that makes skills auto-activate.

**Integration:**
```bash
# Copy both files
cp skill-activation-prompt.sh your-project/.claude/hooks/
cp skill-activation-prompt.ts your-project/.claude/hooks/

# Make executable
chmod +x your-project/.claude/hooks/skill-activation-prompt.sh

# Install dependencies
cd your-project/.claude/hooks
npm install
```

**Add to settings.json:**
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

> **Note:** Uses `bash .claude/hooks/...` format for Windows compatibility. See [Windows Compatibility](#windows-compatibility) section.

**Customization:** ✅ None needed - reads skill-rules.json automatically

---

### post-tool-use-tracker (PostToolUse)

**Purpose:** Tracks file changes to maintain context across sessions

**How it works:**
1. Monitors Edit/Write/MultiEdit tool calls
2. Records which files were modified
3. Creates cache for context management
4. Auto-detects project structure (frontend, backend, packages, etc.)

**Why it's essential:** Helps Claude understand what parts of your codebase are active.

**Integration:**
```bash
# Copy file
cp post-tool-use-tracker.sh your-project/.claude/hooks/

# Make executable
chmod +x your-project/.claude/hooks/post-tool-use-tracker.sh
```

**Add to settings.json:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-tool-use-tracker.sh"
          }
        ]
      }
    ]
  }
}
```

> **Note:** Uses `bash .claude/hooks/...` format for Windows compatibility. See [Windows Compatibility](#windows-compatibility) section.

**Customization:** ✅ None needed - auto-detects structure

---

## Optional Hooks (Require Customization)

### tsc-check (Stop)

**Purpose:** TypeScript compilation check when user stops

**⚠️ WARNING:** Configured for multi-service monorepo structure

**Integration:**

**First, determine if this is right for you:**
- ✅ Use if: Multi-service TypeScript monorepo
- ❌ Skip if: Single-service project or different build setup

**If using:**
1. Copy tsc-check.sh
2. **EDIT the service detection (line ~28):**
   ```bash
   # Replace example services with YOUR services:
   case "$repo" in
       api|web|auth|payments|...)  # ← Your actual services
   ```
3. Test manually before adding to settings.json

**Customization:** ⚠️⚠️⚠️ Heavy

---

### trigger-build-resolver (Stop)

**Purpose:** Auto-launches build-error-resolver agent when compilation fails

**Depends on:** tsc-check hook working correctly

**Customization:** ✅ None (but tsc-check must work first)

---

## For Claude Code

**When setting up hooks for a user:**

1. **Read [CLAUDE_INTEGRATION_GUIDE.md](../../CLAUDE_INTEGRATION_GUIDE.md)** first
2. **Always start with the two essential hooks**
3. **Ask before adding Stop hooks** - they can block if misconfigured  
4. **Verify after setup:**
   ```bash
   ls -la .claude/hooks/*.sh | grep rwx
   ```

**Questions?** See [CLAUDE_INTEGRATION_GUIDE.md](../../CLAUDE_INTEGRATION_GUIDE.md)
