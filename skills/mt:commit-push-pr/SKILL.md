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

5. **PR** — Create a pull request:
   ```bash
   gh pr create --base <base-branch> --fill
   ```
   - `--base` comes from the argument, or defaults to `main`
   - Use `--fill` to auto-generate title and body from the commit

## Rules

- You MUST execute all steps in a single message with multiple tool calls
- Do NOT send any text or explanations between tool calls
- Do NOT run any other commands besides the ones listed above
- If there are no changes to commit, tell the user and stop
