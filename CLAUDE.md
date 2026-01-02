# CLAUDE.md (project context)

This repository is a **template** for building Claude Code automations and MCP servers.

## Repo goals

- Be easy to fork.
- Provide a sane default MCP server in TypeScript.
- Provide examples of Claude Code commands and hooks.

## Key files

- `.mcp.json`: Claude Code MCP server configuration (project-scoped).
- `.claude/settings.json`: Hook configuration.
- `.claude/commands/`: Custom commands that show up as `/...`.
- `.claude/hooks/`: Hook scripts.
- `src/index.ts`: MCP server entrypoint.

## Development conventions

- Prefer minimal diffs.
- Keep scripts safe and portable.
- Keep documentation in sync (README + skills files).

## When adding tools

- Use `zod` schemas.
- Return text via `{ content: [{ type: "text", text: "..." }] }`.
- Avoid side effects by default; require explicit user intent for destructive operations.

## When adding hooks

- Hooks are configured in `.claude/settings.json`.
- Keep hooks fast and deterministic.
- Prefer blocking only high-confidence dangerous operations.

Docs:
- Hooks: https://code.claude.com/docs/en/hooks
- Slash commands: https://code.claude.com/docs/en/slash-commands
- MCP: https://code.claude.com/docs/en/mcp
