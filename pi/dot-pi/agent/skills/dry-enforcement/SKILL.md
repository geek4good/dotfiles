---
description: Check for duplicated logic, inconsistent patterns, and DRY violations in code. Use when reviewing code for consistency, during refactoring, or when the reviewer or oracle flags potential duplication.
---

# DRY Enforcement Skill

## When to use

- Reviewing code for consistency before merging
- Refactoring to consolidate duplicated patterns
- When the reviewer or oracle flags potential duplication
- As a quality gate after multi-file changes

## What to check

### 1. Duplicated logic
Identical or near-identical code blocks appearing in multiple places. Look for:
- Same algorithm implemented in multiple files
- Similar validation or transformation functions
- Repeated error handling patterns
- Identical data parsing or formatting logic

### 2. Inconsistent patterns
Same concept implemented differently across the codebase:
- Different naming conventions for the same abstraction
- Mixed async/sync approaches for the same operation type
- Different error types or error handling strategies for similar failures
- Inconsistent import styles or module structures

### 3. Copy-paste with variations
Code that was clearly duplicated then modified:
- Similar functions differing only in constant values
- Nearly identical classes with minor behavioral differences
- Config objects that share most fields
- Test setups that repeat the same fixture creation

### 4. Repeated constants and configuration
Values that should be centralized:
- Magic numbers appearing in multiple files
- String literals (URLs, error messages, keys) repeated across the code
- Configuration values duplicated between files
- Environment variable names referenced in multiple places

### 5. Near-duplicate functions
Functions that do almost the same thing:
- Same function with different parameter names or types
- Wrappers that only add minor formatting
- Variants that could be unified with a parameter

## Process

1. **Scope** — identify the files or modules to check
2. **Read** — load the relevant code
3. **Compare** — look for the five patterns above
4. **Cite** — for each finding, provide exact file paths and line numbers
5. **Recommend** — suggest the canonical version or shared abstraction

## Output format

```markdown
## DRY Findings

### Finding 1: {title}
- **Type:** {duplicated logic | inconsistent pattern | copy-paste | repeated constant | near-duplicate}
- **Locations:**
  - `path/to/file1.ext:L10-L30`
  - `path/to/file2.ext:L45-L65`
- **Recommendation:** {specific fix}
- **Priority:** {high — different behavior risks bugs | medium — maintenance burden | low — cosmetic}

### Finding 2: ...
```

If no DRY issues are found, state: "No DRY violations found in the reviewed scope."
