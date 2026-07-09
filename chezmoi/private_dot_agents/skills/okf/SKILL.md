---
name: okf
description: >-
  Create and maintain knowledge bundles in Open Knowledge Format (OKF) —
  markdown + YAML-frontmatter concept files for durable, cross-project or
  cross-team knowledge. Use when the user wants to write, structure, or
  validate an OKF bundle (e.g. `~/.okf/`), add a "concept" document, build an
  `index.md`/`log.md`, cross-link concepts, or asks "is this OKF-conformant".
---

# Open Knowledge Format (OKF)

OKF v0.1 (Draft, GoogleCloudPlatform/knowledge-catalog) is a spec for
knowledge as a directory of markdown files with YAML frontmatter — readable
by humans, parseable by agents, diffable in git. No SDK, schema registry, or
central authority required. This file contains the full spec; no need to
re-fetch it.

## Terminology

- **Bundle** — the directory tree of knowledge (unit of distribution).
- **Concept** — one unit of knowledge = one markdown file in the bundle.
- **Concept ID** — the file's path minus `.md` (e.g. `tables/orders.md` → `tables/orders`).
- **Frontmatter** — the `---`-delimited YAML block at the top of a file.

## Bundle layout

```text
bundle/
├── index.md            # optional, directory listing for progressive disclosure
├── log.md               # optional, chronological change history
├── <concept>.md         # a concept at bundle root
└── <subdir>/            # groups concepts by topic
    ├── index.md
    ├── <concept>.md
    └── ...
```

`index.md` and `log.md` are **reserved filenames** — never use them for a
concept document. Every other `.md` file is a concept. File encoding UTF-8,
extension `.md` only.

## Creating a concept

Every concept file MUST start with frontmatter containing a non-empty `type`.
Full schema:

```yaml
---
type: <kind>                 # REQUIRED. Free text, not centrally registered
                              # (e.g. "Playbook", "API Endpoint", "Metric",
                              # "Reference", "Preferences"). Pick a
                              # descriptive, self-explanatory value.
title: <display name>        # recommended; derive from filename if omitted
description: <one sentence>  # recommended; used in index entries/search
resource: <canonical URI>    # recommended if concept wraps a physical asset;
                              # omit for abstract concepts (playbooks, notes)
tags: [<tag>, <tag>]          # recommended; cross-cutting categorization
timestamp: <ISO 8601 datetime>  # recommended; last meaningful change
# any other producer-defined keys are allowed and MUST be preserved by tools
---
```

Field priority when trimming: `title`, `description`, `resource`, `tags`,
`timestamp` — in that order.

Body has no required sections. Prefer structural markdown over prose.
Conventional (optional) headings:

- `# Schema` — columns/fields of a data asset (table format)
- `# Examples` — concrete usage, often fenced code
- `# Citations` — sources backing claims, see below

### Example concept (bound to a resource)

```markdown
---
type: BigQuery Table
title: Customer Orders
description: One row per completed customer order across all channels.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders
tags: [sales, orders, revenue]
timestamp: 2026-05-28T14:30:00Z
---

# Schema

| Column        | Type      | Description                              |
|---------------|-----------|-------------------------------------------|
| `order_id`    | STRING    | Globally unique order identifier.        |
| `customer_id` | STRING    | FK to [customers](/tables/customers.md). |

# Citations

[1] [BigQuery table schema](https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders)
```

### Example concept (not bound to a resource)

```markdown
---
type: Playbook
title: Incident response — data freshness alert
description: Steps to triage a freshness alert on the orders pipeline.
tags: [oncall, incident]
timestamp: 2026-04-12T09:00:00Z
---

# Trigger

A freshness alert fires when `orders` lags more than 30 minutes behind
its expected SLA. See the [orders table](/tables/orders.md).

# Steps

1. Check the [ingestion job dashboard](https://example.com/dash).
```

## Cross-linking concepts

