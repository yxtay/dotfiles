---
name: databricks
description: >-
  Use when the user asks about Databricks jobs, clusters, pipelines, bundles,
  SQL warehouses, DBFS/volumes, or workspace objects, or says "use databricks".
argument-hint: "[jobs|clusters|bundle|fs|workspace|...] <action> [args]"
---

# databricks — Databricks CLI

## Core commands

### Jobs

```bash
# List
databricks jobs list --output json
databricks jobs list --output json | jq '.jobs[] | {id:.job_id, name:.settings.name}'

# Get / run
databricks jobs get --job-id 123 --output json
databricks jobs run-now --job-id 123
databricks jobs run-now --job-id 123 --job-parameters '{"key": "value"}'

# Runs
databricks jobs list-runs --job-id 123 --output json
databricks jobs list-runs --active-only --output json
databricks jobs get-run --run-id 456 --output json
databricks jobs get-run-output --run-id 456 --output json
databricks jobs cancel-run --run-id 456
```

### Clusters

```bash
# List / get
databricks clusters list --output json
databricks clusters get --cluster-id abc123 --output json

# Lifecycle
databricks clusters start --cluster-id abc123
databricks clusters delete --cluster-id abc123   # terminate
databricks clusters restart --cluster-id abc123

# Spark versions / node types (for creating clusters)
databricks clusters spark-versions --output json
databricks clusters list-node-types --output json
```

### Bundles (DABs)

```bash
# Init and develop
databricks bundle init default-python            # scaffold new project
databricks bundle validate                       # check config
databricks bundle plan --target dev

# Deploy and run
databricks bundle deploy --target dev
databricks bundle deploy --target prod
databricks bundle run my_job --target dev
databricks bundle run my_pipeline --target dev

# Inspect
databricks bundle summary --target dev --output json

# Import existing resources
databricks bundle generate job --existing-job-id 123 --key my_job
databricks bundle deployment bind my_job 123

# Sync (file sync mode)
databricks bundle sync --target dev
```

### Pipelines (Lakeflow / DLT)

```bash
databricks pipelines list --output json
databricks pipelines get --pipeline-id abc123 --output json
databricks pipelines start-update --pipeline-id abc123
databricks pipelines history --pipeline-id abc123 --output json
```

### SQL warehouses

```bash
databricks warehouses list --output json
databricks warehouses get --id abc123 --output json
databricks warehouses start --id abc123
databricks warehouses stop --id abc123
```

### Filesystem (DBFS / UC Volumes)

```bash
databricks fs ls dbfs:/path/
databricks fs ls dbfs:/path/ --output json
databricks fs cp local_file.csv dbfs:/path/file.csv
databricks fs cp dbfs:/path/file.csv ./local/
databricks fs cat dbfs:/path/file.txt
databricks fs rm dbfs:/path/file.csv
databricks fs mkdir dbfs:/path/dir/
```

### Workspace

```bash
# List / navigate
databricks workspace list /Users/me@example.com --output json

# Import / export
databricks workspace export /path/notebook --output json > notebook.ipynb
databricks workspace import ./notebook.py --path /path/notebook --language PYTHON
databricks workspace export-dir /path/dir ./local-dir/
databricks workspace import-dir ./local-dir/ /path/dir/
```

### Secrets

```bash
databricks secrets list-scopes --output json
databricks secrets list --scope my-scope --output json
databricks secrets put-secret --scope my-scope --key my-key --string-value "value"
databricks secrets delete-secret --scope my-scope --key my-key
```

## Common patterns

### Run a job and tail its output

```bash
# 1. Trigger
RUN_ID=$(databricks jobs run-now --job-id 123 --output json | jq -r '.run_id')

# 2. Poll until done
databricks jobs get-run --run-id "$RUN_ID" --output json | jq '{state:.state.life_cycle_state, result:.state.result_state}'

# 3. Get output
databricks jobs get-run-output --run-id "$RUN_ID" --output json
```

### Deploy bundle and run

```bash
databricks bundle validate
databricks bundle deploy --target dev
databricks bundle run my_job --target dev
```

### Find a running cluster and check it

```bash
databricks clusters list --output json \
  | jq '.clusters[] | select(.state == "RUNNING") | {id:.cluster_id, name:.cluster_name}'
databricks clusters get --cluster-id <id> --output json \
  | jq '{state:.state, spark:.spark_version, workers:.num_workers}'
```

### Copy local data to DBFS and back

```bash
databricks fs cp ./data.csv dbfs:/tmp/data.csv
databricks fs ls dbfs:/tmp/ --output json
databricks fs cp dbfs:/tmp/result.csv ./result.csv
```

## Flags

| Flag | Effect |
| ---- | ------ |
| `--output json` | Machine-readable output (prefer for parsing) |
| `-p <profile>` | Use named profile from `~/.databrickscfg` |
| `-t <target>` | Bundle target (e.g. `dev`, `prod`) |
| `--debug` | Verbose debug logging |
| `--var "k=v"` | Override bundle variable |

## Auth

```bash
databricks auth login --host https://<workspace>.azuredatabricks.net
databricks auth profiles          # list configured profiles
databricks auth describe          # show active credentials
databricks configure              # interactive setup (~/.databrickscfg)
```
