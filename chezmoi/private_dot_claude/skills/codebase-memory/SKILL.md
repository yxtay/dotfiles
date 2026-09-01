---
name: codebase-memory
description: >-
  Use the codebase knowledge graph for structural code queries. Triggers on:
  explore the codebase, understand the architecture, what functions exist,
  show me the structure, who calls this function, what does X call,
  trace the call chain, find callers of, show dependencies, impact analysis,
  dead code, unused functions, high fan-out, refactor candidates,
  code quality audit, graph query syntax, Cypher examples, edge types.
---

# Codebase Memory — Knowledge Graph Tools

Graph tools return precise structural results in ~500 tokens vs ~80K for grep.

**All tools run via CLI** (no MCP server required):

```bash
codebase-memory-mcp cli <tool> --flag value [--flag2 value2 ...]
# or pipe JSON (also accepted):
echo '<json>' | codebase-memory-mcp cli <tool>
```

Raw JSON positional args (`cli <tool> '<json>'`) still work but are deprecated.

## Quick Decision Matrix

| Question                | Tool call                                                 |
|-------------------------|-----------------------------------------------------------|
| Who calls X?            | `trace_path --direction inbound`                          |
| What does X call?       | `trace_path --direction outbound`                         |
| Full call context       | `trace_path --direction both`                             |
| Find by name pattern    | `search_graph --name-pattern '...'`                       |
| NL keyword search       | `search_graph --query 'words'`                            |
| Dead code               | `search_graph --max-degree 0 --exclude-entry-points true` |
| Cross-service edges     | `query_graph` with Cypher                                 |
| Impact of local changes | `detect_changes`                                          |
| Risk-classified trace   | `trace_path --risk-labels true`                           |
| Text search             | `search_code` or Grep                                     |

## Exploration Workflow

1. `codebase-memory-mcp cli list_projects` — check if project is indexed
2. `codebase-memory-mcp cli get_graph_schema --project <id>` — understand node/edge types
3. `codebase-memory-mcp cli search_graph --project <id> --label Function --name-pattern '.*'`
4. `codebase-memory-mcp cli get_code_snippet --project <id> --qualified-name path.FuncName`

## Tracing Workflow

1. `codebase-memory-mcp cli search_graph --project <id> --name-pattern '.*FuncName.*'`
2. `codebase-memory-mcp cli trace_path --project <id> --function-name FuncName --direction both`
3. `codebase-memory-mcp cli detect_changes --project <id>` — map git diff to symbols

## search_graph Key Flags

| Flag                          | Purpose                                                                             |
|-------------------------------|-------------------------------------------------------------------------------------|
| `--query <text>`              | BM25 NL search (camelCase split, noise labels filtered); overrides `--name-pattern` |
| `--name-pattern <regex>`      | Regex match on node name                                                            |
| `--qn-pattern <regex>`        | Regex match on qualified name                                                       |
| `--file-pattern <regex>`      | Regex match on file path                                                            |
| `--label <string>`            | Filter by node type (Function, Class, etc.)                                         |
| `--min-degree / --max-degree` | Degree filter                                                                       |
| `--fields <array>`            | Extra columns: complexity, signature, docstring, return_type, is_test, lines        |
| `--format json`               | Structured JSON output instead of tree text                                         |
| `--semantic-query <array>`    | Keyword array for vector search (requires full index mode)                          |

## Quality Analysis

- Dead code: `search_graph --project <id> --max-degree 0 --exclude-entry-points true`
- High fan-out: `search_graph --project <id> --min-degree 10 --relationship CALLS --direction outbound`
- High fan-in: `search_graph --project <id> --min-degree 10 --relationship CALLS --direction inbound`

## 15 CLI Tools

`index_repository`, `index_status`, `list_projects`, `delete_project`,
`search_graph`, `search_code`, `trace_path`, `detect_changes`,
`query_graph`, `get_graph_schema`, `get_code_snippet`, `get_architecture`,
`manage_adr`, `ingest_traces`, `check_index_coverage`

## Edge Types

CALLS, HTTP_CALLS, ASYNC_CALLS, IMPORTS, DEFINES, DEFINES_METHOD,
HANDLES, IMPLEMENTS, OVERRIDE, USAGE, FILE_CHANGES_WITH,
CONTAINS_FILE, CONTAINS_FOLDER, CONTAINS_PACKAGE

## Cypher Examples

```bash
codebase-memory-mcp cli query_graph --project <id> \
  --query 'MATCH (a)-[r:HTTP_CALLS]->(b) RETURN a.name, b.name LIMIT 20'
codebase-memory-mcp cli query_graph --project <id> \
  --query 'MATCH (f:Function) WHERE f.name =~ ".*Handler.*" RETURN f.name'
```

## Gotchas

1. `"relationship":"HTTP_CALLS"` in `search_graph` filters by degree — use `query_graph` for edges.
2. `query_graph` has a 200-row cap — use `search_graph` with degree filters for counting.
3. `trace_path` needs exact names — use `search_graph` with `--name-pattern` first.
4. `"direction":"outbound"` misses cross-service callers — use `"direction":"both"`.
5. Results default to 10 per page — check `has_more` and use `--offset`.
6. `--semantic-query` requires an array of strings, not a single string.
