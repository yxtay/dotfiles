# dotfiles

Personal macOS and Linux shell setup managed with [chezmoi](https://chezmoi.io/) and
[Homebrew](https://brew.sh/).

## What's in this repo

- `chezmoi/`: templated dotfiles for shell and tool config (zsh, git, helix, wezterm, bat, etc.)
- `plugins/`: personal Claude Code plugins — a local marketplace installed via `chezmoi apply`
- `bin/`: convenience maintenance scripts (`update-all.sh`, `cleanup-all.sh`)

## Apply directly from repo

Install chezmoi and apply dotfiles in one step, no clone needed:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply yxtay
```

The following commands require cloning the repo first.

## Bootstrap

Run:

```bash
./install.sh
```

This script installs `chezmoi` if missing, then initializes and applies this repo as the source.

## Apply dotfiles

```bash
chezmoi apply
```

This installs all Homebrew packages and applies config files.

## Development workflow

```bash
# Install pre-commit hooks
pre-commit install
```

## Maintenance scripts

```bash
# Refresh dotfiles (requires `gh auth login`)
./bin/update-all.sh

# Clean caches and old artifacts
./bin/cleanup-all.sh
```

## Claude Code plugins

Personal skills-directory plugin deployed by `chezmoi apply` to `~/.claude/skills/okf/`.
Loaded automatically as `okf@skills-dir` on session start — no install step.

Current plugins:

- `okf` — OKF skill + SessionEnd hook that distills memsearch journals into the `~/wiki` OKF bundle

## License

MIT
