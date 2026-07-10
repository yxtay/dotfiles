---
name: okf
description: >-
  Create and maintain knowledge bundles in Open Knowledge Format (OKF) —
  markdown + YAML-frontmatter concept files for durable knowledge. Use when
  the user wants to write, structure, or validate an OKF bundle, add a
  "concept" document, build an `index.md`/`log.md`, cross-link concepts, or
  asks "is this OKF-conformant".
---

# Open Knowledge Format (OKF)

OKF is a spec for knowledge as a directory of markdown files with YAML frontmatter — readable by
humans, parseable by agents, diffable in git. No SDK, schema registry, or central authority
required.

[SAMPLE/](SAMPLE/) is a small worked bundle — every file kind in one directory tree — copy from it
when actually writing a bundle, not just reading about one. [SPEC.md](SPEC.md) holds the full
field-level spec (frontmatter fields, citations, versioning); load it only when a rule below doesn't
answer the question in front of you.

## Terminology

- **Bundle** — the directory tree of knowledge (unit of distribution).
- **Concept** — one unit of knowledge = one markdown file in the bundle.
- **Concept ID** — the file's path minus `.md` (e.g. `tables/orders.md` → `tables/orders`).
- **Frontmatter** — the `---`-delimited YAML block at the top of a file.

## Bundle layout

```text
bundle/
├── index.md             # optional, directory listing for progressive disclosure
├── log.md               # optional, chronological change history
├── <concept>.md         # a concept at bundle root
└── <subdir>/            # groups concepts by topic
    ├── index.md
    ├── <concept>.md
    └── ...
```

`index.md` and `log.md` are **reserved filenames** — never use them for a concept document. Every
other `.md` file is a concept.

Every concept opens with a frontmatter block carrying a non-empty `type` (free-text, not centrally
registered — e.g. `Playbook`, `API Endpoint`, `Metric`). Body has no required sections; prefer
structural markdown (tables, lists, fenced code) over prose. See [SPEC.md](SPEC.md) for the full
recommended-field list and citation conventions.

Cross-link concepts with standard markdown links, relative to the linking file, e.g.
`[customers table](../tables/customers.md)`. A link only asserts "these are related"; the
relationship kind belongs in surrounding prose, never in link syntax. A broken link is tolerated,
not an error — it may name knowledge not yet written. Never "fix" a dangling link by deleting it
without first checking whether the target should simply be created.

## Conformance — the only hard rules

A bundle is OKF-conformant iff:

1. Every non-reserved `.md` file has parseable YAML frontmatter.
2. Every frontmatter block has a non-empty `type`.
3. `index.md`/`log.md`, where present, follow the structures in [SPEC.md](SPEC.md).

Everything else is soft guidance. Never reject or "fix" a bundle for: missing optional fields,
unknown `type` values, unknown extra frontmatter keys, broken links, or a missing `index.md`. This
permissiveness is intentional — it supports partial, incremental, agent-driven growth. Before
treating a bundle as broken, check it against these three rules only — never invent stricter ones.

## Maintaining a bundle

1. **New concept** — pick the right subdirectory (create one if the topic is new), model the file on
   the closest match in [SAMPLE/](SAMPLE/) with `type` + recommended fields (see
   [SPEC.md](SPEC.md)), link it from related concepts and from the nearest `index.md`.
2. **Update a concept** — edit body/frontmatter in place, bump `timestamp`, add a `log.md` entry at
   the relevant directory level if the bundle maintains one.
3. **Reorganize** — moving a file breaks relative links pointing to or from it; update those links
   and the old and new directories' `index.md` entries.
4. **New subdirectory** — add its `index.md`, and add one line linking to `subdir/` from the parent
   `index.md`.
