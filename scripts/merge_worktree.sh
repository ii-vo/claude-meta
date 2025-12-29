#!/usr/bin/env bash
set -euo pipefail

# merge_worktree.sh - Merge worktree branch to main and clean up
#
# Usage: ./merge_worktree.sh [worktree_path_or_branch] [options]
#
# Options:
#   --squash       Squash all commits into one
#   --no-pr        Skip PR, merge directly
#   --keep-branch  Don't delete branch after merge

# Default worktree location
WORKTREES_BASE="${WORKTREES_BASE:-$HOME/worktrees}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Options
SQUASH=false
NO_PR=false
KEEP_BRANCH=false
BRANCH_NAME=""
WORKTREE_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --squash)
            SQUASH=true
            shift
            ;;
        --no-pr)
            NO_PR=true
            shift
            ;;
        --keep-branch)
            KEEP_BRANCH=true
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
        *)
            if [[ -z "$BRANCH_NAME" ]]; then
                BRANCH_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Function to list worktrees
list_worktrees() {
    echo -e "${YELLOW}Available worktrees:${NC}"
    git worktree list | tail -n +2 || {
        echo "No additional worktrees found"
        return 1
    }
}

# Function to get main project directory
get_main_dir() {
    git worktree list | head -1 | awk '{print $1}'
}

# Function to get branch name from worktree
get_branch_from_worktree() {
    local wt_path="$1"
    git worktree list --porcelain | grep -A2 "worktree $wt_path" | grep "branch" | sed 's|branch refs/heads/||'
}

# If no branch provided, list and prompt
if [[ -z "$BRANCH_NAME" ]]; then
    list_worktrees || exit 1
    echo ""
    read -p "Enter worktree name or path to merge: " BRANCH_NAME
    if [[ -z "$BRANCH_NAME" ]]; then
        echo -e "${RED}No worktree specified${NC}"
        exit 1
    fi
fi

