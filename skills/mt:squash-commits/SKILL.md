---
name: mt:squash-commits
description: "(Minh Tran) Consolidate a messy branch's many commits into 2-3 clean, logical commits without changing the code. Use when the user runs /mt:squash-commits [base-branch] or asks to squash, combine, tidy, or clean up the commits on a branch (e.g. after brainstorm/plan/implement or worktree work created lots of tiny WIP commits)."
argument-hint: "[base-branch]"
allowed-tools: [Bash]
model: sonnet
---

# mt:squash-commits

Rewrite the commit history of the current branch so the *same final code* is split
into a small number (ideally **2-3**, never more than the guardrail below) of clean,
logical commits. The working tree and the final diff against the base branch **must be
byte-for-byte identical** before and after — this skill only reshapes history, it never
changes code.

Use this after a workflow (brainstorm → plan → implement, or worktree merges) has
produced many tiny "WIP", "fix", "typo" commits that are noise in the PR.

**Arguments:** $ARGUMENTS — an optional base branch.

## Context

- Current branch: !`git branch --show-current`
- Base branch guess: !`git log --format='%D' HEAD | grep -oE 'origin/(main|master|develop)' | sed 's|origin/||' | head -1`
- Working tree status (must be clean to start): !`git status --porcelain`
- Commits on this branch vs base guess: !`base=$(git log --format='%D' HEAD | grep -oE 'origin/(main|master|develop)' | sed 's|origin/||' | head -1); base=${base:-main}; git log --oneline "$(git merge-base HEAD origin/$base 2>/dev/null || git merge-base HEAD $base)"..HEAD 2>/dev/null | head -50`

## Determine the base branch

1. If `$ARGUMENTS` names a branch, use it as the base.
2. Otherwise auto-detect: the first `main`/`master`/`develop` ref reachable from HEAD
   (see Context). Fall back to `main` if none is found.
3. Resolve the fork point once and reuse it everywhere:
   ```bash
   BASE=<resolved base>            # e.g. main
   FORK=$(git merge-base HEAD "origin/$BASE" 2>/dev/null || git merge-base HEAD "$BASE")
   ```
   All history from `FORK` to `HEAD` will be rewritten; everything at/below `FORK` is untouched.

## Preconditions — stop if any fail

- **Working tree must be clean.** If `git status --porcelain` is non-empty, stop and tell
  the user to commit or stash first. Never squash with uncommitted changes.
- **There must be more than one commit** in `FORK..HEAD`. If there is 0 or 1, tell the
  user there is nothing to consolidate and stop.
- **Never rewrite a core branch.** If the current branch is `main`, `master`, `develop`,
  or matches `release*`, refuse and stop.
- **No merge commits in range.** Run `git log --merges FORK..HEAD`; if any exist, stop and
  ask the user how to proceed (rewriting merges is out of scope).

## Steps

Execute in order. Do not skip the safety and verification steps.

1. **Snapshot for safety.** Record the current tip and tag it so the work can always be
   recovered:
   ```bash
   ORIGINAL=$(git rev-parse HEAD)
   git tag "squash-backup-$(date +%s)" "$ORIGINAL"
   ```
   Tell the user the backup tag name.

2. **Study the changes.** Read the full picture so commits are grouped by *intent*, not by
   file accident:
   ```bash
   git log --oneline "$FORK"..HEAD          # the messy history
   git diff --stat "$FORK"..HEAD            # files touched
   git diff "$FORK"..HEAD                   # the actual change (read it)
   ```

3. **Plan the groups.** Decide on **2-3 logical commits** (see Grouping guidance). For a
   truly small change, 1 commit is fine. More than 3 needs justification — prefer fewer.
   Briefly state the planned commits and which files/hunks go in each before executing.

4. **Reset history, keep the code.** Move the branch back to the fork point while leaving
   every change staged. This does NOT touch working-tree contents:
   ```bash
   git reset --soft "$FORK"
   ```
   After this, `git status` shows all branch changes as staged; the files on disk are
   unchanged.

5. **Re-commit in logical groups.** Unstage everything, then stage and commit each group:
   ```bash
   git reset            # unstage; files stay on disk untouched
   git add <paths for group 1> && git commit -m "<type>: <subject 1>"
   git add <paths for group 2> && git commit -m "<type>: <subject 2>"
   # ...up to 3
   ```
   - Group by whole files when possible. If one file must be split across commits, use
     `git add -p <file>` to stage specific hunks.
   - The **last** commit stages the remainder: finish with `git add -A && git commit` so no
     change is left behind.

6. **VERIFY the code is identical (mandatory).** The final tree must match the backup exactly:
   ```bash
   git diff "$ORIGINAL" HEAD --stat        # MUST print nothing
   git status --porcelain                  # MUST be empty (nothing left unstaged)
   ```
   If `git diff "$ORIGINAL" HEAD` shows ANY difference, the squash changed code — this is a
   failure. Recover immediately:
   ```bash
   git reset --hard "$ORIGINAL"
   ```
   then report the problem to the user and stop. Do not force-push a broken result.

7. **Show the result.**
   ```bash
   git log --oneline "$FORK"..HEAD
   ```

8. **Update the remote (only if the branch was already pushed).**
   ```bash
   git rev-parse --abbrev-ref --symbolic-full-name @{u}   # is there an upstream?
   ```
   If an upstream exists, the history diverged, so a force push is required — use the safe
   variant, never a plain `--force`:
   ```bash
   git push --force-with-lease
   ```
   If there is no upstream yet, do nothing (a normal push happens later). Tell the user
   whether you pushed.

## Grouping guidance

Aim for commits a reviewer can read top-to-bottom as a story:

- Separate **refactors/moves** from **behavior changes**.
- Separate **production code** from **tests/docs/config** when the split clarifies review.
- Keep a single feature's core change together rather than scattering it by file type.
- Prefer **fewer** commits when in doubt — 2 clean commits beat 3 contrived ones.

## Commit message format

Follow Conventional Commits (Claude Code's default style):

```
<type>: <imperative subject, <=72 chars>

<optional body: why, not what>
```

`type` is one of `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`.
Do not add tool advertising or co-author trailers unless the user already uses them.

## Rules

- **Never change code.** Step 6 verification is mandatory; if it fails, `git reset --hard`
  to the backup and stop.
- Always create the backup tag (step 1) before `git reset`.
- Never rewrite core branches (`main`/`master`/`develop`/`release*`).
- Only ever force-push with `--force-with-lease`, and only when an upstream already exists.
- If the working tree is dirty at the start, stop and ask the user to commit or stash.
- Keep the count at 2-3 commits unless the user explicitly asks for a different number.
