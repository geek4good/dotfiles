# Pi Coding Agent — System Specification

> Generated: 2026-06-03  
> Version: 0.78.0  
> Model: opencode / claude-sonnet-4-6 / thinking: high

---

## Architecture

```
~/.pi/agent/                          ← Pi config directory
├── settings.json → dotfiles          ← Core config (provider, model, thinking)
├── models.json   → dotfiles          ← Custom providers
├── mcp.json      → dotfiles          ← MCP server definitions
├── AGENTS.md     → dotfiles          ← Agent guidelines
├── SYSTEM.md     → dotfiles          ← System prompt
├── keybindings.json                 ← Custom keyboard shortcuts
├── auth.json                         ← OAuth tokens
├── prompts/      → dotfiles          ← 19 prompt templates (.md files)
├── skills/       → dotfiles          ← 15 skill definitions
├── agents/       → dotfiles          ← 10 agent profiles
├── extensions/   → dotfiles          ← 4 local extensions (.ts files)
├── agents/                           ← Local agent definitions
├── sessions/                         ← 104 saved sessions
├── npm/                              ← npm-installed packages
├── git/                              ← git-installed packages
└── .backup/                          ← Pre-symlink backup (delete me)
```

All dotfiles-managed items are symlinked from `~/Projects/dotfiles/pi/dot-pi/agent/`.

---

## Extensions (113 total)

### Core Packages
| Package | Source | Contents |
|---|---|---|
| **agent-pi** | `git:github.com/ruizrica/agent-pi` | 107 extensions (banner, chain, team, board, cleanup, MCP, security, etc.) |
| **pi-web-access** | npm | Web search, URL fetch, GitHub clone, PDF, code search |
| **pi-mcp-adapter** | npm | MCP server bridge |

### Local Extensions (4)
| Extension | File | Tools Registered |
|---|---|---|
| agent-memory | `agent-memory.ts` | `agent_memory_search`, `agent_memory_code_nav` |
| agent-viewer | `agent-viewer.ts` | `agent_viewer_plan`, `agent_viewer_spec` |
| complexity-heatmap | `complexity-heatmap.ts` | `/heatmap` command |
| stable-checkpoint | `stable-checkpoint.ts` | `/stable` command |

---

## Prompt Templates (19)

All templates are `.md` files with YAML frontmatter. Invoked via `/name`.

### Planning & Spec
| Template | Description |
|---|---|
| `/agent-plan` | Interactive plan builder with browser review gate |
| `/agent-spec` | Spec-driven development: requirements → tasks |
| `/kiro` | Kiro methodology: spec → design → build (Cursor integration) |

### Multi-Agent
| Template | Description |
|---|---|
| `/team` | Multi-agent parallel implementation |
| `/haiku` | Spawn team of 10 agents |

### Documentation
| Template | Description |
|---|---|
| `/handbook` | Generate comprehensive project handbook |
| `/code2course` | Turn codebase into interactive HTML course |
| `/design` | Interactive design system generator (CSS/Tailwind/SCSS) |

### Session Management
| Template | Description |
|---|---|
| `/save` | Save work: commit changes, merge to main, cleanup |
| `/restore` | Restore session from daily logs |
| `/compact` | Memory-aware session compaction |
| `/compact-min` | Ultra-minimal session snapshot |
| `/stable` | Create stable git checkpoint with documentation |
| `/worktree` | Create isolated development worktree |

### Implementation
| Template | Description |
|---|---|
| `/@implement` | Convert @implement comments to documentation |
| `/agent-memory` | Search/manage agent memories |
| `/commit` | Smart conventional commit |
| `/review` | Code review checklist |
| `/setup` | Initialize project: CLI, memory, hooks |

---

## Skills (15)

Skills are located in `~/.pi/agent/skills/` (symlinked to dotfiles).

| Skill | Type |
|---|---|
| `agent-memory` | Tool usage guide |
| `agent-viewer` | Tool usage guide |
| `autoresearch` | Research automation |
| `brainstorming` | Ideation method |
| `codebase-to-course` | Documentation generation |
| `context-mode` | Context mode documentation |
| `copywriting` | UX copy guidelines |
| `frontend-design` | UI/UX patterns |
| `receiving-code-review` | Code review process |
| `skill-creator` | Meta — skill creation |
| `systematic-debugging` | Debugging methodology |
| `test-driven-development` | TDD methodology |
| `verification-before-completion` | Quality assurance |

---

## Agent Profiles (10)

Located in `~/.pi/agent/agents/` (symlinked to dotfiles).

| Agent | Role |
|---|---|
| `coder-jun` | Routine implementation |
| `coder-sen` | Complex algorithms, architecture |
| `explorer` | Read-only codebase navigation |
| `researcher` | Web search, documentation |
| `scribe` | Documentation, prose |
| `codex-agent` | OpenAI Codex CLI integration |
| `cursor-agent` | Cursor CLI integration |
| `droid-agent` | Factory Droid CLI integration |
| `gemini-agent` | Gemini 1M token context |
| `opencode-agent` | OpenRouter 75+ models |

Plus 6 built-in Pi specialists: scout, builder, reviewer, planner, tester, red-team.

---

## MCP Servers

