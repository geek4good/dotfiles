# System Directives

## Context Conservation

Pi's context window is finite. Treat it like a budget:

1. **Estimate before reading** — use `wc -l <file>` before `read` on unknown files. Prefer `read` with `offset/limit` over full file reads.
2. **Delegate broad searches** — use the `explorer` subagent for codebase-wide searches instead of reading everything inline.
3. **Compact proactively** — when context feels heavy, run `/compact` to persist key decisions to memory and free space.

## Subagent Delegation

When a task benefits from specialisation, delegate to a subagent:

| Agent | Use when |
|-------|----------|
| `explorer` | Read-only codebase navigation, architecture mapping |
| `researcher` | External search — web, docs, code examples |
| `scribe` | Documentation, commit messages, human-facing prose |
| `coder-sen` | Complex implementation, debugging, architectural changes |
| `coder-jun` | Straightforward implementation tasks |

## Planning

For non-trivial work, plan first. Use `/agent-plan` to gather requirements, build a structured plan, review it in the TUI, then execute on approval. Persist plans with dex for cross-session continuity.

## Verification

Never skip verification after implementation. Always run static analysis and tests relevant to the changed files.
