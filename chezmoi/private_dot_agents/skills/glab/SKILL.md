---
name: glab
description: >-
  Use when the user asks about GitLab merge requests, issues, CI/CD pipelines,
  pipeline jobs, or repositories, or says "use glab".
argument-hint: "[mr|issue|ci] <action> [args]"
---

# glab — GitLab CLI

## Core commands

### Merge requests

```bash
# View
glab mr view
glab mr view 123
glab mr view my-branch-name
glab mr view 123 --comments

# List
glab mr list
glab mr list --state all
glab mr list --assignee @me
glab mr list --label "bugfix" --output json
glab mr list --search "keyword" --output json
glab mr list --not-draft --output json

# Create
glab mr create --fill                                # title/desc from branch + commits
glab mr create --title "Title" --description "Body"
glab mr create --fill --draft
glab mr create --fill --label "bugfix" --assignee @me
glab mr create --fill --reviewer username --remove-source-branch
glab mr create --fill --target-branch main

# Update
glab mr update 123 --title "New title"
glab mr update 123 --description "Updated body"
glab mr update 123 --assignee @me
glab mr update 123 --label "ready" --unlabel "draft"
glab mr update 123 --ready                           # unmark draft

# Review / approval
glab mr approve 123
glab mr revoke 123
glab mr diff 123
glab mr diff 123 --output json

# Merge
glab mr merge 123
glab mr merge 123 --squash
glab mr merge 123 --remove-source-branch
glab mr merge 123 --auto-merge                       # merge when CI passes

# Comments / discussions
glab mr note 123 --message "Comment text"

# Other lifecycle
glab mr close 123
glab mr reopen 123
glab mr rebase 123
glab mr checkout 123
```

### Issues

```bash
# View
glab issue view 456
glab issue view 456 --comments

# List
glab issue list
glab issue list --state all --output json
glab issue list --assignee @me --output json
glab issue list --label "bug" --output json
glab issue list --search "keyword" --output json
glab issue list --milestone "v2.0" --output json

# Create
glab issue create --title "Bug: X breaks Y"
glab issue create --title "Title" --description "Body" --label "bug" --assignee @me

# Update
glab issue update 456 --title "New title"
glab issue update 456 --label "confirmed" --assignee @me

# Lifecycle
glab issue close 456
glab issue reopen 456

# Comments
glab issue note 456 --message "Comment text"
```

### CI/CD pipelines

```bash
# defaults to current branch
glab ci status
glab ci status --branch main

glab ci list
glab ci list --status running --output json
glab ci list --branch main --output json

# TUI job picker
glab ci view
glab ci view --branch main

glab ci get --pipeline-id 789 --output json
glab ci run
glab ci run --branch main
glab ci cancel --pipeline-id 789
glab ci retry --pipeline-id 789

# interactive picker when no arg
glab ci trace
glab ci trace 1234
glab ci trace job-name

glab ci trigger job-name
glab ci artifact HEAD job-name --path ./artifacts
```

### Repository / project

```bash
glab repo clone owner/project
glab repo clone owner/group/project
glab repo view --web
glab repo fork owner/project
```

## Common patterns

### Review an open MR

```bash
# 1. View summary
glab mr view 123

# 2. See the diff
glab mr diff 123

# 3. Check CI status
glab ci status --branch <mr-branch>

# 4. Approve and merge
glab mr approve 123
glab mr merge 123 --squash --remove-source-branch
```

### Find and fix a failing pipeline

```bash
# 1. Check status
glab ci status

# 2. View jobs (pick the failing one)
glab ci view

# 3. Stream its log
glab ci trace <job-name>

# 4. Retry after fixing
glab ci retry <job-id>
```

### Create an MR from current branch

```bash
glab mr create --fill --draft --remove-source-branch
# review, then mark ready:
glab mr update --ready
```

### Searching across a group

```bash
glab issue list -g my-group --search "login" --output json
glab mr list -g my-group --state all --assignee @me --output json
```

## Flags

| Flag                                  | Effect                                       |
|---------------------------------------|----------------------------------------------|
| `--output json`                       | Machine-readable output (prefer for parsing) |
| `--assignee @me`                      | Filter to current authenticated user         |
| `--state all\|opened\|closed\|merged` | Filter by state                              |
| `--label <name>`                      | Filter by label (repeatable)                 |
| `--milestone <name>`                  | Filter by milestone                          |
| `--search <str>`                      | Full-text search in title/description        |
| `--jq <expr>`                         | Apply jq filter to JSON output               |
| `--paginate`                          | Fetch all pages                              |
| `-R <owner/repo>`                     | Target a different project                   |
| `-g <group>`                          | Target a group instead of a project          |
| `--web`                               | Open result in browser                       |
| `-y / --yes`                          | Skip confirmation prompts                    |

## Auth

```bash
glab auth login
glab auth status
```
