---
description: "Plan → Build → Review: structured execution pipeline for clear requirements"
argument-hint: "[task description]"
---

# Task — Plan → Build → Review Pipeline

Execute a plan-build-review cycle for: $ARGUMENTS

You are running a three-phase pipeline. Each phase delegates to a subagent with isolated context. Do not implement anything yourself — you are the orchestrator.

## Phase 1: Plan

Delegate to the `planner` agent with `context: "fork"`.
Provide the task description plus any relevant codebase context you already have.
Wait for the planner to return a structured implementation plan.

After the planner returns, present the plan to the user and wait for approval.
- If the user approves → proceed to Phase 2
- If the user requests changes → incorporate them, then re-present
- Do not proceed without explicit approval

## Phase 2: Build

Delegate to the `worker` agent with `context: "fork"`.
Provide the approved plan as the task.
The worker implements all changes.

After the worker returns, collect the summary of changes made.

## Phase 3: Review

Delegate to the `reviewer` agent with `context: "fork"`.
Provide:
1. The approved plan (from Phase 1)
2. The worker's summary of changes (from Phase 2)
3. A diff of all changes — run `git diff` to capture this

The reviewer checks correctness, security, performance, style, and DRY compliance.

## Phase 4: Report

Synthesize all three phases into a single report:

```markdown
## Task: {original task}

### Plan
{brief summary of the approved plan}

### Changes Made
- `path/to/file1`: {what changed}
- `path/to/file2`: {what changed}

### Review Findings
- ✅ {what passed}
- ⚠️ {issues or notes from reviewer}
- 🔴 {blockers, if any}

### Verification
- Lint: {status}
- Types: {status}
- Tests: {status}
```

Present this to the user. If the reviewer found blockers, ask the user whether to fix them (re-enter Phase 2 with a targeted fix task) or accept as-is.

## Rules

1. **Never implement directly** — always delegate to the appropriate subagent
2. **Never skip the approval gate** — the plan must be approved before building
3. **Never skip the review** — even for small tasks, the reviewer must run
4. **Always capture the diff** — the reviewer needs to see what actually changed
5. **If a phase fails**, report the failure clearly and ask the user how to proceed

Begin now by reading any immediately relevant context, then start Phase 1.
