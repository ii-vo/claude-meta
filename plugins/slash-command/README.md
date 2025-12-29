# Slash Command Plugin

Planning, implementation, and shipping workflows for Claude Code.

## Commands

- `/create_plan` - Create detailed implementation plans through interactive research
- `/create_plan_no_thoughts` - Create implementation plans (no notes directory)
- `/implement_plan` - Execute a plan with verification
- `/iterate_plan` - Update existing plans based on feedback
- `/validate_plan` - Verify implementation against plan success criteria
- `/ship` - Ship code via PR or direct merge
- `/commit` - Create git commits with clear, atomic messages
- `/create_handoff` - Create handoff document for transferring work
- `/resume_handoff` - Resume work from a handoff document
- `/research_codebase` - Document codebase with notes for historical context

## Agents

- `codebase-locator` - Find files and directories relevant to a task
- `codebase-analyzer` - Analyze implementation details of components
- `codebase-pattern-finder` - Find similar implementations and usage examples
- `notes-locator` - Discover relevant documents in thoughts/ directories
- `notes-analyzer` - Extract insights and decisions from documentation
- `web-search-researcher` - Research topics using web search
