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

- **agents/** — shared agent skills (SKILL.md files) → `~/.config/agents/skills/`
- **bash/** — shell config (`.bashrc`, `.bash_profile`)
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

## Shared agent skills (`agents/`)

`agents/dot-config/agents/skills/` is the **single source of truth** for all shared skills. Every coding agent (pi, opencode, crush) loads skills from here via `~/.config/agents/skills/`.

Skills follow the Agent Skills standard: each is a directory with a `SKILL.md` (YAML frontmatter + Markdown body) and optional `references/`.

### Shared skills

| Skill | Purpose |
|-------|---------|
| `skill-loading` | Mandatory pre-implementation protocol (philosophy selection + skill discovery) |
| `behavioral-rules` | Universal coding behavior (concise output, no debug, fail fast, etc.) |
| `code-philosophy` | The 5 Laws of Elegant Defense (backend/logic) |
| `frontend-philosophy` | The 5 Pillars of Intentional UI |
| `iac-philosophy` | The 5 Pillars of Immutable Infrastructure |
| `astro` | Astro framework patterns + 14 reference docs |
| `code-review` | 4-layer review methodology with severity classification |
| `plan-protocol` | Implementation plan format with citations |
| `plan-review` | Plan quality review criteria |
| `commit` | Git commit workflow and Conventional Commits format |
| `rails-upgrade` | Rails upgrade assistant (2.3→8.1) with version guides, detection patterns, and FastRuby.io methodology |
| `github-actions` | CI/CD workflow creation and optimization (from el-feo/ai-context) |
| `kamal` | Docker deployment configuration with Kamal (from el-feo/ai-context) |
| `tailscale` | VPN setup and configuration (from el-feo/ai-context) |
| `mermaid-diagrams` | Software diagrams with Mermaid syntax (from el-feo/ai-context) |
| `eslint` | JavaScript/TypeScript linting with ESLint (from el-feo/ai-context) |
| `vitest` | Vitest testing framework and Jest migration (from el-feo/ai-context) |
| `javascript-unit-testing` | Unit testing patterns with Jest (from el-feo/ai-context) |
| `rails` | Comprehensive Rails v8.1 development guide (from el-feo/ai-context) |
| `ruby` | Ruby language fundamentals and design patterns (from el-feo/ai-context) |
| `rspec` | RSpec testing patterns and best practices (from el-feo/ai-context) |
| `rubocop` | Ruby linting and code style (from el-feo/ai-context) |
| `rubycritic` | Code quality analysis (from el-feo/ai-context) |
| `simplecov` | Test coverage analysis (from el-feo/ai-context) |
| `brakeman` | Rails security vulnerability scanner (from el-feo/ai-context) |
| `rails-generators` | Creating custom Rails generators (from el-feo/ai-context) |
| `review-ruby-code` | Code review with Sandi Metz rules, SOLID, and OO design (from el-feo/ai-context) |
| `postgresql-rails-analyzer` | PostgreSQL optimization for Rails (from el-feo/ai-context) |
| `cucumber-gherkin` | Cucumber/Gherkin BDD testing (from el-feo/ai-context) |
| `design-patterns-ruby` | Ruby design patterns (creational, structural, behavioral) (from el-feo/ai-context) |
| `ghpm` | GitHub Project Management workflow — PRD→Epics→Tasks→TDD (from el-feo/ai-context) |
| `ghpmplus` | Autonomous GitHub Project Management with parallel execution (from el-feo/ai-context) |

### Rules

- **Never duplicate** a skill into an agent-specific directory. If it's useful across agents, it belongs in `agents/`.
- **Agent-specific configs** (model settings, role definitions, plugins, themes) stay in their own directories (`pi/`, `opencode/`, `crush/`).
- **When updating a skill**, update it only in `agents/`. All agents pick it up automatically.

## Git conventions

- Default branch: `main`
- All commits GPG-signed
- Commit style: `type(scope): description` (e.g., `feat(crush):`, `refactor(aerospace):`)
- `setup/` directory is empty; bootstrap lives in `bin/dot-local/bin/_bootstrap`

## What not to do

- Don't commit plaintext secrets, API keys, or tokens
- Don't modify `.stow-local-ignore` without understanding what it excludes from stow
- Don't create files at the repo root unless they're repo-level config (`.gitignore`, `.stow-local-ignore`, `README.md`, this file)
- Don't add stow packages that don't follow the `dot-` naming convention
- Don't touch `secrets/encrypted/*.age` files unless explicitly asked
- Don't duplicate shared skills into agent-specific directories — `agents/` is the single source of truth
