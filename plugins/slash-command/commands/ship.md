---
description: Ship code via PR (with full description) or direct merge, with automatic cleanup
argument-hint: [--direct | --pr-only | --squash]
---

# Ship

Ship your branch to main with automatic cleanup. Works with both worktrees and regular branches.

## Modes

| Mode | Command | Description |
|------|---------|-------------|
| **Full PR** | `/ship` | Describe changes, create/merge PR, cleanup |
| **Direct** | `/ship --direct` | Merge directly to main, no PR |
| **PR Only** | `/ship --pr-only` | Create PR with description, don't merge (for team review) |

## Process

### Step 1: Detect Context

Run these commands to understand the current state:

```bash
# Get current branch
BRANCH=$(git branch --show-current)

# Check if we're in a worktree (not the main repo)
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
CURRENT_DIR=$(pwd)
IS_WORKTREE=false
if [[ "$CURRENT_DIR" != "$MAIN_REPO" ]] && git worktree list | grep -q "$CURRENT_DIR"; then
    IS_WORKTREE=true
fi

# Check if branch is pushed to remote
HAS_REMOTE=false
if git branch -r | grep -q "origin/$BRANCH"; then
    HAS_REMOTE=true
fi

# Check for uncommitted changes
UNCOMMITTED=$(git status --porcelain)
```

**Report to user:**
```
Branch: $BRANCH
Type: [Worktree | Regular branch]
Remote: [Pushed | Local only]
Changes: [Clean | Uncommitted changes detected]
```

If uncommitted changes exist, ask user:
- Commit them now?
- Stash them?
- Abort?

### Step 2: Determine Mode

**If `--direct` flag:**
- Skip to Step 5 (Direct Merge)

**If `--pr-only` flag:**
- Do Steps 3-4, then STOP (don't merge or cleanup)

**Default (full PR workflow):**
- If branch not pushed: push it first
- Continue to Step 3

### Step 3: Analyze Changes (for PR modes)

```bash
# Get the diff against main
git diff main...$BRANCH

# Get commit history
git log main..$BRANCH --oneline
```

Thoroughly analyze:
- What problem does this solve?
- What are the key changes?
- Are there breaking changes?
- What testing was done?

### Step 4: Create/Update PR

1. **Check for PR template:**
   ```bash
   # Look for template
   cat .github/pull_request_template.md 2>/dev/null || cat prs/pr_template.md 2>/dev/null
   ```

2. **Check if PR exists:**
   ```bash
   gh pr view $BRANCH --json number,state,url 2>/dev/null
   ```

3. **Create or update PR:**

   If no PR exists:
   ```bash
   gh pr create --head $BRANCH --base main --title "[descriptive title]" --body "[full description]"
   ```

   If PR exists:
   ```bash
   gh pr edit $BRANCH --body "[updated description]"
   ```

4. **Save description locally:**
   ```bash
   mkdir -p prs
   # Write to prs/{number}_description.md
   ```

**If `--pr-only` mode, STOP here and inform user:**
```
PR created/updated: [URL]
Description saved to: prs/{number}_description.md

When ready to merge, run:
  /ship                    (to merge with cleanup)
  /ship --direct           (to merge without PR)
```

### Step 5: Merge

**For PR workflow (default):**
```bash
# Merge via GitHub (runs CI, proper merge commit)
gh pr merge $BRANCH --merge --delete-branch
```

**For direct workflow (`--direct`):**
```bash
# Go to main repo if in worktree
cd $MAIN_REPO

# Checkout and update main
git checkout main
git pull origin main

# Merge the branch
git merge $BRANCH --no-ff -m "Merge branch '$BRANCH'"

# Push
git push origin main
```

### Step 6: Cleanup

**If worktree:**
```bash
# Remove the worktree
git worktree remove $WORKTREE_PATH --force 2>/dev/null || {
    rm -rf $WORKTREE_PATH
    git worktree prune
}
```

**Delete branch (if not already deleted by PR merge):**
```bash
# Local
git branch -D $BRANCH 2>/dev/null || true

# Remote
git push origin --delete $BRANCH 2>/dev/null || true
```

**Prune:**
```bash
git worktree prune
git fetch --prune
```

### Step 7: Confirm

```
✓ Branch '$BRANCH' shipped to main
✓ [Worktree removed: $PATH | Branch deleted: $BRANCH]
✓ [PR merged: $URL | Direct merge complete]
```

## Options

| Flag | Description |
|------|-------------|
| `--direct` | Skip PR, merge directly to main |
| `--pr-only` | Create/update PR but don't merge (for team review) |
| `--squash` | Squash commits when merging |

## Auto-Detection Logic

The command automatically detects:

1. **Worktree vs Regular Branch:**
   - Compare current directory against `git worktree list`
   - If current dir is in worktree list (not first entry) → it's a worktree

2. **Can use PR workflow:**
   - Branch must be pushed to remote
   - `gh` CLI must be available
   - If not → suggest `--direct` or push first

3. **Cleanup strategy:**
   - Worktree → remove worktree directory + delete branch
   - Regular branch → just delete branch

## Examples

**Ship with full PR (default):**
```
/ship
```
→ Analyzes changes, creates PR with description, merges, cleans up

**Quick direct merge:**
```
/ship --direct
```
→ Merges to main locally, pushes, cleans up

**Create PR for team review:**
```
/ship --pr-only
```
→ Creates PR with full description, stops for review

**Ship from main repo (not in worktree):**
```
/ship feature-branch
```
→ Ships the specified branch

## Relationship to Other Commands

Recommended workflow:
1. `/create_plan` - Design implementation approach
2. `/implement_plan` - Execute the plan (creates worktree by default)
3. `/commit` - Create commits for changes
4. `/ship` - Ship to main and cleanup worktree

This command handles both worktree and regular branch workflows automatically.

## Error Handling

**Uncommitted changes:**
→ Prompt to commit, stash, or abort

**Branch not pushed (for PR mode):**
→ Offer to push, or suggest `--direct`

**Merge conflicts:**
→ Stop and provide resolution instructions

**PR checks failing:**
→ Warn user, ask if they want to proceed anyway

**No `gh` CLI:**
→ Fall back to `--direct` mode with warning
