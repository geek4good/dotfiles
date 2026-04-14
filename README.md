# dotfiles

Configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that mirrors the target structure under `$HOME`, using `dot-` prefixes in place of leading dots.

## Tech stack

- **Stow** — symlinks config files into place
- **Homebrew** — system packages
- **mise** — dev tool version management (Node, Go, Rust, Python, etc.)
- **fnox** + **age** — encrypted secrets, decrypted at shell init via SSH key
- **bash** — shell, with bash-completion, fzf integration, and fancy Ctrl-Z
- **Neovim** (LazyVim) — editor
- **fzf** — fuzzy finder (Ctrl+R history, Ctrl+T files, Alt+C dirs)

## Setup

```sh
curl -fsSL https://raw.githubusercontent.com/geek4good/dotfiles/main/bin/dot-local/bin/_bootstrap | sh
```
