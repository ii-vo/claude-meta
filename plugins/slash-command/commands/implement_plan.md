---
description: Implement technical plans from thoughts/plans/ with verification (uses worktree by default for isolation)
argument-hint: [plan-path] [--here]
---

# Implement Plan

Implement an approved technical plan. By default, creates an isolated worktree environment. Use `--here` to implement in the current directory.

## Context Detection

First, determine the execution context:

```bash
# Check if already in a worktree
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
CURRENT_DIR=$(pwd)
IS_WORKTREE=false
if [[ "$CURRENT_DIR" != "$MAIN_REPO" ]] && git worktree list | grep -q "$CURRENT_DIR"; then
    IS_WORKTREE=true
fi
```

**Decision logic:**
- If `--here` flag provided → implement in current directory
- If already in a worktree → implement directly (already isolated)
- Otherwise (in main repo) → create worktree and launch in new terminal

---

## Mode A: Direct Implementation (worktree or --here)

Use this mode when already in a worktree OR when `--here` flag is provided.

### Getting Started

When given a plan path:
- Read the plan completely and check for any existing checkmarks (- [x])
- Read all files mentioned in the plan
- **Read files fully** - never use limit/offset parameters, you need complete context
- Think deeply about how the pieces fit together
- Create a todo list to track your progress
- Start implementing if you understand what needs to be done

If no plan path provided, look for recent plans in `thoughts/plans/` and ask which one.

### Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:
- Follow the plan's intent while adapting to what you find
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context
- Update checkboxes in the plan as you complete sections

When things don't match the plan exactly, think about why and communicate clearly. The plan is your guide, but your judgment matters too.

If you encounter a mismatch:
- STOP and think deeply about why the plan can't be followed
- Present the issue clearly:
  ```
  Issue in Phase [N]:
  Expected: [what the plan says]
  Found: [actual situation]
  Why this matters: [explanation]

  How should I proceed?
  ```

### Verification Approach

After implementing a phase:
- Run the success criteria checks (usually `make check test` covers everything)
- Fix any issues before proceeding
- Update your progress in both the plan and your todos
- Check off completed items in the plan file itself using Edit
- **Pause for human verification**: After completing all automated verification for a phase, pause and inform the human that the phase is ready for manual testing:
  ```
  Phase [N] Complete - Ready for Manual Verification

  Automated verification passed:
  - [List automated checks that passed]

  Please perform the manual verification steps listed in the plan:
  - [List manual verification items from the plan]

  Let me know when manual testing is complete so I can proceed to Phase [N+1].
  ```

If instructed to execute multiple phases consecutively, skip the pause until the last phase.

Do not check off items in the manual testing steps until confirmed by the user.

### If You Get Stuck

When something isn't working as expected:
- First, make sure you've read and understood all the relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-tasks sparingly - mainly for targeted debugging or exploring unfamiliar territory.

### Resuming Work

If the plan has existing checkmarks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off

Remember: You're implementing a solution, not just checking boxes. Keep the end goal in mind and maintain forward momentum.

---

## Mode B: Worktree Creation (default in main repo)

Use this mode when in the main repository without `--here` flag. This creates an isolated environment for implementation.

### Process

1. **Get the required information:**
   - If a plan file path is provided as argument, use it
   - Otherwise, look for recently created plans in `thoughts/plans/` directory and ask which one
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
   osascript -e 'tell application "iTerm" to activate' -e 'tell application "iTerm" to create window with default profile' -e 'tell application "iTerm" to tell current session of current window to write text "cd ~/worktrees/$BRANCH_NAME && claude --dangerously-skip-permissions \"/implement_plan --here $ABSOLUTE_PLAN_PATH\""'
   ```

   For macOS with Terminal.app:
   ```bash
   osascript -e 'tell application "Terminal" to activate' -e 'tell application "Terminal" to do script "cd ~/worktrees/$BRANCH_NAME && claude --dangerously-skip-permissions \"/implement_plan --here $ABSOLUTE_PLAN_PATH\""'
   ```

5. **Confirm to user:**
   ```
   ✓ Worktree created: ~/worktrees/$BRANCH_NAME
   ✓ New terminal opened with Claude implementing the plan

   When done, ship your changes:
     /ship              (full PR with description)
     /ship --direct     (quick merge, no PR)
   ```

### Terminal Configuration

The terminal app can be configured via `CLAUDE_TERMINAL` environment variable:

**macOS:** `iterm`, `terminal`, `warp`, `kitty`, `alacritty`, `ghostty`
**Linux:** `gnome-terminal`, `konsole`, `kitty`, `alacritty`, `xterm`

If not set, auto-detects (macOS: iTerm2 > Warp > Terminal.app)

Example: `export CLAUDE_TERMINAL=warp`

### Important for Worktree Mode

- Execute the osascript command directly - do NOT ask for confirmation
- Check `CLAUDE_TERMINAL` env var first, then auto-detect terminal
- The plan path MUST be absolute so it works from the worktree directory
- This opens a completely new terminal window - no manual steps required

---

## Examples

**Default (creates worktree):**
```
/implement_plan thoughts/plans/2025-12-29-auth-refactor.md
```
→ Creates `~/worktrees/auth-refactor`, opens new terminal with Claude

**Implement in current directory:**
```
/implement_plan thoughts/plans/2025-12-29-auth-refactor.md --here
```
→ Implements directly in current directory

**Already in worktree (auto-detected):**
```
/implement_plan thoughts/plans/2025-12-29-auth-refactor.md
```
→ Detects worktree, implements directly (no new terminal)

---

## Relationship to Other Commands

Recommended workflow:
1. `/create_plan` - Design implementation approach
2. `/implement_plan` - Execute the plan (creates worktree by default)
3. `/commit` - Create commits for changes
4. `/ship` - Ship to main and clean up worktree
