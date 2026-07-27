# Atlassian Document Format (ADF)

Jira `--description` and `--description-file` accept **plain text** OR **ADF JSON**.
Use ADF when you need rich formatting (headings, lists, code blocks, bold/italic).
Markdown is NOT rendered — pass ADF instead.

## Skeleton

```json
{
  "version": 1,
  "type": "doc",
  "content": []
}
```

## Block node types

Heading (level 1–6):

```json
{ "type": "heading", "attrs": { "level": 2 }, "content": [{ "type": "text", "text": "Section" }] }
```

Paragraph:

```json
{ "type": "paragraph", "content": [{ "type": "text", "text": "Body text." }] }
```

Bullet list (ordered list: same shape, `"type": "orderedList"`):

```json
{
  "type": "bulletList",
  "content": [
    {
      "type": "listItem",
      "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Item" }] }]
    }
  ]
}
```

Code block:

```json
{
  "type": "codeBlock",
  "attrs": { "language": "bash" },
  "content": [{ "type": "text", "text": "echo hi" }]
}
```

## Text marks (inline formatting)

Bold: `"marks": [{ "type": "strong" }]`

Italic: `"marks": [{ "type": "em" }]`

Inline code: `"marks": [{ "type": "code" }]`

Link:

```json
{ "type": "text", "text": "click here",
  "marks": [{ "type": "link", "attrs": { "href": "https://example.com" } }] }
```

## Practical workflow

```bash
# Write ADF to a temp file, then pass it
cat > /tmp/desc.json <<'EOF'
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading", "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "Problem" }]
    },
    { "type": "paragraph", "content": [{ "type": "text", "text": "Description here." }] },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Step 1" }] }]
        },
        {
          "type": "listItem",
          "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "Step 2" }] }]
        }
      ]
    }
  ]
}
EOF
acli jira workitem create --summary "Title" --project "PROJ" --type "Task" --description-file /tmp/desc.json
acli jira workitem edit --key "KEY-123" --description-file /tmp/desc.json
```
