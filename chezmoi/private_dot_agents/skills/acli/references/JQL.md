# JQL Reference

Common patterns for `--jql` queries.

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
