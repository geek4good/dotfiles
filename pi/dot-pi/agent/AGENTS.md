# Global Pi Agent Instructions

## Forked repo workflow

When working in a forked repo (e.g. saasmail), follow the three-tier branch model:

- **`origin/main`** — exact mirror of `upstream/main`. Never commit here. Sync with `git push origin upstream/main:refs/heads/main`.
- **`origin/preview`** — live deployment branch. Merge feature branches into it for testing in our environment.
- **`origin/feat/*`** — individual features branched off `main`, one per upstream PR.

Typical flow: sync upstream → branch `feat/*` from `main` → merge into `preview` and test → iterate → open PR to upstream when confident → after merge, clean up.

Rules:
- Never commit directly to `main` or `preview`
- After rebasing `feat/*` onto `main`, run `yarn install` to regenerate lockfile before pushing
