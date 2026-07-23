# Inline diff comments (DiffNotes) and Suggestions

## DiffNotes via API

`glab api -f` sends flat key=value form fields — it cannot build the nested `position` object at
all. Always use `--input` with a JSON file + explicit Content-Type header.

```bash
# 1. Get diff_refs (base_sha, start_sha, head_sha)
glab api "projects/<id>/merge_requests/<iid>" \
  | jq '.diff_refs'

# 2. Inspect file paths (old_path / new_path for renamed files)
glab api "projects/<id>/merge_requests/<iid>/diffs?per_page=100" --paginate \
  | jq -r '.[] | "\(.old_path) -> \(.new_path) | renamed: \(.renamed_file)"'

# 3. Verify a line is inside a diff hunk (lines outside hunks → 400)
#    Show hunk headers for a specific file
glab api "projects/<id>/merge_requests/<iid>/diffs?per_page=100" --paginate \
  | jq -r '.[] | select(.new_path == "path/to/file.ts") | .diff' \
  | grep '^@@'

# 4. Build the JSON payload
jq -n \
  --arg body "your comment" \
  --arg base  "<diff_refs.base_sha>" \
  --arg start "<diff_refs.start_sha>" \
  --arg head  "<diff_refs.head_sha>" \
  --arg old_path "src/original/path/file.ts" \
  --arg new_path "src/new/path/file.ts" \
  --argjson new_line 15 \
  '{body: $body, position: {
      position_type: "text",
      base_sha: $base, start_sha: $start, head_sha: $head,
      old_path: $old_path, new_path: $new_path,
      new_line: $new_line
    }}' > /tmp/note.json
# For renamed files also add old_line and line_code (see below)

# 5. Post — Content-Type header is required (--input alone sends no MIME type → 415)
glab api "projects/<id>/merge_requests/<iid>/discussions" \
  -X POST -H "Content-Type: application/json" --input /tmp/note.json

# 6. Confirm it landed as DiffNote (not DiscussionNote)
glab api "projects/<id>/merge_requests/<iid>/discussions?per_page=100" --paginate \
  | jq -r '.[] | .notes[] | select(.type == "DiffNote") |
      "id=\(.id) \(.position.new_path):\(.position.new_line) \(.body[:50])"'
```

**line_code** — required for renamed files (old_path ≠ new_path), optional otherwise:

```bash
new_path="src/new/path/file.ts"
old_line=142
new_line=149
sha=$(printf '%s' "$new_path" | shasum -a 1 | cut -d' ' -f1)
line_code="${sha}_${old_line}_${new_line}"
```

Add to position: `"old_line": 142, "new_line": 149, "line_code": "<value>"`.

**new_line vs old_line**: `new_line` = line in new file (added `+` or context); `old_line` = line in
old file (removed `-` or context). Set one or both for context lines.

**Multi-line anchor** — attach a note to a range of lines via `line_range`:

```json
"line_range": {
  "start": { "line_code": "<sha>_<old>_<new>", "type": "new", "old_line": 10, "new_line": 12 },
  "end":   { "line_code": "<sha>_<old>_<new>", "type": "new", "old_line": 15, "new_line": 17 }
}
```

`type`: `"new"` for added lines, `"old"` for removed lines.

| Gotcha                            | Symptom                             | Fix                                       |
|-----------------------------------|-------------------------------------|-------------------------------------------|
| `-f` can't nest `position` object | API rejects or ignores position     | Use `--input json_file`                   |
| Missing `Content-Type`            | HTTP 415                            | Add `-H "Content-Type: application/json"` |
| Renamed file, no `line_code`      | HTTP 400 `line_code can't be blank` | `sha1(new_path)_old_new`                  |
| Line outside diff hunk            | HTTP 400 or silent fallback         | Verify line is in hunk range              |
| Used `git rev-parse HEAD`         | Silent fallback                     | Fetch `diff_refs` from MR API             |

## Suggestions

A suggestion block lets reviewers apply a one-click code fix. The block content **replaces** the
line(s) the note is anchored to.

**Single-line** (replace the one commented line):

````md
```suggestion
replacement code here
```
````

**Multi-line** — offsets relative to the anchored line; `-N` = N lines above, `+N` = N lines below:

````md
```suggestion:-2+3
line A
line B
line C
line D
line E
```
````

Range limit: up to 100 lines above + 100 below (201 total). The anchor `new_line` must still point
to a line inside the diff; use `line_range` to span the full replacement range visually.

**Quote the affected code** — paste the original lines as a regular fenced block before the
suggestion block to show context:

````md
Original:
```ts
const x = foo()
const y = bar(x)
```

Suggested fix:
```suggestion
const { x, y } = fooBar()
```
````

**Full API example:**

````bash
# Get diff_refs first (step 1 above), then:
jq -n \
  --arg body '```suggestion\nconst { x, y } = fooBar()\n```' \
  --arg base  "<base>" \
  --arg start "<start>" \
  --arg head  "<head>" \
  --arg old_path "src/file.ts" \
  --arg new_path "src/file.ts" \
  --argjson new_line 42 \
  '{body: $body, position: {
      position_type: "text",
      base_sha: $base, start_sha: $start, head_sha: $head,
      old_path: $old_path, new_path: $new_path,
      new_line: $new_line
    }}' \
  | glab api "projects/<id>/merge_requests/<iid>/discussions" \
      -X POST -H "Content-Type: application/json" --input -
````
