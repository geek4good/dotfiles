# zsh fish-parity UX — Design

Date: 2026-10-27
Status: approved (sections 1–9 with amendments to §2, §3, §8)

## Motivation

fish's non-POSIX syntax keeps causing friction. Switch the interactive daily
driver to zsh while preserving the fish UX that matters. The existing zsh
config already provides autosuggestions, syntax highlighting, and fzf-tab via
zinit; this design closes the remaining gaps.

## Decisions (from brainstorming)

| Decision | Choice |
|---|---|
| Scope | Daily-driver subset; `zmx_select` port **deferred** (extract to shared script later if zsh sticks) |
| Switch mechanics | `chsh -s /bin/zsh` now; fish stays installed/configured as fallback |
| Abbreviations | **Everything** becomes zsh-abbr user abbreviations (existing aliases converted too) |
| Structure | Approach A — single `dot-zshrc` + one external abbreviations file |
| Plugin manager | zinit stays; plugin review deferred until after the port |
| Terminal title hook | included (independent of the picker) |

## Design

### 1. Shell switch & mise convergence

- `chsh -s /bin/zsh` (Apple zsh; no brew formula — verified adequate for the
  plugin set).
- Remove the zinit gh-r **mise** block from `dot-zshrc`; activate with the
  explicit path `eval "$(~/.local/bin/mise activate zsh)"` (same pattern as
  the fish fix; one mise binary everywhere).
- Keep the zinit `usage` install (separate binary mise depends on).
- Rollback: `chsh -s /opt/homebrew/bin/fish`.

### 2. Prompt — starship + `prompt_hint`

- Replace the hand-rolled `PROMPT=…❯…` line with `eval "$(starship init zsh)"`.
- Add `prompt_hint()` — static heredoc legend matching the actual
  `starship/dot-config/starship.toml`:
  - anatomy: `[session in] ~/dir on  branch [git-status] [exit] ❯`
  - `❯` cyan = success · bright-purple = failure · `[N]` = exit code
  - git_status defaults: `!` modified · `+` staged · `?` untracked · `✘`
    deleted · `»` renamed · `$` stashed · `⇡` ahead · `⇣` behind · `⇕`
    diverged · `=` conflicted
  - `session` prefix = `$ZMX_SESSION` (zmx sessions only)
- Cross-reference comments in `starship.toml` and `dot-zshrc`: change symbols
  → update `prompt_hint`.

### 3. Abbreviations — zsh-abbr

- `zinit light olets/zsh-abbr`; persisted user file pointed into the repo:
  `zsh/dot-config/zsh/abbreviations` → `~/.config/zsh/abbreviations`
  (mechanism per installed zsh-abbr docs — `ABBR_USER_PATHS`; verify exact
  syntax during implementation).
- Seed file = **all abbreviations from
  `fish/dot-config/fish/config.fish`** (editor, listing, brew, mise, zmx,
  docker, git, work sections) with these adaptations:
  - `cf` → `v ~/.config/zsh/.zshrc`
  - `rf` → `exec zsh`
  - `psql-icecast` — nested quotes re-escaped for zsh
  - `d` → `docker.lima` etc. (docker set works unchanged as abbreviations)
- Existing zsh aliases (bubo/bubc/bcubo/bcubc/bubu, ml, vi/vim/view/vimdiff,
  oc, ll/la) are converted to abbreviations; alias block deleted.
- **One alias survives**: `alias ls='ls --color'` (verified `/bin/ls` accepts
  `--color`). `ll`/`la` expand to `ls -lh(-A)`; color applies via the alias at
  execution time.
- One new **global** abbreviation: `dotf` → `~/Projects/dotfiles`
  (expands in any position).

### 4. fnox, environment, PATH, options

- `if command -v fnox >/dev/null; then eval "$(fnox activate zsh)"; fi`
  (verify `fnox activate zsh` exists during implementation).
- Exports: `LC_ALL=en_GB.UTF-8`, `EDITOR=nvim`, `LESS=-FRX`,
  `HOMEBREW_NO_ENV_HINTS=1`, `umask 022`.
- PATH additions before `brew shellenv`, mirroring fish order (minus the
  shims entry, superseded by mise activate): `~/Applications`,
  `~/.bun/bin`, `~/.local/bin`, `~/govuk/govuk-docker/exe`. `PNPM_HOME` block
  folds into the same sequence.
- Options: `setopt auto_cd` and `setopt interactivecomments`.

### 5. Key bindings

| Chord | Binding | Note |
|---|---|---|
| `alt+D` (`\ed`) | `kill-word` | bigword semantics via existing `select-word-style bash` |
| delete (`\e[127;4u`) | `backward-kill-word` | CSI-u |
| ctrl+shift+L (`\e[108;6u`) | `clear-screen` | CSI-u |
| cmd+k (`\e[107;9u`) | — | **deferred**; placeholder comment marks the spot |

Existing `^p`/`^n`/`^l`, `bindkey -e` untouched.

### 6. Terminal title

`add-zsh-hook precmd` hook: title = `$ZMX_SESSION` when set, else cwd
(`print -Pn '\e]0;%…\a'`). fish_title parity.

### 7. History

`HISTSIZE` 5000 → 50000, `SAVEHIST` → 10000; all other history options
unchanged. Fish history is not converted (incompatible formats; start
fresh). Location stays `~/.local/share/zsh/.zsh_history`.

### 8. Deployment & the fate of ./sync

Rider change in `mise.toml`: skills ingestion
(`bin/dot-local/bin/dotfiles-sync-skills`) moves into a `pre-dotfiles` hook —
`mise dot apply` and `mise bootstrap` become fully self-sufficient. `./sync`
keeps working unchanged (its explicit ingest call simply becomes a harmless
re-run); retirement is a later, separate decision.

### 9. Files & rollout order

| File | Change |
|---|---|
| `zsh/dot-config/zsh/dot-zshrc` | rewritten per §§1–7 |
| `zsh/dot-config/zsh/abbreviations` | new — seeded abbreviation file |
| `starship/dot-config/starship.toml` | cross-reference comment only |
| `mise.toml` | pre-dotfiles hook (§8) |
| `README.md` | stack section: zsh is the shell (currently says bash — stale) |

Rollout: commit repo changes → `./sync` (deploys new abbreviations file) →
`zsh -ic` verification battery → user runs `chsh -s /bin/zsh` → real-world
use in new Ghostty tabs.

### 10. Verification

Non-interactive (`zsh -ic`):
- starship prompt function initialized; `prompt_hint` prints the legend
- `abbr list` shows ~55 user abbreviations; `gs`␣ visibly expands (manual)
- fnox env vars present; `mise doctor` clean; `fzf` key bindings installed
- `bindkey` output contains all four chords
- title updates on `cd` (check via `\e]0;` capture or Ghostty tab)
- `docker.lima`, `v`, `za`, `dotf` (global) resolve

Then: user switches via `chsh`, uses zsh normally for a trial period;
rollback documented in §1.

## Out of scope (queued follow-ups)

1. zinit plugin review (explicitly requested, after the port settles)
2. `zmx_select` → language-agnostic shared script + cmd+k binding
3. fish package retirement
4. `./sync` retirement / drift-report-as-task
