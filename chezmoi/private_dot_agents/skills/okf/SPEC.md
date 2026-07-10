# OKF Spec Reference

Field-level detail for [SKILL.md](SKILL.md). Source: OKF v0.1 (Draft,
[GoogleCloudPlatform/knowledge-catalog](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)).

## Concept frontmatter fields

Recommended fields, in priority order when trimming:

| Field         | Required | Meaning                                         |
|---------------|----------|-------------------------------------------------|
| `type`        | **yes**  | Free-text kind. Not centrally registered.       |
| `title`       | no       | Display name; derives from filename if omitted. |
| `description` | no       | One sentence; feeds index entries and search.   |
| `resource`    | no       | Canonical URI of the underlying asset.          |
| `tags`        | no       | List for cross-cutting categorization.          |
| `timestamp`   | no       | ISO 8601 datetime of last meaningful change.    |

`resource` is omitted for abstract concepts (playbooks, decisions, notes) — it exists for concepts
describing a concrete addressable asset (a table, an endpoint).

Extra producer-defined keys are always allowed — preserve them, never strip an unrecognized key.

Conventional body headings: `# Schema` (columns/fields of a data asset), `# Examples` (usage),
`# Citations` (see below).

## `index.md`

Progressive disclosure for a directory: a flat, headed list of links to its concepts and
subdirectories, each with a short description pulled from the linked concept's frontmatter. May
exist at any directory level, including bundle root.

No frontmatter — **except** the bundle-root `index.md`, which may carry a frontmatter block
containing only `okf_version` (see Versioning below). That is the one place frontmatter is permitted
in an `index.md`.

## `log.md`

Optional at any directory level; records that scope's change history as a flat, date-grouped list,
**newest date first**, headings in `## YYYY-MM-DD` form. The leading bold word per entry
(`**Update**`, `**Creation**`, `**Deprecation**`) is convention, not required structure.

## Citations

When a concept's body makes claims sourced from external material, list them under a trailing
`# Citations` heading, numbered. Targets may be external URLs, bundle-relative paths, or paths into
a `references/` subdirectory that mirrors external material as first-class concepts.

## Versioning

Format `<major>.<minor>`; this spec is `0.1`. Minor bump = backward-compatible addition (new
optional field, new conventional heading). Major bump = breaking (renamed required field, changed
reserved filename). Declare a bundle's target version only via `okf_version` in the bundle-root
`index.md` frontmatter — see [SAMPLE/index.md](SAMPLE/index.md).
