# AGENTS.md

Guide for AI agents working in this dotfiles repository.

## Repository purpose

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that maps into `$HOME`.

## Stow package convention

Every top-level directory is a stow package. The target is always `$HOME`:

```
<package>/dot-foo/...    →  ~/...    (dot- becomes a leading .)
<package>/dot-config/X/  →  ~/.config/X/
<package>/dot-local/bin/ →  ~/.local/bin/
```

Examples:

| Repo path                               | Symlink target                |
|-----------------------------------------|-------------------------------|
| `bash/dot-bashrc`                       | `~/.bashrc`                   |
| `git/dot-config/git/config`             | `~/.config/git/config`        |
| `ssh/dot-ssh/config`                    | `~/.ssh/config`               |
| `bin/dot-local/bin/_bootstrap`          | `~/.local/bin/_bootstrap`     |
| `nvim/dot-config/nvim/`                 | `~/.config/nvim/`             |
| `aerospace/dot-config/aerospace/`       | `~/.config/aerospace/`        |

**When adding a new config**: create or use an existing top-level package directory, then mirror the `~/` path inside it, replacing the leading dot with `dot-`.

To verify before linking:

```sh
stow --simulate -t ~ <package>
```

To link:

```sh
stow -t ~ <package>
```

## Key directories

- **bash/** — shell config (`.bashrc`, `.bash_profile`)
- **fnox/** — fnox secrets config → `~/.config/fnox/`
- **gh/** — GitHub CLI config → `~/.config/gh/`
- **git/** — git config and ignores → `~/.config/git/`
- **homebrew/** — Brewfile → `~/Brewfile`
- **launchagents/** — user LaunchAgents → `~/Library/LaunchAgents/` (e.g. `pr-worktree-clean`, which removes merged-PR worktrees and closes their Herdr workspaces every 15 min)
- **mise/** — dev tool version management → `~/.config/mise/`
- **nvim/** — Neovim (LazyVim) config → `~/.config/nvim/`
- **pi/** — pi coding agent config → `~/.pi/agent/` (skills live here too, see below)
- **secrets/** — age-encrypted secrets (never plaintext in git)
- **ssh/** — SSH client config → `~/.ssh/config`

## Sensitive files — do not modify or expose

- **secrets/** — only `*.age` encrypted files; the `.gitignore` blocks everything else
- **fnox/dot-config/fnox/age.txt** — gitignored; decryption key reference
- **gnupg/** — GPG keys and ownertrust
- **ssh/dot-ssh/** — SSH config only; keys must never be committed

## Pi skills (`pi/`)

Pi is the primary coding agent. Its skills live at `pi/dot-pi/agent/skills/<name>/SKILL.md` and stow into `~/.pi/agent/skills/`.

### Managing skills

Install a skill into `~/.pi/agent/skills/` — manually or via the [`skills` npm CLI](https://github.com/vercel-labs/skills) — then run `./sync` from the repo root. `sync` calls `dotfiles-sync-skills`, which ingests anything new in `~/.pi/agent/skills/` into `pi/dot-pi/agent/skills/`, then stows everything back so the repo is the version-controlled source of truth.

### Rules

- **Pi skills** live only under `pi/dot-pi/agent/skills/` — the single source of truth.
- **`~/.agents/skills/`** is a shared, externally managed location installed directly by the `skills` CLI. Pi loads it too, but it is not repo-managed: never copy skills between the two locations.

## Git conventions

- Default branch: `main`
- All commits GPG-signed
- Commit style: `type(scope): description` (e.g., `feat(pi):`, `refactor(aerospace):`)
- `./sync` runs stow (including the skills sync); full-machine bootstrap lives in `bin/dot-local/bin/_bootstrap`

## What not to do

- Don't commit plaintext secrets, API keys, or tokens
- Don't modify `.stow-local-ignore` without understanding what it excludes from stow
- Don't create files at the repo root unless they're repo-level config (`.gitignore`, `.stow-local-ignore`, `README.md`, this file)
- Don't add stow packages that don't follow the `dot-` naming convention
- Don't touch `secrets/encrypted/*.age` files unless explicitly asked
- Don't duplicate skills between `pi/dot-pi/agent/skills/` and `~/.agents/skills/` — the former is repo-managed, the latter is externally managed by the `skills` CLI
