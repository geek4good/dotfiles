---
name: plan-protocol
description: Guidelines for creating and managing structured implementation plans with phased tasks, citations, and progress tracking. Use when starting multi-step implementations.
---

# Plan Protocol

> **Load this skill** when creating or updating implementation plans.

## TL;DR Checklist

When creating or updating a plan, ensure:

- [ ] YAML frontmatter with `status`, `phase`, `updated`
- [ ] `## Goal` section (one sentence)
- [ ] `## Context & Decisions` table with citations
- [ ] Phases with status markers: `[COMPLETE]`, `[IN PROGRESS]`, `[PENDING]`
- [ ] Tasks with hierarchical numbering (1.1, 1.2, 2.1)
- [ ] Only ONE task marked `<- CURRENT`
- [ ] Citations for all research-based decisions

---

## When to Use

1. Starting a multi-step implementation
2. After receiving a complex user request
3. When tracking progress across phases
4. After research that informs architectural decisions

## When NOT to Use

1. Simple one-off tasks
2. Pure research/exploration
3. Quick fixes that don't need tracking
4. Single-file changes with no dependencies

---

## Plan Format

```markdown
---
status: STATUS
phase: PHASE_NUMBER
updated: YYYY-MM-DD
---

# Implementation Plan

## Goal
ONE_SENTENCE_DESCRIBING_OUTCOME

## Context & Decisions
| Decision | Rationale | Source |
|----------|-----------|--------|
| CHOICE | WHY | ref:SOURCE |

## Phase 1: NAME [STATUS_MARKER]
- [x] 1.1 Completed task
- [x] 1.2 Another completed task

## Phase 2: NAME [IN PROGRESS]
- [x] 2.1 Completed task
- [ ] **2.2 Current task** <- CURRENT
- [ ] 2.3 Pending task

## Phase 3: NAME [PENDING]
- [ ] 3.1 Future task
- [ ] 3.2 Another future task

## Notes
- YYYY-MM-DD: Observation or decision
```

### Frontmatter Fields

| Field | Values | Description |
|-------|--------|-------------|
| `status` | `not-started`, `in-progress`, `complete`, `blocked` | Overall plan status |
| `phase` | Number (1, 2, 3...) | Current phase number |
| `updated` | `YYYY-MM-DD` | Last update date |

### Phase Status Markers

| Marker | Meaning |
|--------|---------|
| `[PENDING]` | Not yet started |
| `[IN PROGRESS]` | Currently being worked on |
| `[COMPLETE]` | Finished successfully |
| `[BLOCKED]` | Waiting on dependencies |

---

## Critical Rules

1. **Only ONE phase** may be `[IN PROGRESS]` at any time
2. **Only ONE task** may have `<- CURRENT` marker at any time
3. **Move `<- CURRENT`** immediately when starting a new task
4. **Mark tasks `[x]`** immediately after completing them
