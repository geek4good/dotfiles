# RUNBOOK.md

Infrastructure decisions, service layout, and operational conventions for this setup.

## VPS (silo)

Hostname on Tailscale: `silo` (resolves via MagicDNS).
OS: Ubuntu aarch64.

### Services

| Service | Role | Runs as | Port | Notes |
|---|---|---|---|---|
| Coolify | PaaS for web apps | Docker | 80/443 | Handles domains, SSL, reverse proxying |
| Lightpanda | Headless browser for AI agents | systemd | 9222 | CDP WebSocket server, 16× less RAM than Chrome |
| Tailscale | Private networking | systemd | — | WireGuard-based; `silo` reachable from all tailnet devices |

### Lightpanda

Installed as a static binary at `/usr/local/bin/lightpanda`, managed by systemd.

```bash
# Install
curl -L -o /usr/local/bin/lightpanda \
  https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-aarch64-linux
chmod +x /usr/local/bin/lightpanda
```

```ini
# /etc/systemd/system/lightpanda.service
[Unit]
Description=Lightpanda headless browser CDP server
After=network.target tailscaled.service
Requires=tailscaled.service

[Service]
ExecStart=/usr/local/bin/lightpanda serve --host 0.0.0.0 --port 9222 --obey-robots
Restart=on-failure
RestartSec=5
Environment=LIGHTPANDA_DISABLE_TELEMETRY=true

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now lightpanda
```

**Why bare metal, not Coolify**: Lightpanda is a single binary exposing a WebSocket. It doesn't need SSL, domains, or reverse proxying — Coolify's strengths. Running it through Docker would add a networking layer for zero benefit.

**Firewall**: Binds `0.0.0.0:9222` but access is restricted to Tailscale:

```bash
sudo ufw allow in on tailscale0 to any port 9222
sudo ufw deny 9222/tcp
```

### Tailscale

Installed via the official one-liner (detects architecture automatically):

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Provides a private network between all joined devices. Services are reached by MagicDNS hostname (e.g. `silo:9222`) — no SSH tunnels, no hardcoded IPs.

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
| `pi-mcp-adapter` + chrome-devtools-mcp | Interactive browsing (click, fill forms, screenshots, JS execution) | Connects to Lightpanda on `silo:9222` via Tailscale |

**Why both**: pi-web-access is "search and read" (fast, structured, citation-backed). Lightpanda is "browse and interact" (dynamic pages, forms, visual inspection).

### Claude Code

Config: `claude/dot-claude/` (stowed to `~/.claude/`).

Shared skills live at `claude/dot-claude/skills/`. Plugin marketplace at `claude/dot-config/claude-plugins/`.

---

## Terminal (Ghostty)

Config: `ghostty/dot-config/ghostty/config`.

### Keybindings

| Action | Keybind | Notes |
|---|---|---|
| Create split left/down/up/right | `ctrl+space` → `h/j/k/l` | Leader prefix |
| Zoom split | `ctrl+space` → `z` | Leader prefix |
| Navigate split left/down/up/right | `ctrl+h/j/k/l` | Consumes ctrl+h (backspace), ctrl+l (clear screen) |
| Clear screen (remap) | `ctrl+shift+l` | Replaces native ctrl+l |
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
┌─────────────────────────────────────────────────────┐
│  MacBook (macOS)                                    │
│                                                     │
│  Ghostty → fish → zmx sessions                      │
│  Pi agent ──→ pi-web-access (Exa/Gemini API)        │
│           └─→ pi-mcp-adapter                        │
│                └─→ chrome-devtools-mcp               │
│                     │                                │
│  Tailscale ─────────┼───────────────────────────    │
│                     │                                │
└─────────────────────┼───────────────────────────────┘
                      │  WireGuard (Tailscale)
                      │  MagicDNS: silo
┌─────────────────────┼───────────────────────────────┐
│  VPS — silo (Ubuntu aarch64)                        │
│                     │                                │
│  Tailscale ◄────────┘                               │
│  UFW: 9222 only on tailscale0                       │
│                                                     │
│  Lightpanda :9222 (CDP WebSocket)                   │
│  Coolify :80/443 (web apps)                         │
└─────────────────────────────────────────────────────┘
```
