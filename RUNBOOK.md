# RUNBOOK.md

Infrastructure decisions, service layout, and operational conventions for this setup.

## Workstation provisioning (this Mac)

**Nov 2026 — Model B (track + origin sync).** Dotfiles are real files, tracked
in place by `mise dot`; the watcher checkpoints every edit and syncs with the
private origin `setup.git`. All Macs converge through the history, not through
this repo. The repo keeps machine declarations (`mise.toml`: packages, tools,
LaunchAgents, hooks, bootstrap task) + pi skills + the pre-track archive
(`zsh/`, `fish/`, ...). Fresh machine: install mise, then
`mise bootstrap --adopt geek4good/setup` (see README for the declarations caveat).

| Concern | Tool | Command |
|---|---|---|
| Dotfiles + cross-machine sync | mise history + origin | automatic (watcher); `mise dot sync` to flush |
| System packages (brew/brew-cask) | `[bootstrap.packages]` | `mise bootstrap packages apply` |
| Full machine setup | `mise bootstrap` | |
| Drift check (CI-able) | | `mise bootstrap status --missing` |
| History: undo/rollback | | `mise dot undo` / `mise dot rollback` |

mise itself lives in `~/.local/bin/mise` (official release), `mise self-update`.

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
