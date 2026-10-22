---
description: "Review a GOV.UK (alphagov) PR read-only and give a verdict"
argument-hint: "<repo> <pr-number>  (org defaults to alphagov)"
---

Review **https://github.com/alphagov/$1/pull/$2** and give me your verdict.

Sanity-check before starting: the repo should be `$1` and the PR number `$2`. If either is missing, the assembled URL is malformed (doubled org, trailing slash, etc.), or `$1` is actually a full URL or an `owner/repo` pair, stop and ask me for the correct details rather than guessing or searching GitHub.

## Gather (read-only)

Use the `gh` CLI in read-only mode — `gh pr view <url> --json ...`, `gh pr diff <url>`, and `gh api` for review threads — or fetch the PR page if the CLI fails. Collect:

1. Title, description, and linked issues
2. The full diff
3. All review comments and discussion threads
4. Commits pushed in response to review feedback — did they actually address the concerns raised?
5. CI / status checks

## Assess

- **Correctness** — bugs, edge cases, migration and data risks
- **Design** — is the approach sound, or is there a simpler / more standard one?
- **Security** — auth, data exposure, injection, secret handling
- **Tests** — are the changes adequately covered?
- **Consistency** — does it follow the codebase's existing patterns?
- **Discussion state** — are open review concerns genuinely resolved, or waved away?

## Reply format

Reply to me here, and only here, with:

- **Summary** — 2–3 sentences on what the PR does
- **Strengths** — brief
- **Concerns** — ordered by severity, with file/line references
- **Verdict** — one of `Approve` / `Approve with comments` / `Request changes` / `Needs discussion`, plus a one-paragraph justification

## Hard constraints

Strictly read-only: no comments, reviews, reactions, labels, closes, rebases, pushes, or any other change on GitHub. Findings go to me in this session only.
