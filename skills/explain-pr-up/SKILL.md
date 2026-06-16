---
name: explain-pr-up
description: Create a standalone HTML artifact that presents a pull request for review. Shows before/after code changes, file-by-file tour with annotated diffs, risk map, review focus areas, and TL;DR. Use when the user asks to write up a PR, summarize code changes visually, create a PR review document, show before and after diffs in HTML, or prepare a change walkthrough for reviewers.
---

# Explain PR Up

## Overview

Create a self-contained HTML document that presents a pull request as a visual review artifact. The output is a single HTML file a reviewer can open in any browser to understand what changed, why, and where to focus.

Use `assets/pr-review-template.html` as a starting structure, then replace every placeholder with real data from the PR.

## Workflow

1. Gather the PR data.
   - Read the diff (`git diff`), commit messages, and any PR description.
   - Identify every changed file, the line counts (+/−), and whether each file is new, modified, or deleted.
   - Read enough surrounding context in each file to understand the change.

2. Classify each file by review risk.
   - **safe** — additive, type-only, test, config, or trivially correct.
   - **worth a look** — logic changes that are straightforward but warrant scanning.
   - **needs attention** — new core logic, tricky mutations, error handling, security-sensitive, or likely to hide bugs.

3. Write the PR narrative.
   - **TL;DR**: one paragraph summarizing what changed and why, written for someone who hasn't seen the code.
   - **Before / After**: concrete behavioral comparison — what users or the system experienced before vs. after.
   - **File-by-file tour**: ordered for reading (most important first), not alphabetically. For each file provide:
     - A short explanation of *why* this file changed (not just *what*).
     - A code snippet showing the key change, with deleted lines and added lines visually distinct.
   - **Review focus**: 2–3 numbered items pointing reviewers to the exact lines or decisions that matter most.

4. Build the HTML artifact.
   - Save to the path the user requested.
   - If no path is given, use `docs/<pr-number-or-short-name>-review.html`.
   - Keep all CSS inline. No external CDNs, no bundlers, no servers required.

5. Polish the artifact.
   - Ensure the diff rendering uses proper syntax highlighting classes (`.kw`, `.str`, `.cm`, `.fn`).
   - Mark added lines with `.add` and deleted lines with `.del` backgrounds.
   - Verify the risk map chips link to the correct file sections via anchor IDs.
   - Test that the file is readable on both desktop and mobile widths.

## Sections

Include these sections unless the PR clearly does not need one:

1. **Header** — PR number, title, branch → target, author, total +/− stats.
2. **TL;DR** — One paragraph, clay-accented left border, plain language.
3. **Before / After** — Side-by-side panels comparing old vs. new behavior.
4. **Risk map** — Colored chips (safe / worth a look / needs attention) linking to file sections.
5. **File tour** — Collapsible `<details>` cards per file, each with:
   - File path, badge (new/mod/del), +/− stats.
   - A *why* paragraph explaining the change in context.
   - A code block with syntax-highlighted diff (`.add` / `.del` lines).
6. **Review focus** — Numbered cards calling out the 2–3 most important review points.
7. **Checklist** (optional) — Interactive checkboxes for reviewer sign-off steps.

## Design Principles

- Use the Anthropic HTML-effectiveness palette: `--ivory`, `--slate`, `--clay`, `--oat`, `--olive`.
- Serif headings (`ui-serif, Georgia`), sans body (`system-ui`), mono for code and file paths.
- Restrained chrome: rounded 12px cards, 1.5px borders, minimal decoration.
- Code blocks use a dark (`--slate`) background with warm off-white text.
- Added lines get a subtle olive background; deleted lines get a subtle clay/rust background with strikethrough.
- Responsive: single-column layout below 900px.
- Keep the artifact practical — no animations, no decorative gradients.

## Code Diff Rendering

For each file's key change, render syntax-highlighted code:

```html
<div class="code"><pre>
<span class="kw">const</span> x = <span class="fn">doThing</span>();
<span class="del">  old line removed</span>
<span class="add">  new line added</span>
<span class="cm">// comment</span>
<span class="str">'string literal'</span>
</pre></div>
```

Use these classes:
- `.kw` — keywords (const, await, if, return, etc.)
- `.fn` — function names
- `.str` — string literals
- `.cm` — comments
- `.add` — added lines (olive background)
- `.del` — deleted lines (clay background, strikethrough)

## Template

The starter template is:

```text
assets/pr-review-template.html
```

Read the file, replace all `{{PLACEHOLDER}}` values with real PR data, then remove or duplicate sections as needed for the actual number of files and review points.
