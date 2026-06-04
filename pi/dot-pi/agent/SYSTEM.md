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
| `researcher` | External search — web, docs, specs, benchmarks |
| `planner` | Structured implementation plans from code context |
| `worker` | Implementation work, approved plan execution |
| `reviewer` | Code review after implementation, diff analysis |
| `oracle` | Second opinion, challenging assumptions, risky decisions |
| `knight` | Security vulnerability review — injection, secrets, auth bypass |
| `red-team` | Adversarial testing, finding failure modes |
| `web-security-scanner` | HTTP headers, SSL/TLS, CORS, CSP, dependency CVEs |
| `perf-auditor` | Lighthouse audits, Core Web Vitals, network waterfalls |
| `warden` | Quality gate synthesis — coordinates findings from multiple agents |
| `paladin` | Surgical remediation — fixes what other agents find |
| `ranger` | DRY enforcement, pattern consistency |
| `tester` | Test creation and validation |
| `network-scout` | Passive network recon, interface and listener analysis |
| `port-scan-analyst` | Safe local port analysis |
| `security-news-analyst` | Threat intelligence from CISA, NVD, OWASP |

For parallel work (e.g., code review + security audit), use parallel execution.
For sequential work (e.g., scout → plan → build → review), use chains.

Do not ask permission to delegate — act on your judgment.

## Planning

For non-trivial work, plan first. Use the `planner` agent to gather requirements, build a structured plan, review it, then execute on approval.

## Verification

Never skip verification after implementation. Always run static analysis and tests relevant to the changed files.
