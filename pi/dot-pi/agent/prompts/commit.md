---
description: "Stage and commit changes in logical groups"
argument-hint: "[optional: message or scope hint]"
allowed-tools: ["Bash", "Read"]
---

Stage and commit the current changes in logical groups.

## Phase 1: Reconnaissance

Run these commands to understand the full picture:
1. `git status` — modified/untracked files
2. `git diff --stat` — overview of unstaged changes
3. `git diff --staged --stat` — overview of already staged changes
4. `git log --oneline -5` — recent context for amend decisions

If nothing is staged and nothing is modified, report "Nothing to commit" and stop.

## Phase 2: Safety Check

Before staging anything, verify:
- No files matching `*.pem`, `*.key`, `*.env`, `id_rsa*`, or containing secrets
- No large binary files (>1 MB)
- No files in `.gitignore` that somehow appear

If you find any, exclude them and warn the user.

## Phase 3: Group & Stage

If nothing is staged, group unstaged changes by logical concern. Use
`git diff -- <file>` to inspect each file before grouping.

Stage each group separately:
```
git add <files for group 1>
```

## Phase 4: Commit

For each staged group, create a commit:

```
git commit -m "<title>" -m "<body>"
```

### Title Rules
- Imperative mood ("Add feature" not "Added feature")
- Conventional type prefix: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `build`
- Max 50 characters total (including prefix)
- Lowercase after the prefix

### Body Rules
- Separate from title with a blank line
- Explain the *why*, not the *what*
- Wrap at 72 characters

### Amend Rule
Only `git commit --amend` when ALL of these are true:
1. The last commit is unpushed (`git log -1 --oneline` matches the branch tip)
2. The new changes are within the same scope/files as that commit
3. It's a fixup (typo, missing file, small correction)

Never amend if the last commit is from another author or a merge commit.

## Phase 5: Dex Integration (Optional)

If there is an active dex task in the current project:
1. Run `dex status` to check for active tasks
2. If the commit relates to a dex task, link it:
   - Root task → include `Fixes #<issue>` in the body
   - Subtask → include `Refs #<issue>` in the body
3. After committing, run `dex complete <id> --commit <sha>`

## Phase 6: Summary

After all commits, show:
```
git log --oneline -N   (where N = number of new commits)
git status --short
```

Report the final state: "Working tree clean" or list remaining unstaged files.
