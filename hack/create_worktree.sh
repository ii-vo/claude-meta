#!/bin/bash

# create_worktree.sh - Create a new git worktree for development work
# Usage: ./create_worktree.sh [worktree_name] [base_branch]
# If no name provided, generates a unique human-readable one
# If no base branch provided, uses current branch

set -e

# Function to generate a unique worktree name
generate_unique_name() {
    local adjectives=("swift" "bright" "clever" "smooth" "quick" "clean" "sharp" "neat" "cool" "fast")
    local nouns=("fix" "task" "work" "dev" "patch" "branch" "code" "build" "test" "run")

    local adj=${adjectives[$RANDOM % ${#adjectives[@]}]}
    local noun=${nouns[$RANDOM % ${#nouns[@]}]}
    local timestamp=$(date +%H%M)

    echo "${adj}_${noun}_${timestamp}"
}

# Get worktree name from parameter or generate one
WORKTREE_NAME=${1:-$(generate_unique_name)}

# Get base branch from second parameter or use current branch
BASE_BRANCH=${2:-$(git branch --show-current)}

# Get repository name
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

# Default worktree location
WORKTREES_BASE="${WORKTREES_BASE:-$HOME/worktrees}"
WORKTREE_PATH="${WORKTREES_BASE}/${WORKTREE_NAME}"

echo "Creating worktree: ${WORKTREE_NAME}"
echo "Location: ${WORKTREE_PATH}"

# Check if worktrees base directory exists
if [ ! -d "$WORKTREES_BASE" ]; then
    echo "Creating worktrees directory: $WORKTREES_BASE"
    mkdir -p "$WORKTREES_BASE"
fi

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "Error: Worktree directory already exists: $WORKTREE_PATH"
    exit 1
fi

echo "Creating from branch: ${BASE_BRANCH}"

# Create worktree (creates branch if it doesn't exist)
if git show-ref --verify --quiet "refs/heads/${WORKTREE_NAME}"; then
    echo "Using existing branch: ${WORKTREE_NAME}"
    git worktree add "$WORKTREE_PATH" "$WORKTREE_NAME"
else
    echo "Creating new branch: ${WORKTREE_NAME}"
    git worktree add -b "$WORKTREE_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"
fi

# Copy .claude directory if it exists
if [ -d ".claude" ]; then
    echo "Copying .claude directory..."
    cp -r .claude "$WORKTREE_PATH/"
fi

echo ""
echo "Worktree created successfully!"
echo "Path: ${WORKTREE_PATH}"
echo "Branch: ${WORKTREE_NAME}"
echo ""
echo "To work in this worktree:"
echo "  cd ${WORKTREE_PATH}"
echo ""
echo "To remove this worktree later:"
echo "  git worktree remove ${WORKTREE_PATH}"
echo "  git branch -D ${WORKTREE_NAME}"