Standard markdown links, two forms:

- **Bundle-absolute (recommended)** — starts with `/`, relative to bundle
  root: `[customers table](/tables/customers.md)`. Stable across moves
  within a subdirectory.
- **Relative** — `[neighboring concept](./other.md)`.

A link just asserts "these are related" — the kind of relationship
(parent/child, joins-with, depends-on) belongs in surrounding prose, not
link syntax. Broken links are tolerated, not an error — they may represent
knowledge not yet written. Don't "fix" a dangling link by deleting it
without checking whether the target should simply be created.

## `index.md`

Purpose: progressive disclosure. May exist in any directory, including
bundle root. No frontmatter, **except** the bundle-root `index.md` may carry
a frontmatter block containing only `okf_version` (see Versioning below) —
the one exception to "index.md has no frontmatter".

Body = one or more headed sections, each a flat bullet list of links with a
short description (pull the description from the linked concept's
frontmatter when generating/updating):

```markdown
# Section Heading

* [Title 1](relative-url-1) - short description of item 1
* [Title 2](relative-url-2) - short description of item 2

# Another Section

* [Subdirectory](subdir/) - short description of the subdirectory
```

## `log.md`

Optional, at any directory level, records that scope's change history.
Flat list, date-grouped headings in **`## YYYY-MM-DD`** form, **newest
first**:

```markdown
# Directory Update Log

## 2026-05-22
* **Update**: Added new BigQuery table reference for [Customer Metrics](/tables/customer-metrics.md).
* **Creation**: Established the [Dataplex Playbook](/playbooks/dataplex.md).

## 2026-05-15
* **Initialization**: Created foundational directory structure.
```

The leading bold word (`**Update**`, `**Creation**`, `**Deprecation**`) is
convention, not required structure — entries are otherwise free prose.

## Citations

When a concept's body makes claims sourced from external material, list
them under a trailing `# Citations` heading, numbered:

```markdown
# Citations

[1] [BigQuery public dataset announcement](https://cloud.google.com/blog/...)
[2] [Internal data quality runbook](https://wiki.acme.internal/data/quality)
```

Citation targets may be external URLs, bundle-relative paths, or paths into
a `references/` subdirectory that mirrors external material as first-class
OKF concepts.

## Conformance — the only hard rules

A bundle is OKF-conformant iff:

1. Every non-reserved `.md` file has parseable YAML frontmatter.
2. Every frontmatter block has a non-empty `type`.
3. `index.md`/`log.md`, where present, follow the structures above.

Everything else is soft guidance. Do **not** reject or "fix" a bundle for:
missing optional fields, unknown `type` values, unknown extra frontmatter
keys, broken links, or a missing `index.md`. This permissiveness is
intentional — it supports partial/incremental agent-driven growth.

## Versioning

Format `<major>.<minor>`; this spec is `0.1`. Minor bump = backward-compatible
addition (new optional field, new conventional heading). Major bump =
breaking (renamed required field, changed reserved filename). Declare a
bundle's target version only in the bundle-root `index.md` frontmatter:

```yaml
---
okf_version: "0.1"
---
```

## Maintaining a bundle (workflow)

1. **New concept** — pick the right subdirectory (create one if the topic
  is new), write the file with required `type` + recommended fields, link
  it from related concepts and from the nearest `index.md`.
2. **Update a concept** — edit body/frontmatter in place, bump `timestamp`,
  add a `log.md` entry at the relevant directory level if the bundle
  maintains one.
3. **Reorganize** — moving a file only breaks *relative* (`./`) links, not
  bundle-absolute (`/`) ones; prefer bundle-absolute links to make this
  safe. Update the old and new directories' `index.md` entries.
4. **New subdirectory** — add its `index.md`, and add one line linking to
  `subdir/` from the parent `index.md`.
5. Before treating a bundle as broken, check it against the three
  conformance rules above only — don't invent stricter rules.
