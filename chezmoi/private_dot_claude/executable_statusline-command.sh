#!/bin/bash

input=$(cat)

eval "$(echo "$input" | jq -r '
  "cwd=\(.cwd // .workspace.current_dir // "" | @sh)
model=\(.model?.display_name // "" | @sh)
effort=\(.effort?.level // "" | @sh)
total_input=\(.context_window?.total_input_tokens // "" | @sh)
ctx_size=\(.context_window?.context_window_size // "" | @sh)
cost=\(.cost?.total_cost_usd // "" | @sh)
dur_ms=\(.cost?.total_duration_ms // "" | @sh)"
')"

# --- Line 1: model | effort | context | cost | duration ---
line1=""
[ -n "$model" ] && line1="$model"
[ -n "$effort" ] && line1="${line1:+$line1 | }$effort"

if [ -n "$total_input" ] && [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
  line1="${line1:+$line1 | }$((total_input / 1000))k/$((ctx_size / 1000))k"
fi

if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  line1="${line1:+$line1 | }$(printf '$%.4f' "$cost")"
fi

if [ -n "$dur_ms" ] && [ "$dur_ms" -gt 0 ] 2>/dev/null; then
  dur_min=$((dur_ms / 60000))
  if [ "$dur_min" -ge 60 ]; then
    dur_fmt="$((dur_min / 60))h$((dur_min % 60))m"
  else
    dur_fmt="${dur_min}m"
  fi
  line1="${line1:+$line1 | }$dur_fmt"
fi

printf '%s' "$line1"

# --- Line 2: dir | branch markers ---
printf '\n'

line2=""
if [ -n "$cwd" ]; then
  if [[ "$cwd" == "$HOME"* ]]; then
    line2="~${cwd#"$HOME"}"
  else
    line2="$cwd"
  fi
fi

if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
    git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    [ ${#branch} -gt 32 ] && branch="${branch:0:12}..${branch: -12}"
    git_status=$(git -C "$cwd" status --porcelain 2>/dev/null)
    markers=""
    printf '%s' "$git_status" | grep -q '^[MADRC]' && markers="${markers}+"
    printf '%s' "$git_status" | grep -q '^.[MD]' && markers="${markers}!"
    printf '%s' "$git_status" | grep -q '^??' && markers="${markers}?"
    printf '%s' "$git_status" | grep -qE '^(UU|AA|DD)' && markers="${markers}~"
    line2="${line2:+$line2 | }$branch${markers:+ $markers}"
  fi
fi

printf '%s' "$line2"
