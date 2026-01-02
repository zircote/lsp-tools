---
description: Build and run the MCP server locally
allowed-tools: Bash
argument-hint: [dev|build|start]
---

If $ARGUMENTS is "dev", run the dev server.
If $ARGUMENTS is "build", compile to dist.
If $ARGUMENTS is "start", run compiled dist.

!`case "$ARGUMENTS" in \
  dev) npm run dev ;; \
  build) npm run build ;; \
  start) npm run start ;; \
  *) echo "Usage: /mcp [dev|build|start]"; exit 2 ;; \
esac`
