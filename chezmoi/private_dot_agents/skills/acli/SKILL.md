---
name: acli
description: >-
  Use when the user asks about Jira issues, JQL searches, sprints, boards,
  or Confluence pages/spaces, or says "use acli".
argument-hint: "[jira|confluence] <action> [args]"
---

# acli — Atlassian CLI

## Core commands

### Jira — work items

```bash
# View a work item (default fields: key, issuetype, summary, status, assignee, description)
acli jira workitem view KEY-123
acli jira workitem view KEY-123 --json
acli jira workitem view KEY-123 --fields '*all'
acli jira workitem view KEY-123 --fields 'summary,comment,status,assignee,priority,labels,description'

# Search via JQL
acli jira workitem search --jql "project = PROJ AND status = 'In Progress'" --json
acli jira workitem search \
  --jql "assignee = currentUser() AND sprint in openSprints()" \
  --fields 'key,summary,status,priority' --json
acli jira workitem search --jql "project = PROJ" --paginate --json   # all results

# Create
acli jira workitem create --summary "Title" --project "PROJ" --type "Task"
acli jira workitem create \
  --summary "Title" --project "PROJ" --type "Story" --assignee "@me" --description "Body"
acli jira workitem create --summary "Title" --project "PROJ" --type "Bug" --parent "PROJ-10"

# Edit
acli jira workitem edit --key "KEY-123" --summary "New title"
acli jira workitem edit --key "KEY-123" --description "Updated body" --yes
acli jira workitem edit --key "KEY-123" --assignee "@me" --yes

# Transition (change status)
acli jira workitem transition --key "KEY-123" --status "In Progress" --yes
acli jira workitem transition --key "KEY-123" --status "Done" --yes

# Comments
acli jira workitem comment list --key "KEY-123" --json
acli jira workitem comment create --key "KEY-123" --body "Comment text"
```

### Jira — projects, boards, sprints

```bash
# Projects
acli jira project list --limit 50 --json    # use --paginate for all pages
acli jira project list --paginate --json
acli jira project view --json   # prompts for project key

# Boards
acli jira board search --json
acli jira board search --project "PROJ" --json
acli jira board search --name "My Board" --json

# Sprints (requires board ID)
acli jira board list-sprints --board <board-id> --json    # get sprint IDs
acli jira sprint view --sprint <sprint-id> --json
acli jira sprint list-workitems --sprint <sprint-id> --board <board-id> --json
acli jira sprint list-workitems --sprint <sprint-id> --board <board-id> \
  --fields 'key,summary,assignee,status,priority' --json
```

### Confluence — pages

```bash
# View page by ID
acli confluence page view --id 123456789
acli confluence page view --id 123456789 --json
acli confluence page view --id 123456789 --body-format storage    # raw HTML/wiki
acli confluence page view --id 123456789 --body-format view       # rendered
acli confluence page view --id 123456789 --include-direct-children --include-labels --json
```

### Confluence — spaces

```bash
acli confluence space list --json
acli confluence space list --type global --json
acli confluence space view --json    # prompts for space key
```

### Confluence — blog posts

```bash
acli confluence blog list --space-id 12345 --json
acli confluence blog list --space-id 12345 --title "Release Notes" --json
acli confluence blog view --id 98765 --json
acli confluence blog view --id 98765 --body-format storage
```

## Common patterns

### Find and read a Jira issue

```bash
# 1. Search to find the key
acli jira workitem search \
  --jql "project = PROJ AND text ~ 'keyword'" --fields 'key,summary,status' --json

# 2. Read full details
acli jira workitem view KEY-123 --fields '*all' --json
```

### Current sprint work

```bash
# 1. Find board ID
acli jira board search --project "PROJ" --json

# 2. List sprints to get active sprint ID
acli jira board list-sprints --board <board-id> --json

# 3. List sprint items
acli jira sprint list-workitems --sprint <sprint-id> --board <board-id> \
  --fields 'key,summary,assignee,status,priority' --json
```

### Assign and transition

```bash
acli jira workitem edit --key "KEY-123" --assignee "@me" --yes
acli jira workitem transition --key "KEY-123" --status "In Progress" --yes
```

### Add a comment

```bash
acli jira workitem comment create --key "KEY-123" --body "Investigated — root cause is X. Fix in KEY-124."
```

### JQL reference (common patterns)

```text
project = PROJ                              # by project
assignee = currentUser()                    # my issues
status = "In Progress"                      # by status
status in ("To Do", "In Progress")          # multiple statuses
sprint in openSprints()                     # active sprint
sprint in openSprints() AND assignee = currentUser()
priority = High
text ~ "keyword"                            # full-text search
labels = "my-label"
created >= -7d                              # last 7 days
updated >= "2026-07-01"
parent = PROJ-10                            # subtasks of epic
issueType = Epic
issuetype in (Story, Task, Bug)
```

## Flags

| Flag | Effect |
| ---- | ------ |
| `--json` | Machine-readable output (prefer for parsing) |
| `--fields '*all'` | All fields; `--fields 'key,summary,status'` for minimal |
| `--paginate` | Fetch all pages |
| `--limit N` | Cap results |
| `--yes` / `-y` | Skip confirmation on edit/transition/delete |

## Auth

```bash
acli jira auth        # Jira (OAuth or API token)
acli confluence auth  # Confluence
acli auth             # all products
```
