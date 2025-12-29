#!/usr/bin/env bash
set -euo pipefail

# cleanup_worktree.sh - Clean up git worktrees
#
# Usage: ./cleanup_worktree.sh [worktree_path_or_name]
#
# If no worktree is provided, lists available worktrees to clean up

# Default worktree location
WORKTREES_BASE="${WORKTREES_BASE:-$HOME/worktrees}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to list worktrees
list_worktrees() {
    echo -e "${YELLOW}Available worktrees:${NC}"
    git worktree list | tail -n +2 || {
        echo "No additional worktrees found"
        return 1
    }
}

# Function to clean up a specific worktree
cleanup_worktree() {
    local input="$1"
    local worktree_path

    # Check if input is a full path or just a name
    if [[ "$input" == /* ]]; then
        worktree_path="$input"
    else
        worktree_path="$WORKTREES_BASE/$input"
    fi

    # Check if worktree exists
    if ! git worktree list | grep -q "$worktree_path"; then
        echo -e "${RED}Error: Worktree not found at $worktree_path${NC}"
        echo ""
        list_worktrees
        exit 1
    fi

    # Get branch name from worktree
    local branch_name
    branch_name=$(git worktree list --porcelain | grep -A2 "worktree $worktree_path" | grep "branch" | sed 's|branch refs/heads/||')

    echo -e "${YELLOW}Cleaning up worktree: $worktree_path${NC}"
    echo "Branch: $branch_name"

    # Remove the worktree
    echo "Removing git worktree..."
    if git worktree remove --force "$worktree_path"; then
        echo -e "${GREEN}Worktree removed successfully${NC}"
    else
        echo -e "${RED}Error: Failed to remove worktree${NC}"
        echo "Try manually running:"
        echo "  rm -rf $worktree_path"
        echo "  git worktree prune"
        exit 1
    fi

    # Delete the branch (with confirmation)
    if [ -n "$branch_name" ]; then
        echo ""
        read -p "Delete the branch '$branch_name'? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if git branch -D "$branch_name" 2>/dev/null; then
                echo -e "${GREEN}Branch deleted${NC}"
            else
                echo -e "${YELLOW}Branch might not exist or already deleted${NC}"
            fi
        else
            echo "Branch kept: $branch_name"
        fi
    fi

    # Prune worktree references
    echo "Pruning worktree references..."
    git worktree prune

    echo ""
    echo -e "${GREEN}Cleanup complete!${NC}"
}

# Main logic
if [ $# -eq 0 ]; then
    list_worktrees || exit 1
    echo ""
    echo "Usage: $0 <worktree_path_or_name>"
    echo "Example: $0 swift_fix_1430"
    echo "Example: $0 ~/worktrees/my_feature"
else
    cleanup_worktree "$1"
fi
