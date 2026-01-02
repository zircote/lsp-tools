# claude-plugin-template

A ready-to-fork template for building a **Claude Code “plugin”** using:

- **Claude Code project assets**: `.claude/commands`, `.claude/hooks`, `.claude/settings.json`
- **MCP server** (Model Context Protocol) in **TypeScript** using stdio transport
- **Team automation** in `.github/` (CI, templates, Copilot prompts/instructions)

## Quickstart

```bash
npm install
npm run typecheck
npm run build
```

Run the MCP server locally:

```bash
npm run dev
# or
npm run start
```

## Fork checklist (rename it once)

- Rename the package in `package.json` and the server name/version in `src/index.ts`.
- Update the `.mcp.json` server key (`mcpServers.<name>`) to match.

## Using with Claude Code (recommended)

1) Build the server:

```bash
npm run build
```

2) Ensure `.mcp.json` exists at repo root (it does in this template):

```json
{
  "mcpServers": {
    "claude-plugin-template": {
      "type": "stdio",
      "command": "node",
      "args": ["dist/index.js"],
      "env": {}
    }
  }
}
```

3) Add/enable the MCP server in Claude Code.

If you use the CLI, the flow is typically:

```bash
claude mcp add claude-plugin-template -- node dist/index.js
claude mcp list
```

Docs: https://code.claude.com/docs/en/mcp

## Using with Claude Desktop

Claude Desktop MCP servers are typically configured in `claude_desktop_config.json`.
Common location (macOS): `~/Library/Application Support/Claude/claude_desktop_config.json`.
Docs: https://modelcontextprotocol.io/docs/develop/connect-local-servers

## What’s included

### 1) MCP server (`src/index.ts`)

This template exposes:
- Tool: `hello({ name })` → returns “Hello, <name>!”
- Resource: `template://readme`

Add more tools/resources in `src/index.ts`.

### 2) Claude Code commands (`.claude/commands/*`)

Examples included:
- `/setup` – install + build sanity check
- `/mcp [dev|build|start]` – run the MCP server
- `/github:pr-review <owner/repo#PR>` – review a PR with `gh`

Reminder: nested folders create namespaces, e.g. `.claude/commands/github/pr-review.md` ⇒ `/github:pr-review`.
Docs: https://code.claude.com/docs/en/slash-commands

### 3) Claude Code hooks (`.claude/settings.json` + `.claude/hooks/*`)

This template includes a minimal **PreToolUse** Bash guard hook that blocks obviously-dangerous shell commands.
Docs: https://code.claude.com/docs/en/hooks

### 4) “Skills” (`skills/*`)

Put durable team guidance here: conventions, how-to, runbooks.

### 5) GitHub automation (`.github/*`)

- CI (`.github/workflows/ci.yml`) runs `npm ci`, `typecheck`, `build`.
- Issue templates + PR template.
- Copilot instructions and reusable prompts.

## Developing new features

### Add a new MCP tool

1) Add `server.tool(...)` in `src/index.ts`.
2) Run:

```bash
npm run typecheck
npm run build
```

### Add a new slash command

Create: `.claude/commands/<name>.md`

Use YAML frontmatter to set `description` and restrict tools via `allowed-tools`.

## Security checklist

- Never commit tokens or API keys.
- Prefer `env` entries in `.mcp.json` and local overrides in `.claude/settings.local.json`.
- Keep hooks fail-open unless you’re confident about payload compatibility.
