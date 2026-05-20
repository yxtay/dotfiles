# AI Agent Instructions

AI agent instructions for working with this repository.

## Overview

Personal macOS dotfiles managed with [chezmoi](https://chezmoi.io/)
and [Homebrew](https://brew.sh/).

## Commands

```bash
# Run pre-commit hooks locally
pre-commit run --all-files

# Apply chezmoi dotfiles (installs packages + applies config)
chezmoi apply

# Bootstrap from scratch
./install.sh
```

## Architecture

### Chezmoi (`chezmoi/`)

`.chezmoiroot` sets `chezmoi/` as the source directory. Files use
chezmoi naming conventions (`private_dot_config/`, `dot_`,
`symlink_`, `.tmpl`). Templates get data from
`.chezmoi.toml.tmpl`.

Key scripts:

- `run_before_brew_bundle_install.sh.tmpl` — installs all Homebrew packages/casks
- `run_onchange_macos_defaults.sh.tmpl` — applies macOS system settings

### CI (`.github/workflows/`)

- `ci.yml` — Tests chezmoi install
- `pr.yml` — MegaLinter on PRs

### Dependency management

- **Renovate** auto-updates pre-commit hooks and GitHub Actions (configured in `renovate.json`)
- **Dependabot** as secondary updater

## Conventions

- Shell scripts exclude `.zsh` files from shellcheck/shfmt (zsh-specific syntax)
- Pre-commit hooks enforce formatting on commit;
  CI verifies no uncommitted formatting changes
- Commits follow conventional commits style (see git log)
