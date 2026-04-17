---
name: mt:commit-push-pr
description: "(Minh Tran) Commit, push, and open a PR in one shot. Use when the user runs /mt:commit-push-pr [base-branch] or asks to commit and create a PR."
argument-hint: "[base-branch]"
allowed-tools: [Bash]
---

# mt:commit-push-pr

Commit all changes, push to origin, and create a pull request.

**Arguments:** $ARGUMENTS

Parse arguments to determine intent:

- **Core branches**: `main`, `master`, `develop`, or any branch matching `release*`
- **Ticket branch**: anything else (e.g. a Jira ID like `GRAP-18760`)

**If the argument looks like a ticket branch (not a core branch):**
- The argument is the *feature branch* to checkout/use, NOT the base branch
- If currently on a core branch (`main`, `master`, `develop`, `release*`), checkout that ticket branch:
  ```bash
  git checkout <argument>
  ```
- The base branch is then auto-detected (see below) from the checked-out branch

**If the argument is a core branch or empty:**
- Use it directly as the base branch
- If empty, auto-detect by running:
  ```bash
  git log --format='%D' HEAD | grep -oE 'origin/[^ ,]+' | sed 's|origin/||' | head -1
  ```
  This finds the first remote branch ref in the commit history from HEAD. If nothing is found, fall back to `main`.

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`

## Instructions

Based on the above changes, execute ALL of the following in a single message:

1. **Checkout** — If the argument is a ticket branch and currently on a core branch, checkout the ticket branch first (as described above). Then proceed on that branch.

2. **Branch** — If still on a core branch after step 1 (no argument given, or argument was a base branch), create a new branch with a descriptive name based on the changes. Otherwise, stay on the current branch.

3. **Stage** — Stage all changed files:
   ```bash
   git add -A
   ```

4. **Commit** — Create a single commit following the format:
   ```
   FEAT: {branch-name} <short description>
   ```
   - `{branch-name}` is the current branch name exactly as-is (e.g. `GRAP-18760`)
   - Example: `FEAT: GRAP-18760 clear note RichTextEditor after form submission`

5. **Push** — Push the branch to origin:
   ```bash
   git push -u origin HEAD
   ```

6. **Label** — Only apply a label when the target base branch is `main`:
   - `main` → label `production`
   - anything else → no label

7. **PR** — Create a pull request with a custom body:
   ```bash
   gh pr create --base <base-branch> --title "<commit-message>" --body "<body>" --label production
   ```
   - `--base` comes from the argument, or the auto-detected base branch (from git log decorations), or `main` as last resort
   - `--title` is the commit message (same as step 3)
   - Only include `--label production` when the base branch is `main`
   - If the `production` label does not exist in the repo, create it first:
     ```bash
     gh label create production --force
     ```
   - Generate `--body` as a **Summary only** (no Test Plan section):
     - List what was added/changed based on the diff
     - **Exclude any mention of `schema.json` changes** — these are auto-generated from the backend and do not need to be listed
     - Do NOT include a "Test plan" section

## Rules

- You MUST execute all steps in a single message with multiple tool calls
- Do NOT send any text or explanations between tool calls
- Do NOT run any other commands besides the ones listed above
- If there are no changes to commit, tell the user and stop
