#!/usr/bin/env python3
"""
Branch Protection Hook for Claude Code

Blocks deletion of protected branches (main, staging, development).
Used as a PreToolUse hook to intercept dangerous git commands.

Exit codes:
  0 - Allow the command
  2 - Block the command (stderr shown to Claude)
"""
import json
import sys
import re

PROTECTED_BRANCHES = ['main', 'staging', 'development']

def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Hook error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(0)  # Allow on parse error (fail open)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    command = tool_input.get("command", "")

    if tool_name != "Bash":
        sys.exit(0)

    # Patterns that delete branches
    dangerous_patterns = [
        # git branch -D <branch> or git branch -d <branch>
        (r'git\s+branch\s+-[dD]\s+(\S+)', 'delete local branch'),
        # git push origin --delete <branch>
        (r'git\s+push\s+\S*\s*--delete\s+(\S+)', 'delete remote branch'),
        # git push origin :<branch>
        (r'git\s+push\s+\S+\s+:(\S+)', 'delete remote branch'),
        # gh pr merge --delete-branch (extracts branch from earlier in command or uses current)
        (r'gh\s+pr\s+merge\s+(\S+)\s+.*--delete-branch', 'delete branch via PR merge'),
    ]

    for pattern, description in dangerous_patterns:
        match = re.search(pattern, command, re.IGNORECASE)
        if match:
            branch_name = match.group(1)

            if branch_name in PROTECTED_BRANCHES:
                error_msg = (
                    f"BLOCKED: Cannot {description} '{branch_name}'. "
                    f"Protected branches: {', '.join(PROTECTED_BRANCHES)}"
                )
                print(error_msg, file=sys.stderr)
                sys.exit(2)

    sys.exit(0)

if __name__ == "__main__":
    main()