# Resolve worktree path
if [[ "$BRANCH_NAME" == /* ]]; then
    WORKTREE_PATH="$BRANCH_NAME"
    BRANCH_NAME=$(basename "$WORKTREE_PATH")
elif [[ -d "$WORKTREES_BASE/$BRANCH_NAME" ]]; then
    WORKTREE_PATH="$WORKTREES_BASE/$BRANCH_NAME"
else
    # Try to find by branch name
    WORKTREE_PATH=$(git worktree list | grep "\[$BRANCH_NAME\]" | awk '{print $1}' || echo "")
    if [[ -z "$WORKTREE_PATH" ]]; then
        WORKTREE_PATH="$WORKTREES_BASE/$BRANCH_NAME"
    fi
fi

# Verify worktree exists
if ! git worktree list | grep -q "$WORKTREE_PATH"; then
    echo -e "${RED}Error: Worktree not found: $WORKTREE_PATH${NC}"
    list_worktrees
    exit 1
fi

# Get actual branch name from worktree
ACTUAL_BRANCH=$(get_branch_from_worktree "$WORKTREE_PATH")
if [[ -n "$ACTUAL_BRANCH" ]]; then
    BRANCH_NAME="$ACTUAL_BRANCH"
fi

echo -e "${BLUE}Merging worktree:${NC} $WORKTREE_PATH"
echo -e "${BLUE}Branch:${NC} $BRANCH_NAME"
echo ""

# Check for uncommitted changes
if [[ -d "$WORKTREE_PATH" ]]; then
    CHANGES=$(git -C "$WORKTREE_PATH" status --porcelain 2>/dev/null || echo "")
    if [[ -n "$CHANGES" ]]; then
        echo -e "${YELLOW}Warning: Uncommitted changes in worktree:${NC}"
        echo "$CHANGES"
        echo ""
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted. Please commit or stash changes first."
            exit 1
        fi
    fi
fi

# Get main project directory
MAIN_DIR=$(get_main_dir)
echo -e "${BLUE}Main project:${NC} $MAIN_DIR"

# Check if branch has remote
HAS_REMOTE=false
if git branch -r | grep -q "origin/$BRANCH_NAME"; then
    HAS_REMOTE=true
fi

# Determine merge strategy
if [[ "$NO_PR" == false ]] && [[ "$HAS_REMOTE" == true ]] && command -v gh &> /dev/null; then
    echo ""
    echo -e "${YELLOW}Merge strategy: PR-based${NC}"

    # Check if PR exists
    PR_STATE=$(gh pr view "$BRANCH_NAME" --json state -q '.state' 2>/dev/null || echo "NONE")

    if [[ "$PR_STATE" == "NONE" ]]; then
        echo "Creating PR..."
        gh pr create --head "$BRANCH_NAME" --base main --title "Merge $BRANCH_NAME" --fill || {
            echo -e "${YELLOW}PR creation failed, falling back to direct merge${NC}"
            NO_PR=true
        }
    elif [[ "$PR_STATE" == "OPEN" ]]; then
        echo "PR already exists and is open"
    elif [[ "$PR_STATE" == "MERGED" ]]; then
        echo -e "${GREEN}PR already merged${NC}"
    fi

    if [[ "$NO_PR" == false ]]; then
        # Merge the PR
        if [[ "$SQUASH" == true ]]; then
            echo "Merging PR with squash..."
            gh pr merge "$BRANCH_NAME" --squash --delete-branch || {
                echo -e "${RED}PR merge failed${NC}"
                exit 1
            }
        else
            echo "Merging PR..."
            gh pr merge "$BRANCH_NAME" --merge --delete-branch || {
                echo -e "${RED}PR merge failed${NC}"
                exit 1
            }
        fi
        echo -e "${GREEN}PR merged successfully${NC}"
    fi
fi

# Direct merge if no PR
if [[ "$NO_PR" == true ]] || [[ "$HAS_REMOTE" == false ]]; then
    echo ""
    echo -e "${YELLOW}Merge strategy: Direct merge${NC}"

    cd "$MAIN_DIR"

    # Ensure we're on main
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ "$CURRENT_BRANCH" != "main" ]] && [[ "$CURRENT_BRANCH" != "master" ]]; then
        git checkout main 2>/dev/null || git checkout master
    fi

    # Pull latest
    git pull origin "$(git branch --show-current)" 2>/dev/null || true

    # Merge
    if [[ "$SQUASH" == true ]]; then
        echo "Squash merging..."
        git merge --squash "$BRANCH_NAME" || {
            echo -e "${RED}Merge conflicts detected. Please resolve and run again.${NC}"
            exit 1
        }
        git commit -m "feat: merge $BRANCH_NAME (squashed)"
    else
        echo "Merging..."
        git merge "$BRANCH_NAME" --no-ff -m "Merge branch '$BRANCH_NAME'" || {
            echo -e "${RED}Merge conflicts detected. Please resolve and run again.${NC}"
            exit 1
        }
    fi

    # Push
    echo "Pushing to remote..."
    git push origin "$(git branch --show-current)"

    echo -e "${GREEN}Merge complete${NC}"
fi

# Clean up worktree
echo ""
echo -e "${YELLOW}Cleaning up worktree...${NC}"
git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || {
    echo "Force removing directory..."
    rm -rf "$WORKTREE_PATH"
    git worktree prune
}
echo -e "${GREEN}Worktree removed${NC}"

# Delete branch
if [[ "$KEEP_BRANCH" == false ]]; then
    echo ""
    echo -e "${YELLOW}Deleting branch...${NC}"

    # Delete local branch
    git branch -D "$BRANCH_NAME" 2>/dev/null || echo "Local branch already deleted"

    # Delete remote branch
    git push origin --delete "$BRANCH_NAME" 2>/dev/null || echo "Remote branch already deleted or doesn't exist"

    echo -e "${GREEN}Branch deleted${NC}"
fi

# Prune
git worktree prune

echo ""
echo -e "${GREEN}✓ Complete!${NC}"
echo -e "  Branch '$BRANCH_NAME' merged to main"
echo -e "  Worktree removed: $WORKTREE_PATH"
if [[ "$KEEP_BRANCH" == false ]]; then
    echo -e "  Branch deleted: $BRANCH_NAME"
fi
