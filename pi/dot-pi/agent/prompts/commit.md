Review `git status` and `git diff --staged` to understand the changes. If nothing is staged, stage all modified files, grouping related changes together.

Group changes into logical commits. For each group:

1. Stage the relevant files
2. Write a commit message following these rules:
   - Imperative mood ("Add feature" not "Added feature")
   - Title of max 50 characters
   - Blank line separating title from body
   - Body explains the changes and motivation (the *why*, not the *what*)
3. Execute the commit:
   ```
   git commit -m "<title>" -m "<body>"
   ```

Amend the previous commit only when the new changes are a direct continuation of it (e.g., fixing a typo, adding a missing file from the same logical change).
