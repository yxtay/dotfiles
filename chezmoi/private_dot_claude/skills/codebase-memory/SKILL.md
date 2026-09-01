---
name: codebase-memory
description: >-
  Use the codebase knowledge graph for structural code queries. Triggers on:
  explore the codebase, understand the architecture, what functions exist,
  show me the structure, who calls this function, what does X call,
  trace the call chain, find callers of, show dependencies, impact analysis,
  dead code, unused functions, high fan-out, refactor candidates,
  code quality audit, graph query syntax, Cypher query examples, edge types,
  how to use search_graph.
---

# Codebase Memory — Knowledge Graph Tools

Graph tools return precise structural results in ~500 tokens vs ~80K for grep.

All tools run via CLI (no MCP server required):
`codebase-memory-mcp cli <tool> --flag value` or `echo '<json>' | codebase-memory-mcp cli <tool>`

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
3. `codebase-memory-mcp cli search_graph --project <id> --label Function --name-pattern '.*Pattern.*'`
   — find code
4. `codebase-memory-mcp cli get_code_snippet --project <id> --qualified-name project.path.FuncName`
   — read source

## Tracing Workflow

1. `codebase-memory-mcp cli search_graph --project <id> --name-pattern '.*FuncName.*'`
   — discover exact name
2. `codebase-memory-mcp cli trace_path --project <id> --function-name FuncName --direction both`
   `--depth 3` — trace
3. `codebase-memory-mcp cli detect_changes --project <id>` — map git diff to affected symbols

## Evidence Tiers

- **Scout (Tier 1):** fast positive lookup with few graph calls and targeted source checks. Treat
  results as provisional; never make absence, exhaustive, dead-code, or complete-impact claims.
- **Verify (Tier 2, default):** task-directed searches, relevant trace directions, exact snippets
  for material claims, and all relevant result pages.
- **Auditor (Tier 3):** bounded-scope full verification with a current graph generation, complete
  relevant pagination, both call directions and broader relationships when material, plus explicit
  unresolved limitations.
- **Every tier:** after candidate paths are known, call `check_index_coverage` once with every
  evidence path. For negative or exhaustive claims also include the relevant scopes. A clean result
  means no recorded gap, not proof of completeness. For partial, skipped, excluded, stale, pending,
  or unknown coverage, read/grep the reported ranges or scope before relying on the graph.

## Sessions and Subagents

- At session start or after compaction, run `list_projects`/`index_status` before structural
  exploration, then choose Scout, Verify, or Auditor for the task.
- Before delegating to a subagent, query the graph and coverage in the parent. Pass the tier, exact
  project, generation/freshness, bounded scope, queries and pagination state, qualified symbols,
  paths, call-chain findings, coverage ranges/reasons, source fallback already performed, and
  unresolved questions to the child.
- A child without CLI access must not call or claim CLI access. It should work from the supplied
  evidence and use read/grep on exact source, especially every reported missed-coverage range.

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
`check_index_coverage`, `manage_adr`, `ingest_traces`

## Edge Types

CALLS, HTTP_CALLS, ASYNC_CALLS, DATA_FLOWS, IMPORTS, DEFINES, DEFINES_METHOD,
HANDLES, IMPLEMENTS, OVERRIDE, USAGE, CALL_REFERENCE, CONFIGURES, FILE_CHANGES_WITH,
SIMILAR_TO, SEMANTICALLY_RELATED, CONTAINS_FILE, CONTAINS_FOLDER, CONTAINS_PACKAGE

## Cypher Examples (for query_graph)

```bash
codebase-memory-mcp cli query_graph --project <id> \
  --query 'MATCH (a)-[r:HTTP_CALLS]->(b) RETURN a.name, b.name, r.url_path, r.confidence LIMIT 20'
codebase-memory-mcp cli query_graph --project <id> \
  --query 'MATCH (f:Function) WHERE f.name =~ ".*Handler.*" RETURN f.name, f.file_path'
codebase-memory-mcp cli query_graph --project <id> \
  --query 'MATCH (a)-[r:CALLS]->(b) WHERE a.name = "main" RETURN b.name'
```

## Gotchas

1. `search_graph --relationship HTTP_CALLS` filters nodes by degree — use `query_graph` with Cypher
   to see actual edges.
2. `query_graph` has a 100k row ceiling — add a Cypher `LIMIT` for broad queries or use
   `search_graph` pagination.
3. `trace_path` needs exact names — use `search_graph --name-pattern` first.
4. `--direction outbound` misses cross-service callers — use `--direction both`.
5. `search_graph` results default to 50 per page — check `has_more` and use `--offset`.
6. `--semantic-query` requires an array of strings, not a single string.
