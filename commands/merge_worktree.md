---
description: "[DEPRECATED - Use /ship instead] Merge worktree branch to main and clean up"
---

> **DEPRECATED**: This command has been replaced by `/ship` which provides a unified workflow for both PR-based and direct merges, with automatic worktree detection.
>
> Use instead:
> - `/ship` - Full PR workflow with description
> - `/ship --direct` - Quick direct merge

## Process

1. **Identify the worktree to merge:**
   - If a worktree path or branch name is provided as argument, use it
   - Otherwise, list available worktrees and ask which one to merge:
     ```bash
     git worktree list
     ```
   - Confirm the worktree path and branch name

2. **Verify the worktree state:**
   ```bash
   # Check for uncommitted changes in the worktree
   git -C ~/worktrees/$BRANCH_NAME status --porcelain
   ```
   - If there are uncommitted changes, warn the user and ask how to proceed:
     - Commit them first
     - Stash them
     - Discard them
     - Abort

3. **Determine merge strategy:**
   - Check if branch has been pushed to remote:
     ```bash
     git branch -r | grep -q "origin/$BRANCH_NAME"
     ```
   - Ask user for merge strategy:
     - **PR merge (recommended)**: Create/use existing PR, merge via GitHub
     - **Direct merge**: Merge directly to main locally
     - **Squash merge**: Squash all commits into one

4. **Execute the merge:**

   **Option A: PR-based merge (if branch is pushed)**
   ```bash
   # Check if PR exists
   gh pr view $BRANCH_NAME --json state 2>/dev/null

   # If no PR, create one
   gh pr create --head $BRANCH_NAME --base main --title "Merge $BRANCH_NAME" --fill

   # Merge the PR (squash by default)
   gh pr merge $BRANCH_NAME --squash --delete-branch
   ```

   **Option B: Direct merge**
   ```bash
   # Go to main project directory (not worktree)
   cd $(git worktree list | head -1 | awk '{print $1}')

   # Ensure on main and up to date
   git checkout main
   git pull origin main

   # Merge the branch
   git merge $BRANCH_NAME --no-ff -m "Merge branch '$BRANCH_NAME'"

   # Push to remote
   git push origin main
   ```

   **Option C: Squash merge**
   ```bash
   cd $(git worktree list | head -1 | awk '{print $1}')
   git checkout main
   git pull origin main
   git merge --squash $BRANCH_NAME
   git commit -m "feat: $BRANCH_NAME (squashed)"
   git push origin main
   ```

5. **Clean up the worktree:**
   ```bash
   # Remove the worktree
   git worktree remove ~/worktrees/$BRANCH_NAME --force

   # Prune worktree references
   git worktree prune
   ```

6. **Delete the branch:**
   ```bash
   # Delete local branch
   git branch -D $BRANCH_NAME

   # Delete remote branch (if exists and not deleted by PR merge)
   git push origin --delete $BRANCH_NAME 2>/dev/null || true
   ```

7. **Confirm completion:**
   ```
   ✓ Branch '$BRANCH_NAME' merged to main
   ✓ Worktree removed: ~/worktrees/$BRANCH_NAME
   ✓ Branch deleted: $BRANCH_NAME

   Main branch is now up to date with the merged changes.
   ```

## Options

| Flag | Description |
|------|-------------|
| `--squash` | Squash all commits into one |
| `--no-pr` | Skip PR creation, merge directly |
| `--keep-branch` | Don't delete the branch after merge |

## Examples

**Merge with PR (recommended):**
```
/merge_worktree feature-auth
```
→ Creates PR if needed, merges via GitHub, cleans up

**Direct squash merge:**
```
/merge_worktree feature-auth --squash --no-pr
```
→ Squashes commits, merges directly to main, cleans up

**List available worktrees:**
```
/merge_worktree
```
→ Shows all worktrees and prompts for selection

## Important

- Always verify there are no uncommitted changes before merging
- PR merge is recommended for better history and CI checks
- The command will detect the main project directory automatically
- If merge conflicts occur, the command will pause and ask for resolution
- Remote branch deletion is attempted but won't fail if already deleted

## Handling Merge Conflicts

If conflicts occur during merge:
```
Merge conflict detected in the following files:
- src/file1.ts
- src/file2.ts

Options:
1. Resolve conflicts manually and continue
2. Abort the merge
3. Use the worktree version (--theirs)
4. Use the main version (--ours)
```

After resolution:
```bash
git add .
git commit
# Then re-run /merge_worktree to complete cleanup
```

## Relationship to Other Commands

Recommended worktree workflow:
1. `/implement_in_worktree` - Create worktree and start implementation
2. `/implement_plan` - Execute the plan (runs in new terminal)
3. `/commit` - Create commits for changes
4. `/merge_worktree` - Merge to main and clean up worktree

This command completes the worktree lifecycle by merging changes back to main and cleaning up the isolated development environment.
