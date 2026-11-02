# dotfiles

Dotfiles are **tracked in place by mise** (`mise dot`) and synced across machines
through a private origin (`setup.git`) — the watcher checkpoints every edit and
publishes/fetches automatically.

This repo is no longer the file deployment source. It holds **machine
declarations** (`mise.toml`: packages, tools, LaunchAgents, hooks, bootstrap
task) plus the **pi skills** and the pre-track **archive** of config files
(`zsh/`, `fish/`, `nvim/`, …) kept for reference.

## Setup (fresh machine)

```sh
# 1. Install mise — https://mise.jdx.dev
# 2. Restore all dotfiles + declarations from the history origin:
mise bootstrap --adopt geek4good/setup
```

Daily: nothing — the watcher syncs. Manual flush: `mise dot sync && mise dot pull`.
Drift/status: `mise dot status`. History: `mise dot history` / `rollback` / `undo`.

## Tech stack

- **mise** — everything: dotfile tracking + cross-machine sync (history origin),
  system packages (`[bootstrap.packages]`), dev tool version management
  (`[tools]`), and full machine bootstrap
- **Homebrew** — kept installed as an escape hatch; mise installs brew/brew-cask
  packages itself and never runs the `brew` CLI
- **fnox** + **age** — encrypted secrets, decrypted at shell init via SSH key
- **zsh** — shell (fish-parity UX: zsh-autosuggestions, syntax highlighting, fzf-tab, zsh-abbr, starship); fish kept installed as fallback
- **Neovim** (LazyVim) — editor
- **fzf** — fuzzy finder (Ctrl+R history, Alt+O files, Alt+C dirs; Ctrl+T swaps adjacent characters)

## Maintenance

```sh
mise bootstrap packages status        # package drift
mise bootstrap status --missing       # full drift check (CI-friendly)
mise bootstrap --skip-dirty           # repeatable full setup (declarations)
```

One caveat: `[bootstrap.packages]`/LaunchAgent declarations live in this
repo's `mise.toml`, which the `--adopt` flow does **not** clone — until those
move into the tracked global config, follow `--adopt` with cloning this repo
and one `mise bootstrap`.

Historical: GNU Stow → mise deploy groups (Oct 2026) → mise track + origin
sync (Nov 2026). The per-app `dot-` directories are the pre-track archive.
