---
name: ghpmplus
description: Autonomous GitHub Project Management with orchestrator-agent coordination for parallel task execution via git worktrees, automated code review, and QA testing. Extends GHPM with autonomous end-to-end execution capabilities. Use when managing large multi-epic projects, parallel task execution, automated code review cycles, or QA testing with Playwright.
---

# GHPMplus — Autonomous GitHub Project Management

GHPMplus extends GHPM with autonomous execution. While GHPM requires manual step-by-step invocation, GHPMplus automates the entire workflow through a central orchestrator agent with integrated review cycles and QA.

## Structure

- `commands/` — Slash command definitions (create-prd, auto-execute, team-execute)
- `agents/` — Sub-agent definitions for autonomous execution
- `skills/` — Shared helper skills (worktree-helpers)
- `docs/` — Documentation (agent comment format)

## Commands

| Command | Description |
|---------|-------------|
| `/ghpmplus:create-prd` | Create a PRD with adaptive clarification |
| `/ghpmplus:auto-execute` | Autonomous execution for small-medium PRDs (1-2 epics) |
| `/ghpmplus:team-execute` | Agent team execution for large PRDs (3+ epics) |

## Agents

| Agent | Purpose |
|-------|---------|
| orchestrator | Central coordinator with state reconstruction |
| epic-creator | Creates Epic issues from PRD analysis |
| task-creator | Creates Task issues from Epic breakdown |
| task-executor | Executes tasks via TDD or non-TDD workflow |
| pr-review | Reviews PRs against Task specifications |
| conflict-resolver | Detects and resolves merge conflicts |
| review-cycle-coordinator | Orchestrates review-fix-review cycle |
| ci-check | Monitors CI status and handles failures |
| qa-planner | Creates QA issues and steps from PRD |
| qa-executor | Executes QA steps via Playwright automation |

## Key Features

- Parallel task execution via git worktrees
- Automated code review cycle (max 3 iterations)
- State reconstruction for workflow resume
- PAUSE/RESUME human intervention
- Circuit breaker failure recovery
- Idempotent operations for safe re-runs
