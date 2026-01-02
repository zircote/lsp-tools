# Skill: Claude Code project layout

## Core directories

- `.claude/commands/`: Custom slash commands (version-controlled).
- `.claude/hooks/`: Hook scripts referenced from settings.
- `.claude/settings.json`: Project settings (including hooks).

## Custom slash commands

Create `./.claude/commands/<name>.md` and it becomes `/name`.
Nested folders create namespaces: `.claude/commands/github/pr-review.md` becomes `/github:pr-review`.

Docs: https://code.claude.com/docs/en/slash-commands
