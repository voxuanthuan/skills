---
name: mt:commit-push-pr
description: "(Minh Tran) Commit, push, and open a PR in one shot. Use when the user runs /mt:commit-push-pr [base-branch] or asks to commit and create a PR."
argument-hint: "[base-branch]"
allowed-tools: [Bash]
---

# mt:commit-push-pr

Commit all changes, push to origin, and create a pull request.

**Arguments:** $ARGUMENTS

Parse the base branch from arguments. If empty, default to `main`.

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`

## Instructions

Based on the above changes, execute ALL of the following in a single message:

1. **Branch** — If currently on `main` or `master`, create a new branch with a descriptive name based on the changes. Otherwise, stay on the current branch.

2. **Stage** — Stage all changed files:
   ```bash
   git add -A
   ```

3. **Commit** — Create a single commit following the format:
   ```
   FEAT: {branch-name} <short description>
   ```
   - `{branch-name}` is the current branch name exactly as-is (e.g. `GRAP-18760`)
   - Example: `FEAT: GRAP-18760 clear note RichTextEditor after form submission`

4. **Push** — Push the branch to origin:
   ```bash
   git push -u origin HEAD
   ```

5. **Label** — Determine the PR label based on the target base branch:
   - `develop` → label `development`
   - starts with `release` (e.g. `release/1.0`, `release-1.0`) → label `uat`
   - `main` → label `production`
   - anything else → no label

6. **PR** — Create a pull request with a custom body:
   ```bash
   gh pr create --base <base-branch> --title "<commit-message>" --body "<body>" --label <label>
   ```
   - `--base` comes from the argument, or defaults to `main`
   - `--title` is the commit message (same as step 3)
   - Include `--label <label>` only if a label applies (from step 5)
   - If the label does not exist in the repo, create it first:
     ```bash
     gh label create <label> --force
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
