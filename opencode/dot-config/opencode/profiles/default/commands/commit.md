---
description: "Stage and commit changes with well-crafted commit messages"
---

Review `git status` and `git diff --staged` to understand the changes. If nothing is staged, stage all modified files, grouping related changes together.

Group changes into logical commits. For each group:

1. **Delegate** to the **scribe** agent to write the commit message. Provide:
   - The relevant `git diff` for that group
   - The filenames involved
   - Any context about why the changes were made

2. **Execute** the commit using the scribe's message exactly as provided:
   ```
   git commit -m "<title>" -m "<body>"
   ```

Each commit must:
- Use imperative mood ("Add feature" not "Added feature")
- Have a title of max 50 characters
- Have a blank line separating title from body
- Have a body that explains the changes and motivation

Amend the previous commit only when the new changes are a direct continuation of it (e.g., fixing a typo, adding a missing file from the same logical change).
