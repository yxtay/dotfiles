#!/bin/bash
# Claude Code statusline — styled to match powerlevel10k

input=$(cat)

C_RESET='\033[0m'
C_SEP='\033[38;5;244m'
C_BRANCH_CLEAN='\033[38;5;76m'
C_BRANCH_DIRTY='\033[38;5;178m'
C_BRANCH_UNTRACKED='\033[38;5;39m'
C_BRANCH_CONFLICT='\033[38;5;196m'
SEP=" ${C_SEP}|${C_RESET} "

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')

# --- Line 1: Model | effort | context | cost | duration ---
line1=""

model=$(echo "$input" | jq -r '.model.display_name // empty')
[ -n "$model" ] && line1+="\033[36m${model}\033[0m"

effort=$(echo "$input" | jq -r '.effort.level // empty')
if [ -n "$effort" ]; then
  case "$effort" in
  max | xhigh) ec='\033[38;5;196m' ;;
  high) ec='\033[38;5;178m' ;;
  *) ec='\033[38;5;244m' ;;
  esac
  [ -n "$line1" ] && line1+="$SEP"
  line1+="${ec}${effort}\033[0m"
fi

total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
if [ -n "$total_input" ] && [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
  [ -n "$line1" ] && line1+="$SEP"
  line1+="\033[35m$((total_input / 1000))k/$((ctx_size / 1000))k\033[0m"
fi

cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  cost_fmt=$(printf '$%.4f' "$cost")
  [ -n "$line1" ] && line1+="$SEP"
  line1+="\033[33m${cost_fmt}\033[0m"
fi

dur_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
if [ -n "$dur_ms" ] && [ "$dur_ms" -gt 0 ] 2>/dev/null; then
  dur_min=$((dur_ms / 60000))
  if [ "$dur_min" -ge 60 ]; then
    dur_fmt="$((dur_min / 60))h$((dur_min % 60))m"
  else
    dur_fmt="${dur_min}m"
  fi
  [ -n "$line1" ] && line1+="$SEP"
  line1+="\033[38;5;244m${dur_fmt}\033[0m"
fi

printf '%b' "$line1"

# --- Line 2: dir | branch + markers | PR ---
printf '\n'

line2=""
if [ -n "$cwd" ]; then
  if [[ "$cwd" == "$HOME"* ]]; then
    short_cwd="~${cwd#"$HOME"}"
  else
    short_cwd="$cwd"
  fi
  line2+="\033[34m${short_cwd}\033[0m"
fi

if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
    git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

  if [ -n "$branch" ]; then
    [ ${#branch} -gt 32 ] && branch="${branch:0:12}..${branch: -12}"

    git_status=$(git -C "$cwd" status --porcelain 2>/dev/null)
    staged=$(printf '%s' "$git_status" | grep -c '^[MADRC]')
    unstaged=$(printf '%s' "$git_status" | grep -c '^.[MD]')
    untracked=$(printf '%s' "$git_status" | grep -c '^??')
    conflicts=$(printf '%s' "$git_status" | grep -cE '^(UU|AA|DD)')

    if [ "$conflicts" -gt 0 ]; then
      color="$C_BRANCH_CONFLICT"
    elif [ "$staged" -gt 0 ] || [ "$unstaged" -gt 0 ]; then
      color="$C_BRANCH_DIRTY"
    elif [ "$untracked" -gt 0 ]; then
      color="$C_BRANCH_UNTRACKED"
    else
      color="$C_BRANCH_CLEAN"
    fi

    markers=""
    [ "$staged" -gt 0 ] && markers="${markers}+"
    [ "$unstaged" -gt 0 ] && markers="${markers}!"
    [ "$untracked" -gt 0 ] && markers="${markers}?"
    [ "$conflicts" -gt 0 ] && markers="${markers}~"

    [ -n "$line2" ] && line2+="$SEP"
    line2+="${color}${branch}${C_RESET}"
    [ -n "$markers" ] && line2+=" ${markers}"
  fi
fi

printf '%b' "$line2"
