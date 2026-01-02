---
title: Add a Claude Code slash command
---

Create a new command under `.claude/commands/`.

Requirements:
- Include YAML frontmatter with `description`.
- Use `allowed-tools` to restrict tools.
- Provide clear argument handling (`$ARGUMENTS`).
