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
re-fetch it. [TEMPLATE/](TEMPLATE/) is a small worked bundle — every file
kind below in one directory tree — copy from it when actually writing a
bundle, not just reading about one.

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

## Concept frontmatter

Every concept MUST open with a frontmatter block carrying a non-empty
`type`. Recommended fields, in priority order when trimming: `title`,
`description`, `resource`, `tags`, `timestamp`.

| Field | Required | Meaning |
| --- | --- | --- |
| `type` | **yes** | Free-text kind. Not centrally registered. |
| `title` | no | Display name; derives from filename if omitted. |
| `description` | no | One sentence; feeds index entries and search. |
| `resource` | no | Canonical URI of the underlying asset. |
| `tags` | no | List for cross-cutting categorization. |
| `timestamp` | no | ISO 8601 datetime of last meaningful change. |

`type` examples: `Playbook`, `API Endpoint`, `Metric`. Pick a
self-explanatory value; tolerate unknown ones you encounter. `resource` is
omitted for abstract concepts (playbooks, decisions, notes).

Extra producer-defined keys are always allowed — preserve them, never strip
an unrecognized key.

Body has no required sections. Prefer structural markdown (tables, lists,
fenced code) over prose. Conventional headings: `# Schema` (columns/fields
of a data asset), `# Examples` (usage), `# Citations` (see below).

## Cross-linking concepts

Standard markdown links, two forms:

- **Bundle-absolute (recommended)** — starts with `/`, relative to bundle
  root: `[customers table](/tables/customers.md)`. Survives the file being
  moved within its subdirectory.
- **Relative** — `[neighboring concept](./other.md)`.

A link only asserts "these are related" — the relationship kind
(parent/child, joins-with, depends-on) belongs in surrounding prose, never
in link syntax. A broken link is tolerated, not an error: it may name
knowledge not yet written. Never "fix" a dangling link by deleting it
without first checking whether the target should simply be created.

## `index.md`

Progressive disclosure for a directory: a flat, headed list of links to
its concepts and subdirectories, each with a short description pulled from
the linked concept's frontmatter. May exist at any directory level,
including bundle root.

No frontmatter — **except** the bundle-root `index.md`, which may carry a
frontmatter block containing only `okf_version` (see Versioning). That is
the one place frontmatter is permitted in an `index.md`.

## `log.md`

Optional at any directory level; records that scope's change history as a
flat, date-grouped list, **newest date first**, headings in `## YYYY-MM-DD`
form. The leading bold word per entry (`**Update**`, `**Creation**`,
`**Deprecation**`) is convention, not required structure.

## Citations

When a concept's body makes claims sourced from external material, list
them under a trailing `# Citations` heading, numbered. Targets may be
external URLs, bundle-relative paths, or paths into a `references/`
subdirectory that mirrors external material as first-class concepts.

## Conformance — the only hard rules

A bundle is OKF-conformant iff:

1. Every non-reserved `.md` file has parseable YAML frontmatter.
2. Every frontmatter block has a non-empty `type`.
3. `index.md`/`log.md`, where present, follow the structures above.

Everything else is soft guidance. Never reject or "fix" a bundle for:
missing optional fields, unknown `type` values, unknown extra frontmatter
keys, broken links, or a missing `index.md`. This permissiveness is
intentional — it supports partial, incremental, agent-driven growth.

## Versioning

Format `<major>.<minor>`; this spec is `0.1`. Minor bump = backward-compatible
addition (new optional field, new conventional heading). Major bump =
breaking (renamed required field, changed reserved filename). Declare a
bundle's target version only via `okf_version` in the bundle-root
`index.md` frontmatter — see [TEMPLATE/index.md](TEMPLATE/index.md).

## Maintaining a bundle

1. **New concept** — pick the right subdirectory (create one if the topic
  is new), model the file on the closest match in
  [TEMPLATE/](TEMPLATE/) with `type` + recommended fields, link it from
  related concepts and from the nearest `index.md`.
2. **Update a concept** — edit body/frontmatter in place, bump `timestamp`,
  add a `log.md` entry at the relevant directory level if the bundle
  maintains one.
3. **Reorganize** — moving a file only breaks *relative* (`./`) links, not
  bundle-absolute (`/`) ones; prefer bundle-absolute links to make this
  safe. Update the old and new directories' `index.md` entries.
4. **New subdirectory** — add its `index.md`, and add one line linking to
  `subdir/` from the parent `index.md`.
5. Before treating a bundle as broken, check it against the three
  conformance rules above only — never invent stricter rules.
