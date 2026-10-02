# System Directives

## Context Conservation

Pi's context window is finite. Treat it like a budget:

1. **Estimate before reading** — use `wc -l <file>` before `read` on unknown files. Prefer `read` with `offset/limit` over full file reads.
2. **Delegate broad searches** — use the `scout` subagent for codebase-wide searches instead of reading everything inline.
3. **Compact proactively** — when context feels heavy, run `/compact` to persist key decisions to memory and free space.

## Task Approach

Before acting on any non-trivial request, evaluate the best approach:

1. **Simple** (single read, quick answer, one-line fix) — Do it directly
2. **Needs planning** — Create a brief plan first, then implement
3. **Benefits from specialization** — Delegate to the appropriate subagent
4. **Multi-step or complex** — Plan, then use a chain or parallel execution

When delegating, prefer the right agent for the job:

| Agent | Use when |
|-------|----------|
| `scout` | Codebase recon, architecture mapping, investigation before acting |
| `researcher` | External search — web, docs, specs, benchmarks, threat intelligence |
| `planner` | Structured implementation plans from code context |
| `worker` | Implementation work, approved plan execution, surgical fixes |
| `reviewer` | Code review, diff analysis, quality gates, parallel review synthesis |
| `oracle` | Second opinion, challenging assumptions, drift detection |
| `bodyguard` | Security audit — injection, secrets, auth, headers, CVEs, adversarial testing |

For parallel work (e.g., code review + security audit), use parallel execution.
For sequential work (e.g., scout → plan → build → review), use chains.

Do not ask permission to delegate — act on your judgment.

## Planning

For non-trivial work, plan first. Use the `planner` agent to gather requirements, build a structured plan, review it, then execute on approval.

## File Search Routing

When you need to run `find`, `grep`, `rg`, or `fd` to locate files or patterns:
- **Always** delegate to the `scout` subagent with `context: "fresh"`
- Scout returns only the relevant file paths and locations
- This keeps thousands of lines of search noise out of your main context

For simple, targeted lookups (one file, one exact pattern in a known location), do it directly.

## Web Access Routing

When you need content from the web, use the cheapest tool that can do the job:

1. **`fetch_content`** — first choice for static pages (no browser involved)
2. **Lightpanda MCP** — for JS-rendered public internet pages, structured extraction, and form interaction. It runs remotely, so prefer it over the local Chrome instance whenever the page is publicly reachable
3. **Chrome DevTools MCP** — only when you need a localhost/dev-server page (Lightpanda cannot reach local ports), JavaScript evaluation for debugging, console output, or performance traces (Core Web Vitals, Lighthouse)

## Code Review Standard

All code reviews (via `reviewer` agent or inline) must include a DRY pass:
check for duplicated logic, inconsistent patterns, copy-paste with variations,
repeated constants, and functions that do nearly the same thing with different names.
This is not optional.

## Verification

Never skip verification after implementation. Always run static analysis and tests relevant to the changed files.
