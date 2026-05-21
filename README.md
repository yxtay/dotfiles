# dotfiles

Personal macOS and shell setup managed with
[chezmoi](https://chezmoi.io/) and [Homebrew](https://brew.sh/).

## What's in this repo

- `chezmoi/`: templated dotfiles for shell and tool config
  (zsh, git, helix, wezterm, bat, etc.)
- `scripts/`: convenience maintenance scripts (`update-all.sh`, `cleanup-all.sh`)

## Prerequisites

- macOS
- `git`
- `gh` authenticated (`gh auth login`) for update flows
  that need a GitHub token

## Bootstrap

Run:

```bash
./install.sh
```

This script installs `chezmoi` if missing, then initializes
and applies this repo as the source.

## Apply dotfiles directly from repo

To install chezmoi and apply dotfiles in one step:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply yxtay
```

## Apply dotfiles

```bash
chezmoi apply
```

This installs all Homebrew packages and applies config files.

## Development workflow

```bash
# Run configured pre-commit hooks
pre-commit run --all-files
```

## Maintenance scripts

```bash
# Refresh dotfiles
./scripts/update-all.sh

# Clean caches and old artifacts
./scripts/cleanup-all.sh
```

## License

MIT
