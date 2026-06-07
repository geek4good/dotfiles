---
description: "Code review via reviewer agent"
argument-hint: "[scope: staged | recent | file/path]"
---

Delegate a code review to the `reviewer` agent.

**Scope:** $ARGUMENTS

If no arguments: review staged changes via `git diff --cached`.
If "recent": review changes since last commit via `git diff HEAD~1`.
Otherwise: review the specified file(s) or directory.

Capture the relevant diff first, then delegate to the `reviewer` agent with `context: "fork"`.
Pass the scope and diff. The reviewer will check correctness, security, performance, style, and DRY compliance.
Return the reviewer's findings to the user.
