# AI Agent Instructions

AI agent instructions for working with this repository.

## Overview

Personal macOS dotfiles managed with two complementary tools:

- **Nix flakes** (`nix-darwin` + `home-manager`) for declarative
  system/user package management
- **chezmoi** for templated shell/tool config files (zsh, git, helix, wezterm, bat)

Host: `Mac` | User: `yuxuantay` (defined in `flake.nix`)

## Commands

```bash
# Enter dev shell (provides extra tools for working in this repo)
nix develop

# Format all files (deadnix, prettier, shellcheck, shfmt, statix, taplo, yamlfmt)
nix fmt

# Check flake validity (runs in CI)
nix flake check

# Run pre-commit hooks locally
uv run pre-commit run --all-files

# Apply system config (nix-darwin) — requires sudo
sudo nix run nix-darwin -- switch --flake .#Mac

# Apply user config (home-manager standalone)
nix run home-manager -- switch --flake .#yuxuantay

# Apply chezmoi dotfiles
chezmoi apply

# Bootstrap from scratch
./install.sh
```

## Architecture

### Nix modules (`modules/`)

- `flake-parts/` — Flake composition: wires together darwin,
  home-manager, treefmt, git-hooks, and devshell.
  Entry point for `flake.nix`.
- `darwin/` — macOS system-level config: Homebrew casks/formulae,
  keyboard, networking, system defaults, zsh system shell.
- `home/` — User-level packages and programs via home-manager:
  CLI tools (`apps.nix`), git, zsh, helix, tmux, wezterm, fonts.

### Chezmoi (`chezmoi/`)

`.chezmoiroot` sets `chezmoi/` as the source directory. Files use
chezmoi naming conventions (`private_dot_config/`, `dot_`,
`symlink_`, `.tmpl`). Templates get data from
`.chezmoi.toml.tmpl`.

### CI (`.github/workflows/`)

- `ci.yml` — Runs `nix flake check` + `nix fmt` on macOS, tests chezmoi install
- `pr.yml` — MegaLinter on PRs
- `update.yml` — Automated flake/dependency updates

### Dependency management

- **Renovate** auto-updates pre-commit hooks and GitHub Actions (configured in `renovate.json`)
- **Dependabot** as secondary updater
- Nix flake inputs pinned via `flake.lock`

## Conventions

- Nix files are formatted with `nixfmt-rfc-style` (via treefmt/git-hooks)
- Shell scripts exclude `.zsh` files from shellcheck/shfmt (zsh-specific syntax)
- Pre-commit hooks enforce formatting on commit;
  CI verifies no uncommitted formatting changes
- Commits follow conventional commits style (see git log)
