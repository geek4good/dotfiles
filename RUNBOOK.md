# RUNBOOK.md

Infrastructure decisions, service layout, and operational conventions for this setup.

## Workstation provisioning (this Mac)

The dotfiles repo is the machine definition, deployed by **mise** (see `mise.toml` at
the repo root). GNU Stow and the `_bootstrap` script were retired in Oct 2026.

| Concern | Tool | Command |
|---|---|---|
| Dotfile deployment | `mise dot` groups | `./sync` or `mise dot apply` |
| System packages (brew/brew-cask) | `[bootstrap.packages]` | `mise bootstrap packages apply` |
| Full machine setup | `mise bootstrap` | see below |
| Drift check (CI-able) | | `mise bootstrap status --missing` |
| Tool version updates | `tool_update.global_auto` | automatic (see notes below) |
| Cross-machine sync | launchd `dev.mise.dotfiles-sync` | automatic every 15 min (see notes below) |
| Homebrew CLI | kept as escape hatch | `brew list/upgrade` still work on mise-installed formulae |

**Fresh machine**: install mise (<https://mise.jdx.dev>), `git clone
git@github.com:geek4good/dotfiles.git ~/Projects/dotfiles`, then `cd ~/Projects/dotfiles
&& mise trust && mise bootstrap` (interactive terminal required once — it creates the
Touch-ID PAM file under `/etc/pam.d`). **Unattended/repeated runs**: add `--skip-dirty`
(the repo is often intentionally dirty; edits land in it through symlinks).

**Rollback to stow** (if ever needed): `brew install stow`, uncomment the stow flow
from git history (`git show 7afb063^:sync`), restore `.stow-local-ignore` and
`homebrew/dot-Brewfile` from `git show 078f7f1^`. mise links are stow-compatible
relative symlinks, so cutover back is mechanical.

### Package ownership notes

- Formulae installed by mise's brew manager are brew-compatible (visible to
  `brew list`); casks installed by the brew CLI stay brew-owned (mise leaves them
  alone). Ownership is per-package, not per-machine.
- `mise bootstrap packages prune --dry-run` is the explicit cleanup (like
  `brew bundle cleanup`) — never run it blind.
- mise itself lives in `~/.local/bin/mise` (official release tarball), updated via
  `mise self-update`. It is deliberately NOT a brew formula or `[tools]` entry.
  Shell activation: fish uses the explicit path in `config.fish` (PATH-lookup
  is fragile — brew shellenv prepends `/opt/homebrew/bin`); bash resolves via
  PATH; zsh installs its own copy via zinit from GitHub Releases.

### Tool version doctrine (2026-10-27)

`tool_update.global_auto = true` in the global config: every global tool
auto-updates **within its declared range** — shims/`mise exec` upgrade before
running (background at the prompt in activated shells). Supply-chain gated by
the default `minimum_release_age` (24h); superseded versions auto-prune after
24h (`upgrade.prune_after`). Failures surface in `mise doctor`.

- **Runtimes are range-bound** (`python = "3.14"`, `ruby = "4.0"`, `go = "1.26"`,
  `zig = "0.16"`, `node = "26"`) so auto-updates never major-jump. Leaf CLIs
  (gh, pnpm, uv, yarn, …) ride `latest`.
- **`terraform` is exact-pinned** — bump deliberately; its failure mode is the
  infra repo. (Exact pins are the opt-out: they never auto-update.)
- **One owner per tool**: `gh`, `pipx`, `elm` live in `[tools]` (mise wins on
  PATH; their `brew:` entries were removed). `pocketbase` is brew-only (the
  dead `npm:pocketbase` pin was removed).
- **pi is single-homed as the `npm:@earendil-works/pi-coding-agent` tool.**
  Never `npm i -g` it under the active node — that copy shadows the mise shim
  and goes stale (it silently broke both error-cause patchers once). If pi
  vanishes after a node bump, check the shim: `mise exec -- pi --version`.
- **age is deliberately dual-present**: mise keeps an internal `age@latest`
  (its encryption integration; see the `age.strict` setting) and `brew:age`
  serves the shell. They coexist — don't prune-battle the mise one.
- `mise upgrade` is now a one-shot catch-up, not a routine: the steady state
  is automatic. `mise outdated` still shows what a catch-up would do.

### Cross-machine dotfiles sync (2026-10-27)

The launchd agent `dev.mise.dotfiles-sync` (declared in `[bootstrap.macos.launchd.agents]`,
script `~/.local/bin/dotfiles-auto-sync`, every 15 min) keeps every Mac
converged on `origin/main`:

1. **Commit** local drift (edits that landed in the worktree through
   symlinks; `.gitignore` filters junk) as `auto(sync): <host> <ts>`
2. **Fetch** — offline cycles skip quietly
3. **Rebase --autostash** onto `origin/main` — on conflict: abort, log,
   desktop notification, skip the cycle (never destructive)
4. **Push** if ahead
5. **`mise dot apply`** to converge this machine (pre/post-dotfiles hooks run,
   same as `./sync`)

Log: `~/Library/Logs/dotfiles-sync.log`. Fresh machines still go through
`mise bootstrap`; this loop is for steady-state convergence only. The script
prepends `/opt/homebrew/bin` to PATH (launchd PATH is minimal; git needs gpg
for signing and ssh for the remote). Manual equivalent: `./sync` for the
drift report, or run the script directly to force a cycle.

Conflicts are rare (two machines editing the same file within 15 min); resolve
manually in the repo and the next cycle resumes automatically.

## Infrastructure — Oracle Cloud

Not tracked here. The source of truth for the server fleet (instances,
networking, services, ops conventions) is `~/Projects/infra/AGENTS.md` —
that repo is the infra definition. This RUNBOOK covers the workstation only.

---

## Secret management

Secrets are encrypted with [age](https://github.com/FiloSottile/age) and managed by [fnox](https://github.com/jdx/fnox).

### How it works

1. An age identity is derived from the SSH ed25519 private key (`ssh-to-age`) and stored at `~/.config/fnox/age.txt` (gitignored).
2. Fnox encrypts secrets with age and stores them in `~/.config/fnox/config.toml` (also gitignored).
3. `.bashrc` runs `eval "$(fnox activate bash)"`, which decrypts and exports secrets as environment variables.
4. Tools pick up keys from the environment (e.g. `GEMINI_API_KEY`, `ZAI_API_KEY`).

### Adding a new secret

```bash
fnox set SECRET_NAME "secret_value"
```

This encrypts and stores it. It will be available as `$SECRET_NAME` in new shell sessions.

### Secrets in the repo

The `secrets/encrypted/` directory contains `*.age` files (GPG keys, Cloudflare tunnel creds) that are decrypted by `_bootstrap` using the SSH key directly (not fnox). These never appear as plaintext in git.

---

## AI agents

### Pi (coding agent)

Config: `pi/dot-pi/agent/` (stowed to `~/.pi/agent/`).

| File | Purpose |
|---|---|
| `settings.json` | Default model, packages, compaction settings |
| `models.json` | Custom provider/model definitions |
| `mcp.json` | MCP servers (Lightpanda via chrome-devtools-mcp) |
| `SYSTEM.md` | System prompt |
| `agents/` | Sub-agent definitions |
| `skills/` | Installed skills |

#### Web access stack

Pi has two complementary web capabilities — they serve different purposes and both are needed:

| Package | Provides | Mechanism |
|---|---|---|
| `pi-web-access` | Search (`web_search`, `code_search`), content extraction (`fetch_content`) | Exa MCP → Gemini API → Gemini Web (fallback chain). Picks up `GEMINI_API_KEY` from env via fnox. |
| `pi-mcp-adapter` + chrome-devtools-mcp | Interactive browsing (click, fill forms, screenshots, JS execution) | Connects to Lightpanda on `svc-02:9222` via Tailscale |

**Why both**: pi-web-access is "search and read" (fast, structured, citation-backed). Lightpanda is "browse and interact" (dynamic pages, forms, visual inspection).

---

## Terminal (Ghostty)

Config: `ghostty/dot-config/ghostty/config`.

### Keybindings

| Action | Keybind | Notes |
|---|---|---|
| Create split left/down/up/right | `ctrl+space` → `h/j/k/l` | Leader prefix |
| Zoom split | `ctrl+space` → `z` | Leader prefix |
| Navigate split left/down/up/right | `ctrl+h/j/k/l` | Consumes ctrl+h (backspace), ctrl+l (clear screen) |
| Clear screen (remap) | `ctrl+shift+l` | Replaces native ctrl+l; works in Herdr too |
| Previous/next tab | `ctrl+alt+h/l` | vim-style |
| Tab 1–9 | `cmd+1–9` | Native Ghostty |
| Session picker (zmx) | `cmd+k` | Sends escape sequence to fish |

---

## Shell (fish)

Config: `fish/dot-config/fish/`.

- zmx for persistent sessions (autostarts via `conf.d/10-zmx.fish`)
- fzf for fuzzy finding
- Abbreviations: `za` (zmx attach), `zk` (zmx kill), `zl` (zmx list), `zr` (zmx run), `rf` (reload config)

---

## Bootstrap

`_bootstrap` (`bin/dot-local/bin/_bootstrap`) handles a fresh machine setup:

1. Homebrew + essential packages (including `age`, `fnox`, `mise`)
2. Clone dotfiles repo
3. Stow all packages via `./sync`
4. Brew bundle from `~/Brewfile`
5. Touch ID for sudo (macOS)
6. `mise install` for language runtimes and tools
7. Derive age identity from SSH key
8. Decrypt and provision GPG keys and Cloudflare tunnel creds

---

## Network diagram

```
┌─────────────────────────────────────────────────────────────┐
│  MacBook (macOS, Thailand)                                  │
│                                                             │
│  Ghostty → fish → zmx sessions                              │
│  Pi agent ──→ pi-web-access (Exa/Gemini API)                │
│           └─→ pi-mcp-adapter                                │
│                └─→ chrome-devtools-mcp ──→ svc-02:9222      │
│                                                             │
│  Tailscale ─────────────────────────────────────────────    │
│                      WireGuard (Tailscale)                  │
│                      MagicDNS                               │
└──────────────────────────┬──────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  svc-01         │ │  svc-02         │ │  svc-03         │
│  2 OCPU / 12 GB │ │  1 OCPU / 6 GB  │ │  1 OCPU / 6 GB  │
│  110 GB disk    │ │  45 GB disk     │ │  45 GB disk     │
│                 │ │                 │ │                 │
│  Tailscale      │ │  Tailscale      │ │  Tailscale      │
│  Uncloud daemon │ │  Uncloud daemon │ │  Uncloud daemon │
│  tududi         │ │  Lightpanda :9222│ │  Rails sampler  │
│  umami          │ │                 │ │                 │
│  n8n            │ │                 │ │                 │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                   │
         └───────────────────┴───────────────────┘
                 Uncloud WireGuard mesh
                 (container networking,
                  service discovery)
```
