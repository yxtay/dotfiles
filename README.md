# dotfiles

Personal macOS and shell setup managed with
[chezmoi](https://chezmoi.io/) and [Homebrew](https://brew.sh/).

## What's in this repo

- `chezmoi/`: templated dotfiles for shell and tool config
  (zsh, git, helix, wezterm, bat, etc.)
- `scripts/`: convenience maintenance scripts (`update-all.sh`, `cleanup-all.sh`)

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

This script installs `chezmoi` if missing, then initializes
and applies this repo as the source.

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
# Refresh dotfiles (requires `gh auth login`)
./scripts/update-all.sh

# Clean caches and old artifacts
./scripts/cleanup-all.sh
```

## License

MIT
