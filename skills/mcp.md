# Skill: MCP servers (Model Context Protocol)

## What you ship

- A process Claude can start (usually stdio) that exposes tools/resources.
- A config entry in `.mcp.json` (Claude Code) or `claude_desktop_config.json` (Claude Desktop).

## Local development loop

- `npm run dev` during development.
- `npm run build` then `npm run start` to validate the compiled build.

Docs:
- Claude Code MCP: https://code.claude.com/docs/en/mcp
- MCP spec/transports: https://modelcontextprotocol.io/specification
