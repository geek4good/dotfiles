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
- **claude/** — Claude Code config → `~/.claude/` (skills) and `~/.config/claude-plugins/` (local plugin marketplace)
- **crush/** — Crush AI assistant config → `~/.config/crush/`
- **fnox/** — fnox secrets config → `~/.config/fnox/`
- **gh/** — GitHub CLI config → `~/.config/gh/`
- **git/** — git config and ignores → `~/.config/git/`
- **homebrew/** — Brewfile → `~/Brewfile`
- **mise/** — dev tool version management → `~/.config/mise/`
- **nvim/** — Neovim (LazyVim) config → `~/.config/nvim/`
- **opencode/** — OpenCode AI editor config → `~/.config/opencode/`
- **pi/** — pi coding agent config → `~/.pi/agent/`
- **secrets/** — age-encrypted secrets (never plaintext in git)
- **ssh/** — SSH client config → `~/.ssh/config`

## Sensitive files — do not modify or expose

- **secrets/** — only `*.age` encrypted files; the `.gitignore` blocks everything else
- **fnox/dot-config/fnox/age.txt** — gitignored; decryption key reference
- **gnupg/** — GPG keys and ownertrust
- **ssh/dot-ssh/** — SSH config only; keys must never be committed

## Shared skills and Claude Code plugins (`claude/`)

Claude Code is the primary consumer and source of truth. Shared skills live at `claude/dot-claude/skills/<name>/SKILL.md` and stow into `~/.claude/skills/`. A local plugin marketplace at `claude/dot-config/claude-plugins/` stows into `~/.config/claude-plugins/` and hosts `ghpm` and `ghpmplus`.

### Managing skills

Skills are managed with the [`skills` npm CLI](https://github.com/vercel-labs/skills):

```
npx skills add <source> -a claude-code -g    # install a skill
npx skills update -g                          # update all skills
npx skills remove <name> -g                   # remove a skill
```

After any add/update/remove, run `./sync` from the repo root. `sync` calls `dotfiles-sync-skills`, which ingests anything new in `~/.claude/skills/` into `claude/dot-claude/skills/`, then stows everything back so the repo is the version-controlled source of truth.

### Plugins (ghpm, ghpmplus)

The local marketplace at `claude/dot-config/claude-plugins/` has a `.claude-plugin/marketplace.json` listing `ghpm` and `ghpmplus`. Each plugin is a subdirectory with `.claude-plugin/plugin.json`, `commands/`, `agents/`, and (for ghpm) `skills/`. One-time registration per machine inside Claude Code:

```
/plugin marketplace add ~/.config/claude-plugins
/plugin install ghpm@dotfiles-local ghpmplus@dotfiles-local
```

### Rules

- **Shared skills** live only under `claude/dot-claude/skills/`. Never duplicate into agent-specific directories.
- **Agent-specific configs** (model settings, role definitions, themes) stay in their own stow packages (`pi/`, `opencode/`, `crush/`).
- **Plugin commands and sub-agents** belong inside their plugin directory under `claude/dot-config/claude-plugins/`, not in `claude/dot-claude/commands/` or `claude/dot-claude/agents/`, so they stay namespaced (`/ghpm:create-prd` rather than `/create-prd`).

## Git conventions

- Default branch: `main`
- All commits GPG-signed
- Commit style: `type(scope): description` (e.g., `feat(crush):`, `refactor(aerospace):`)
- `./sync` runs stow (including the skills sync); full-machine bootstrap lives in `bin/dot-local/bin/_bootstrap`

## What not to do

- Don't commit plaintext secrets, API keys, or tokens
- Don't modify `.stow-local-ignore` without understanding what it excludes from stow
- Don't create files at the repo root unless they're repo-level config (`.gitignore`, `.stow-local-ignore`, `README.md`, this file)
- Don't add stow packages that don't follow the `dot-` naming convention
- Don't touch `secrets/encrypted/*.age` files unless explicitly asked
- Don't duplicate shared skills into agent-specific directories — `claude/dot-claude/skills/` is the single source of truth
