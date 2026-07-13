---
name: okf
description: >-
  Create and maintain knowledge bundles in Open Knowledge Format (OKF) —
  markdown + YAML-frontmatter concept files for durable knowledge. Use when
  the user wants to write, structure, or validate an OKF bundle, add a
  "concept" document, build an `index.md`/`log.md`, cross-link concepts, or
  asks "is this OKF-conformant".
user-invocable: true
argument-hint: "[produce|maintain|consume] [bundle-path]"
---

# Open Knowledge Format (OKF) skill

OKF represents knowledge as a directory of markdown files with YAML frontmatter.
Minimal by design: no schema registry, no runtime, no SDK. Produce, maintain, and
consume OKF bundles **conformant with the spec**, not memory of it.

**Before non-trivial work, read:** [SPEC.md](SPEC.md) — verbatim OKF v0.1 spec,
source of truth for every rule below.

## The one hard rule

A bundle is conformant (§9) iff: every non-reserved `.md` file has a parseable
YAML frontmatter block, and every such block has a **non-empty `type`** field.
Everything else is soft guidance — never reject a bundle for missing optional
fields, unknown types, or broken links.

## Conventions

- **One concept = one file.** File path minus `.md` is the concept ID.
- **Frontmatter:** `type` required. Add `title`, `description`, `tags`,
  `timestamp` (ISO 8601) when useful; add `resource` (canonical URI) only for
  concepts bound to a real asset — omit for abstract concepts.
- **Body:** prefer structural markdown (headings, tables, lists, fenced code).
  Conventional headings: `# Schema`, `# Examples`, `# Citations`.
- **Cross-links:** standard markdown links; prefer absolute bundle-relative form
  (`/services/auth-api.md`). Relationship kind lives in surrounding prose, not
  the link syntax.
- **Reserved files:** `index.md` (directory listing, no frontmatter — except
  bundle-root index may carry only `okf_version`) and `log.md` (ISO-dated change
  history, newest first). Never use these names for concepts.

Templates to copy: [concept](templates/concept.md), [index](templates/index.md),
[log](templates/log.md).

## Bundle location

The bundle path is always caller-supplied or already known from context (e.g.
`~/wiki` for the personal wiki, `.okf/` for a project bundle). Never assume a
fixed path — use what the task specifies.

## Modes

### produce — create or extend a bundle

1. Read [SPEC.md](SPEC.md).
2. Pick sources: **code** (source, READMEs, docstrings, config), **docs/wiki**
   (distill into concepts, link originals under `# Citations`), **manual**
   (decisions, playbooks, metrics).
3. Choose directory layout by domain (`services/`, `datasets/`, `decisions/`).
   One concept per file.
4. Write each concept from [templates/concept.md](templates/concept.md): set a
   descriptive `type`, fill recommended fields, cross-link related concepts.
5. Add/refresh `index.md` per directory (and `okf_version: "0.1"` in root
   index). Append a dated entry to `log.md`.

### maintain — keep a bundle in sync with reality

1. Identify affected concepts (search by `resource`, path, or topic). Touch
   every affected file in one pass.
2. Update body and `timestamp`; fix or add cross-links; create new concepts for
   new assets; mark removed assets (`**Deprecation**`) rather than deleting.
3. Update relevant `index.md` files and append a dated `log.md` entry.

### consume — use a bundle as context

1. Read the bundle-root `index.md` first for progressive disclosure, then follow
   links into relevant concepts only.
2. Treat broken links as not-yet-written knowledge, not errors.
3. If you learn something durable while working, switch to **maintain** and write
   it back.

## Before declaring done

- Every concept file written or touched has parseable YAML frontmatter with
  non-empty `type`.
- `index.md` updated for any new concept files.
- `log.md` entry appended if the bundle maintains one.
