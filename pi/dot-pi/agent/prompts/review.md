Perform a code review. Load the `code-review` skill first.

**Scope:** {{scope}}

If no scope provided, review staged changes using `git diff --cached`.
If scope is "recent", review changes since last commit using `git diff HEAD~1`.
Otherwise, review the specified file(s) or directory.

Apply the 4 Review Layers:
1. **Correctness** — logic errors, edge cases, type safety
2. **Security** — secrets, injection, auth, input validation
3. **Performance** — N+1 queries, caching, re-renders, complexity
4. **Style** — conventions, DRY, complexity, test coverage

Classify findings by severity (Critical, Major, Minor, Nitpick).
Only report findings with >=80% confidence.
Include positive observations.
Provide Philosophy Compliance checklist results.
