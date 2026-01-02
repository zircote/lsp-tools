# Copilot instructions

You are working in a template repository for Claude Code + MCP servers.

## Priorities

1. Keep changes small and reviewable.
2. Prefer TypeScript and the official `@modelcontextprotocol/sdk`.
3. Update documentation when you change developer-facing behavior.

## Commands

- Build: `npm run build`
- Typecheck: `npm run typecheck`
- Run MCP server (dev): `npm run dev`

## Security

- Never hardcode tokens.
- Prefer env vars in `.mcp.json` / Claude Desktop config.
