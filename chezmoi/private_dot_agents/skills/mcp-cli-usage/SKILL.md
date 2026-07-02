---
name: mcp-cli-usage
description: >
  How to call MCP servers from the CLI when no native MCP integration is
  available. Use when the user asks to invoke an MCP tool, mentions mcp-cli,
  needs a tool's schema, or wants to run an MCP server tool by hand.
---

# MCP CLI Usage

Access MCP servers via the `mcp-cli` CLI when no native MCP integration is
available. Prefer native MCP tools over `mcp-cli` when both exist.

## Commands

- `mcp-cli --help` — commands, config search paths, and examples.
- `mcp-cli info <server> <tool>` — inspect a tool's schema.
- `mcp-cli call <server> <tool> '<json_args>'` — execute a tool.
