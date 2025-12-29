---
description: Create git worktree and launch Claude in a new terminal to implement a plan
---

## Process

1. **Get the required information:**
   - If a plan file path is provided as argument, use it
   - Otherwise, look for recently created plans in `plans/` directory and ask which one
   - Derive branch name from the plan filename (e.g., `2025-12-29-workflow-redesign.md` → `workflow-redesign`)
   - Convert plan path to absolute path

2. **Create the worktree:**
   ```bash
   mkdir -p ~/worktrees
   git worktree add ~/worktrees/$BRANCH_NAME -b $BRANCH_NAME
   ```

3. **Copy .claude directory if it exists:**
   ```bash
   [ -d .claude ] && cp -r .claude ~/worktrees/$BRANCH_NAME/
   ```

4. **Open a new terminal and launch Claude:**

   For macOS with iTerm2:
   ```bash
   osascript -e 'tell application "iTerm" to activate' -e 'tell application "iTerm" to create window with default profile' -e 'tell application "iTerm" to tell current session of current window to write text "cd ~/worktrees/$BRANCH_NAME && claude --dangerously-skip-permissions \"/implement_plan $ABSOLUTE_PLAN_PATH\""'
   ```

   For macOS with Terminal.app:
   ```bash
   osascript -e 'tell application "Terminal" to activate' -e 'tell application "Terminal" to do script "cd ~/worktrees/$BRANCH_NAME && claude --dangerously-skip-permissions \"/implement_plan $ABSOLUTE_PLAN_PATH\""'
   ```

5. **Confirm to user:**
   ```
   ✓ Worktree created: ~/worktrees/$BRANCH_NAME
   ✓ New terminal opened with Claude implementing the plan

   When done, use /merge_worktree to merge and clean up:
     /merge_worktree $BRANCH_NAME
   ```

## Configuration

The terminal app can be configured via `CLAUDE_TERMINAL` environment variable:

**macOS:** `iterm`, `terminal`, `warp`, `kitty`, `alacritty`, `ghostty`
**Linux:** `gnome-terminal`, `konsole`, `kitty`, `alacritty`, `xterm`

If not set, auto-detects (macOS: iTerm2 > Warp > Terminal.app)

Example: `export CLAUDE_TERMINAL=warp`

## Important

- Execute the osascript command directly - do NOT ask for confirmation
- Check `CLAUDE_TERMINAL` env var first, then auto-detect terminal
- The plan path MUST be absolute so it works from the worktree directory
- This opens a completely new terminal window - no manual steps required

## Example

User runs: `/implement_in_worktree plans/2025-12-29-workflow-redesign.md`

Claude executes:
```bash
mkdir -p ~/worktrees
git worktree add ~/worktrees/workflow-redesign -b workflow-redesign
[ -d .claude ] && cp -r .claude ~/worktrees/workflow-redesign/
osascript -e 'tell application "iTerm" to activate' -e 'tell application "iTerm" to create window with default profile' -e 'tell application "iTerm" to tell current session of current window to write text "cd ~/worktrees/workflow-redesign && claude --dangerously-skip-permissions \"/implement_plan /Users/ia/project/plans/2025-12-29-workflow-redesign.md\""'
```

Output to user:
```
✓ Worktree created: ~/worktrees/workflow-redesign
✓ New terminal opened with Claude implementing the plan

When done, use /merge_worktree to merge and clean up:
  /merge_worktree workflow-redesign
```

## Relationship to Other Commands

Recommended worktree workflow:
1. `/implement_in_worktree` - Create worktree and start implementation
2. `/implement_plan` - Execute the plan (runs in new terminal)
3. `/commit` - Create commits for changes
4. `/merge_worktree` - Merge to main and clean up worktree
