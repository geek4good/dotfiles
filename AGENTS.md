# AGENTS.md

Guide for AI agents working in this dotfiles repository.

## Repository purpose

Personal configuration files deployed with [mise](https://mise.jdx.dev/) dotfile
groups. Each top-level directory is a **group** (formerly a GNU Stow package)
that maps into `$HOME`. Deployment is declared in `mise.toml` at the repo root.

## Layout convention

Every top-level directory is a dotfile group. The target is always `$HOME`:

```
<group>/dot-foo/...    →  ~/...    (dot- becomes a leading .)
<group>/dot-config/X/  →  ~/.config/X/
<group>/dot-local/bin/ →  ~/.local/bin/
```

Examples:

| Repo path                               | Symlink target                |
|-----------------------------------------|-------------------------------|
| `bash/dot-bashrc`                       | `~/.bashrc`                   |
| `git/dot-config/git/config`             | `~/.config/git/config`        |
| `ssh/dot-ssh/config`                    | `~/.ssh/config`               |
| `bin/dot-local/bin/_bootstrap` (gone)   | `~/.local/bin/…`              |
| `launchagents/Library/LaunchAgents/…`   | `~/Library/LaunchAgents/…`    |
| `nvim/dot-config/nvim/`                 | `~/.config/nvim/`             |

**When adding a new config**: create or use an existing top-level group directory,
then mirror the `~/` path inside it, replacing the leading dot with `dot-`. No
`mise.toml` edit is needed for files inside an existing group — the next apply
picks them up. A *new* group needs a `[dotfile_groups.<name>]` table in `mise.toml`.

**Never deployed** (mirrored from the old `.stow-local-ignore`): `.DS_Store`,
`.git`, `.gitignore`, `README.md` (every group excludes these), plus
`docker/dot-docker/config.json` (docker rewrites it in place — live file wins)
and `zed/{.tmp*,prompts}` (stale junk).

To preview changes:

```sh
mise -C ~/Projects/dotfiles dot status
mise -C ~/Projects/dotfiles dot apply --dry-run
```

To deploy (skills ingestion + drift report included):

```sh
./sync
```

## Key directories

- **bash/** — shell config (`.bashrc`, `.bash_profile`)
- **bin/dot-local/bin/** — personal scripts (deployed to `~/.local/bin/`); includes `bootstrap-extras` (the mise `bootstrap` task) and `dotfiles-sync-skills`
- **fnox/** — fnox secrets config → `~/.config/fnox/`
- **gh/** — GitHub CLI config → `~/.config/gh/`
- **git/** — git config and ignores → `~/.config/git/`
- **launchagents/** — user LaunchAgents → `~/Library/LaunchAgents/` (plain plists; mise's `[bootstrap.macos.launchd.agents]` is NOT used — it can't express `WatchPaths` and renames labels to `dev.mise.*`)
- **mise/dot-config/mise/config.toml** — global mise config (`[tools]`), deployed to `~/.config/mise/config.toml`
- **secrets/** — age-encrypted secrets (never plaintext in git)
- **ssh/** — SSH client config → `~/.ssh/config`

## mise configuration map

| File | Contains |
|---|---|
| `mise.toml` (repo root, trusted project config) | `[dotfile_groups]` (deployment), `[bootstrap.packages]` (former Brewfile), `[bootstrap.repos]`, `[bootstrap.files]` (Touch-ID PAM), `[bootstrap.hooks]`, `[tasks.bootstrap]` |
| `mise/dot-config/mise/config.toml` (global) | `[tools]` (runtimes, language servers, CLI extras), `experimental = true` |

Per-machine variation: `~/.config/mise/config.local.toml` (never committed) can
select groups via `[bootstrap] dotfile_groups = [...]`, or load platform files
(`config.macos.toml` with `auto_env`).

Common commands (run inside the repo, or with `-C ~/Projects/dotfiles`):

```sh
./sync                                  # deploy + skills ingest + drift report
mise dot status                         # drift check for dotfiles
mise bootstrap packages status          # drift check for brew/brew-cask
mise bootstrap status --missing         # everything, CI-friendly exit code
mise bootstrap                          # full machine setup (add --skip-dirty when the repo has local changes)
```

Homebrew remains installed as an escape hatch (mise never runs it, but installs
are interop-compatible). mise itself lives at `~/.local/bin/mise` (official
release, `mise self-update`).

## Sensitive files — do not modify or expose

- **secrets/** — only `*.age` encrypted files; the `.gitignore` blocks everything else
- **fnox/dot-config/fnox/age.txt** — gitignored; decryption key reference
- **gnupg/** — GPG keys and ownertrust
- **ssh/dot-ssh/** — SSH config only; keys must never be committed

## Pi skills (`pi/`)

Pi is the primary coding agent. Its skills live at `pi/dot-pi/agent/skills/<name>/SKILL.md`
and stow into `~/.pi/agent/skills/`.

### Managing skills

Install a skill into `~/.pi/agent/skills/` — manually or via the [`skills` npm CLI](https://github.com/vercel-labs/skills) — then run `./sync` from the repo root. `sync` calls `dotfiles-sync-skills`, which ingests anything new in `~/.pi/agent/skills/` into `pi/dot-pi/agent/skills/`, then deploys everything back so the repo is the version-controlled source of truth.

### Rules

- **Pi skills** live only under `pi/dot-pi/agent/skills/` — the single source of truth.
- **`~/.agents/skills/`** is a shared, externally managed location installed directly by the `skills` CLI. Pi loads it too, but it is not repo-managed: never copy skills between the two locations.

## Git conventions

- Default branch: `main`
- All commits GPG-signed
- Commit style: `type(scope): description` (e.g., `feat(pi):`, `refactor(aerospace):`)
- `./sync` runs `mise dot apply` (including the skills sync); full machine bootstrap is `mise bootstrap`

## What not to do

- Don't commit plaintext secrets, API keys, or tokens
- Don't use `stow` — deployment is mise's job now (`mise dot apply` / `./sync`). The `dot-` naming is kept because `dot_prefix = true` depends on it.
- Don't edit files under `$HOME` that are symlinks into this repo — edit the repo file (they're the same file; edits through the link make the repo dirty on purpose, see `./sync` drift report)
- Don't add `[dotfiles]` entries with a `group` key (invalid); per-file overrides go in `[dotfile_groups.<name>.entries]`
- Don't create files at the repo root unless they're repo-level config (`.gitignore`, `README.md`, `mise.toml`, this file)
- Don't declare `brew:mise` or add mise to `[tools]` — mise self-manages from `~/.local/bin`
- Don't touch `secrets/encrypted/*.age` files unless explicitly asked
- Don't duplicate skills between `pi/dot-pi/agent/skills/` and `~/.agents/skills/` — the former is repo-managed, the latter is externally managed by the `skills` CLI
