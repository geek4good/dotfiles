# dotfiles

Configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that mirrors the target structure under `$HOME`, using `dot-` prefixes in place of leading dots.

## Tech stack

- **Stow** — symlinks config files into place
- **Homebrew** — system packages
- **mise** — dev tool version management (Node, Go, Rust, Python, etc.)
- **fnox** + **age** — encrypted secrets, decrypted at shell init via SSH key
- **zinit** — zsh plugin manager
- **Neovim** (LazyVim) — editor
- **fzf** + **zoxide** — fuzzy finder and directory jumper

## Setup

```sh
curl -fsSL https://raw.githubusercontent.com/geek4good/dotfiles/main/bin/dot-local/bin/_bootstrap | sh
```
