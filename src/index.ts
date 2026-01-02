import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "claude-plugin-template",
  version: "0.1.0"
});

server.tool(
  "hello",
  {
    name: z.string().default("world")
  },
  async ({ name }) => {
    return {
      content: [{ type: "text", text: `Hello, ${name}!` }]
    };
  }
);

server.resource("template_readme", "template://readme", async (uri) => {
  return {
    contents: [
      {
        uri: uri.toString(),
        text: "This is a sample MCP resource from claude-plugin-template."
      }
    ]
  };
});

const transport = new StdioServerTransport();
await server.connect(transport);
