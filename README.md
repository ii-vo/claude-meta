# Claude Meta

A marketplace of commands and agents for Claude Code that enhance planning, implementation, and shipping workflows.

## Installation

Add the marketplace and install the plugin:

```bash
/plugin marketplace add ii-vo/claude-meta
/plugin install claude-meta:slash-command
```

Or install directly from the marketplace:

```bash
/plugin install github:ii-vo/claude-meta
```

## Commands

### Planning & Implementation

| Command | Description |
|---------|-------------|
| `/create_plan` | Create detailed implementation plans through interactive research |
| `/create_plan_no_thoughts` | Create implementation plans (no notes directory) |
| `/implement_plan` | Execute a plan with verification |
| `/implement_in_worktree` | Create git worktree and implement plan in isolated branch |
| `/iterate_plan` | Update existing plans based on feedback |
| `/validate_plan` | Verify implementation against plan success criteria |

### Shipping

| Command | Description |
|---------|-------------|
| `/ship` | Ship code via PR (with full description) or direct merge |
| `/commit` | Create git commits with clear, atomic messages |

**`/ship` modes:**
- `/ship` - Full PR workflow: analyze, describe, create PR, merge, cleanup
- `/ship --direct` - Direct merge to main, no PR
- `/ship --pr-only` - Create PR with description, don't merge (for team review)

### Context & Handoff

| Command | Description |
|---------|-------------|
| `/create_handoff` | Create handoff document for transferring work |
| `/resume_handoff` | Resume work from a handoff document |
| `/research_codebase` | Document codebase with notes for historical context |

## Agents

Specialized sub-agents spawned by commands for parallel research:

| Agent | Purpose |
|-------|---------|
| `codebase-locator` | Find files and directories relevant to a task |
| `codebase-analyzer` | Analyze implementation details of components |
| `codebase-pattern-finder` | Find similar implementations and usage examples |
| `notes-locator` | Discover relevant documents in notes/research directories |
| `notes-analyzer` | Extract insights and decisions from documentation |
| `web-search-researcher` | Research topics using web search |

## Typical Workflows

### Feature Development

```
/create_plan          → Design implementation approach
/implement_plan       → Execute the plan
/commit               → Commit changes
/ship                 → Create PR, merge, cleanup
```

### Worktree Workflow (Isolated Development)

```
/create_plan                    → Design implementation approach
/implement_in_worktree          → Create worktree + new terminal with Claude
                                  (automatically runs /implement_plan)
/commit                         → Commit changes (in worktree terminal)
/ship                           → Merge PR and cleanup worktree
```

This workflow opens a new terminal in `~/worktrees/<branch>` with Claude already running `/implement_plan`. Perfect for keeping your main terminal free while Claude works.

### Quick Fix

```
(make changes)
/commit
/ship --direct        → Merge directly, no PR
```

### Team Collaboration

```
/create_plan
/implement_plan
/commit
/ship --pr-only       → Create PR for review
(wait for approval)
/ship                 → Merge and cleanup
```

### Handoff Between Sessions

```
/create_handoff       → Document current state
(new session)
/resume_handoff       → Continue from handoff
```

## Structure

```
.claude-plugin/
  marketplace.json     # Marketplace definition
plugins/
  slash-command/       # Main plugin
    .claude-plugin/
      plugin.json      # Plugin metadata
    commands/          # Slash commands
    agents/            # Sub-agent definitions
```

## License

MIT