### chrome-devtools (29 tools)
- Command: `npx -y chrome-devtools-mcp@latest --browserUrl http://silo:9222`
- Provides: screenshot, navigate, click, fill, console, network, Lighthouse, performance
- **Requires:** Chrome/Lightpanda on port 9222

---

## Config (settings.json)

```json
{
  "defaultProvider": "opencode",
  "defaultModel": "claude-sonnet-4-6",
  "defaultThinkingLevel": "high",
  "defaultModelTemperature": 0,
  "quietStartup": true,
  "theme": "midnight-ocean",
  "compaction": { "enabled": true, "reserveTokens": 16384, "keepRecentTokens": 20000 },
  "retry": { "enabled": true, "maxRetries": 3, "baseDelayMs": 2000 }
}
```

### Providers (models.json)
- `zai-coding-plan` — GLM 5.x models
- `opencode-go` — DeepSeek, Claude via OpenCode Go
- `opencode-go-anthropic` — MiniMax models via Anthropic API

---

## CLI Tools

| Tool | Source | Purpose |
|---|---|---|
| **agent-memory** | `pip3 install ~/.pi/bin/agent-memory` | Hybrid (vector+BM25) search over memory files |
| **agent-viewer** | `npm install -g ~/.pi/bin/agent-viewer` | Browser-based plan/spec/completion review |
| **hermes** | `~/.hermes/hermes-agent/` | AI agent framework |
| **pi** | mise | Primary coding agent |
| **claude** | mise | Anthropic Claude Code CLI |

---

## Memory System

### Architecture
```
agent-memory → SQLite DB (~/.context/memory.db)
  ├── sqlite-vec    → Vector similarity search
  ├── FTS5          → BM25 keyword search
  └── FastEmbed     → Local embedding model (all-MiniLM-L6-v2, 67MB)
```

### Data Sources
| Source | Path Pattern |
|---|---|
| Daily logs | `<cwd>/.context/daily-logs/*.md` |
| Session snapshots | `<cwd>/.context/sessions/*.md` |
| Project memory | `<cwd>/.context/projects/*/memory/MEMORY.md` |

### Current State
- 276 chunks across 16 files
- 104 Pi sessions summarized across 22 projects
- DB: `~/Projects/dotfiles/.context/memory.db`

### Commands
```bash
agent-memory index                              # Index all memory files
agent-memory search "query"                     # Hybrid search
agent-memory search "query" --vector            # Semantic only
agent-memory search "query" --keyword           # Keyword only
agent-memory code-index ./src                   # Index codebase for nav
agent-memory code-nav "function name"           # Navigate code tree
agent-memory add "memory text" --source "proj"  # Add manual memory
```

---

## Morning Ritual

```bash
morning       # Full launch: checks → Chrome → memory → Pi
morning -q    # Quick check only
```

### What it does
1. Checks brew & mise for outdated packages
2. Confirms Pi version
3. Starts Chrome with DevTools on port 9222 (if not running)
4. Confirms memory DB health
5. Shows yesterday's Pi sessions
6. Launches Pi in `~/Projects/dotfiles`

---

## Project Contexts

### Active Projects (with .pi/ + .context/)
| Project | Type | Sessions | Key Features |
|---|---|---|---|
| **dotfiles** | config | 30 | Pi setup, extensions, prompts |
| **pocrocket** | Astro/Cloudflare | 15 | SaaS landing page, Creem payments |
| **surf-radio** | Rails/Docker | 3 | Radio analytics dashboard, Phlex SVG |
| **geek4good** | Ruby/Docker | 13 | Personal site |
| **job-hunt** | Go/Ruby | 13 | Job search tools |
| **infra** | Terraform | 2 | Infrastructure config |

---

## Workflows

### Spec-Driven Development
```
/agent-plan "Feature idea"
  → Q&A to gather details
  → agent-viewer opens for review
  → Execute on approval
```

### Multi-Agent Dispatch
```
/team "Task description"
  → Spawns parallel specialists
  → Merges results with dashboard
```

### Session Management
```
/save "commit message"     → Commit, merge, cleanup
/compact                   → Summarize, persist to memory
/stable                    → Tagged git checkpoint + docs
```

### Code Quality
```
/heatmap                   → Complexity visualization (browser)
/agent-memory search "..." → Search past decisions
agent-memory code-nav "fn" → Navigate code structure
```

---

## Maintenance

### Daily
```bash
morning            # Full launch
```

### Weekly
```bash
mise upgrade       # Update all tools
pi update          # Update Pi + packages
brew upgrade       # Update system packages
agent-memory index # Re-index memories
```

### On Session Start
```bash
/reload            # Pick up new extensions/skills/prompts
```

---

## Known Issues & TODO

| Item | Priority | Status |
|---|---|---|
| Delete deprecated dirs (`commands/`, `scripts/`, `templates/`, `.backup/`) | 🔴 | Manual (security guard blocks) |
| Start Chrome on :9222 for MCP | 🔴 | Manual |
| surf-radio deploy | 🟡 | Needs Docker host |
| pocrocket migration deploy | 🟡 | Run `wrangler d1 execute --remote` |
| Creem payment integration | 🟡 | Blocked — needs Creem account |
| agent-memory code-index broken | 🟢 | Python 3.14 + tree-sitter bytes/str bug |
| Commander MCP offline | 🟢 | Needs Commander service |
| pocrocket local D1 seeding | 🟢 | Empty DB causes dev server crash |
