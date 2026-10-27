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

## Infrastructure — Oracle Cloud (Singapore, Always Free)

All instances run in the Oracle Cloud home region (Singapore).
Arch: ARM (Ampere A1). Provisioned via Terraform + cloud-init.

### Instances

| Instance | OCPU | RAM | Boot disk | Role |
|---|---|---|---|---|
| `svc-01` | 2 | 12 GB | 110 GB | Uncloud control, tududi, umami, n8n |
| `svc-02` | 1 | 6 GB | 45 GB | Lightpanda CDP server |
| `svc-03` | 1 | 6 GB | 45 GB | Rails Icecast stats sampler |

**Total**: 4 OCPU / 24 GB RAM / 200 GB — within Always Free limits ✓

### Networking

Two WireGuard-based meshes, each serving a different purpose:

| Layer | Tool | Connects | Purpose |
|---|---|---|---|
| Device → infrastructure | Tailscale | MacBook ↔ all servers | SSH, Lightpanda CDP access from laptop, MagicDNS |
| Server → server | Uncloud mesh | Server ↔ server | Container networking, service discovery, cross-machine deploys |

**Why both**: Uncloud's mesh handles container-to-container traffic between cluster nodes. Tailscale handles device-to-infrastructure access (your MacBook isn't running Docker or the Uncloud daemon). Resource cost is minimal — ~50 MB RAM for Tailscale, ~150 MB for Uncloud per machine.

### Tailscale

Installed via cloud-init on every instance. Provides MagicDNS so services are reachable by hostname from any tailnet device.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey=<key>
```

### Lightpanda (svc-02)

Headless browser for AI agents. Runs as a systemd service, not through Docker — it's a single binary that doesn't need SSL, domains, or reverse proxying.

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

**Firewall**: Binds `0.0.0.0:9222` but access is restricted to Tailscale interface only.

**Known issue**: Oracle Cloud ARM instances use 64k page kernels. Lightpanda has an open issue ([#1370](https://github.com/lightpanda-io/browser/issues/1370)) crashing on 64k pages. Verify with `getconf PAGESIZE` after provisioning — may need a custom 4k-page kernel or a Lightpanda fix.

### Uncloud (svc-01, svc-02, svc-03)

[Uncloud](https://uncloud.run/) orchestrates Docker Compose apps across the three instances — zero-downtime deploys, service discovery, and cross-machine container networking via its built-in WireGuard mesh.

```bash
# On the first machine (becomes cluster seed)
uc machine init user@svc-01

# Add the other machines
uc machine add user@svc-02
uc machine add user@svc-03
```

**Why Uncloud over Coolify**: The workload spans 3 machines. Coolify is designed for single-server deployments. Uncloud treats multiple machines as one cluster with decentralized state — no single control plane to maintain.

### Terraform

All infrastructure is defined as code. Machines are cattle, not pets.

```
infra/
├── main.tf              # providers (oci, tailscale)
├── variables.tf         # compartment OCIDs, region, instance specs
├── oci-networking.tf    # VCN, subnets, gateways
├── oci-instances.tf     # 3 ARM instances with cloud-init
├── tailscale.tf         # auth keys, ACLs
├── cloud-init/
│   ├── svc-01.yaml      # Uncloud + Docker, tududi, umami, n8n
│   ├── svc-02.yaml      # Tailscale + Lightpanda
│   └── svc-03.yaml      # Tailscale + Rails Icecast sampler
├── terraform.tfvars     # secrets (gitignored)
└── .gitignore
```

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
