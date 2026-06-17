---
name: explain-pr-up
description: Create a standalone HTML artifact that presents a pull request for review. Shows before/after code changes, file-by-file tour with annotated diffs, risk map, review focus areas, and a short summary. Use when the user asks to write up a PR, summarize code changes visually, create a PR review document, show before and after diffs in HTML, or prepare a change walkthrough for reviewers.
---

# Explain PR Up

## Overview

Create a self-contained HTML document that shows what a pull request changed and why. A reviewer opens the file in any browser and sees the full picture — no scrolling through terminal diffs.

Use `assets/pr-review-template.html` as a starting structure, then replace every placeholder with real data from the PR.

## Writing Style

Write the way `explain-issue-html` writes: short, plain, concrete.

1. Use short sentences. One idea per sentence.
2. Use simple words. Say "blank" not "null, empty, or whitespace-only." Say "breaks" not "introduces a regression in."
3. Define technical terms before using them. If the reader needs to know what "ABN" or "debtor sync" means, say it once in plain words first.
4. Show a concrete example before a general rule. Instead of "adapters preserve existing values field-by-field," show:
   ```
   Before: sync sends blank → name gets erased
   After:  sync sends blank → name stays "John"
   ```
5. Do not stack multiple changes into one long sentence. Break them into a list.
6. Prefer "what the user sees" over "what the code does." Say "the name disappears from the form" not "the adapter overwrites the nested contact object."
7. Avoid passive voice when you can. Say "sync erases the name" not "the name is erased by the sync."
8. Avoid jargon soup. Do not write "nested contact/address adapters preserve existing values field-by-field." Write "if the sync sends a blank name, we keep the old name."

## Workflow

1. Gather the PR data.
   - Read the diff (`git diff`), commit messages, and any PR description.
   - List every changed file, the line counts (+/−), and whether each file is new, modified, or deleted.
   - Read enough surrounding context to understand each change.

2. Classify each file by review risk.
   - **safe** — small addition, type-only, test, config, or obviously correct.
   - **worth a look** — logic change that is straightforward but worth scanning.
   - **needs attention** — new core logic, tricky edge case, error handling, or security-sensitive.

3. Write the PR story in plain language.
   - **TL;DR**: A bullet list (5–7 items). Each bullet is one short sentence that a high-school student can understand. No jargon without a one-line definition first.
   - **Flow diagram**: If the PR touches 2+ functions in a call chain, draw a horizontal block diagram. Each block = a function name. Blocks link to the file section below.
   - **Short summary**: 2–3 sentences. What changed? Why? Written so someone who has never seen this code can follow.
   - **Before / After**: what happened before this PR vs. what happens now. Use bullet points. Keep each bullet to one line.
   - **File-by-file tour**: most important file first. For each file:
     - One sentence: *why* this file changed (not just *what*).
     - A code snippet showing the key change with Claude Code–style colors (green = added, red = deleted).
   - **Review focus**: 2–3 numbered items. Point to the exact lines or decisions that matter most. Say why they matter.

4. Build the HTML artifact.
   - Save to the path the user requested.
   - If no path is given, use `docs/<pr-number-or-short-name>-review.html`.
   - Keep all CSS inline. No external CDNs, no bundlers, no servers required.

5. Review your own text before finishing.
   - Read every sentence. If it has more than one comma, split it.
   - If a bullet point wraps to a third line, it is too long. Shorten it.
   - Replace any fancy word with a simpler one.

## Sections

Include these sections unless the PR clearly does not need one:

1. **Header** — PR number, title, branch → target, author, +/− line counts.
2. **TL;DR** — Bullet list of what changed. Each bullet is one short sentence. Write so a high-school student can follow. No jargon without explaining it first. Max 5–7 bullets.
3. **Flow diagram** — A horizontal block-box diagram showing the execution flow of the code that changed. Each box is a function or module name. Boxes connect with arrows (→). Each box is clickable and scrolls to the matching file section. Only show when the PR touches 2+ functions in a call chain or data pipeline.
4. **Before / After** — Side-by-side panels. Short bullet points only.
5. **Risk map** — Colored chips (safe / worth a look / needs attention) that link to file sections.
6. **File tour** — Collapsible cards per file, each with:
   - File path, badge (new/mod/del), +/− stats.
   - One sentence explaining *why* this file changed.
   - A code block showing the diff with Claude Code–style coloring.
7. **Review focus** — Numbered cards with the 2–3 most important review points.
8. **Checklist** (optional) — Interactive checkboxes for reviewer sign-off.

## Design Principles

- Palette: `--ivory`, `--slate`, `--clay`, `--oat`, `--olive` (from Anthropic HTML effectiveness examples).
- Serif headings (`ui-serif, Georgia`), sans body (`system-ui`), mono for code and paths.
- Rounded 12px cards, 1.5px borders, minimal decoration.
- Dark code blocks (`--slate` background) with warm off-white text.
- **Code diff colors follow Claude Code style:**
  - Added lines: green background (`rgba(46,160,67,0.20)`), solid green left border (`#3fb950`). Text stays readable.
  - Deleted lines: red background (`rgba(248,81,73,0.20)`), solid red left border (`#f85149`), strikethrough text.
  - Unchanged context lines have no highlight — just the default dark background.
- Responsive: single column below 900px.
- No animations, no gradients, no decoration for decoration's sake.

## Code Diff Rendering

For each file's key change, render syntax-highlighted code using Claude Code–style diff colors:

```html
<div class="code"><pre>
<span class="kw">const</span> x = <span class="fn">doThing</span>();
<span class="del">- old line removed</span>
<span class="add">+ new line added</span>
<span class="cm">// comment</span>
<span class="str">'string literal'</span>
</pre></div>
```

Classes:
- `.kw` — keywords (const, await, if, return)
- `.fn` — function names
- `.str` — string literals
- `.cm` — comments
- `.add` — added lines (green background, green left border — Claude Code green)
- `.del` — deleted lines (red background, red left border, strikethrough — Claude Code red)

## Flow Diagram

When the PR changes touch functions in a call chain or data pipeline, include a flow diagram above the file tour. Build it with CSS flexbox boxes and arrow connectors. Each box:
- Shows the function or module name.
- Is wrapped in an `<a href="#file-N">` so clicking navigates to that file's section.
- Uses the same card styling (rounded, bordered) as the rest of the page.

```html
<div class="flow">
  <a href="#file-1" class="flow-box">functionX</a>
  <span class="flow-arrow">→</span>
  <a href="#file-2" class="flow-box">functionY</a>
  <span class="flow-arrow">→</span>
  <a href="#file-3" class="flow-box">functionZ</a>
</div>
```

Omit this section if the PR is a single-file config change or has no meaningful call flow.

## Template

The starter template is:

```text
assets/pr-review-template.html
```

Read the file, replace all `{{PLACEHOLDER}}` values with real PR data, then add or remove sections to match the actual number of files and review points. Do not leave any placeholder text in the final artifact.
