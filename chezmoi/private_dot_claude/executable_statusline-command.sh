#!/bin/bash
# Claude Code statusline script
# Shows: cwd, git branch, git changes, model, context tokens, cost, caveman badge

input=$(cat)

# --- Directory ---
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
if [ -n "$cwd" ]; then
  # Collapse $HOME to ~
  short_cwd="${cwd/#$HOME/~}"
  printf '\033[34m%s\033[0m' "$short_cwd"
fi

# --- Git branch + changes ---
if [ -n "$cwd" ] && [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
    git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    printf ' \033[32m(%s)\033[0m' "$branch"
    # Count staged + unstaged changes (skip untracked for brevity)
    changes=$(git -C "$cwd" status --porcelain 2>/dev/null | grep -c '^')
    if [ "$changes" -gt 0 ] 2>/dev/null; then
      printf ' \033[33m*%s\033[0m' "$changes"
    fi
  fi
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model" ]; then
  printf ' \033[36m[%s]\033[0m' "$model"
fi

# --- Context: tokens used + percentage ---
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$total_input" ] && [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
  printf ' \033[35m%sk/%sk' "$((total_input / 1000))" "$((ctx_size / 1000))"
  if [ -n "$used_pct" ]; then
    printf ' (%.0f%%)' "$used_pct"
  fi
  printf '\033[0m'
fi

# --- Cost ---
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  printf ' \033[33m$%.4f\033[0m' "$cost"
fi

# --- Caveman badge (preserved from existing script) ---
FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ -f "$FLAG" ] && [ ! -L "$FLAG" ]; then
  MODE=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
  MODE=$(printf '%s' "$MODE" | tr -cd 'a-z0-9-')
  case "$MODE" in
  off | lite | full | ultra | wenyan-lite | wenyan | wenyan-full | wenyan-ultra | commit | review | compress)
    printf ' '
    if [ -z "$MODE" ] || [ "$MODE" = "full" ]; then
      printf '\033[38;5;172m[CAVEMAN]\033[0m'
    else
      SUFFIX=$(printf '%s' "$MODE" | tr '[:lower:]' '[:upper:]')
      printf '\033[38;5;172m[CAVEMAN:%s]\033[0m' "$SUFFIX"
    fi
    if [ "${CAVEMAN_STATUSLINE_SAVINGS:-1}" != "0" ]; then
      SAVINGS_FILE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-statusline-suffix"
      if [ -f "$SAVINGS_FILE" ] && [ ! -L "$SAVINGS_FILE" ]; then
        SAVINGS=$(head -c 64 "$SAVINGS_FILE" 2>/dev/null | tr -d '\000-\037')
        [ -n "$SAVINGS" ] && printf ' \033[38;5;172m%s\033[0m' "$SAVINGS"
      fi
    fi
    ;;
  esac
fi
