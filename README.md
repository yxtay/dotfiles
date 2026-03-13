# dotfiles

Personal macOS and shell setup managed with
[chezmoi](https://chezmoi.io/) and Nix flakes
(`nix-darwin` + `home-manager`).

## What's in this repo

- `chezmoi/`: templated dotfiles for shell and tool config
  (zsh, git, helix, wezterm, bat, etc.)
- `modules/darwin/`: host-level macOS settings (`nix-darwin`),
  Homebrew integration, system defaults
- `modules/home/`: user-level packages and CLI/tooling (`home-manager`)
- `modules/flake-parts/`: flake composition, dev shell,
  format/lint and pre-commit hooks
- `scripts/`: convenience maintenance scripts (`update-all.sh`, `cleanup-all.sh`)

## Prerequisites

- macOS
- Nix with flakes enabled
- `git`
- `gh` authenticated (`gh auth login`) for update flows
  that need a GitHub token

## Bootstrap with chezmoi

Run:

```bash
./install.sh
```

This script installs `chezmoi` if missing, then initializes
and applies this repo as the source.

## Apply system config (`nix-darwin`)

```bash
# Remote source
sudo nix run github:LnL7/nix-darwin -- switch --flake "github:yxtay/dotfiles#Mac"

# Local checkout
sudo nix run github:LnL7/nix-darwin -- switch --flake ".#Mac"
```

## Apply user config (`home-manager` standalone)

```bash
nix run home-manager -- switch --flake .#yuxuantay
```

## Development workflow

```bash
# Enter dev shell
nix develop

# Format/lint via flake formatter
nix fmt

# Run configured pre-commit hooks
nix develop -c pre-commit run --all-files
```

## Maintenance scripts

```bash
# Rebuild + refresh dotfiles + upgrade uv tools
./scripts/update-all.sh

# Clean caches and old artifacts
./scripts/cleanup-all.sh
```

Notes:

- `update-all.sh` requires `gh auth token` and uses `sudo`
  for `nix-darwin switch`.
- `cleanup-all.sh` aggressively prunes caches
  (Nix, Docker/Podman/npm/uv, and user cache dirs).

## Host/User defaults

Current flake defaults are:

- Host: `Mac`
- User: `yuxuantay`

These are defined in `flake.nix`.

## License

MIT
