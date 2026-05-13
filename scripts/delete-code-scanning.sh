#!/usr/bin/env bash
set -euo pipefail

REPO="yxtay/dotfiles"
TOOLS_TO_DELETE=(
  "Trivy"
  "Grype"
  "KICS"
  "devskim"
  "Gitleaks"
  "osv-scanner"
  "Bandit"
  "BinSkim"
  "checkov"
  "ESLint"
  "templateanalyzer"
  "syft"
)

wait_for_rate_limit() {
  while true; do
    local remaining
    remaining=$(gh api rate_limit --jq '.resources.core.remaining' 2>/dev/null || echo "0")
    if [[ "$remaining" -gt 50 ]]; then
      return
    fi
    local reset now wait_secs
    reset=$(gh api rate_limit --jq '.resources.core.reset' 2>/dev/null || echo "0")
    now=$(date +%s)
    wait_secs=$((reset - now + 5))
    if [[ "$wait_secs" -gt 0 ]]; then
      echo "Rate limit low (remaining=$remaining). Sleeping ${wait_secs}s..."
      sleep "$wait_secs"
    fi
  done
}

delete_tool_analyses() {
  local tool_name="$1"
  echo ""
  echo "=== Fetching analyses for: $tool_name ==="
  wait_for_rate_limit

  local ids
  ids=$(gh api "repos/${REPO}/code-scanning/analyses?tool_name=${tool_name}&per_page=100&direction=desc" \
    --paginate --jq '.[].id' 2>/dev/null || true)

  if [[ -z "$ids" ]]; then
    echo "No analyses found for $tool_name."
    return
  fi

  local count
  count=$(echo "$ids" | wc -l | tr -d ' ')
  echo "Found $count analyses for $tool_name. Deleting..."

  local i=0
  while IFS= read -r id; do
    i=$((i + 1))
    if ((i % 50 == 0)); then
      wait_for_rate_limit
    fi

    echo -n "  [$i/$count] Deleting $id... "
    if gh api "repos/${REPO}/code-scanning/analyses/${id}?confirm_delete" \
      --method DELETE >/dev/null 2>&1; then
      echo "OK"
    else
      echo "FAILED"
    fi
  done <<<"$ids"

  echo "Finished $tool_name: deleted $i analyses."
}

echo "Deleting code scanning analyses for: ${TOOLS_TO_DELETE[*]}"
echo "Repository: $REPO"

for tool in "${TOOLS_TO_DELETE[@]}"; do
  delete_tool_analyses "$tool"
done

echo ""
echo "All done."
