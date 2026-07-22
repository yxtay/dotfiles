---
name: okf
description: >-
  OKF skill — create, extend, or sync knowledge bundles in Open Knowledge
  Format (markdown + YAML-frontmatter concept files). Use when producing a new
  bundle from code, docs, or decisions; maintaining (syncing) an existing
  bundle; consuming a bundle as context; or when another skill needs OKF format
  conventions.
metadata:
  argument-hint: "[produce|maintain|consume] [bundle-path]"
---

# Open Knowledge Format (OKF) skill

OKF is a directory of markdown files with YAML frontmatter. Work from the spec —
[references/SPEC.md](references/SPEC.md) is the source of truth.

## The one hard rule

Conformant (§9): every non-reserved `.md` file has parseable YAML frontmatter
with a **non-empty `type`** field. Everything else is soft guidance — tolerate
missing optional fields, unknown types, and broken links.

## Conventions

- **One concept = one file.** File path minus `.md` is the concept ID.
- **Bundle path:** use what comes from context — `~/wiki` (personal wiki) or
  `.okf/` (project bundle) are common. Use the path from the task; invent none.
- **Frontmatter:** `type` required. Add `title`, `description`, `tags`,
  `timestamp` (ISO 8601) when useful; `resource` (canonical URI) only for
  concepts bound to a real asset.
- **Body:** structural markdown (tables, lists, fenced code) over prose.
  Conventional headings: `# Schema`, `# Examples`, `# Citations`.
- **Cross-links:** standard markdown links; absolute bundle-relative form
  (`/services/auth-api.md`) preferred. Relationship kind belongs in prose.
- **Reserved:** `index.md` (directory listing) and `log.md` (ISO-dated history,
  newest first) — concepts never use these names.

Templates: [concept](assets/concept.md), [index](assets/index.md),
[log](assets/log.md).

## Task types

### produce — create or extend a bundle

1. Read [references/SPEC.md](references/SPEC.md).
2. Choose sources: **code** (source, READMEs, docstrings, config), **docs/wiki**
   (distill into concepts; cite originals under `# Citations`), **manual**
   (decisions, playbooks, metrics).
3. Lay out directories by domain (`services/`, `datasets/`, `decisions/`).
4. Write each concept from [assets/concept.md](assets/concept.md): set a
   descriptive `type`, fill recommended fields, cross-link related concepts.
5. Add/refresh `index.md` per directory (`okf_version: "0.1"` in root index)
   and append to `log.md`.

### maintain — sync a bundle with reality

1. Triage affected concepts by `resource`, path, or topic — cover every one.
2. Read each target concept. If it mixes genuinely different subjects (different
   tool, system, or concern), split the unrelated sections into their own files
   and cross-link them.
3. Update body and `timestamp`; add or fix cross-links; create concepts for new
   assets; mark removed assets with `**Deprecation**` to preserve context.
4. Update `index.md` entries and append to `log.md`.

### consume — use a bundle as context

1. Read the bundle-root `index.md` first, then follow links into relevant
   concepts only.
2. Broken links are not-yet-written knowledge, not errors.
3. When you learn something durable, switch to **maintain** and write it back.

## Before declaring done

- `index.md` updated for any new concepts.
- `log.md` entry appended if the bundle has one.
