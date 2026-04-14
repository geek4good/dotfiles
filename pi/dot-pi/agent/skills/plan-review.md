# Plan Review

> **Load this skill** when reviewing implementation plans (not code).

## TL;DR
Systematic plan review focused on 3 quality categories: Citation Quality, Completeness, and Actionability. Focus on whether the plan provides actionable implementation guidance.

## When to Use This Skill
- When reviewing implementation plans before execution
- When auditing plan quality after creation
- When verifying plans meet documentation standards

---

## Plan Review Checklist

### 1. Citation Quality

| Requirement | Check |
|-------------|-------|
| Decisions reference sources | Citations used for architectural decisions |
| No unsubstantiated claims | No "industry standard" without citation |
| Research phases show refs | Completed research tasks include citations |

**Red Flags:**
- Decisions table with empty or `-` in Source column
- Claims like "industry standard" or "best practice" without citation
- Research tasks marked complete without references

### 2. Completeness

| Requirement | Check |
|-------------|-------|
| Goal is specific | Measurable outcome, not vague intent |
| Phases are logical | Sequential, with clear progression |
| Edge cases considered | Error handling, failure modes addressed |
| Notes section present | Key decisions and observations documented |
| Context & Decisions table | Captures architectural choices with rationale |

**Goal Quality Examples:**
- Bad: "Improve authentication" (vague)
- Bad: "Make it better" (unmeasurable)
- Good: "Add JWT authentication with refresh token support" (specific)
- Good: "Migrate user table to PostgreSQL with zero downtime" (measurable)

### 3. Actionability

| Requirement | Check |
|-------------|-------|
| Tasks are specific | Clear what file/component is affected |
| No ambiguous tasks | Avoids "investigate" or "figure out" without scope |
| Dependencies clear | Sequential tasks show logical order |
| Implementation path obvious | Developer can start without clarification |

---

## Severity Classification

| Severity | Criteria | Action Required |
|----------|----------|-----------------|
| Critical | Missing citations for key decisions, no clear goal, unactionable tasks | Must fix before execution |
| Major | Vague tasks, incomplete phases, missing edge case handling | Should fix |
| Minor | Missing notes, unclear dependencies, incomplete rationale | Nice to fix |
| Nitpick | Style preferences, wording suggestions | Optional |

---

## Output Format

Structure your plan review as:

1. **Files Reviewed** - Plan document(s)
2. **Overall Assessment** - APPROVE | REQUEST_CHANGES | NEEDS_DISCUSSION
3. **Summary** - 2-3 sentence overview of plan quality
4. **Issues by Severity** - Critical, Major, Minor, Nitpick
5. **Quality Assessment Table** - Pass/Fail for each category
6. **Positive Observations** - What's done well (always include at least one)

## Adherence Checklist

Before completing a plan review, verify:
- [ ] All 3 quality categories analyzed (Citations, Completeness, Actionability)
- [ ] Severity assigned to each finding
- [ ] Specific locations noted for all issues
- [ ] Quality Assessment table completed
- [ ] Positive observations noted
