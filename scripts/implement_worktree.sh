#!/bin/bash

# implement_worktree.sh - Create worktree and launch Claude in a new terminal
# Usage: ./implement_worktree.sh <branch-name> <plan-file-path>
#
# This script:
# 1. Creates a git worktree with the specified branch name
# 2. Opens a NEW terminal window (Terminal.app or iTerm2)
# 3. Launches Claude Code with --dangerously-skip-permissions
# 4. Automatically starts implementing the plan

set -e

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Usage: implement_worktree.sh <branch-name> <plan-file-path>"
    echo ""
    echo "Example:"
    echo "  implement_worktree.sh feature-timeline ~/project/plans/timeline.md"
    exit 1
fi

BRANCH_NAME="$1"
PLAN_PATH="$2"

# Resolve plan path to absolute path
if [[ "$PLAN_PATH" != /* ]]; then
    PLAN_PATH="$(pwd)/$PLAN_PATH"
fi

# Verify plan file exists
if [ ! -f "$PLAN_PATH" ]; then
    echo "Error: Plan file not found: $PLAN_PATH"
    exit 1
fi

# Default worktree location
WORKTREES_BASE="${WORKTREES_BASE:-$HOME/worktrees}"
WORKTREE_PATH="${WORKTREES_BASE}/${BRANCH_NAME}"

# Create worktrees directory if needed
if [ ! -d "$WORKTREES_BASE" ]; then
    mkdir -p "$WORKTREES_BASE"
fi

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "Worktree already exists at: $WORKTREE_PATH"
else
    echo "Creating worktree: $BRANCH_NAME"
    echo "Location: $WORKTREE_PATH"

    # Create worktree with new branch
    git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" 2>/dev/null || \
        git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"

    # Copy .claude directory if it exists
    if [ -d ".claude" ]; then
        cp -r .claude "$WORKTREE_PATH/"
    fi

    echo "Worktree created!"
fi

# The command to run in the new terminal
CMD="cd '$WORKTREE_PATH' && claude --dangerously-skip-permissions '/implement_plan $PLAN_PATH'"

# Terminal app - configurable via CLAUDE_TERMINAL env var
# Supported values: iterm, terminal, warp, kitty, alacritty, ghostty, gnome-terminal, konsole, xterm
# If not set, auto-detects on macOS (iTerm2 > Terminal.app)
TERMINAL_APP="${CLAUDE_TERMINAL:-auto}"

echo ""
echo "Opening new terminal..."
echo "Plan: $PLAN_PATH"

open_macos_terminal() {
    local app="$1"
    case "$app" in
        iterm|iTerm|iTerm2)
            osascript <<EOF
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        write text "cd '$WORKTREE_PATH' && claude --dangerously-skip-permissions '/implement_plan $PLAN_PATH'"
    end tell
end tell
EOF
            ;;
        terminal|Terminal)
            osascript <<EOF
tell application "Terminal"
    activate
    do script "cd '$WORKTREE_PATH' && claude --dangerously-skip-permissions '/implement_plan $PLAN_PATH'"
end tell
EOF
            ;;
        warp|Warp)
            osascript <<EOF
tell application "Warp"
    activate
    tell application "System Events" to tell process "Warp"
        keystroke "t" using command down
        delay 0.5
        keystroke "cd '$WORKTREE_PATH' && claude --dangerously-skip-permissions '/implement_plan $PLAN_PATH'"
        keystroke return
    end tell
end tell
EOF
            ;;
        kitty)
            kitty @ launch --type=os-window --cwd="$WORKTREE_PATH" bash -c "$CMD; exec bash"
            ;;
        alacritty)
            alacritty --working-directory "$WORKTREE_PATH" -e bash -c "$CMD; exec bash" &
            ;;
        ghostty)
            ghostty -e bash -c "cd '$WORKTREE_PATH' && $CMD; exec bash" &
            ;;
        *)
            echo "Unknown terminal: $app"
            echo "Supported: iterm, terminal, warp, kitty, alacritty, ghostty"
            echo "Set CLAUDE_TERMINAL environment variable."
            return 1
            ;;
    esac
}

# Detect OS and open new terminal
case "$(uname -s)" in
    Darwin)
        if [ "$TERMINAL_APP" = "auto" ]; then
            # Auto-detect: iTerm2 > Warp > Terminal.app
            if [ -d "/Applications/iTerm.app" ]; then
                TERMINAL_APP="iterm"
            elif [ -d "/Applications/Warp.app" ]; then
                TERMINAL_APP="warp"
            else
                TERMINAL_APP="terminal"
            fi
        fi
        open_macos_terminal "$TERMINAL_APP"
        echo "New terminal opened! ($TERMINAL_APP)"
        ;;
    Linux)
        if [ "$TERMINAL_APP" = "auto" ]; then
            # Auto-detect Linux terminal
            if command -v gnome-terminal &> /dev/null; then
                TERMINAL_APP="gnome-terminal"
            elif command -v konsole &> /dev/null; then
                TERMINAL_APP="konsole"
            elif command -v kitty &> /dev/null; then
                TERMINAL_APP="kitty"
            elif command -v alacritty &> /dev/null; then
                TERMINAL_APP="alacritty"
            elif command -v xterm &> /dev/null; then
                TERMINAL_APP="xterm"
            fi
        fi

        case "$TERMINAL_APP" in
            gnome-terminal)
                gnome-terminal -- bash -c "$CMD; exec bash"
                ;;
            konsole)
                konsole -e bash -c "$CMD; exec bash" &
                ;;
            kitty)
                kitty @ launch --type=os-window --cwd="$WORKTREE_PATH" bash -c "$CMD; exec bash"
                ;;
            alacritty)
                alacritty --working-directory "$WORKTREE_PATH" -e bash -c "$CMD; exec bash" &
                ;;
            xterm)
                xterm -e "bash -c '$CMD; exec bash'" &
                ;;
            *)
                echo "Could not detect terminal emulator."
                echo "Set CLAUDE_TERMINAL to: gnome-terminal, konsole, kitty, alacritty, xterm"
                echo "Run this manually:"
                echo "$CMD"
                exit 1
                ;;
        esac
        echo "New terminal opened! ($TERMINAL_APP)"
        ;;
    *)
        echo "Unsupported OS. Run this manually:"
        echo "$CMD"
        exit 1
        ;;
esac

echo ""
echo "When done, clean up with:"
echo "  git worktree remove $WORKTREE_PATH"
echo "  git branch -D $BRANCH_NAME"
