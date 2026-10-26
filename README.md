# dotfiles

Configuration files deployed with [mise](https://mise.jdx.dev/) dotfile groups.
Each top-level directory is a group that mirrors the target structure under
`$HOME`, using `dot-` prefixes in place of leading dots (see `mise.toml`).

## Tech stack

- **mise** — dotfile deployment (`[dotfile_groups]`), system packages
  (`[bootstrap.packages]`, former Brewfile), dev tool version management
  (`[tools]`: Node, Go, Rust, Python, …), and full machine bootstrap
- **Homebrew** — kept installed as an escape hatch; mise installs brew/brew-cask
  packages itself and never runs the `brew` CLI
- **fnox** + **age** — encrypted secrets, decrypted at shell init via SSH key
- **bash** — shell, with bash-completion, fzf integration, and fancy Ctrl-Z
- **Neovim** (LazyVim) — editor
- **fzf** — fuzzy finder (Ctrl+R history, Ctrl+T files, Alt+C dirs)

## Setup (fresh machine)

```sh
# 1. Install mise — https://mise.jdx.dev (official installer)
# 2. Clone and bootstrap:
git clone git@github.com:geek4good/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
mise trust
mise bootstrap        # interactive terminal: creates the Touch-ID PAM file once
```

Daily use from inside the repo:

```sh
./sync                                # deploy dotfiles (+ skills ingest, drift report)
mise bootstrap packages status        # package drift
mise bootstrap status --missing       # full drift check (CI-friendly)
mise bootstrap --skip-dirty           # repeatable full setup
```

Historical note: GNU Stow + a `Brewfile` + a `_bootstrap` script were replaced
by mise in Oct 2026. Stow-style `dot-` layout is preserved (`dot_prefix`).
