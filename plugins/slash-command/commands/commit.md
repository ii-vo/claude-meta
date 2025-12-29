---
description: Create git commits for session changes with clear, atomic messages
allowed-tools: Bash
---

# Commit Changes

You are tasked with creating git commits for the changes made during this session.

## Current State

```bash
!git status --short
```

```bash
!git diff --stat
```

## Process:

1. **Think about what changed:**

    - Review the conversation history and understand what was accomplished
    - Use the git status/diff output above to understand the modifications
    - Consider whether changes should be one commit or multiple logical commits

2. **Plan your commit(s):**

    - Identify which files belong together
    - Draft clear, descriptive commit messages
    - Use prefixes on the commit messages; fix, refactor, feat, docs, style, test
    - Use imperative mood in commit messages
    - Focus on why the changes were made, not just what

3. **Execute upon confirmation:**
    - Use `git add` with specific files (never use `-A` or `.`)
    - Never commit dummy files, test scripts, or other files which you created or which appear to have been created but which were not part of your changes or directly caused by them (e.g. generated code)
    - **ALWAYS commit** `.claude/sessions/` directory - session data must always be committed
    - **DO commit** `.claude/` directory contents including sessions, commands, hooks, skills, and settings
    - **DO commit** `thoughts/` directory (plans/, handoffs/, research/, prs/)
    - **DO commit** `public/` assets (logos, icons, images)
    - **DO NOT commit** `.claude/settings.json.backup.*` temporary backup files
    - Create commits with your planned messages until all of your changes are committed with `git commit -m`

## Remember:

-   You have the full context of what was done in this session
-   Group related changes together
-   Keep commits focused and atomic when possible
-   The user trusts your judgment - they asked you to commit
-   **IMPORTANT**: - never stop and ask for feedback from the user.
